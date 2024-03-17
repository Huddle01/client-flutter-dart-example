import 'package:flutter/material.dart';
import 'package:huddle01_flutter_client/huddle_client.dart';
import 'package:p2p_example_app/screens/home_screen.dart';

class MeetingScreen extends StatefulWidget {
  final HuddleClient huddleClient;
  const MeetingScreen({super.key, required this.huddleClient});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  bool isAudioOn = false;
  bool isVideoOn = false;

  RTCVideoRenderer? localVideoRenderer;

  @override
  void dispose() {
    localVideoRenderer?.dispose();
    peersNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("p2p call app"),
        ),
        body: ValueListenableBuilder(
          valueListenable: peersNotifier,
          builder: (_, __, ___) {
            return Column(
              children: [
                Expanded(
                  child: Stack(children: [
                    peersNotifier.value.isNotEmpty &&
                            peersNotifier.value.values.first != null
                        ? RTCVideoView(
                            peersNotifier.value.values.first,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                            mirror: true,
                            filterQuality: FilterQuality.low,
                          )
                        : peersNotifier.value.keys.isNotEmpty
                            ? Center(
                                child: Text(
                                  peersNotifier.value.keys.first,
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Text("no peers 🥲"),
                              ),
                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: SizedBox(
                        height: 150,
                        width: 120,
                        child: localVideoRenderer != null
                            ? RTCVideoView(
                                localVideoRenderer!,
                                objectFit: RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                              )
                            : Container(),
                      ),
                    )
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(isAudioOn ? Icons.mic : Icons.mic_off),
                        onPressed: _toggleMic,
                      ),
                      IconButton(
                          icon: Icon(
                              isVideoOn ? Icons.videocam : Icons.videocam_off),
                          onPressed: _toggleCam),
                      IconButton(
                        icon: const Icon(Icons.call_end),
                        iconSize: 30,
                        onPressed: () {
                          widget.huddleClient.leaveRoom();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _toggleMic() async {
    !isAudioOn
        ? await widget.huddleClient.localPeer.enableAudio()
        : widget.huddleClient.localPeer.disableAudio();
    setState(() {
      isAudioOn = !isAudioOn;
    });
  }

  void _toggleCam() async {
    if (!isVideoOn) {
      await widget.huddleClient.localPeer.enableVideo().then((value) =>
          localVideoRenderer = widget.huddleClient.localPeer.videoRenderer);
    } else {
      widget.huddleClient.localPeer.disableVideo();
      localVideoRenderer = null;
    }
    setState(() {
      isVideoOn = !isVideoOn;
    });
  }
}
