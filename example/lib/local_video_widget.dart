import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:screenmeet_sdk_flutter/local_video.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_parameters_manager.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_plugin.dart';

/// A widget doing the local video preview
///
/// It renders your own video for preview when on call.
/// It uses [Texture]. The video frames are supplied by swift SDK.
/// The implementation of the texture frames processing can be found at the native part (java, obj-c/swift) of the plugin
class LocalVideoWidget extends StatefulWidget {

  LocalVideoWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LocalVideoState();
  }

}

class LocalVideoState extends State<LocalVideoWidget> {
  /// Width of the local video are that renders preview from the camera. Can be adjsuted as  per UI requirements
  final double localVideoWidth = 100.0;

  /// Height of the local video are that renders preview from the camera. Can be adjsuted as  per UI requirements
  final double localVideoHeight = 136.0;

  /// Number of participants on the call. If it is 0 (no one except you on the call), local video is stretched to full screen
  /// If participants > 0, it will be shown as small rectengular view at the top right
  int numberOfParticipants = 0;

  /// A local video meta data objects. Basically it's just the id of the texture and a boolean flag that indicates whether video is was turned on
  LocalVideo localVideo = LocalVideo.stopped();

  LocalVideoState();

  void updateLocalVideoState(LocalVideo localVideo) {
    setState(() {
      this.localVideo = localVideo;
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      this.localVideo = LocalVideo.stopped();
    });

    updateCurrentLocalVideo();

    ///  Start receiving events from native SDK about the state of the local video
    ScreenMeetPlugin().setLocalVideoListener(listener: (LocalVideo localVideo) {
      updateLocalVideo(localVideo);
    });
  }

  void updateLocalVideo(LocalVideo localVideo) async {
    /// Get number of participants to know if we show local video fullscreen (in case no one's on the call yet) or as small view
    var response = await ScreenMeetPlugin().getParticipants();

    response.fold(
            (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.text))),
            (participants) =>setState(() { this.numberOfParticipants = participants.length;})
    );

    updateLocalVideoState(localVideo);
  }

  void updateCurrentLocalVideo() async {
    /// Get the information about local video from native SDK
    var response = await ScreenMeetPlugin().getLocalVideo();

    response.fold(
            (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.text))),
            (localVideo) =>setState(() {
              this.localVideo = localVideo;
            })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(height: 580,  width: MediaQuery.of(context).size.width - 20, child:
      Stack(children: [
        Container(child: (numberOfParticipants == 0 && localVideo != null && localVideo.isOn && localVideo.textureId != -1) ? new Texture(textureId: localVideo.textureId) : Container(color: Colors.blue, height: 0)),
        Align(alignment: Alignment.topRight, child: Container( margin: const EdgeInsets.only(left: 0.0, right: 0.0), height: localVideoHeight, width:localVideoWidth,
            child: Stack(children: [
              (numberOfParticipants > 0 && localVideo != null && localVideo.isOn && localVideo.textureId != -1) ?
              Container(height: localVideoHeight, width:localVideoWidth, child: new Texture(textureId: localVideo.textureId)) : SizedBox(height: localVideoHeight),

              (numberOfParticipants > 0 && localVideo != null && localVideo.isOn && localVideo.textureId != -1) ?
              Align(alignment: Alignment.topRight, child:
              IconButton(padding: const EdgeInsets.all(0.0), onPressed: () async {
                await ScreenMeetPlugin().changeVideoSource();
              },
                icon: Icon(Icons.flip_camera_android, size: 22, color: CupertinoColors.systemGrey4,),

              )
              )  : SizedBox(height: 22)
            ]
            )))
      ])
    );
  }
}
