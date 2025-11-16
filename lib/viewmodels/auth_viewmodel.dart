import 'package:flutter/material.dart';
import 'package:p2mobile/data/services/auth_service.dart';

// Enum para gerenciar os estados da UI de forma clara
enum AuthStatus {
  uninitialized,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.uninitialized;
  String _errorMessage = '';

  // Getters (para a UI poder "ler" o estado)
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;

  // Função genérica para login (continua a mesma)
  Future<bool> _authenticate(
    Future<void> Function() authMethod,
    BuildContext context,
  ) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await authMethod();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();

      _showErrorSnackbar(context, _errorMessage);
      return false;
    }
  }

  // Método de Login (continua igual)
  Future<void> signIn(
    BuildContext context,
    String email,
    String password,
  ) async {
    await _authenticate(
      () => _authService.signInWithEmail(email, password),
      context,
    );
  }

  // [AJUSTE AQUI] Método de Cadastro com a nova lógica
  Future<void> signUp(
    BuildContext context,
    String email,
    String password,
  ) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // 1. Tenta criar o usuário
      await _authService.signUpWithEmail(email, password);

      // 2. [NOVA LÓGICA] Faz logout imediatamente
      await _authService.signOut();

      // 3. Avisa a UI que está desautenticado (para o wrapper não mudar)
      _status = AuthStatus.unauthenticated;
      notifyListeners();

      // 4. [NOVA LÓGICA] Mostra um Snackbar de SUCESSO
      _showSuccessSnackbar(
        context,
        "Cadastro realizado com sucesso! Faça o login.",
      );

      // 5. [NOVA LÓGICA] Navega de volta para o LoginScreen
      // (Fecha a tela de RegisterScreen)
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // 6. Se deu erro no cadastro, mostra o erro
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      _showErrorSnackbar(context, _errorMessage);
    }
  }

  // Método de Logout (continua igual)
  Future<void> signOut() async {
    await _authService.signOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Helper para mostrar o Snackbar de erro
  void _showErrorSnackbar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // [AJUSTE AQUI] Novo helper para mostrar Snackbar de Sucesso
  void _showSuccessSnackbar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green[600], // Cor de sucesso
        ),
      );
    }
  }
}
