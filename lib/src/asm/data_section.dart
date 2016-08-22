import "section.dart";
import "initialized_data_declaration.dart";

/// Represents initialized data in an Assembly file.
class DataSection extends Section {
  DataSection():super("data");

  List<InitializedDataDeclaration> declarations = [];
}