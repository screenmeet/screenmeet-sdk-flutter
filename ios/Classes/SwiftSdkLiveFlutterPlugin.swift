import Flutter
import UIKit
import ScreenMeetSDK

typealias PermissionRequstCallback = (_ granted: Bool) -> Void
public class SwiftSdkLiveFlutterPlugin: NSObject, FlutterPlugin {
    
    private let kLocalMediaStateEventChannel = "platform_channel_events/screenmeet/localMediaState"
    private let kRemoteParticipantsEventChannel = "platform_channel_events/screenmeet/remoteParticipants"
    private let kConnectionStateEventChannel = "platform_channel_events/screenmeet/connectionState"
    private let kLocalVideoEventChannel = "platform_channel_events/screenmeet/localVideo"
    private let kRemoteControlEventChannel = "platform_channel_events/screenmeet/remoteControl"
    private let kFeatureRequestChannel = "platform_channel_events/screenmeet/featureRequest"
    private let kImageTransferChannel = "platform_channel_events/screenmeet/imageTransfer"
    
    private var connectionStateEventChannel: FlutterEventChannel!
    private var localMediaStateEventChannel: FlutterEventChannel!
    private var remoteParticipantEventChannel: FlutterEventChannel!
    private var localVideoEventChannel: FlutterEventChannel!
    private var remoteControlEventChannel: FlutterEventChannel!
    private var featureRequestsChannel: FlutterEventChannel!
    private var imageTransferChannel: FlutterBasicMessageChannel!
    
    private var connectionStreamHandler: ConnectionStreamHandler!
    private var localMediaStateStreamHandler: LocalMediaStateStreamHandler!
    private var participantsStreamHandler: ParticipantsStreamHandler!
    private var localVideoStreamHandler: LocalVideoStreamHandler!
    private var remoteControlStreamHandler: RemoteControlStreamHandler!
    private var featureRequestStreamHandler: FeatureRequestStreamHandler!
    
    private let pm = SwiftChannelParamsManager()
    private var textures: FlutterTextureRegistry!
    private var messanger: FlutterBinaryMessenger!
    private var registry: FlutterPluginRegistrar!
    
    private var confidentialRects = [String: CGRect]()
    private var featureRequests = [String: PermissionRequstCallback]()
    
    private var renderers = [String: FlutterRTCVideoRenderer]()
    private var localRenderer: FlutterRTCVideoRenderer? = nil
    private var localVideoTrack: RTCVideoTrack? = nil
    
