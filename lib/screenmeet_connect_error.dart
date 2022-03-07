
import 'dart:typed_data';

///Flutter screenmeet error class holding the code returned by native ScreenMeet SDK and error text
class ScreenMeetConnectError {
  String _text;
  int _code;
  Uint8List? _challengeImage;

  ScreenMeetConnectError(this._text, this._code, this._challengeImage);

  ///Code of the error. See [ScreenMeetErrorCode] for more information
  int get code => _code;

  ///Readable text with the error description
  String get text => _text;

  ///Captcha image
  Uint8List? get challengeImage => _challengeImage;
}