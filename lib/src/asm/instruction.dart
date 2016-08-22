import "../codegen/codegen.dart";
import "statement.dart";

class Instruction extends Statement {
  String name;
  List operands = [];

  Instruction(this.name, { List operands: const [] }) {
    this.operands.addAll(operands);
  }

  @override
  void generate(AssemblyCodegen codegen) {
    printComments(codegen);
    String line = "$name " + operands.map((x) => x.toString()).join(", ");
    codegen.writeln(line.trim());
  }
}