import 'package:flutter/material.dart';
import 'package:p2mobile/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validadores (Email igual ao do LoginScreen)
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha.';
    }
    if (value != _passwordController.text) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  void _submitRegister() {
    if (_formKey.currentState!.validate()) {
      // Chama o ViewModel para fazer o cadastro
      context.read<AuthViewModel>().signUp(
        context,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthViewModel>().status;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
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
                  Text(
                    'Crie sua conta',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(
                    'Preencha os dados para começar',
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
                      labelText: 'Senha (mín. 6 caracteres)',
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
                  const SizedBox(height: 20),

                  // Campo Confirmar Senha
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isPasswordVisible,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Senha',
                      prefixIcon: Icon(Icons.lock_reset),
                    ),
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 32),

                  // Botão de Cadastrar
                  ElevatedButton(
                    onPressed: authStatus == AuthStatus.loading
                        ? null
                        : _submitRegister,
                    child: authStatus == AuthStatus.loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text('Cadastrar'),
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
