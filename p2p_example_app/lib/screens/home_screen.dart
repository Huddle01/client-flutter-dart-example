import 'package:flutter/material.dart';
import 'package:huddle01_flutter_client/huddle_client.dart';
import 'package:p2p_example_app/screens/meeting_screen.dart';

import '../utils/common.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HuddleClient huddleClient = HuddleClient(
    projectId: 'YOUR_PROJECT_ID',
  );

  String roomId = const String.fromEnvironment("ROOM_ID");
  String token = const String.fromEnvironment("TOKEN");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: ElevatedButton(
          onPressed: () async {
            await huddleClient.joinRoom(roomId, token);
            if (roomId.isNotEmpty && token.isNotEmpty) {
              screenReplacementTimer(context, 0,
                  screen: MeetingScreen(
                    huddleClient: huddleClient,
                  ));
            }
          },
          child: const Text("Join Room"),
        ),
      )),
    );
  }
}
