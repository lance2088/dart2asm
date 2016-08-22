import "../codegen/codegen.dart";
import "statement.dart";

class EmptyStatement extends Statement {
  @override
  void generate(AssemblyCodegen codegen) {
    codegen.add("\n");
  }
}