///Configuration class for native ScreenMeet SDK
///
/// Default constructor requires organization key. SDK will respond with error if it's not set or wrong when trying to connect to a room
/// Other properties (endpoint, whether to collect metrics and log level) are optional
/// Only set endpoint when you specifically know which one you need
/// Default values for collecting metrics and log level are false and .error (See [ScreenMeetLoggingLevel])
class ScreenMeetConfig {

  /// Organization key to access API
  String organizationKey;

  /// Initial connection endpoint/port
  String endpoint = "https://edge.screenmeet.com";

  /// Allow collecting metrics
  bool collectMetric = false;

  /// Represent the severity and importance of log messages output (`.info`, `.debug`, `.error`, see [ScreenMeetLoggingLevel])
  String loggingLevel = ScreenMeetLoggingLevel.error;

  ScreenMeetConfig({required this.organizationKey});
}

/// The level of logs printed by the SDK
class ScreenMeetLoggingLevel {
  static const String info = "info";
  static const String debug = "debug";
  static const String error = "error";
}