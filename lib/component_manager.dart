part of siege_engine;

class ComponentManager {
  
  Map<Type, Map<dynamic, Component>> _componentsByType;
  Set<dynamic> _changedEntities;
  
  ComponentManager() {
    _componentsByType = new LinkedHashMap<Type, Map<dynamic, Component>>();
    _changedEntities = new LinkedHashSet<dynamic>();
  }
  
  /**
   * Returns a list of entity ids that have had components added or removed.
   */
  Set<dynamic> get changedEntities => _changedEntities;
  
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
    if (!_componentsByType.containsKey(component.runtimeType)) {
      _componentsByType[component.runtimeType] = new HashMap<dynamic, Component>();
    }
    _componentsByType[component.runtimeType][entityId] = component;
    _changedEntities.add(entityId);
  }
  
  /**
   * Removes the [Component] of the given [Type] from the given entity id.
   */
  void removeComponentFromEntity(dynamic entityId, Type componentType) {
    if (!_componentsByType.containsKey(componentType)) return;
    if (!_componentsByType[componentType].containsKey(entityId)) return;
    _componentsByType[componentType].remove(entityId);
    _changedEntities.add(entityId);
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
  
  List<Component> getAllComponentsFromEntity(dynamic entityId) {
    
  }
  
  void removeAllComponentsFromEntity(dynamic entityId, {bool withEvent : true}) {
    
    if (withEvent) _changedEntities.add(entityId);
  }
}