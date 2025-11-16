import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p2mobile/data/services/auth_service.dart';
import 'package:p2mobile/views/auth/login_screen.dart';
import 'package:p2mobile/views/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Pegamos o AuthService (via Provider) que foi injetado no main.dart
    final authService = context.watch<AuthService>();

    // Usamos um StreamBuilder para ouvir as mudanças de autenticação
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Se estiver aguardando a conexão
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o snapshot tiver dados, o usuário está logado
        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // Se não tiver dados, o usuário não está logado
        return const LoginScreen();
      },
    );
  }
}