    private var imageHandler: SMImageHandler!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sdk_live_flutter_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftSdkLiveFlutterPlugin(registrar.textures(), registrar.messenger(), registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(_ textures: FlutterTextureRegistry, _ messanger: FlutterBinaryMessenger, _ registrar: FlutterPluginRegistrar) {
        super.init()
        
        self.textures = textures
        self.messanger = messanger
        self.registry = registrar
        
        localMediaStateEventChannel = FlutterEventChannel(name: kLocalMediaStateEventChannel, binaryMessenger: registrar.messenger())
        remoteParticipantEventChannel = FlutterEventChannel(name: kRemoteParticipantsEventChannel, binaryMessenger: registrar.messenger())
        connectionStateEventChannel = FlutterEventChannel(name: kConnectionStateEventChannel, binaryMessenger: registrar.messenger())
        localVideoEventChannel = FlutterEventChannel(name: kLocalVideoEventChannel, binaryMessenger: registrar.messenger())
        remoteControlEventChannel = FlutterEventChannel(name: kRemoteControlEventChannel, binaryMessenger: registrar.messenger())
        featureRequestsChannel = FlutterEventChannel(name: kFeatureRequestChannel, binaryMessenger: registrar.messenger())
        
        imageTransferChannel = FlutterBasicMessageChannel(name: kImageTransferChannel, binaryMessenger: registrar.messenger(), codec: FlutterStandardMessageCodec.sharedInstance())

        connectionStreamHandler = ConnectionStreamHandler()
        connectionStateEventChannel.setStreamHandler(connectionStreamHandler)
        
        localMediaStateStreamHandler = LocalMediaStateStreamHandler()
        localMediaStateEventChannel.setStreamHandler(localMediaStateStreamHandler)
        
        participantsStreamHandler = ParticipantsStreamHandler()
        remoteParticipantEventChannel.setStreamHandler(participantsStreamHandler)
        
        localVideoStreamHandler = LocalVideoStreamHandler()
        localVideoEventChannel.setStreamHandler(localVideoStreamHandler)
        
        remoteControlStreamHandler = RemoteControlStreamHandler()
        remoteControlEventChannel.setStreamHandler(remoteControlStreamHandler)
        
        featureRequestStreamHandler = FeatureRequestStreamHandler()
        featureRequestsChannel.setStreamHandler(featureRequestStreamHandler)
        
        imageTransferChannel.setMessageHandler { [unowned self] params, reply in
            /*The array of parameters contains raw image data as the first element, then followed by any number of dictionaries of rects*/
            if let items = params as? [Any] {
                
                if let flutterData = items[0] as? FlutterStandardTypedData {
                    let scale = 1.0 / UIScreen.main.scale
                    var image = UIImage(data: flutterData.data, scale: scale)
                    if items.count > 1 {
                        for i in 1...(items.count-1) {
                            if let dict = items[i] as? [String: Double]  {
                                let rect = CGRect(x: dict[pm.kX]! * UIScreen.main.scale, y: dict[pm.kY]! * UIScreen.main.scale, width: dict[pm.kWidth]! * UIScreen.main.scale, height: dict[pm.kHeight]! * UIScreen.main.scale)
                                image = drawRectangleOnImage(rect, image!)
                            }
                        }
                    }
                    
                    imageHandler.transferImage(image!)
                }
            }
        }
    }
    
    func drawRectangleOnImage(_ rectangle: CGRect, _ image: UIImage) -> UIImage {
        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)

        image.draw(at: CGPoint.zero)

        //let rectangle = CGRect(x: 0, y: (imageSize.height/2) - 30, width: imageSize.width, height: 60)

        UIColor.black.setFill()
        UIRectFill(rectangle)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == pm.kConnectCommand) {
            
            if let arguments = call.arguments as? [String: Any] {
                if let roomId = arguments[pm.kConnectRoomId] as? String, let userName = arguments[pm.kConnectUserName] as? String {
                    
                    ScreenMeet.delegate = self
                    ScreenMeet.connect(roomId, userName) { [weak self] error in
                        if let error = error, let pm = self?.pm {
                            
                            if error.code == .knockEntryPermissionRequiredError {
                                result(pm.error(error.message, pm.kErrorKnowEntryPermissionRequired))
                            }
                            else {
                                result(pm.error(error.message, pm.kErrorCodeConnectFailed))
                            }
                            
                        }
                        else if let pm = self?.pm{
                            result(pm.success())
                        }
                    }
                }
                else {
                    result(pm.error("Parameters for this channel method are wrong", pm.kErrorCodeWrongMethodParameters))
                }
            }
        }
        
        if (call.method == pm.kDisconnectCommand) {
            ScreenMeet.disconnect()
            clearTextures()
            result(pm.success())
        }
        
        if (call.method == pm.kSetConfigCommand) {
            if let arguments = call.arguments as? [String: Any] {
                if let organizationKey = arguments[pm.kOrganizationKey] as? String,
                let endpoint = arguments[pm.kEndpoint] as? String,
                let collectMetrics = arguments[pm.kCollectMetrics] as? Bool,
                let logLevel = arguments[pm.kLogLevel] as? String {
                    
                    if logLevel == "info" { ScreenMeet.config.loggingLevel = .info }
                    if logLevel == "debug" { ScreenMeet.config.loggingLevel = .debug }
                    if logLevel == "error" { ScreenMeet.config.loggingLevel =  .error }

                    ScreenMeet.config.collectMetric = collectMetrics
                    if !endpoint.isEmpty { ScreenMeet.config.endpoint = URL(string: endpoint)! }
                    if !organizationKey.isEmpty { ScreenMeet.config.organizationKey = organizationKey }
                }
                else {
                    result(pm.error("Parameters for this channel method are wrong. Organization key, endpoint, log level or collect metric not found", pm.kErrorCodeWrongMethodParameters))
                }
            }
            else {
                result(pm.error("Parameters for this channel method are wrong", pm.kErrorCodeWrongMethodParameters))
            }
            result(pm.success())
        }
    
