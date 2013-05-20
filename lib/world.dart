part of siege_engine;

class World {
  
  Map<dynamic, Entity> _inactiveEntities;
  Map<dynamic, Entity> _activeEntities;  
  List<System> _systems;
  Queue<WorldEvent> _entityEvents;
  Queue<WorldEvent> _systemEvents;
  ComponentManager _cm;
  
  World() {
    _cm = new ComponentManager(this);
    _initPrivate();
  }
  
  World.withComponentManager(this._cm) {
    _initPrivate();
  }
  
  void _initPrivate() {
    _inactiveEntities = new LinkedHashMap<dynamic, Entity>();
    _activeEntities = new LinkedHashMap<dynamic, Entity>();
    _systems = new List<System>();
    _entityEvents = new Queue<WorldEvent>();
    _systemEvents = new Queue<WorldEvent>();
  }

  /**
   * Creates [Entity] with given id.
   * Returns [null] if id is already in use or id is [null].
   */
  Entity createEntity(dynamic id) {
    if (_inactiveEntities.containsKey(id) || id == null) return null;
    Entity entity = new Entity(_cm, id);
    _inactiveEntities[id] = entity;
    return entity;
  }
  
  /**
   * Returns [true] if id is already in use
   * ([Entity] has been created).
   */
  bool containsEntity(dynamic id) =>
      _inactiveEntities.containsKey(id) ||
      _activeEntities.containsKey(id);
  
  /**
   * Returns [Entity] with given id or [null]
   * if no [Entity] with given id has been created. 
   */
  Entity getEntityById(dynamic id) {
    if (_activeEntities.containsKey(id)) return _activeEntities[id];
    if (_inactiveEntities.containsKey(id)) return _inactiveEntities[id];
    return null;
  }
  
  /**
   * Queues an activate [WorldEvent] that will be
   * resolved with next [process] call.
   */
  void activateEntity(dynamic id) {
    _entityEvents.addLast(new WorldEvent(_activateEntityBroadcast, id));
  }
  
  void _activateEntityBroadcast(dynamic id) {
    if (!_inactiveEntities.containsKey(id)) return;
    Entity entity = _inactiveEntities.remove(id);
    _activeEntities[id] = entity;
    
    for (System system in _systems) {
      system.entityActivation(entity);
    }
  }
  
  /**
   * Returns [true] if entity is active.
   * Examples:
   * 
   * * Entity is not active if it has just been created.
   * * Entity is not active if it has been activated and
   * process has not been called yet.
   * * Entity is active if it has been activated and
   * process has been called.
   * * Entity is active if it was active and deactivate
   * has been called and process has not been called yet.
   * 
   */
  bool isEntityActive(dynamic id) => _activeEntities.containsKey(id);
  
  /**
   * Queues a deactivate [Entity] [WorldEvent] that will be
   * resolved with next [process] call.
   */
  void deactivateEntity(dynamic id) {
    _entityEvents.addLast(new WorldEvent(_deactivateEntityBroadcast, id));
  }
  
  void _deactivateEntityBroadcast(dynamic id) {
    if (!_activeEntities.containsKey(id)) return;
    Entity entity = _activeEntities.remove(id);
    _inactiveEntities[id] = entity;
    
    for (System system in _systems) {
      system.entityDeactivation(entity);
    }
  }
  
  /**
   * Queues a destroy [WorldEvent] that will be
   * resolved with next [process] call.
   * Event also removes [Component]s from [Entity].
   */
  void destroyEntity(dynamic id) {
    _entityEvents.addLast(new WorldEvent(_destroyEntityBroadcast, id));
  }
  
  void _destroyEntityBroadcast(dynamic id) {
    _deactivateEntityBroadcast(id);
    Entity entity = _inactiveEntities.remove(id);
    if (entity == null) return;
    entity.removeAllComponents();
  }
  
  /**
   * Queues an add [System] [WorldEvent] that will be
   * resolved with next [process] call.
   */
  void addSystem(System system) {
    _systemEvents.addLast(new WorldEvent(_addSystem, system));
  }
  
  void _addSystem(System system) {
    for (Entity entity in _activeEntities.values) {
      system.entityActivation(entity);
    }
    system.attachWorld(this);
    _systems.add(system);
    _systems.sort((system1, system2) => system1.priority - system2.priority);
  }
  
  /**
   * Queues a remove [System] [WorldEvent] that will be
   * resolved with next [process] call.
   */
  void removeSystem(System system) {
    _systemEvents.addLast(new WorldEvent(_removeSystem, system));
  }
  
  void _removeSystem(System system) {
    if (!_systems.remove(system)) return;
    for (Entity entity in _activeEntities.values) {
      system.entityDeactivation(entity);
    }
    system.detachWorld();
  }
  
  // TODO remove and getAllSystems, remember detach + tests
  
  List<System> getAllSystems() {
    return _systems;
  }
  
  /**
   * Resolves [WorldEvent]s and processes all [System]s.
   * Forwards given timeDelta to [System]s or 0 if it is [null].
   */
  void process([num timeDelta = 0]) {
    
    while(!_entityEvents.isEmpty) {
      _entityEvents.removeFirst().resolve();
    }
    
    while(!_systemEvents.isEmpty) {
      _systemEvents.removeFirst().resolve();
    }
    
    for (System system in _systems) {
      if (system.enabled) system.process(timeDelta);
    }
  }
}