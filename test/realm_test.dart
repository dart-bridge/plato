library realm_test;
import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:realm/realm.dart' as realm;
import 'dart:mirrors';

class RealmTest implements TestCase {
  setUp() {
  }

  tearDown() {
  }

  @test
  it_can_list_all_public_declarations() async {
    var all = realm.declarations();
    expect(all, contains(classMirror));
    expect(all, contains(methodMirror));
  }

  @test
  it_can_get_a_mirror_from_symbol() async {
    expect(realm.declaration(#Class), equals(classMirror));
  }

  @test
  it_returns_null_when_cannot_find_mirror() async {
    expect(realm.declaration(#doesnt.exist), isNull);
  }

  @test
  it_can_find_mirror_by_qualified_name() async {
    expect(realm.declaration(#realm.Realm), equals(reflectType(realm.Realm)));
  }

  @test
  it_can_list_all_public_class_declarations() async {
    expect(realm.classes(), contains(classMirror));
  }

  @test
  it_can_find_class_mirror_by_symbol() async {
    expect(realm.classMirror(#Class), equals(classMirror));
    expect(realm.classMirror(#realm.Realm), equals(reflectType(realm.Realm)));
  }

  @test
  it_can_list_all_public_method_declarations() async {
    expect(realm.methods(), contains(methodMirror));
  }

  @test
  it_can_find_method_mirror_by_symbol() async {
    expect(realm.method(#function), equals(methodMirror));
  }

  @test
  it_can_list_all_public_variable_declarations() async {
    expect(realm.variables(), contains(variableMirror));
  }

  @test
  it_can_find_variable_mirror_by_symbol() async {
    expect(realm.variable(#variable), equals(variableMirror));
  }

  @test
  it_has_shortcuts_for_casting_instance_mirrors() async {
    expect(realm.instance(#variable), new isInstanceOf<InstanceMirror>());
    expect(realm.closure(#function), new isInstanceOf<ClosureMirror>());
    expect(realm.type(#Class), new isInstanceOf<TypeMirror>());
  }

  @test
  it_can_return_the_annotations_of_a_declaration() async {
    expect(realm.annotations(#function), contains(metadata));
    expect(realm.annotations(#function).last.val, equals('value'));
  }

  @test
  it_can_instantiate_a_class() async {
    expect(realm.instantiate(realm.classMirror(#Class), ['value']).val, equals('value'));
  }

  @test
  it_can_apply_a_function() async {
    expect(realm.apply(#function, ['val'], {#named:'ue'}), equals('value'));
  }

  @test
  it_can_trace_a_string_expression() async {
    expect(realm.trace('realm_test.Class.stat'), equals(Class.stat));
    expect(realm.trace('function'), equals(function));
    expect(realm.trace('Class'), equals(Class));
    expect(realm.trace('realm_test.globalRef.val'), equals('value'));
  }

  MethodMirror get methodMirror => (reflect(function) as ClosureMirror).function;
  ClassMirror get classMirror => reflectType(Class);
  VariableMirror get variableMirror => currentMirrorSystem()
    .findLibrary(#realm_test).declarations[#variable];
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


