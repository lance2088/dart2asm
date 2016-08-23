import "../datum.dart";

class Integer extends DartDatum {
  int intVal;

  Integer(this.intVal, compiler, source):super(compiler, source);

  @override
  String get asmValue => intVal.toString();

  @override
  String get asmType => "dd";
}