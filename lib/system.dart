part of siege_engine;

abstract class System {
  
  /**
   * Systems are required to return a non null priority value.
   */
  int priority;
  
  /**
   * Systems are required to return a non null enabled value.
   * Checked every time before calling [process].
   */
  bool enabled;
  
  /**
   * Called by [World] when enabled returns [true] and
   * [World]'s [process] has been called.
   */
  void process(var broadcastParam);
  
  /**
   * Called when [System] is added to [World] and
   * [World]'s [process] is called after.
   */
  void attachWorld(World world);
  
  /**
   * Called when [System] is removed from [World] and
   * [World]'s [process] is called after.
   */
  void detachWorld();
  
  /**
   * Called when the given [Entity] is activated.
   */
  void entityActivation(Entity entity);
  
  /**
   * Called when the given [Entity] is deactivated.
   */
  void entityDeactivation(Entity entity);
}