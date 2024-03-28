// ignore_for_file: use_build_context_synchronously

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

  List<MediaDeviceInfo>? audioInput;
  List<MediaDeviceInfo>? audioOutput;
  @override
  void initState() {
    super.initState();
    peersNotifier.addListener(_updatePeers);
  }

  void _updatePeers() {
    setState(() {});
  }

  @override
  void dispose() {
    localVideoRenderer?.dispose();
    peersNotifier.removeListener(_updatePeers);
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
          title: const Text("one-2-one call app 📞"),
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
                    _localVideoView()
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onLongPress: () => _onMicBtnLongPressed(context),
                        child: IconButton(
                          icon: Icon(isAudioOn ? Icons.mic : Icons.mic_off),
                          onPressed: _toggleMic,
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                              isVideoOn ? Icons.videocam : Icons.videocam_off),
                          onPressed: _toggleCam),
                      IconButton(
                        icon: const Icon(
                          Icons.call_end,
                          color: Colors.red,
                        ),
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

  Widget _localVideoView() {
    return Positioned(
      right: 20,
      bottom: 20,
      child: SizedBox(
        height: 150,
        width: 120,
        child: localVideoRenderer != null
            ? RTCVideoView(
                localVideoRenderer!,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
            : Container(),
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

  void _onMicBtnLongPressed(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("change audio options"),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              child: const Text(
                'CHANGE OUTPUT AUDIO DEVICE',
              ),
              onPressed: () async {
                audioOutput = await widget.huddleClient.localPeer.deviceHandler
                    .getAudioOutputDevices();
                if (!mounted) return;
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Select output Audio Device"),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SingleChildScrollView(
                          reverse: true,
                          child: Column(
                            children: audioOutput!
                                .map(
                                  (e) => ElevatedButton(
                                    child: Text(e.label),
                                    onPressed: () => {
                                      widget
                                          .huddleClient.localPeer.deviceHandler
                                          .switchAudioDevice(e),
                                      Navigator.pop(context)
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
