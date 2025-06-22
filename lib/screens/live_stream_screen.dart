import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

const String appId = "4bfb365aac8742c7ab1984b942325003"; // 🔁 Replace with your real App ID
const String channelName = "gammer_channel";
const String token = '';
 // Use null for testing
const int uid = 0;

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  late RtcEngine _engine;
  bool _joined = false;
  int _remoteUid = 0;
  bool _isBroadcaster = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        setState(() {
          _joined = true;
        });
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        setState(() {
          _remoteUid = remoteUid;
        });
      },
      onUserOffline: (connection, remoteUid, reason) {
        setState(() {
          _remoteUid = 0;
        });
      },
    ));

    await _engine.enableVideo();
  }

  Future<void> _joinChannel() async {
    await _engine.setClientRole(
      role: _isBroadcaster
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );

    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> _leaveChannel() async {
    await _engine.leaveChannel();
    setState(() {
      _joined = false;
      _remoteUid = 0;
    });
  }

  @override
  void dispose() {
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream'),
        actions: [
          Switch(
            value: _isBroadcaster,
            onChanged: (val) {
              setState(() {
                _isBroadcaster = val;
              });
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.blueGrey,
          ),
        ],
      ),
      body: Center(
        child: _joined
            ? Stack(
                children: [
                  _isBroadcaster
                      ? const Center(child: Text("You are live"))
                      : _remoteUid != 0
                          ? AgoraVideoView(
                              controller: VideoViewController.remote(
                                rtcEngine: _engine,
                                canvas: VideoCanvas(uid: _remoteUid),
                                connection: const RtcConnection(channelId: channelName),
                              ),
                            )
                          : const Center(child: Text("Waiting for host...")),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ElevatedButton(
                      onPressed: _leaveChannel,
                      child: const Text('Leave Stream'),
                    ),
                  )
                ],
              )
            : ElevatedButton(
                onPressed: _joinChannel,
                child: Text(_isBroadcaster ? 'Start Live Stream' : 'Join Stream'),
              ),
      ),
    );
  }
}
