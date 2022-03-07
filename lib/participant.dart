import 'media_state.dart';

///Holds information about remote participant
class Participant {
  String _id;
  String _name;

  int _textureId;
  MediaState _mediaState;

  Participant(this._id, this._name, this._textureId, this._mediaState);

  ///The identifier of the remote participant
  String get id => _id;

  ///The name of the remote participant
  String get name => _name;

  ///Texture id that binds native SDK and flutter [Texture]
  int get textureId => _textureId;

  ///Media state of the remote participant
  MediaState get mediaState => _mediaState;
}