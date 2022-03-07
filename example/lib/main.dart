import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:screenmeet_flutter_plugin_example/local_video_widget.dart';
import 'package:screenmeet_sdk_flutter/confidential_widget.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_parameters_manager.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_plugin.dart';
import 'package:screenmeet_sdk_flutter/remote_control_events.dart';

import 'call_controls_widget.dart';
import 'remote_participants_widget.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_config.dart';
import 'package:screenmeet_sdk_flutter/feature_request.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    ScreenMeetConfig config = ScreenMeetConfig(organizationKey: '');
    ScreenMeetPlugin().setConfig(config);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: "HelveticaNeue",
        visualDensity: VisualDensity.adaptivePlatformDensity
      ),
      home: _ScreenMeetConnectPage(),
    );
  }
}

/// Initial screen of the app
///
/// Contains a "room code" text field and connect button
/// The textfield input should be either 6 digit room-code or
/// a full 12 characters room id
class _ScreenMeetConnectPage extends StatefulWidget {
  _ScreenMeetConnectPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConnectState();
  }

}

class _ConnectState extends State<_ScreenMeetConnectPage> {

  bool _isConnecting = false;

  /// room textfield controller
  final TextEditingController roomEditingController = TextEditingController(text: "");

  _ConnectState();

  @override
  void initState() {
    super.initState();

    //Subscribe for connection changes
    ScreenMeetPlugin().setConnectionStateListener(listener: (String connectionState) {
      //Go to main screen if connected (entered the room successfully)
      if (connectionState == ScreenMeetConnectionState.connected)  {
        Navigator.push(
          context,
          PageRouteBuilder(pageBuilder: (c, a1, a2) =>
            _ScreenMeetDemoPage(),
            transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: Duration(milliseconds: 800)
          )
        );
      }
      if (connectionState == ScreenMeetConnectionState.disconnected)  {
        Navigator.maybePop(context);
        setState(() { _isConnecting = false;});
      }
    });

    //Subscribe for feature permission request from remote peers
    ScreenMeetPlugin().setFeatureRequestListener(listener: (FeatureRequest featureRequest) {
      Widget rejectButton = TextButton(
        child: Text("Reject"),
        style: TextButton.styleFrom(primary: Color.fromARGB(255, 100, 100, 100)),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          ScreenMeetPlugin().rejectAccess(featureRequest);
        }
      );
      Widget approveButton = TextButton(
        child: Text("Grant"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          ScreenMeetPlugin().grantAccess(featureRequest);
        }
      );
      AlertDialog alert = AlertDialog(
          content: Text("Would you like to grant access to ${featureRequest.type} "
              "requested by ${featureRequest.requestorName}?"),
          actions: [rejectButton, approveButton]
      );
      showDialog(context: context, builder: (BuildContext context) { return alert; });
    });
  }

  void displayCaptcha(Uint8List challenge){
    final TextEditingController captchaController = TextEditingController(text: "");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20.0)
          ),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.memory(challenge, width: 250, height: 100, fit: BoxFit.fill),
                  TextField(
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'What code is in the image?'),
                  ),
                  TextField(
                    onSubmitted: (newValue){},
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(fontSize: 24),
                    autofocus: true,
                    decoration: InputDecoration(counterText: ""),
                    controller: captchaController
                  ),
                  Wrap(
                    children:[
                      ElevatedButton(
                        onPressed: () async {
                          var response = await ScreenMeetPlugin().solveChallenge(captchaController.text);
                          processConnectResponse(response);
                        },
                        child: Text(
                          "Complete",
                          style: TextStyle(color: Colors.white),
                        )
                      )
                    ]
                  )
                ]
              )
            )
          )
        );
      }
    );
  }

  void processConnectResponse(dynamic response){
    response.fold((error) {
      var challengeImage = error.challengeImage;
      return {
        //kErrorKnowEntryPermissionRequired means that host has to let us in the room
        if (error.code == ScreenMeetErrorCode.kErrorKnowEntryPermissionRequired) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.text),
              backgroundColor: Colors.orange
            )
          ),
          Navigator.of(context).maybePop()
        } else if (error.code == ScreenMeetErrorCode.kErrorCaptchaRequired) {
          if(challengeImage != null) displayCaptcha(challengeImage),
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.text),
              backgroundColor: Colors.orange
            )
          )
        } else {
          setState(() { _isConnecting = false;}),
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.text))
          ),
          Navigator.of(context).maybePop()
        }
      };
    }, (success) => {
      Navigator.of(context).maybePop(),
      setState(() { _isConnecting = false;})
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 50),
          new Expanded(
            flex: 30,
            child: Image.asset("assets/flutter.png", height: 160.0, width: 160.0)
          ),
          SizedBox(height: 50),
          new Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(100.0, 0, 100.0, 0.0),
              child: Center(
                child: TextField(
                  textAlign: TextAlign.center,
                  enabled: !_isConnecting,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: TextStyle(fontSize: 20),
                  autofocus: true,
                  decoration: InputDecoration(counterText: ""),
                  controller: roomEditingController
                )
              ),
            )
          ),
          SizedBox(height: 10),
          _isConnecting ? Container(
            margin: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 12.0),
            child: CircularProgressIndicator(strokeWidth: 1.0)
          ) : Padding(
            padding: const EdgeInsets.fromLTRB(100.0, 0, 100.0, 0.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() { _isConnecting = true;});
                    //Connect to the room
                    var response = await ScreenMeetPlugin().connect(roomEditingController.text, "Flutter guy");
                    processConnectResponse(response);
                },
                child: Text(
                  'Connect',
                  style: TextStyle(
                    fontFamily: 'HelveticeNeue-Light',
                    fontWeight: FontWeight.w300, fontSize: 18
                  )
                ),
              )
            )
          ),
          Spacer(flex: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Powered by Screenmeet ©",
                style: TextStyle(fontSize: 12.0)
              ),
              SizedBox(width: 4),
              Image(width: 22, height: 22, image: AssetImage('assets/screenmeet.png'))
            ]
          ),
          Spacer()
        ]
      )
    );
  }
}

