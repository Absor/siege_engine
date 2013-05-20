part of siege_engine;

class Entity {
  
  ComponentManager _cm;
  final dynamic id;
  
  Entity(this._cm, this.id);
  
  bool hasComponent(Type type) => _cm.entityHasComponent(id, type);
  
  void addComponent(Component component) => _cm.addComponentToEntity(id, component);
  
  void removeComponent(Type type) => _cm.removeComponentFromEntity(id, type);
  
  Component getComponent(Type type) => _cm.getComponentFromEntity(id, type);
  
  List<Component> getAllComponents() => _cm.getAllComponentsFromEntity(id);
  
  void removeAllComponents() => _cm.removeAllComponentsFromEntity(id);
}