
import 'package:screenmeet_sdk_flutter/screenmeet_parameters_manager.dart';

///Flutter screenmeet error class holding the code returned by native ScreenMeet SDK and error text
class ScreenMeetError {
  String _text;
  int _code;

  ScreenMeetError(this._text, this._code);

  ///Code of the error. See [ScreenMeetErrorCode] for more information
  int get code => _code;

  ///Readable text with the error description
  String get text => _text;
}