part of siege_engine;

class ComponentManager {
  
  World _world;
  Map<Type, Map<dynamic, Component>> _componentsByType;
  
  ComponentManager(this._world) {
    _componentsByType = new LinkedHashMap<Type, Map<dynamic, Component>>();
  }
  
  /**
   * Returns [true] if given entity id has a component 
   */
  bool entityHasComponent(dynamic entityId, Type componentType) {
    if (!_componentsByType.containsKey(componentType)) return false;
    return _componentsByType[componentType].containsKey(entityId);
  }
  
  /**
   * Adds a [Component] to given id. Can only have one component per id per [Type].
   * Overwrites old [Component] of the same type if any.
   */
  void addComponentToEntity(dynamic entityId, Component component) {
    if (!_world.containsEntity(entityId)) return;
    if (!_componentsByType.containsKey(component.runtimeType)) {
      _componentsByType[component.runtimeType] = new HashMap<dynamic, Component>();
    }
    _componentsByType[component.runtimeType][entityId] = component;
    _informWorld(entityId);
  }
  
  /**
   * Removes the [Component] of the given [Type] from the given entity id.
   */
  void removeComponentFromEntity(dynamic entityId, Type componentType) {
    if (!_componentsByType.containsKey(componentType)) return;
    if (!_componentsByType[componentType].containsKey(entityId)) return;
    _componentsByType[componentType].remove(entityId);
    _informWorld(entityId);
  }
  
  /**
   * Returns the [Component] of the given [Type] from the given entity id.
   * Returns [null] if entity id doesn't have matching [Component].
   */
  Component getComponentFromEntity(dynamic entityId, Type componentType) {
    if (!_componentsByType.containsKey(componentType) ||
        !_componentsByType[componentType].containsKey(entityId)) return null;
    return _componentsByType[componentType][entityId];
  }
  
  /**
   * Returns all [Component]s of the given id or an empty
   * [List] if entity has no [Components].
   */
  List<Component> getAllComponentsFromEntity(dynamic entityId) {
    List<Component> components = new List<Component>();
    for (Map<dynamic, Component> componentsOfType in _componentsByType.values) {
      if (componentsOfType.containsKey(entityId)) components.add(componentsOfType[entityId]);
    }
    return components;
  }
  
  /**
   * Removes all [Component]s from the given entity id.
   * Informs [World] with deactivate and activate events.
   */
  void removeAllComponentsFromEntity(dynamic entityId, {bool withEvent : true}) {
    for (Map<dynamic, Component> components in _componentsByType.values) {
      components.remove(entityId);
    }
    if (withEvent) _informWorld(entityId);
  }
  
  void _informWorld(dynamic entityId) {
    if(!_world.isEntityActive(entityId)) return;
    _world.deactivateEntity(entityId);
    _world.activateEntity(entityId);
  }
}