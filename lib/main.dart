import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const VoiceTestApp());

class VoiceTestApp extends StatelessWidget {
  const VoiceTestApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xFF0E5C5C), useMaterial3: true),
      home: const VoiceHome(),
    );
  }
}

class VoiceHome extends StatefulWidget {
  const VoiceHome({super.key});
  @override
  State<VoiceHome> createState() => _VoiceHomeState();
}

class _VoiceHomeState extends State<VoiceHome> {
  // This channel talks to native Android speech recognition (no extra package).
  static const _channel = MethodChannel('bharatgps/voice');

  bool _listening = false;
  String _heard = '';
  String _action = '';
  String _status = 'Tap the mic and speak a command';

  @override
  void initState() {
    super.initState();
    // native sends results back through this handler
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onResult':
          final text = (call.arguments ?? '').toString();
          setState(() {
            _heard = text;
            _listening = false;
            _action = _parse(text);
            _status = 'Done';
          });
          break;
        case 'onError':
          setState(() {
            _listening = false;
            _status = 'Error: ${call.arguments}';
          });
          break;
        case 'onReady':
          setState(() => _status = 'Listening… speak now');
          break;
      }
      return null;
    });
  }

  Future<void> _startListening() async {
    setState(() {
      _listening = true;
      _heard = '';
      _action = '';
      _status = 'Starting…';
    });
    try {
      await _channel.invokeMethod('listen');
    } on PlatformException catch (e) {
      setState(() {
        _listening = false;
        _status = 'Could not start: ${e.message}';
      });
    }
  }

  // simple keyword command parsing (same logic we'll use in the real app)
  String _parse(String raw) {
    final t = raw.toLowerCase().trim();
    if (t.isEmpty) return 'Heard nothing';
    if (t.contains('dashboard') || t.contains('home')) return '➡️ OPEN DASHBOARD';
    if (t.contains('map') || t.contains('live') || t.contains('track')) return '➡️ OPEN LIVE MAP';
    if (t.contains('activity') || t.contains('report')) return '➡️ OPEN ACTIVITY';
    if (t.contains('alert') || t.contains('notification')) return '➡️ OPEN ALERTS';
    if (t.contains('profile') || t.contains('account')) return '➡️ OPEN PROFILE';
    if (t.contains('search') || t.contains('find') || t.contains('vehicle') || RegExp(r'[0-9]').hasMatch(t)) {
      final q = _digits(t.replaceAll(RegExp(r'(search|for|find|vehicle|show|the)'), '').trim());
      return '🔍 SEARCH VEHICLE: "$q"';
    }
    return '❓ Unknown command';
  }

  String _digits(String s) {
    const m = {'zero':'0','one':'1','two':'2','three':'3','four':'4','five':'5','six':'6','seven':'7','eight':'8','nine':'9'};
    var out = s;
    m.forEach((w, d) => out = out.replaceAll(RegExp('\\b$w\\b'), d));
    return out.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0E5C5C);
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F2),
      appBar: AppBar(backgroundColor: teal, foregroundColor: Colors.white, title: const Text('Voice Command Test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Try saying:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('"open dashboard" · "live track" · "show alerts"\n"search 420" · "find vehicle 5567"',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _listening ? null : _startListening,
              child: Container(
                width: 110, height: 110,
                decoration: BoxDecoration(color: _listening ? Colors.red : teal, shape: BoxShape.circle, boxShadow: [BoxShadow(color: (_listening ? Colors.red : teal).withOpacity(.4), blurRadius: 20)]),
                child: Icon(_listening ? Icons.mic : Icons.mic_none, color: Colors.white, size: 50),
              ),
            ),
            const SizedBox(height: 24),
            Text(_status, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 30),
            if (_heard.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('HEARD:', style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('"$_heard"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  const Text('ACTION:', style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_action, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: teal)),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}
