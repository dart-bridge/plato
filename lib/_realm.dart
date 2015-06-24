part of realm;

Realm get currentRealm => new Realm(currentMirrorSystem());

Iterable<DeclarationMirror> declarations() => currentRealm
.declarations();

DeclarationMirror declaration(Symbol symbol) => currentRealm
.declaration(symbol);

Iterable<ClassMirror> classes() => currentRealm
.classes();

ClassMirror classMirror(Symbol symbol) => currentRealm
.classMirror(symbol);

Iterable<MethodMirror> methods() => currentRealm
.methods();

MethodMirror method(Symbol global, [Symbol method]) => currentRealm
.method(global, method);

Iterable<VariableMirror> variables() => currentRealm
.variables();

VariableMirror variable(Symbol symbol) => currentRealm
.variable(symbol);

InstanceMirror instance(Symbol symbol) => currentRealm
.instance(symbol);

ClosureMirror closure(Symbol symbol) => currentRealm
.closure(symbol);

TypeMirror type(Symbol symbol) => currentRealm
.type(symbol);

Iterable annotations(Symbol symbol) => currentRealm
.annotations(symbol);

instantiate(ClassMirror classMirror,
            [List positionalArguments = const [],
            Map<Symbol, dynamic> namedArguments = const {},
            Symbol constructor = const Symbol('')]) => currentRealm
.instantiate(classMirror, positionalArguments, namedArguments, constructor);

apply(Symbol function,
      [List positionalArguments = const [],
      Map<Symbol, dynamic> namedArguments = const {}]) => currentRealm
.apply(function, positionalArguments, namedArguments);

trace(String path) => currentRealm
.trace(path);

abstract class Realm {
  factory Realm(MirrorSystem system) => new _Realm(system);

  Iterable<DeclarationMirror> declarations();

  DeclarationMirror declaration(Symbol symbol);

  Iterable<ClassMirror> classes();

  ClassMirror classMirror(Symbol symbol);

  Iterable<MethodMirror> methods();

  MethodMirror method(Symbol global, [Symbol method]);

  Iterable<VariableMirror> variables();

  VariableMirror variable(Symbol symbol);

  InstanceMirror instance(Symbol symbol);

  ClosureMirror closure(Symbol symbol);

  TypeMirror type(Symbol symbol);

  Iterable annotations(Symbol declarationSymbol);

  instantiate(ClassMirror classMirror,
              [List positionalArguments,
              Map<Symbol, dynamic> namedArguments,
              Symbol constructor]);

  apply(Symbol function,
        [List positionalArguments,
        Map<Symbol, dynamic> namedArguments]);

  trace(String path);
}

class _Realm implements Realm {
  MirrorSystem _system;

  _Realm(MirrorSystem this._system);

  Iterable<DeclarationMirror> declarations() {
    return _system.libraries.values
    .expand((l) => l.declarations.values)
    .where((DeclarationMirror d) => !d.isPrivate);
  }

  DeclarationMirror declaration(Symbol symbol) {
    return _find(declarations(), symbol);
  }

  Iterable<ClassMirror> classes() {
    return declarations().where((d) => d is ClassMirror);
  }

  ClassMirror classMirror(Symbol symbol) {
    return _find(classes(), symbol);
  }

  MethodMirror method(Symbol global, [Symbol method]) {
    var globalMirror = _find(methods(), global);
    if (method != null)
      return (globalMirror as ClassMirror).declarations[method];
    return globalMirror;
  }

  Iterable<MethodMirror> methods() {
    return declarations().where((d) => d is MethodMirror);
  }

  Iterable<VariableMirror> variables() {
    return declarations().where((d) => d is VariableMirror);
  }

  VariableMirror variable(Symbol symbol) {
    return _find(variables(), symbol);
  }

  DeclarationMirror _find(Iterable<DeclarationMirror> declarations,
                          Symbol symbol) {
    return declarations.lastWhere(
            (d) => d.simpleName == symbol || d.qualifiedName == symbol,
        orElse: () => null);
  }

  InstanceMirror instance(Symbol symbol) {
    var asString = MirrorSystem.getName(symbol);
    if (!asString.contains('.'))
      return _instance(_system.libraries.values
      .lastWhere((l) => l.declarations.containsKey(symbol),
      orElse: () => null), symbol);
    var stringSplit = asString.split('.');
    return _instance(_system.findLibrary(
        new Symbol(stringSplit.removeAt(0))),
    new Symbol(stringSplit.join('.')));
  }

  InstanceMirror _instance(LibraryMirror library, Symbol symbol) {
      print(library);
      print(symbol);
    try {
      return library.getField(symbol);
    } catch (e) {
      var d = library.declarations[symbol];
      if (d is ClassMirror) return reflect(d.reflectedType);
      return reflect(library.declarations[symbol].runtimeType);
    }
  }

  ClosureMirror closure(Symbol symbol) {
    return instance(symbol);
  }

  TypeMirror type(Symbol symbol) {
    return instance(symbol).type;
  }

  Iterable annotations(Symbol declarationSymbol) {
    var m = declaration(declarationSymbol).metadata;
    return m.map((i) => i.reflectee);
  }

  instantiate(ClassMirror classMirror,
              [List positionalArguments = const [],
              Map<Symbol, dynamic> namedArguments = const {},
              Symbol constructor = const Symbol('')]) {
    return classMirror
    .newInstance(constructor, positionalArguments, namedArguments).reflectee;
  }

  apply(Symbol function,
        [List positionalArguments = const [],
        Map<Symbol, dynamic> namedArguments]) {
    return closure(function).apply(positionalArguments, namedArguments).reflectee;
  }

  trace(String path) {
    var segments = path.split('.');

    if (segments.length == 1) return _trace(path);

    var explicitLibrary = _system.findLibrary(new Symbol(segments[0]));
    if (explicitLibrary != null
    && explicitLibrary.declarations.containsKey(new Symbol(segments[1]))) {
      return _trace('${segments.removeAt(0)}.${segments.removeAt(1)}', segments);
    }
  }

  _trace(String startingDeclaration, [List<String> segments]) {
    var pointer = instance(new Symbol(startingDeclaration));
    for (var segment in segments) {
      pointer = pointer.getField(new Symbol(segment));
    }
    return pointer.reflectee;
  }
}
