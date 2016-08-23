import "symbol.dart";

class DartDatum {
  var compiler;
  var source;
  String _asmType;

  String get asmType => _asmType;
  set asmType(String val) {
    _asmType = val;
  }

  DartDatum get value => this;
  String get asmValue {
    compiler.warn("null value", source != null ? source : compiler.ast);
    return "0";
  }

  DartDatum(this.compiler, this.source);

  void declareConst(String id) {}

  invoke(args, source, String variableName) {
    if (this.source != null)
      compiler.error("Expression '${this.source}' is not a function.", args);
    else
      compiler.error("Expression [$runtimeType] is not a function.", args);
    return null;
  }

  void onAssigned(DartSymbol symbol) {}

  bool isProxyFor(type) => false;

  @override
  String toString() => asmValue;
}
