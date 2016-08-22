import "../asm/all_imports.dart";
import "codegen.dart";

/// Generates NASM Assembly code.
class NasmAssemblyCodegen extends AssemblyCodegen {
  @override
  String generate(Assembly assembly) {
    assembly.comments.forEach(comment);

    for (Statement statement in assembly.statements) {
      statement.generate(this);
    }

    assembly.constants.forEach(writeln);

    return super.generate(assembly);
  }

  String generateComment(String comment) => "; $comment\n";
}