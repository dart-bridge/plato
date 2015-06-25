library plato_test;
import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:plato/plato.dart' as plato;
import 'dart:mirrors';

class PlatoTest implements TestCase {
  setUp() {
  }

  tearDown() {
  }

  @test
  it_can_list_all_public_declarations() async {
    var all = plato.declarations();
    expect(all, contains(classMirror));
    expect(all, contains(methodMirror));
  }

  @test
  it_can_get_a_mirror_from_symbol() async {
    expect(plato.declaration(#Class), equals(classMirror));
  }

  @test
  it_returns_null_when_cannot_find_mirror() async {
    expect(plato.declaration(#doesnt.exist), isNull);
  }

  @test
  it_can_find_mirror_by_qualified_name() async {
    expect(plato.declaration(#plato.MirrorPlane), equals(reflectType(plato.MirrorPlane)));
  }

  @test
  it_can_list_all_public_class_declarations() async {
    expect(plato.classes(), contains(classMirror));
  }

  @test
  it_can_find_class_mirror_by_symbol() async {
    expect(plato.classMirror(#Class), equals(classMirror));
    expect(plato.classMirror(#plato.MirrorPlane), equals(reflectType(plato.MirrorPlane)));
  }

  @test
  it_can_list_all_public_method_declarations() async {
    expect(plato.methods(), contains(methodMirror));
  }

  @test
  it_can_find_method_mirror_by_symbol() async {
    expect(plato.method(#function), equals(methodMirror));
  }

  @test
  it_can_list_all_public_variable_declarations() async {
    expect(plato.variables(), contains(variableMirror));
  }

  @test
  it_can_find_variable_mirror_by_symbol() async {
    expect(plato.variable(#variable), equals(variableMirror));
  }

  @test
  it_has_shortcuts_for_casting_instance_mirrors() async {
    expect(plato.instance(#variable), new isInstanceOf<InstanceMirror>());
    expect(plato.closure(#function), new isInstanceOf<ClosureMirror>());
    expect(plato.type(#Class), new isInstanceOf<TypeMirror>());
  }

  @test
  it_can_return_the_annotations_of_a_declaration() async {
    expect(plato.annotations(#function), contains(metadata));
    expect(plato.annotations(#function).last.val, equals('value'));
  }

  @test
  it_can_instantiate_a_class() async {
    expect(plato.instantiate(plato.classMirror(#Class), ['value']).val, equals('value'));
  }

  @test
  it_can_apply_a_function() async {
    expect(plato.apply(#function, ['val'], {#named:'ue'}), equals('value'));
  }

  MethodMirror get methodMirror => (reflect(function) as ClosureMirror).function;
  ClassMirror get classMirror => reflectType(Class);
  VariableMirror get variableMirror => currentMirrorSystem()
    .findLibrary(#plato_test).declarations[#variable];
}

var globalRef = new Class('value');
var variable = '';
const metadata = 'meta';

@metadata
@Class('value')
function(String arg1, {String named}) {
  return '$arg1$named';
}

class Class {
  final String val;
  const Class(String this.val);
  static stat() {
    return 'resp';
  }
}


