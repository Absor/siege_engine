part of siege_engine;

abstract class System {
  
  int priority;
  bool enabled;
    
  void process(num timeDelta);
  
  // TODO next two
  void attachWorld(World world);
  
  void detachWorld();
  
  void entityActivation(Entity entity);
  
  void entityDeactivation(Entity entity);
  
  void entityChange(Entity entity);
}