import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VoiceMusicPlayer(),
    );
  }
}

class VoiceMusicPlayer extends StatefulWidget {
  @override
  _VoiceMusicPlayerState createState() => _VoiceMusicPlayerState();
}

class _VoiceMusicPlayerState extends State<VoiceMusicPlayer> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _command = "Say a song name...";
  final AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestPermissions();
  }

  // Request Microphone Permission
  void _requestPermissions() async {
    await Permission.microphone.request();
  }

  // Start Listening
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _command = result.recognizedWords;
          });
          _playSong(_command);
        },
      );
    } else {
      setState(() => _isListening = false);
    }
  }

  // Stop Listening
  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // Play Song Based on Voice Command
  void _playSong(String command) {
    Map<String, String> songMap = {
      "song one": "assets/audio/sample.mp3",
    };

    String? songPath = songMap[command.toLowerCase()];
    if (songPath != null) {
      _audioPlayer.open(
        Audio(songPath),
        autoStart: true,
      );
      setState(() {
        _command = "Playing: $command";
      });
    } else {
      setState(() {
        _command = "Song not found!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Voice Music Player")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _command,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            onPressed: _isListening ? _stopListening : _startListening,
            backgroundColor: _isListening ? Colors.red : Colors.green,
            child: Icon(_isListening ? Icons.mic_off : Icons.mic),
          ),
        ],
      ),
    );
  }
}
