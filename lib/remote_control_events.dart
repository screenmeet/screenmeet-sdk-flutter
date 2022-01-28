
///Basic remote control event
///
/// This event is sent from server to native screenmeet SDK and then to flutter plugin
class RemoteControlEvent {
  String _from = "";
  String _to = "";

  RemoteControlEvent(this._from, this._to);

  ///id of the sender of the event. It's the user who remote controls your screen
  String get from => _from;

  ///id of the receiver of the event. It's your id basically
  String get to => _to;
}

///Mouse remote control event
///
/// This event happens when the remote user who remote controls your scree clicks the mouse
class RemoteControlMouseEvent extends RemoteControlEvent  {

  int _ts = 0;
  double _x = 0.0;
  double _y = 0.0;
  String _actionType = "";

  RemoteControlMouseEvent(from, to, this._ts, this._x, this._y, this._actionType) : super(from, to);

  //X coordinate of the mouse click
  double get x => _x;

  //Y coordinate of the mouse click
  double get y => _y;

  ///Action type of the mouse event (lef/right button, etc). See [RemoteControlMouseActionType]
  String get actionType => _actionType;

  ///Unix timestamp of the remote control event
  int get ts => _ts;
}

///Keyboard remote control event.
///
/// This event happens when the remote user who remote controls your screen hits the button on his keyboard
class RemoteControlKeyboardEvent extends RemoteControlEvent  {
  int _ts = 0;
  String _key = "";

  ///Default controller to make an instance of keyboard event giving the
  RemoteControlKeyboardEvent(from, to, this._ts, this._key): super(from, to);

  ///Keyboard key that has been hit
  String get key => _key;

  ///Unix timestamp of the remote control event
  int get ts => _ts;
}

class RemoteControlMouseActionType {
  static const unknown = "unknown";
  static const leftdown = "leftmousedown";
  static const rightdown = "rightmousedown";
  static const move = "mousemove";
  static const leftup = "leftmouseup";
  static const rightup = "rightmouseup";
}

class RemoteControlKeyboardActionType {
  static const unknown = "unknown";
  static const keydown = "keydown";
  static const keyup = "keyup";
}
