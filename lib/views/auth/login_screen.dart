import 'package:flutter/material.dart';
import 'package:p2mobile/viewmodels/auth_viewmodel.dart';
import 'package:p2mobile/views/auth/register_screen.dart'; // Importe a tela de registro
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu e-mail.';
    }
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
      return 'Por favor, insira um e-mail válido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha.';
    }
    if (value.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres.';
    }
    return null;
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      // Chama o ViewModel para fazer o login
      context.read<AuthViewModel>().signIn(
        context,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pega o status do ViewModel
    final authStatus = context.watch<AuthViewModel>().status;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo ou Imagem (Aqui você pode adicionar a imagem do Endrick ou logo)
                  Icon(
                    Icons.directions_car_filled,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bem-vindo de volta!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(
                    'Acesse sua conta para continuar',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),

                  // Campo E-mail
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),

                  // Campo Senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 32),

                  // Botão de Login
                  ElevatedButton(
                    onPressed: authStatus == AuthStatus.loading
                        ? null // Desabilita o botão se estiver carregando
                        : _submitLogin,
                    child: authStatus == AuthStatus.loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text('Entrar'),
                  ),
                  const SizedBox(height: 24),

                  // Navegação para Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem uma conta?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Cadastre-se'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
