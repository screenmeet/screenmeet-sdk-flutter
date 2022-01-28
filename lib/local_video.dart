
/// Keeps the meta data about local video
class LocalVideo {

  bool _isOn = false;
  int _textureId = -1;

  ///Default constructor to create and instance of local video with given video state and texture id
  LocalVideo(this._isOn, this._textureId);

  /// Factory constructor that just makes new empty instance with local video marked as stopped and teture id set to -1 (not valid)
  factory LocalVideo.stopped() {
    return LocalVideo(false, -1);
  }

  ///Texture used to bind native SDK renderer and flutter [Texture]
  int get textureId => _textureId;

  ///Indicates whether video is turned on locally (camera)
  bool get isOn => _isOn;
}