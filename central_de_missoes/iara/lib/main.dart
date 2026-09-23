import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'providers/missao_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CentralMissoesApp());
}

class CentralMissoesApp extends StatelessWidget {
  const CentralMissoesApp({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => MissaoProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Central de Missões',
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
          home: const HomePage(),
        ),
      );
}
