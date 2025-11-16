import 'package:flutter/material.dart';
import 'package:p2mobile/viewmodels/auth_viewmodel.dart';
import 'package:p2mobile/views/vehicles/vehicle_list_screen.dart'; // [NOVO] Import
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Principal'),
        // O ícone de sair da AppBar foi removido, pois agora está no Drawer
      ),
      // [ATUALIZAÇÃO] Usando o AppDrawer funcional
      drawer: const AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          // Permite rolar em telas menores
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                // [IMPORTANTE] Troque pelo nome exato do seu arquivo
                'assets/images/logo.png',
                height: 300,
                fit: BoxFit.cover,
                // O errorBuilder ainda é útil caso o path esteja errado
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    width: 250,
                    color: Colors.grey[200],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Erro ao carregar imagem',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Bem-vindo ao Gerenciador de Abastecimento!',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Use o menu lateral para gerenciar seus veículos e abastecimentos.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// [ATUALIZAÇÃO] Este é o Drawer funcional
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Gerenciador de Abastecimento',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ),

          // --- Item Meus Veículos (Funcional) ---
          ListTile(
            leading: const Icon(Icons.directions_car_outlined),
            title: const Text('Meus Veículos'),
            onTap: () {
              // 1. Fecha o Drawer
              Navigator.of(context).pop();
              // 2. [NOVO] Navega para a lista de veículos
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => VehicleListScreen()),
              );
            },
          ),

          // --- Item Registrar Abastecimento (Placeholder) ---
          ListTile(
            leading: const Icon(Icons.local_gas_station_outlined),
            title: const Text('Registrar Abastecimento'),
            onTap: () {
              // TODO: Implementar na Etapa 4
              Navigator.of(context).pop();
              // Mostrar um Snackbar temporário
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em desenvolvimento...')),
              );
            },
          ),

          // --- Item Histórico (Placeholder) ---
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Histórico de Abastecimentos'),
            onTap: () {
              // TODO: Implementar na Etapa 4
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em desenvolvimento...')),
              );
            },
          ),

          const Divider(), // Linha divisória
          // --- Item Sair (Funcional) ---
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Sair',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              // 1. Fecha o Drawer
              Navigator.of(context).pop();
              // 2. Faz o Logout
              context.read<AuthViewModel>().signOut();
            },
          ),
        ],
      ),
    );
  }
}
