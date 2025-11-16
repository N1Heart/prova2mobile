import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:p2mobile/data/services/auth_service.dart';
import 'package:p2mobile/viewmodels/auth_viewmodel.dart';
import 'package:p2mobile/views/auth/auth_wrapper.dart';
import 'package:provider/provider.dart';
//import 'core/theme/app_theme.dart';
import 'firebase_options.dart'; // Gerado pelo flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provê o serviço de autenticação
        Provider<AuthService>(create: (_) => AuthService()),

        // Provê o ViewModel de autenticação
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'Fuel Manager',
        debugShowCheckedModeBanner: false,
        //theme: AppTheme.lightTheme,

        // O AuthWrapper agora decide qual tela mostrar
        home: const AuthWrapper(),
      ),
    );
  }
}
