import "../codegen/codegen.dart";
import "statement.dart";

class Indentation extends Statement {
  @override
  void generate(AssemblyCodegen codegen) {
    codegen.enter();
  }
}

class Outdentation extends Statement {
  @override
  void generate(AssemblyCodegen codegen) {
    codegen.exit();
  }
}