import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:p2mobile/data/services/auth_service.dart';
import 'package:p2mobile/data/services/firestore_service.dart';
import 'package:p2mobile/viewmodels/auth_viewmodel.dart';
import 'package:p2mobile/viewmodels/fueling_viewmodel.dart';
import 'package:p2mobile/viewmodels/vehicle_viewmodel.dart';
import 'package:p2mobile/views/auth/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- SERVIÇOS ---
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),

        // --- VIEW MODELS ---
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
        ChangeNotifierProvider<VehicleViewModel>(
          create: (context) =>
              VehicleViewModel(context.read<FirestoreService>()),
        ),
        // [NOVO] Provê o FuelingViewModel
        ChangeNotifierProvider<FuelingViewModel>(
          create: (context) =>
              FuelingViewModel(context.read<FirestoreService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Gerenciador de Abastecimento',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}
