part of plato;

MirrorPlane get currentMirrorPlane => new MirrorPlane(currentMirrorSystem());

Iterable<DeclarationMirror> declarations() => currentMirrorPlane
.declarations();

DeclarationMirror declaration(Symbol symbol) => currentMirrorPlane
.declaration(symbol);

Iterable<ClassMirror> classes() => currentMirrorPlane
.classes();

ClassMirror classMirror(Symbol symbol) => currentMirrorPlane
.classMirror(symbol);

Iterable<MethodMirror> methods() => currentMirrorPlane
.methods();

MethodMirror method(Symbol global, [Symbol method]) => currentMirrorPlane
.method(global, method);

Iterable<VariableMirror> variables() => currentMirrorPlane
.variables();

VariableMirror variable(Symbol symbol) => currentMirrorPlane
.variable(symbol);

InstanceMirror instance(Symbol symbol) => currentMirrorPlane
.instance(symbol);

ClosureMirror closure(Symbol symbol) => currentMirrorPlane
.closure(symbol);

TypeMirror type(Symbol symbol) => currentMirrorPlane
.type(symbol);

Iterable annotations(Symbol symbol) => currentMirrorPlane
.annotations(symbol);

instantiate(ClassMirror classMirror,
            [List positionalArguments = const [],
            Map<Symbol, dynamic> namedArguments = const {},
            Symbol constructor = const Symbol('')]) => currentMirrorPlane
.instantiate(classMirror, positionalArguments, namedArguments, constructor);

apply(Symbol function,
      [List positionalArguments = const [],
      Map<Symbol, dynamic> namedArguments = const {}]) => currentMirrorPlane
.apply(function, positionalArguments, namedArguments);

abstract class MirrorPlane {
  factory MirrorPlane(MirrorSystem system) => new _MirrorPlane(system);

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
}

class _MirrorPlane implements MirrorPlane {
  MirrorSystem _system;

  _MirrorPlane(MirrorSystem this._system);

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
}
