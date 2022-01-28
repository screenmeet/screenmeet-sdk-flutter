//
//  ConnectionStreamHandler.swift
//  sdk_live_flutter_plugin
//
//  Created by Ross on 29.10.2021.
//

import Foundation
import Flutter
import ScreenMeetSDK

class ConnectionStreamHandler: NSObject, FlutterStreamHandler {
    var sink: FlutterEventSink?
       
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
       
     func sendConnectionState(_ connectionState: SMConnectionState) {
        guard let sink = sink else { return }
        sink(connectionState.description)
    }
       
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}
