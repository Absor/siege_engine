part of siege_engine_test;

void world_test() {
  group("World entities:", () {
    World world;
    setUp(() {
      world = new World();
    });
    test("can create entities with number id.", () {
      var entity = world.createEntity(1);
      expect(entity, new isInstanceOf<Entity>());
    });
    test("can create entities with string id.", () {
      var entity = world.createEntity("testi");
      expect(entity, new isInstanceOf<Entity>());
    });
    test("created entities get the given id.", () {
      Entity entity = world.createEntity(1);
      expect(entity.id, equals(1));
    });
    test("created entity id is final.", () {
      Entity entity = world.createEntity(1);
      expect(() => entity.id = 2, throws);
    });
    test("doesn't allow same id to be used multiple times.", () {
      world.createEntity(1);
      expect(world.createEntity(1), isNull);
    });
    test("can check if entity id is in use.", () {
      expect(world.containsEntity(1), isFalse);
      world.createEntity(1);
      expect(world.containsEntity(1), isTrue);
    });
    test("can activate entity.", () {
      world.createEntity(1);
      world.activateEntity(1);
      world.process(0);
      expect(world.isEntityActive(1), isTrue);
    });
    test("active entity is also in the world.", () {
      world.createEntity(1);
      world.activateEntity(1);
      world.process(0);
      expect(world.containsEntity(1), isTrue);
    });
    test("can deactivate entity.", () {
      world.createEntity(1);
      world.activateEntity(1);
      world.process(0);
      world.deactivateEntity(1);
      world.process(0);
      expect(world.isEntityActive(1), isFalse);
    });
    test("can destroy entity.", () {
      world.createEntity(1);
      expect(world.containsEntity(1), isTrue);
      world.destroyEntity(1);
      world.process();
      expect(world.containsEntity(1), isFalse);
    });
    test("can get inactive entity by id.", () {
      Entity entity = world.createEntity(1233);
      expect(world.getEntityById(1233), equals(entity));
    });
    test("can get active entity by id.", () {
      Entity entity = world.createEntity(1233);
      world.activateEntity(1233);
      world.process();
      expect(world.getEntityById(1233), equals(entity));
    });
  });
  group("World systems:", () {
    World world;
    MockSystem system;
    setUp(() {
      world = new World();
      system = new MockSystem();
      system.when(callsTo('get priority')).alwaysReturn(1);
      system.when(callsTo('get enabled')).alwaysReturn(true);
    });
    test("can add a system.", () {
      expect(() => world.addSystem(system), returnsNormally);
    });
    test("can process systems.", () {
      System system2 = new MockSystem();
      system2.when(callsTo('get priority')).alwaysReturn(2);
      system2.when(callsTo('get enabled')).alwaysReturn(true);
      world.addSystem(system);
      world.addSystem(system2);
      world.process(0);
      system.getLogs(callsTo('process')).verify(happenedOnce);
      system2.getLogs(callsTo('process')).verify(happenedOnce);
    });
    test("can process systems with time forwarded.", () {
      world.addSystem(system);
      world.process(100);
      LogEntry entry = system.getLogs(callsTo('process')).logs.first;
      expect(entry.args.first, equals(100));
    });
    test("calling process with no time defaults time to zero.", () {
      world.addSystem(system);
      world.process();
      LogEntry entry = system.getLogs(callsTo('process')).logs.first;
      expect(entry.args.first, equals(0));
    });
    test("system gets active entities when processing (only once).", () {
      world.createEntity(1);
      world.activateEntity(1);
      world.addSystem(system);
      world.process();
      world.process();
      system.getLogs(callsTo('entityActivation')).verify(happenedOnce);
    });
    test("system gets deactivated entities when processing (only once).", () {
      world.createEntity(1);
      world.activateEntity(1);
      world.addSystem(system);
      world.process();
      world.deactivateEntity(1);
      world.process();
      world.process();
      system.getLogs(callsTo('entityDeactivation')).verify(happenedOnce);
    });
    test("doesn't process disabled systems.", () {
      System system2 = new MockSystem();
      system2.when(callsTo('get priority')).alwaysReturn(2);
      system2.when(callsTo('get enabled')).alwaysReturn(false);
      world.addSystem(system2);
      world.addSystem(system);
      world.process();
      world.process();
      system2.getLogs(callsTo('process')).verify(neverHappened);
      system.getLogs(callsTo('process')).verify(happenedExactly(2));
    });
    test("system gets deactivation + activation from changed entities.", () {
      Entity entity = world.createEntity(1);
      world.activateEntity(1);
      world.addSystem(system);
      world.process();
      entity.addComponent(new MockComponent());
      world.process();
      world.process();
      system.getLogs(callsTo('entityDeactivation')).verify(happenedOnce);
      system.getLogs(callsTo('entityActivation')).verify(happenedExactly(2));
    });
    test("can get a list of systems.", () {
      world.addSystem(system);
      world.process(0);
      expect(world.getAllSystems().length, equals(1));
      expect(world.getAllSystems().first, equals(system));
    });
    test("systems are kept in priority order.", () {
      world.addSystem(system);
      System system2 = new MockSystem();
      system2.when(callsTo('get priority')).alwaysReturn(-3);
      system2.when(callsTo('get enabled')).alwaysReturn(false);
      world.addSystem(system2);
      System system3 = new MockSystem();
      system3.when(callsTo('get priority')).alwaysReturn(10);
      system3.when(callsTo('get enabled')).alwaysReturn(false);
      world.addSystem(system3);
      world.process(0);
      expect(world.getAllSystems()[0].priority, equals(-3));
      expect(world.getAllSystems()[1].priority, equals(1));
      expect(world.getAllSystems()[2].priority, equals(10));
    });
    test("can remove a system.", () {
      world.addSystem(system);
      world.process(0);
      world.removeSystem(system);
      world.process(0);
      expect(world.getAllSystems().length, equals(0));
    });
    test("system gets an attach call when added.", () {
      world.addSystem(system);
      world.process(0);
      system.getLogs(callsTo('attachWorld')).verify(happenedOnce);
      LogEntry entry = system.getLogs(callsTo('attachWorld')).first;
      expect(entry.args.first, equals(world));
    });
    test("system gets a detach call when removed.", () {
      world.addSystem(system);
      world.process(0);
      world.removeSystem(system);
      world.process(0);
      system.getLogs(callsTo('detachWorld')).verify(happenedOnce);
    });
  });
}