        else if (call.method == pm.kShareAudioCommand) {
            ScreenMeet.shareMicrophone()
            result(pm.success())
        }
        
        else if (call.method == pm.kStopSharingAudiCommand) {
            ScreenMeet.stopAudioSharing()
            result(pm.success())
        }
        
        else if (call.method == pm.kShareScreenCommand) {
            ScreenMeet.shareScreen()
            result(pm.success())
        }
        
        else if (call.method == pm.kShareScreenWithImageTransferCommand) {
            ScreenMeet.shareScreenWithImageTransfer { [unowned self] handler in
                if let handler = handler {
                    imageHandler = handler
                    result(pm.success())
                }
                else {
                    result(pm.error("Could not start image transfer session", pm.kErrorCouldNotStartImageTransferSession))
                }
            }
            
        }
        else if (call.method == pm.kChangeVideoSourceCommand) {
            let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)

            
            if ScreenMeet.getVideoSourceDevice().uniqueID == frontCamera?.uniqueID {
                ScreenMeet.shareCamera(backCamera)
            }
            if ScreenMeet.getVideoSourceDevice().uniqueID == backCamera?.uniqueID {
                ScreenMeet.shareCamera(frontCamera)
            }
            
            result(pm.success())
        }
        else if (call.method == pm.kShareVideoCommand) {
            if let arguments = call.arguments as? [String: Any] {
                
                if arguments[pm.kShareVideoCameraType] as? String == CameraType.front.rawValue {
                    let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
                    ScreenMeet.shareCamera(frontCamera)
                    result(pm.success())
                                    }
                else if arguments[pm.kShareVideoCameraType] as? String == CameraType.front.rawValue {
                    let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
                    ScreenMeet.shareCamera(backCamera)
                    
                    result(pm.success())
                }
                else {
                    result(pm.error("Parameters for this channel method are wrong. Unknown camera type", pm.kErrorCodeWrongMethodParameters))
                }
            }
        }
        else if (call.method == pm.kStopSharingVideoCommand) {
            ScreenMeet.stopVideoSharing()
            result(pm.success())
        }
        else if (call.method == pm.kGetMediaStateCommand) {
            let mediaState = ScreenMeet.getMediaState()
            result(pm.success(pm.mediaStateToDict(mediaState, localRenderer)))
        }
        else if (call.method == pm.kGetLocalVideoCommand) {
            let mediaState = ScreenMeet.getMediaState()
            handleTextureForLocalVideo(mediaState)
            
            result(pm.success(pm.localVideo(mediaState, localRenderer)))
        }
        else if (call.method == pm.kGetParticipantsCommand) {
            let participants  = ScreenMeet.getParticipants()
            
            handleTexturesForRemoteParticipants(participants)
            result(pm.success(pm.participantsToDict(participants, renderers)))
        }
        
        else if (call.method == pm.kSetConfidetianlRectCommand) {
            if let arguments = call.arguments as? [String: Any] {
                if let id = arguments[pm.kId] as? String,
                let x = arguments[pm.kX] as? Double,
                let y = arguments[pm.kY] as? Double,
                let width = arguments[pm.kWidth] as? Double,
                let height = arguments[pm.kHeight] as? Double {
                    
                    if let previousRect = confidentialRects[id] {
                        ScreenMeet.getAppStreamService().unsetConfidential(rect: previousRect)
                    }
                    let rect = CGRect(x: x, y: y, width: width, height: height)
                    confidentialRects[id] = rect
                    ScreenMeet.getAppStreamService().setConfidential(rect: rect)
                }
                else {
                    result(pm.error("Parameters for this channel method are wrong. Make sure rect id, x, y, width, height are passed", pm.kErrorCodeWrongMethodParameters))
                }
              
            }
            else {
                result(pm.error("Parameters for this channel method are wrong", pm.kErrorCodeWrongMethodParameters))
            }
        }
        
        else if (call.method == pm.kUnsetConfidetianlRectCommand) {
            if let id = call.arguments as? String {
                if let rect = confidentialRects[id] {
                    ScreenMeet.getAppStreamService().unsetConfidential(rect: rect)
                }
                else {
                    result(pm.error("Could not find the confidential rect with given id", pm.kErrorCodeWrongMethodParameters))
                }
                confidentialRects[id] = nil
            }
            else {
                result(pm.error("Parameters for this channel method are wrong", pm.kErrorCodeWrongMethodParameters))
            }
        }
        else if (call.method == pm.kFeatureGrantAccessCommand) {
            if let arguments = call.arguments as? [String: Any] {
                if let requestorId = arguments[pm.kFeatureRequestorId] as? String, let featureType = arguments[pm.kFeatureType] as? String {
                    if let callback = featureRequests["\(requestorId)\(featureType)"] {
                        callback(true)
                    }
                    else {
                        result(pm.error("Parameters for this channel method are wrong. Feature requst with given requstor id or type not found", pm.kErrorCodeWrongMethodParameters))
                    }
                }
                else {
                    result(pm.error("Parameters for this channel method are wrong. Feature requstor id or feature type", pm.kErrorCodeWrongMethodParameters))
                }
            }
            else {
                result(pm.error("Parameters for this channel method are wrong", pm.kErrorCodeWrongMethodParameters))
            }
        }
        
        else if (call.method == pm.kFeatureRejectAccessCommand) {
            if let arguments = call.arguments as? [String: Any] {
                if let requestorId = arguments[pm.kFeatureRequestorId] as? String, let featureType = arguments[pm.kFeatureType] as? String {
                    if let callback = featureRequests["\(requestorId)\(featureType)"] {
                        callback(false)
                    }
                    else {
                        result(pm.error("Parameters for this channel method are wrong. Feature requst with given requstor id or type not found", pm.kErrorCodeWrongMethodParameters))
                    }
                }
                else {
                    result(pm.error("Parameters for this channel method are wrong. Feature requstor id or feature type", pm.kErrorCodeWrongMethodParameters))
                }
            }
            else {
                result(pm.error("Parameters for this channel method are wrong", pm.kErrorCodeWrongMethodParameters))
            }
        }
    }
    
    private func sendMediaState() {
        let mediaState = ScreenMeet.getMediaState()
        localMediaStateStreamHandler.sendMediaState(mediaState, localRenderer)
    }
    
    private func sendLocalVideo() {
        let mediaState = ScreenMeet.getMediaState()
        
        handleTextureForLocalVideo(mediaState)
        localVideoStreamHandler.sendLocalVideo(mediaState, localRenderer)
    }
    
    private func sendParticipants() {
        let participants = ScreenMeet.getParticipants()
        handleTexturesForRemoteParticipants(participants)
        participantsStreamHandler.sendParticipants(participants, renderers)
    }
    
    private func handleTextureForLocalVideo(_ mediaState: SMParticipantMediaState) {
        if  mediaState.isVideoActive  && mediaState.videoState == .CAMERA {
            localRenderer = FlutterRTCVideoRenderer(textureRegistry: registry.textures(), messenger: registry.messenger())!
            localRenderer?.videoTrack = localVideoTrack
        }
        else {
            localRenderer = FlutterRTCVideoRenderer(textureRegistry: registry.textures(), messenger: registry.messenger())!
            localRenderer?.videoTrack = nil
            localRenderer?.dispose()
            localRenderer = nil
        }
    }
    
    private func handleTexturesForRemoteParticipants(_ participants: [SMParticipant]) {
        for participant in participants {
            if participant.avState.isVideoActive, let track = participant.videoTrack {
                if let _ = renderers[participant.id] {
                    
                }
                else {
                    let renderer = FlutterRTCVideoRenderer(textureRegistry: registry.textures(), messenger: registry.messenger())!
                    self.renderers[participant.id] = renderer
                    renderer.videoTrack = track
                }
            }
            else if !participant.avState.isVideoActive, let renderer = renderers[participant.id] {
                renderer.videoTrack = nil
                renderer.dispose()
                renderers[participant.id] = nil
            }
        }
    }
    
    private func clearTextures()  {
        for (participantId, renderer) in renderers {
            renderer.videoTrack = nil
            renderer.dispose()
        }
        renderers = [String: FlutterRTCVideoRenderer]()
    }
    
    
    private func overlay(rect: CGRect, over image: CIImage) -> CIImage {
        let overlayImage = imageWith(rect, .blue)
        
        guard let overlayCIImage = CIImage(image: overlayImage) else { return image }
        guard let cropFilter = CIFilter(name: "CICrop") else { return image }
        
        cropFilter.setValue(overlayCIImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: rect), forKey: "inputRectangle")
        
        guard let overCompositingFilter = CIFilter(name: "CISourceOverCompositing") else { return image }
        
        overCompositingFilter.setValue(cropFilter.outputImage, forKey: kCIInputImageKey)
        overCompositingFilter.setValue(image, forKey: kCIInputBackgroundImageKey)
        
        guard let outputImage = overCompositingFilter.outputImage else { return image }
        
        return outputImage
    }
    
    private func imageWith(_ rect: CGRect, _ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return UIImage.init(cgImage: image!.cgImage!)
    }
}

