import "../codegen/codegen.dart";
import "statement.dart";

class Label extends Statement {
  String name;
  List<Statement> statements = [];

  Label(this.name, {List<Statement> statements: const []}) {
    this.statements.addAll(statements);
  }

  @override
  void generate(AssemblyCodegen codegen) {
    printComments(codegen);
    codegen.writeln("$name:");
    codegen.enter();

    for (Statement statement in statements) {
      statement.generate(codegen);
    }

    codegen.exit();
  }
}