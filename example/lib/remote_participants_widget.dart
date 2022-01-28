
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:screenmeet_sdk_flutter/participant.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_parameters_manager.dart';
import 'package:screenmeet_sdk_flutter/screenmeet_plugin.dart';

///Widget showing remote participants tiles
///
/// It renders video from remote participants
/// It uses [Texture]. The video frames are supplied by swift SDK.
/// The implementation of the texture frames processing can be found at the native part (java, obj-c/swift) of the plugin
class RemoteParticipantsWidget extends StatefulWidget {

  const RemoteParticipantsWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RemoteParticipantsState();
  }

}

class RemoteParticipantsState extends State<RemoteParticipantsWidget> {

  //All participants of the call
  List<Participant> participants = List.empty();

  RemoteParticipantsState();

  void updateParticipantsState(List<Participant> newParticipants) {
    if (mounted) {
      setState(() {
        participants = newParticipants;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      this.participants = List.empty();
    });

    showCurrentParticipants();

    ScreenMeetPlugin().setParticipantsListener(listener: (List<Participant> participants) {
      updateParticipantsState(participants);
    });
  }

  void showCurrentParticipants() async {
    // Get all the participants currently connected to the call
    var response = await ScreenMeetPlugin().getParticipants();

    response.fold(
            (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.text))),
            (participants) => setState(() { this.participants = participants;})
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 520,
        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 0.86,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        children: participants.map((p) =>
            GridTile(child:
                Container(decoration: BoxDecoration(border: Border.all(width: 1.0, color: Colors.grey)),
                    child: Column(mainAxisSize: MainAxisSize.max,
                    children:
                    [Expanded(child: Texture(textureId: p.textureId)),
                      SizedBox(height: 6),
                            Row(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(p.mediaState.isSharingAudio ? Icons.mic:  Icons.mic_off, size: 15),
                                Icon(p.mediaState.isSharingVideo ? Icons.videocam:  Icons.videocam_off, size: 15),
                                Flexible(child: Padding(padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0), child: Text(p.name)))
                              ]
                            ),
                      SizedBox(height: 8)
                    ]
            )))).toList()));
  }
}
