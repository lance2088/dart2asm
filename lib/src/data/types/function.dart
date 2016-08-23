import 'package:analyzer/dart/ast/ast.dart';
import "../datum.dart";

class Function extends DartDatum {
  String name;
  FunctionExpression expression;
  Function(this.expression, this.name, compiler, source):super(compiler, source);

  @override
  String get asmValue => name ?? super.asmValue;
}