/// Main screen of the app
///
/// This screen contains call control buttons (audio, video, screen sharing),
/// remote participants video views and local video view
class _ScreenMeetDemoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ScreenMeetDemoPageState();
  }
}

class _ScreenMeetDemoPageState extends State<_ScreenMeetDemoPage> {

  bool  isDown = false;
  Offset touchPosition = Offset.zero;

  double cut(double val) {
    if (val < 0) {
      return max(val, -40);
    }
    return min(val, 40);
  }

  void tap(Offset pos, String type){
    final result = HitTestResult();
    WidgetsBinding.instance!.hitTest(result, pos);
    result.path.forEach((element) {
      if (type == RemoteControlMouseActionType.leftdown) {
        isDown = true;
        touchPosition = pos;
        element.target.handleEvent(
          PointerDownEvent(
            position: pos,
            kind: PointerDeviceKind.touch
          ),
          element,
        );
      }
      else if (type == RemoteControlMouseActionType.leftup) {
        isDown = false;
          element.target.handleEvent(
            PointerUpEvent(
              position: pos,
              kind: PointerDeviceKind.touch
            ),
            element,
          );
      }
      else if (type == RemoteControlMouseActionType.move) {
        if (isDown) {
          element.target.handleEvent(
            PointerMoveEvent(
              position: pos,
              delta: Offset(
                cut(pos.dx - touchPosition.dx),
                cut(pos.dy - touchPosition.dy)
              )
            ),
            element,
          );
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    //Subscribe for remote control events
    ScreenMeetPlugin().setRemoteControlListener(
      listener: (RemoteControlEvent event) {
        if (event is RemoteControlMouseEvent) {
          tap(Offset(event.x, event.y), event.actionType);
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Spacer(),
              new Expanded(
                flex: 70,
                child: RemoteParticipantsWidget()
              ),
              Spacer(),
              new Expanded(
                flex: 10,
                child: CallControlsWidget()
              ),
              Spacer(),
              new Expanded(
                flex: 3,
                child: ConfidentialWidget(
                  Key("text"),
                  Text(
                    '[confidential widget]',
                    style: TextStyle(fontSize: 12.0)
                  ),
                ),
              ),
              Spacer(),
              new Expanded(
                flex: 15,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0, 0.0, 60.0),
                  child: listView()
                )
              )
            ],
          ),
          Positioned(top: 40, left: 10, child: LocalVideoWidget()),
          Positioned(
            child: new Align(
              alignment: FractionalOffset.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0, 0.0, 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Powered by Screenmeet ©",
                      style: TextStyle(fontSize: 12.0)
                    ),
                    SizedBox(width: 4),
                    Image(
                      width: 22, height: 22,
                      image: AssetImage('assets/screenmeet.png')
                    )
                  ]
                )
              )
            )
          ),
        ]
      ),
    );
  }

  Widget listView(){
    var list = List<Widget>.generate(15, (i) => Container(
      width: 160.0,
      color: i % 2 == 0? Colors.black12: Colors.black38,
    ), growable: true);

    list.insert(2,
        ConfidentialWidget(
            Key("confidential"),
            Container(
              width: 160.0,
              color: Colors.orangeAccent,
            )
        )
    );

    return Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      //margin: EdgeInsets.symmetric(vertical: 10.0),
        child: ListView(
            scrollDirection: Axis.horizontal,
            children: list
        )
    );
  }
}