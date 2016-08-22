import "../codegen/codegen.dart";

class Statement {
  List<String> comments = [];

  void generate(AssemblyCodegen codegen) {
    printComments(codegen);
  }

  void generateUnix(AssemblyCodegen codegen) {
    generate(codegen);
  }

  void generateMac(AssemblyCodegen codegen) {
    generateUnix(codegen);
  }

  void generateWindows(AssemblyCodegen codegen) {
    generateUnix(codegen);
  }

  void printComments(AssemblyCodegen codegen) {
    comments.forEach(codegen.comment);
  }
}
