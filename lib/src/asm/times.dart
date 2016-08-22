import "../codegen/codegen.dart";
import "statement.dart";

class Times extends Statement {
  int times;
  var expression;

  Times(this.times, this.expression);

  @override
  void generate(AssemblyCodegen codegen) {
    printComments(codegen);
    codegen.writeln("times $times-(\$-\$\$) $expression");
  }
}