extension SwiftSdkLiveFlutterPlugin {
    func createWithTextureRegistry(_ registry: FlutterTextureRegistry, _ messanger: FlutterBinaryMessenger) -> FlutterRTCVideoRenderer {
        return FlutterRTCVideoRenderer(textureRegistry: registry, messenger: messanger)
    }
    
    /*
    func rendererSetSrcObject(_ renderer: FlutterRTCVideoRenderer, _ stream: RTCVideoTrack) {
        renderer.videoTrack = stream
    }*/
}

extension SwiftSdkLiveFlutterPlugin: ScreenMeetDelegate {
    public func onFeatureRequest(_ feature: SMFeature, _ decisionHandler: @escaping (Bool) -> Void) {
        featureRequests["\(feature.requestorParticipant.id)\(feature.type.rawValue)"] = decisionHandler
        featureRequestStreamHandler.sendPersmissionRequest(feature)
    }
    
    public func onFeatureRequestRejected(feature: SMFeature) {
        featureRequests["\(feature.requestorParticipant.id)\(feature.type.rawValue)"] = nil
    }
    
    public func onFeatureStopped(feature: SMFeature) {
        NSLog("onFeatureStopped: \(feature.type.rawValue)")
    }
    
    public func onFeatureStarted(feature: SMFeature) {
        NSLog("*Feature started: \(feature.type.rawValue)")
    }
    
