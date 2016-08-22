import "section.dart";
import "statement.dart";

/// Represents an x86 Assembly program.
class Assembly {
  List<String> comments = ["Generated via dart2asm"];
  List<String> constants = [];
  List<Statement> statements = [];
}