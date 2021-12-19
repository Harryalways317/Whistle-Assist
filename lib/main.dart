import 'package:flutter/material.dart';
import 'package:tflite_audio/tflite_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _sound = "Press the button to start";
  bool _recording = false;
  late Stream<Map<dynamic, dynamic>> result;

  @override
  void initState() {
    super.initState();
    TfliteAudio.loadModel(
        inputType: 'rawAudio',
        model: 'assets/soundclassifier.tflite',
        label: 'assets/labels.txt',
        numThreads: 1,
        isAsset: true);
  }

  void _recorder() {
    String recognition = "";
    if (!_recording) {
      setState(() => _recording = true);
      result = TfliteAudio.startAudioRecognition(
        numOfInferences: 1,
        // inputType: 'rawAudio',
        sampleRate: 44100,
        recordingLength: 44032,
        bufferSize: 22016,
      );
      result.listen((event) {
        recognition = event["recognitionResult"];
      }).onDone(() {
        setState(() {
          _recording = false;
          _sound = recognition.split(" ")[1];
        });
      });
    }
  }

  void _stop() {
    TfliteAudio.stopAudioRecognition();
    setState(() => _recording = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage("assets/background.jpg"),
            //   fit: BoxFit.cover,
            // ),
            ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  "What's this sound?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              MaterialButton(
                onPressed: _recorder,
                color: _recording ? Colors.grey : Colors.pink,
                textColor: Colors.white,
                child: Icon(Icons.mic, size: 60),
                shape: CircleBorder(),
                padding: EdgeInsets.all(25),
              ),
              Text(
                '$_sound',
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
