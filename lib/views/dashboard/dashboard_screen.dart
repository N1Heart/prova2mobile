import 'package:flutter/material.dart';
import 'package:p2mobile/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              // Chama o método de signOut do ViewModel
              context.read<AuthViewModel>().signOut();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(), // Vamos criar o Drawer na próxima etapa
      body: const Center(child: Text('Bem-vindo! Você está logado.')),
    );
  }
}

// Placeholder do Drawer (vamos implementar na Etapa 5)
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue, // Usar o tema
            ),
            child: Text('Fuel Manager'),
          ),
          ListTile(title: Text('Item 1')),
        ],
      ),
    );
  }
}
