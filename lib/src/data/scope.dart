import "datum.dart";
import "symbol.dart";

class DartScope {
  List<DartScope> _children = [];
  List<DartSymbol> _symbols = [];
  var compiler;
  Map<String, int> prefixes = {};

  List<DartSymbol> get symbols => _symbols;

  List<DartScope> get children => _children;

  DartScope get currentScope => children.isNotEmpty ? children.last : this;

  DartScope(this.compiler);

  DartSymbol createConstant(DartDatum value, String prefix, source) {
    return new DartSymbol(compiler, "$prefix${_incrementConstant(prefix)}");
  }

  DartSymbol createSymbol(String id) {
    var result = new DartSymbol(compiler, id);
    currentScope.symbols.add(result);
    return result;
  }

  _incrementConstant(String prefix) {
    if (prefixes.containsKey(prefix)) {
      return ++prefixes[prefix];
    } else {
      return prefixes[prefix] = 0;
    }
  }

  /**
   * Adds a new layer to the rootScope.
   */
  void enter() {
    children.add(new DartScope(compiler));
  }

  /**
   * Removes a layer from the rootScope.
   */
  void exit() {
    if (!children.isEmpty) {
      children.removeLast();
    }
  }

  void dump() {
    for (DartSymbol symbol in allSymbols) {
      print("${symbol.id} => ${symbol.value.runtimeType}");
    }
  }

  DartDatum find(String id, source, {bool throwIfAbsent: true}) {
    var symbol = findSymbol(id);

    if (symbol != null)
      return symbol.value;
    else {
      if (throwIfAbsent)
        compiler.error(
            "The symbol '" + id + "' is undefined in this context.", source);
      return null;
    }
  }

  DartSymbol findSymbol(String id) {
    for (DartScope scope in children.reversed) {
      var found = scope.findSymbol(id);

      if (found != null)
        return found;
    }

    for (DartSymbol symbol in symbols) {
      if (symbol.id == id)
        return symbol;
    }

    return null;
  }

  DartSymbol put(String id, DartDatum value, source, {bool isConstant: false}) {
    var target = findSymbol(id) ?? createSymbol(id);
    target.value = value;

    if (isConstant)
      target.makeConst();
    return target;
  }

  List<DartSymbol> get allSymbols {
    var result = []..addAll(symbols);

    for (DartScope childScope in children) {
      result.addAll(childScope.allSymbols);
    }

    return result;
  }

  operator [](String key) => find(key, null, throwIfAbsent: false);

  operator []= (String key, val) {
    if (val is DartDatum)
      put(key, val, null);
    else if (val is DartSymbol) {
      var target = findSymbol(key);

      if (target == null || !target.constant) {
        children.last.symbols.add(val);
      } else throw new UnsupportedError("Cannot overwrite constant '$key'.");
    } else throw new ArgumentError("Scopes can only insert data or symbols.");
  }
}