    public func onRequest(entitlement: SMEntitlementType, participant: SMParticipant, decisionHandler: @escaping (Bool) -> Void) {
        decisionHandler(true)
    }
    
    public func onRemoteControlEvent(_ event: SMRemoteControlEvent) {
        remoteControlStreamHandler.sendRemoteEvent(event)
    }
    
    public var rootViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    public func onLocalAudioCreated() {
        sendMediaState()
    }
    
    public func onLocalVideoCreated(_ videoTrack: RTCVideoTrack) {
        localVideoTrack = videoTrack
        sendMediaState()
        sendLocalVideo()
    }
    
    public func onLocalVideoSourceChanged() {
        sendMediaState()
        //sendLocalVideo()
    }
    
    public func onLocalVideoStopped() {
        localRenderer?.videoTrack = nil
        localRenderer?.dispose()
        localVideoTrack = nil
        
        sendMediaState()
        sendLocalVideo()
    }
    
    public func onLocalAudioStopped() {
        sendMediaState()
    }
    
    public func onParticipantJoined(_ participant: SMParticipant) {
        sendParticipants()
        sendLocalVideo()
    }
    
    public func onParticipantVideoTrackCreated(_ participant: SMParticipant) {
        sendParticipants()
    }
    
    public func onParticipantAudioTrackCreated(_ participant: SMParticipant) {
        sendParticipants()
    }
    
    public func onParticipantLeft(_ participant: SMParticipant) {
        sendParticipants()
        sendLocalVideo()
    }
    
    public func onParticipantMediaStateChanged(_ participant: SMParticipant) {
        sendParticipants()
    }
    
    public func onActiveSpeakerChanged(_ participant: SMParticipant) {
        
    }
    
    public func onConnectionStateChanged(_ newState: SMConnectionState) {
        connectionStreamHandler.sendConnectionState(newState)
    }
    
    public func onError(_ error: SMError) {
        
    }
    

}
