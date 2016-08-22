import "../asm/assembly.dart";

/// Capable of generating Assembly code from an AST.
class AssemblyCodegen {
  int _tabs = 0;
  String _result = "";
  /// Returns a string of Assembly code corresponding to an AST.
  String generate(Assembly assembly) => _result;

  void add(x) {
    _result += x;
  }

  void addLn(x) {
    add("$x\n");
  }

  void comment(String text) {
    writeln("; $text");
  }

  void enter() {
    _tabs++;
  }

  void exit() {
    _tabs--;
  }

  void write(x) {
    for (var i = 0; i < _tabs; i++) {
      add("    ");
    }

    add(x);
  }

  void writeln(x) => write("$x\n");
}