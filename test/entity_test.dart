part of siege_engine_test;

void entity_test() {
  group("Entity unit:", () {
    World world;
    Entity entity;
    MockComponent component;
    MockComponentManager cm;
    setUp(() {
      cm = new MockComponentManager();
      cm.when(callsTo('entityHasComponent', anything, anything)).alwaysReturn(false);
      world = new World.withComponentManager(cm);
      entity = world.createEntity(1);
      component = new MockComponent();
    });
    test("can't create entity with null id.", () {
      Entity entity = world.createEntity(null);
      expect(entity, isNull);
    });
    test("check if an entity has a type of component.", () {
      expect(entity.hasComponent(MockComponent), isFalse);
      cm.getLogs(callsTo('entityHasComponent', anything, anything)).verify(happenedOnce);
      LogEntry entry = cm.getLogs(callsTo('entityHasComponent', anything, anything)).logs.first;
      expect(entry.args[0], equals(1));
      expect(entry.args[1], equals(MockComponent));
    });
    test("can remove a component from entity.", () {
      entity.removeComponent(MockComponent);
      cm.getLogs(callsTo('removeComponentFromEntity', anything, anything)).verify(happenedOnce);
      LogEntry entry = cm.getLogs(callsTo('removeComponentFromEntity', anything, anything)).logs.first;
      expect(entry.args[0], equals(1));
      expect(entry.args[1], equals(MockComponent));
    });
    test("can get a component from entity.", () {
      entity.addComponent(component);
      entity.getComponent(component.runtimeType);
      cm.getLogs(callsTo('getComponentFromEntity', anything, anything)).verify(happenedOnce);
      LogEntry entry = cm.getLogs(callsTo('getComponentFromEntity', anything, anything)).logs.first;
      expect(entry.args[0], equals(1));
      expect(entry.args[1], equals(MockComponent));
    });
  });
  group("Entity with component manager:", () {
    World world;
    Entity entity;
    MockComponent component;
    setUp(() {
      world = new World();
      entity = world.createEntity(1);
      component = new MockComponent();
    });
    test("check if an entity has a type of component.", () {
      expect(entity.hasComponent(MockComponent), isFalse);
      entity.addComponent(component);
      expect(entity.hasComponent(MockComponent), isTrue);
    });
    test("can remove a component from entity.", () {
      entity.addComponent(component);
      entity.removeComponent(MockComponent);
      expect(entity.hasComponent(MockComponent), isFalse);
    });
    test("can get a component from entity.", () {
      entity.addComponent(component);
      expect(entity.getComponent(component.runtimeType), equals(component));
    });
  });
}