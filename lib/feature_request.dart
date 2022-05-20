///Contains information about feature request
class FeatureRequest {
  String _requestorId;
  String _requestorName;
  String _type;

  FeatureRequest(this._requestorId, this._requestorName, this._type);

  ///The id of the participant that requested a certain feature access from you
  String get requestorId => _requestorId;

  ///The name of the participant that requested a certain feature access from you
  String get requestorName => _requestorName;

  ///The type of the feature being requested from you
  String get type => _type;
}

///Contains information about feature canceled remotely
class FeatureCancelation {
  String _type;

  FeatureCancelation(this._type);

  ///The type of the feature being canceled for you
  String get type => _type;
}

///All feature types
class ScreenMeetFeatureType {
  static const String laserpointer = "laserpointer";
  static const String remotecontrol = "remotecontrol";
}
