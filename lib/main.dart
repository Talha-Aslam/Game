import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/audio/audio_service.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF06060E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize cinematic audio system
  await AudioService.instance.init();

  runApp(const ProviderScope(child: SplashGate(child: MafiaAtCityApp())));
}

class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
  static const _minDuration = Duration(milliseconds: 1200);
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Delay the initialization slightly to allow the widget tree to finish building
    // and prevent the "modify a provider while the widget tree was building" error.
    await Future.microtask(() {});

    // Start minimum splash timer
    final splashTimer = Future.delayed(_minDuration);

    // Check auth status
    await ref.read(authProvider.notifier).checkAuth();

    // Wait for minimum duration to complete
    await splashTimer;

    if (!mounted) return;
    setState(() => _showSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) {
      return widget.child;
    }

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(color: Color(0xFF101320)),
          child: SizedBox.expand(
            child: Image(
              image: AssetImage('assets/images/splash_1.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
