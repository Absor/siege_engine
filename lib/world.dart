part of siege_engine;

class World {
  
  Map<dynamic, Entity> _inactiveEntities;
  Map<dynamic, Entity> _activeEntities;  
  List<System> _systems;
  Queue<WorldEvent> _entityEvents;
  Queue<WorldEvent> _systemEvents;
  ComponentManager _cm;
  
  World() : this.withComponentManager(new ComponentManager());
  
  World.withComponentManager(this._cm) {
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
   * Queues an activate [WorldEvent] that will be
   * resolved with next [process] call.
   */
  void activateEntity(dynamic id) {
    _entityEvents.addLast(new WorldEvent(_activateEntity, id));
  }
  
  void _activateEntity(dynamic id) {
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
   * Queues a deactivate [WorldEvent] that will be
   * resolved with next [process] call.
   */
  void deactivateEntity(dynamic id) {
    _entityEvents.addLast(new WorldEvent(_deactivateEntity, id));
  }
  
  void _deactivateEntity(dynamic id) {
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
    _entityEvents.addLast(new WorldEvent(_destroyEntity, id));
  }
  
  void _destroyEntity(dynamic id) {
    _deactivateEntity(id);
    Entity entity = _inactiveEntities.remove(id);
    if (entity == null) return;
    // TODO remove all components
    //entity.removeAllComponents();
    // _cm.removeAllComponentsFromEntity(id);
  }
  
  /**
   * Adds a [System] to this world.
   */
  void addSystem(System system) {
    _systemEvents.addLast(new WorldEvent(_addSystem, system));
  }
  
  void _addSystem(System system) {
    for (Entity entity in _activeEntities) {
      system.entityActivation(entity);
    }
    system.attachWorld(this);
    _systems.add(system);
    // TODO sort by priority
  }
  
  // TODO remove and getAllSystems
  
  /**
   * Resolves [WorldEvent]s and processes all [System]s.
   * Forwards given timeDelta to [System]s or 0 if it is [null].
   */
  void process([num timeDelta = 0]) {
    
    // TODO move to world events?
    for (dynamic entityId in _cm.changedEntities) {
      Entity entity = _activeEntities[entityId];
      if (entity == null) continue;
      for (System system in _systems) {
        system.entityChange(entity);
      }
    }
    _cm.changedEntities.clear();
    
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