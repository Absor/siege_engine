part of siege_engine;

class WorldEvent {
  
  var _function;
  var _arg;
  
  WorldEvent(this._function, this._arg);
  
  void resolve() {
    _function(_arg);
  }
}