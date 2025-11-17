import 'package:flutter/material.dart';
import 'package:p2mobile/views/refueling/add_fueling_screen.dart';
import 'package:p2mobile/views/refueling/fueling_history_screen.dart';
import 'package:p2mobile/viewmodels/auth_viewmodel.dart';
import 'package:p2mobile/views/vehicles/vehicle_list_screen.dart';
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
              'Fuel Manager',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ),

          // --- Item Meus Veículos (Da Etapa 3) ---
          ListTile(
            leading: const Icon(Icons.directions_car_outlined),
            title: const Text('Meus Veículos'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VehicleListScreen(),
                ),
              );
            },
          ),

          // --- [ATUALIZADO] Item Registrar Abastecimento (Funcional) ---
          ListTile(
            leading: const Icon(Icons.local_gas_station_outlined),
            title: const Text('Registrar Abastecimento'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  // Navega para o formulário
                  builder: (context) => const AddFuelingScreen(),
                ),
              );
            },
          ),

          // --- [ATUALIZADO] Item Histórico (Funcional) ---
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Histórico de Abastecimentos'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  // Navega para a lista de histórico
                  builder: (context) => const FuelingHistoryScreen(),
                ),
              );
            },
          ),

          const Divider(),

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
              Navigator.of(context).pop();
              context.read<AuthViewModel>().signOut();
            },
          ),
        ],
      ),
    );
  }
}
