import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const HeyGoogleTest());

class HeyGoogleTest extends StatelessWidget {
  const HeyGoogleTest({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xFF0E5C5C), useMaterial3: true),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const _channel = MethodChannel('bharatgps/assistant');
  String _command = 'none yet';
  String _screen = 'Home';

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onCommand') {
        final cmd = (call.arguments ?? '').toString();
        setState(() { _command = cmd; _screen = _route(cmd); });
      }
      return null;
    });
    _getInitial();
  }

  Future<void> _getInitial() async {
    try {
      final cmd = await _channel.invokeMethod<String>('getLaunchCommand');
      if (cmd != null && cmd.isNotEmpty) {
        setState(() { _command = cmd; _screen = _route(cmd); });
      }
    } catch (_) {}
  }

  String _route(String cmd) {
    final c = cmd.toLowerCase();
    if (c.contains('map') || c.contains('track')) return 'LIVE MAP';
    if (c.contains('alert')) return 'ALERTS';
    if (c.contains('activity') || c.contains('report')) return 'ACTIVITY';
    if (c.contains('dashboard') || c.contains('home')) return 'DASHBOARD';
    return 'DASHBOARD (default)';
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0E5C5C);
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F2),
      appBar: AppBar(backgroundColor: teal, foregroundColor: Colors.white, title: const Text('Hey Google Test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.assistant, size: 70, color: teal),
          const SizedBox(height: 20),
          const Text('Say to Google Assistant:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            '"Hey Google, open Hey Google Test"\n\nThen the shortcuts:\n"Open Map on Hey Google Test"\n"Show Alerts on Hey Google Test"',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('COMMAND RECEIVED:', style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(_command, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              const Text('WOULD OPEN:', style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(_screen, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: teal)),
            ]),
          ),
        ]),
      ),
    );
  }
}
