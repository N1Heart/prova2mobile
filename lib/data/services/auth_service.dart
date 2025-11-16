import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para ouvir o estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obter o usuário atual
  User? get currentUser => _auth.currentUser;

  // Login com E-mail e Senha
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Lança a exceção para ser tratada no ViewModel
      throw _handleAuthException(e);
    }
  }

  // Cadastro com E-mail e Senha
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper para tratar erros do Firebase e retornar mensagens amigáveis
  String _handleAuthException(FirebaseAuthException e) {
    debugPrint('Erro de autenticação: ${e.code} - ${e.message}');
    switch (e.code) {
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'user-disabled':
        return 'Este usuário foi desabilitado.';
      case 'user-not-found':
        return 'Usuário não encontrado. Verifique o e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}
