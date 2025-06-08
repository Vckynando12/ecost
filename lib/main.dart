import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecost/providers/transaction_provider.dart';
import 'package:ecost/providers/debt_provider.dart';
import 'package:ecost/screens/splash_screen.dart';
import 'package:ecost/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = TransactionProvider();
            // Initialize the provider
            provider.init();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => DebtProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'E-cost',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
