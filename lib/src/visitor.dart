import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/src/dart/scanner/reader.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/error.dart';
import 'package:analyzer/src/generated/parser.dart';
import "package:dart2asm/src/asm/all_imports.dart" as asm;
import "package:dart2asm/src/codegen/all_imports.dart";

class Dart2AsmVisitor extends GeneralizingAstVisitor {
  asm.Assembly assembly = new asm.Assembly();

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
          visitStatement(statement);
        }
      }
    }
  }

  @override
  visitExpression(Expression node, [asm.Label label]) {
    if (node is IntegerLiteral) {
      return node.value;
    } else if (node is MethodInvocation) {
      return invokeMethod(node, label);
    } else if (node != null)
      return "<Expression of type:${node.runtimeType}:${node.toSource()}>";
    else
      return "<Null Expression>";
  }


  @override
  visitStatement(Statement node) {
    if (node is ExpressionStatement) {
      return visitExpression(node.expression);
    }

    assembly.comments.add("Unrecognized ${node.runtimeType}:${node.toSource()}");
  }

  @override
  invokeMethod(MethodInvocation node, [asm.Label label]) {
    var adder = label != null ? label.statements.add : assembly.statements.add;

    for (Expression expression in node.argumentList.arguments) {
      adder(new asm.Instruction("push", operands: [visitExpression(expression), label]));
    }

    if (node.methodName != null) {
      adder(new asm.Instruction("call", operands: [node.methodName.name]));
      return "ax";
    }

    var target = visitExpression(node.realTarget);
    adder(new asm.Instruction("call", operands: [target]));
  }
}
