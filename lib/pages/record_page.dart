import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderPage extends StatefulWidget {
  const AudioRecorderPage({Key? key}) : super(key: key);

  @override
  State<AudioRecorderPage> createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  final record = AudioRecorder();
  bool isRecording = false;
  String? filePath;

  Future<bool> checkPermissions() async {
    final hasPermission = await record.hasPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마이크 권한이 필요합니다.')),
      );
      return false;
    }
    return true;
  }

  Future<void> startRecording() async {
    if (!await checkPermissions()) return;

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/audio.m4a';

    try {
      await record.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      setState(() {
        isRecording = true;
        filePath = path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('녹음 시작 실패: $e')),
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await record.stop();
      setState(() {
        isRecording = false;
        filePath = path; // 녹음된 파일 경로 저장
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('녹음 완료: $path')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('녹음 중지 실패: $e')),
      );
    }
  }

  @override
  void dispose() {
    record.dispose(); // 반드시 리소스 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isRecording ? stopRecording : startRecording,
              child: Text(isRecording ? '녹음 중지' : '녹음 시작'),
            ),
            const SizedBox(height: 20),
            if (filePath != null)
              Text('녹음된 파일 경로:\n$filePath'),
          ],
        ),
      ),
    );
  }
}
