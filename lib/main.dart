import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:p2mobile/data/services/auth_service.dart';
import 'package:p2mobile/data/services/firestore_service.dart'; // [NOVO] Import
import 'package:p2mobile/viewmodels/auth_viewmodel.dart';
import 'package:p2mobile/viewmodels/vehicle_viewmodel.dart'; // [NOVO] Import
import 'package:p2mobile/views/auth/auth_wrapper.dart';
import 'package:provider/provider.dart';
//import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

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
        // --- SERVIÇOS ---
        // Serviço de Autenticação (da Etapa 2)
        Provider<AuthService>(create: (_) => AuthService()),

        // [NOVO] Provê o FirestoreService
        // Este serviço falará com o banco de dados
        Provider<FirestoreService>(create: (_) => FirestoreService()),

        // --- VIEW MODELS ---
        // ViewModel de Autenticação (da Etapa 2)
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),

        // [NOVO] Provê o VehicleViewModel
        // Note que ele DEPENDE do FirestoreService (usamos o 'context.read')
        ChangeNotifierProvider<VehicleViewModel>(
          create: (context) =>
              VehicleViewModel(context.read<FirestoreService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Fuel Manager',
        debugShowCheckedModeBanner: false,
        //theme: AppTheme.lightTheme,
        home: const AuthWrapper(), // O AuthWrapper decide qual tela mostrar
      ),
    );
  }
}
