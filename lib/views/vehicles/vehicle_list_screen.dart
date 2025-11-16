import 'package:flutter/material.dart';
import 'package:p2mobile/data/models/vehicle_model.dart';
import 'package:p2mobile/core/utils/fuel_type_enum.dart'; // Importa o Enum
import 'package:p2mobile/viewmodels/vehicle_viewmodel.dart';
import 'package:p2mobile/views/vehicles/add_vehicle_screen.dart'; // Tela que vamos criar
import 'package:provider/provider.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pega o ViewModel (apenas para o delete, o stream é ouvido abaixo)
    final viewModel = context.read<VehicleViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Veículos')),
      // StreamBuilder ouve o stream de veículos em tempo real
      body: StreamBuilder<List<Vehicle>>(
        stream: context.watch<VehicleViewModel>().vehiclesStream,
        builder: (context, snapshot) {
          // Estado de Carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estado de Erro
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao buscar veículos: ${snapshot.error}'),
            );
          }

          // Estado de Sucesso, mas sem dados
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Nenhum veículo cadastrado.\nToque no "+" para adicionar seu primeiro veículo.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
              ),
            );
          }

          // Estado de Sucesso com dados
          final vehicles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 8.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 16.0,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(50),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.directions_car),
                  ),
                  title: Text(
                    '${vehicle.marca} ${vehicle.modelo}',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                  subtitle: Text(
                    'Placa: ${vehicle.placa} | Ano: ${vehicle.ano}\nComb.: ${vehicle.tipoCombustivel.displayName}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () {
                      // Confirmação antes de excluir
                      _showDeleteConfirmation(context, viewModel, vehicle);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      // Botão Flutuante para adicionar
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddVehicleScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Diálogo de confirmação para excluir
  void _showDeleteConfirmation(
    BuildContext context,
    VehicleViewModel viewModel,
    Vehicle vehicle,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Tem certeza que deseja excluir o veículo ${vehicle.marca} ${vehicle.modelo} (Placa ${vehicle.placa})?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha o diálogo
              },
            ),
            TextButton(
              child: Text(
                'Excluir',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () {
                // Chama o ViewModel para excluir
                if (vehicle.id != null) {
                  viewModel.deleteVehicle(context, vehicle.id!);
                }
                Navigator.of(dialogContext).pop(); // Fecha o diálogo
              },
            ),
          ],
        );
      },
    );
  }
}
