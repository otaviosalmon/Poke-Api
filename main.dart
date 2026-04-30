import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// firebase_options.dart é gerado automaticamente pelo FlutterFire CLI.
// Execute: dart pub global activate flutterfire_cli
//          flutterfire configure
// Veja o README para instruções completas.
import 'firebase_options.dart';
import 'screens/home_screen.dart';

// main() é async porque precisamos aguardar o Firebase inicializar
// ANTES de renderizar qualquer widget — ordem importa aqui.
void main() async {
  // Garante que os bindings do Flutter estão prontos antes de chamar código nativo.
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCC0000),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
