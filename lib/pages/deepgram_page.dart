import 'package:flutter/material.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:record/record.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepgramPage extends StatefulWidget {
  const DeepgramPage({super.key});

  @override
  State<DeepgramPage> createState() => _DeepgramPageState();
}

class _DeepgramPageState extends State<DeepgramPage> {
  final mic = AudioRecorder();
  final apiKey = dotenv.get("DEEPGRAM_API_KEY");
  late Deepgram deepgram;
  bool isRecording = false;
  String transcribedText = '';
  String currentTranscript = '';

  @override
  void initState() {
    super.initState();
    deepgram = Deepgram(apiKey, baseQueryParams: {
      'model': 'nova-2-general',
      'language': 'en',
      'encoding': 'linear16',
      'sample_rate': 16000,
    });
  }

  Future<void> startRecording() async {
    if (await mic.hasPermission()) {
      final audioStream = await mic.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      setState(() {
        isRecording = true;
        transcribedText = '듣고 있습니다...\n';
        currentTranscript = '';
      });

      final stream = deepgram.transcribeFromLiveAudioStream(audioStream);
      stream.listen((res) {
        setState(() {
          currentTranscript = res.transcript ?? '';
          if (currentTranscript.isNotEmpty) {
            transcribedText += '$currentTranscript\n';
          }
        });
      });
    }
  }

  Future<void> stopRecording() async {
    await mic.stop();
    setState(() {
      isRecording = false;
      if (currentTranscript.isNotEmpty) {
        transcribedText += '녹음이 종료되었습니다.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('음성 인식 (Deepgram)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Text(
                    transcribedText,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isRecording ? stopRecording : startRecording,
              icon: Icon(isRecording ? Icons.stop : Icons.mic),
              label: Text(isRecording ? '녹음 중지' : '녹음 시작'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mic.dispose();
    super.dispose();
  }
} 