import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'core/config/merchant_config.dart';

// Standard Entry point (For CI/CD)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies(isMock: false); // Use Real Environment
  runApp(const WhiteLabelApp());
}

class WhiteLabelApp extends StatelessWidget {
  const WhiteLabelApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the injected config
    final config = sl<MerchantConfig>();

    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Dynamic Primary Color
        primaryColor: _hexToColor(config.theme.primaryColor),
        scaffoldBackgroundColor: _hexToColor(config.theme.secondaryColor),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(config.appName), // Dynamic Title
          backgroundColor: _hexToColor(config.theme.primaryColor),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome to ${config.appName}"),
              if (config.features.useNativeCheckout)
                const Chip(label: Text("Native Checkout Enabled")),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}