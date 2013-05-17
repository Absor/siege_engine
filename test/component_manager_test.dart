part of siege_engine_test;

void component_manager_test() {
  group("Component manager:", () {
    MockComponent component;
    ComponentManager cm;
    setUp(() {
      cm = new ComponentManager();
      component = new MockComponent();
    });
    test("check if an entity has a type of component.", () {
      expect(cm.entityHasComponent(1, component.runtimeType), isFalse);
      cm.addComponentToEntity(1, component);
      expect(cm.entityHasComponent(1, component.runtimeType), isTrue);
    });
    test("can remove a component from entity.", () {
      cm.addComponentToEntity(1, component);
      cm.removeComponentFromEntity(1, component.runtimeType);
      expect(cm.entityHasComponent(1, component.runtimeType), isFalse);
    });
    test("removing non-existing component does nothing.", () {
      expect(() => cm.removeComponentFromEntity(1, component.runtimeType), returnsNormally);
    });
    test("can get a set of changes.", () {
      cm.addComponentToEntity(123, component);
      cm.removeComponentFromEntity(2, component.runtimeType);
      expect(cm.changedEntities.length, equals(1));
      expect(cm.changedEntities.first, equals(123));
    });
    test("can clear changes.", () {
      cm.addComponentToEntity(123, component);
      cm.addComponentToEntity(2, component);
      expect(cm.changedEntities.length, equals(2));
      cm.changedEntities.clear();
      expect(cm.changedEntities.length, equals(0));
    });
    test("can get an added component.", () {
      cm.addComponentToEntity(123, component);
      expect(cm.getComponentFromEntity(123, component.runtimeType), equals(component));
    });
    test("can get null if requesting non-existing component.", () {
      expect(cm.getComponentFromEntity(123, component.runtimeType), isNull);
    });
  });
}