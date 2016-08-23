import "../codegen/codegen.dart";
import "statement.dart";

class RawStatement extends Statement {
  String text;
  RawStatement(this.text);

  @override
  void generate(AssemblyCodegen codegen) {
    codegen.writeln(text);
  }
}