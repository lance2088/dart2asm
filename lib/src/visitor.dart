import "dart:io";
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/src/dart/scanner/reader.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/error.dart';
import 'package:analyzer/src/generated/parser.dart';
import "asm/all_imports.dart" as asm;
import "codegen/all_imports.dart";
import "data/datum.dart";
import "data/scope.dart";
import "data/symbol.dart";
import "data/types/all_imports.dart" as types;

class Dart2AsmVisitor extends GeneralizingAstVisitor {
  String _defsAs = "";
  List errors = [];
  List warnings = [];
  List<String> magicFunctions = ["raw", "jmp"];
  asm.Assembly assembly = new asm.Assembly();
  DartScope scope;

  Dart2AsmVisitor() {
    scope = new DartScope(this);
  }

  @override
  visitCompilationUnit(CompilationUnit node) {
    for (ImportDirective importDirective
        in node.directives.where((d) => d is ImportDirective)) {
      String uri = importDirective.uri.toString();
      if (uri.startsWith("dart:")) {
        // Todo: System polyfills
      } else {
        var target = importDirective.uri.stringValue;

        if (target == "package:dart2asm/def.dart") {
          if (importDirective.asKeyword != null) {
            _defsAs = importDirective.prefix.name;
          }
        } else {
          // Todo: support cross-platform?
          var file = new File(uri);
          var src = file.readAsStringSync();
          var errorListener = new _ErrorCollector(this);
          var reader = new CharSequenceReader(src);
          var scanner = new Scanner(null, reader, errorListener);
          var token = scanner.tokenize();
          var parser = new Parser(null, errorListener);
          var unit = parser.parseCompilationUnit(token);
          unit.accept(this);
        }
      }
    }

    return super.visitCompilationUnit(node);
  }

  @override
  visitCompilationUnitMember(CompilationUnitMember node) {
    if (node is FunctionDeclaration) {
      return visitFunctionDeclaration(node);
    } else
      print("wtf: ${node.toSource()} is a ${node.runtimeType}");
  }

  @override
  visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.externalKeyword == null) {
      // Todo: Do something about 'external'
      scope.put(node.name.name,
          new types.Function(node.functionExpression, node.name.name, this, node), node,
          isConstant: true);
      var label = new asm.Label(node.name.name);
      assembly.statements.add(label);

      var body = node.functionExpression.body;

      if (body is ExpressionFunctionBody) {
        var retVal = visitExpression(body.expression, label);
        if (retVal != "ax")
          label.statements
              .add(new asm.Instruction("mov", operands: ["ax", retVal]));
        label.statements.add(new asm.Instruction("ret"));
      } else if (body is BlockFunctionBody) {
        for (Statement statement in body.block.statements) {
          _visitStatement(statement, label);
        }
      }
    }
  }

  @override
  visitExpression(Expression node, [asm.Label label]) {
    var value = _visitExpression(node, label);
    return value == null ? 0 : value;
  }

  _visitExpression(Expression node, [asm.Label label]) {
    // Lookup simple ID
    if (node is SimpleIdentifier) {
      if (node.name == _defsAs) {
        return null;
      }

      var resolved = scope.find(node.name, node);

      return resolved != null
          ? resolved
          : error("Undefined symbol '${node.name}'", node);
    }

    if (node is IntegerLiteral) {
      return new types.Integer(node.value, this, node);
    } else if (node is MethodInvocation) {
      return invokeMethod(node, label);
    } else if (node != null)
      return "<Expression of type:${node.runtimeType}:${node.toSource()}>";
    else
      return "<Null Expression>";
  }

  _visitStatement(Statement node, [asm.Label label]) {
    if (node is ExpressionStatement) {
      return visitExpression(node.expression, label);
    }

    assembly.comments
        .add("Unrecognized ${node.runtimeType}:${node.toSource()}");
  }

  invokeMethod(MethodInvocation node, [asm.Label label]) {
    var adder = label != null ? label.statements.add : assembly.statements.add;

    if (node.methodName != null &&
        magicFunctions.contains(node.methodName.toString())) {

      if (node.methodName.toString() == "raw") {
        StringLiteral text = node.argumentList.arguments[0];
        adder(new asm.RawStatement(text.stringValue));

        if (node.argumentList.arguments.length > 1) {
          StringLiteral as = node.argumentList.arguments[1];
          return as.stringValue;
        } else return "ax";
      }

      if (node.methodName.toString() == "jmp") {
        var arg = visitExpression(node.argumentList.arguments[0], label);
        if (arg != null && arg is types.Function) {
          adder(new asm.Instruction("jmp",
              operands: [arg.toString()]));
          return "ax";
        } else
          return error(
              "'${node.argumentList.arguments[0]}' must be a function to be called (it is a(n) ${arg.runtimeType})...", node);
      }
    }

    for (Expression expression in node.argumentList.arguments) {
      adder(new asm.Instruction("push",
          operands: [visitExpression(expression), label]));
    }

    if (node.methodName != null) {
      adder(new asm.Instruction("call", operands: [node.methodName.name]));
      return "ax";
    }

    var target = visitExpression(node.realTarget);
    adder(new asm.Instruction("call", operands: [target]));
  }

  error(String msg, source) {
    errors.add({
      "message": msg,
      "source": source
    });
  }

  warn(String msg, source) {
    warnings.add({
      "message": msg,
      "source": source
    });
  }
}

class _ErrorCollector extends AnalysisErrorListener {
  List<String> errors = [];
  Dart2AsmVisitor visitor;

  _ErrorCollector(this.visitor);

  @override
  onError(error) => visitor.error(error.toString(), null);
}
