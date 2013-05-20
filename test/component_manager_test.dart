part of siege_engine_test;

void component_manager_test() {
  group("Component manager:", () {
    MockComponent component;
    MockComponent2 component2;
    ComponentManager cm;
    World world;
    setUp(() {
      world = new World();
      // these because can't add or get anything to
      // entities that are not in world.
      world.createEntity(1);
      world.createEntity(2);
      cm = new ComponentManager(world);
      component = new MockComponent();
      component2 = new MockComponent2();
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
    test("can get an added component.", () {
      cm.addComponentToEntity(2, component);
      expect(cm.getComponentFromEntity(2, component.runtimeType), equals(component));
    });
    test("can get null if requesting non-existing component.", () {
      expect(cm.getComponentFromEntity(2, component.runtimeType), isNull);
    });
    test("can remove all components from entity.", () {
      cm.addComponentToEntity(1, component);
      cm.addComponentToEntity(1, component2);
      cm.removeAllComponentsFromEntity(1, withEvent:false);
      expect(cm.entityHasComponent(1, MockComponent), isFalse);
      expect(cm.entityHasComponent(1, MockComponent2), isFalse);
    });
    test("can get a list of components from entity.", () {
      cm.addComponentToEntity(1, component);
      cm.addComponentToEntity(1, component2);
      List<Component> addedComponents = new List<Component>();
      addedComponents.add(component);
      addedComponents.add(component2);
      List<Component> components = cm.getAllComponentsFromEntity(1);
      expect(components, unorderedEquals(addedComponents));
    });
    test("can't add anything to entity that is not in the world.", () {
      cm.addComponentToEntity(3, component);
      cm.addComponentToEntity(3, component2);
      expect(cm.entityHasComponent(3, MockComponent), isFalse);
      expect(cm.entityHasComponent(3, MockComponent2), isFalse);
    });
  });
}