import "datum.dart";

class DartSymbol {
  bool _constant = false;
  var compiler;
  String _id;
  DartDatum _value;

  bool get constant => _constant;

  String get id => _id;
  set id(String value) {
    _id = value;
  }

  DartDatum get value => _value;

  set value(DartDatum value) {
    if (constant) {
      // Todo: Throw on re-assigning constants
    } else {
      _value = value;
      value.onAssigned(this);
    }
  }

  DartSymbol(this.compiler, this._id, {bool constant:false}) {
    _constant = constant;
  }

  void makeConst() {
    _constant = true;
  }
}