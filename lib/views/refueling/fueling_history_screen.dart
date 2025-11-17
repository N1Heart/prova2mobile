import 'package:flutter/material.dart';
import 'package:p2mobile/data/models/fueling_model.dart';
import 'package:p2mobile/data/models/vehicle_model.dart'; // Import Vehicle
import 'package:p2mobile/viewmodels/fueling_viewmodel.dart';
import 'package:p2mobile/viewmodels/vehicle_viewmodel.dart'; // Import VehicleViewModel
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FuelingHistoryScreen extends StatelessWidget {
  const FuelingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<FuelingViewModel>();

    // Precisamos do VehicleViewModel para "traduzir" o veiculoId em um nome
    final vehicleViewModel = context.read<VehicleViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Abastecimentos')),
      body: StreamBuilder<List<Fueling>>(
        stream: context.watch<FuelingViewModel>().fuelingStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao buscar histórico: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Nenhum abastecimento registrado.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
              ),
            );
          }

          final fuelings = snapshot.data!;

          // O Stream de Veículos é necessário para mostrar o nome do carro
          // Usamos um StreamBuilder aninhado para garantir que temos os veículos
          return StreamBuilder<List<Vehicle>>(
            stream: vehicleViewModel.vehiclesStream,
            builder: (context, vehicleSnapshot) {
              // Mapa para facilitar a busca do nome do veículo (ID -> Nome)
              final vehicleMap = <String, String>{};
              if (vehicleSnapshot.hasData) {
                for (var v in vehicleSnapshot.data!) {
                  vehicleMap[v.id!] = '${v.marca} ${v.modelo}';
                }
              }
              // Se os veículos ainda estão carregando, mostramos um loading simples
              if (vehicleSnapshot.connectionState == ConnectionState.waiting &&
                  vehicleMap.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: fuelings.length,
                itemBuilder: (context, index) {
                  final fueling = fuelings[index];

                  // Formata os dados para exibição
                  final String vehicleName =
                      vehicleMap[fueling.veiculoId] ?? 'Veículo Excluído';
                  final String formattedDate = DateFormat(
                    'dd/MM/yyyy',
                  ).format(fueling.data.toDate());
                  final String formattedLiters =
                      '${fueling.quantidadeLitros.toStringAsFixed(2)} L';
                  final String formattedValue =
                      'R\$ ${fueling.valorPago.toStringAsFixed(2)}';
                  final String formattedKm = '${fueling.quilometragem} km';

                  // Formata o consumo
                  final String formattedConsumo;
                  if (fueling.consumo == null || fueling.consumo == 0) {
                    formattedConsumo = '-- km/L'; // Primeiro abastecimento
                  } else {
                    formattedConsumo =
                        '${fueling.consumo!.toStringAsFixed(2)} km/L';
                  }

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
                        ).colorScheme.secondary.withAlpha(50),
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        child: const Icon(Icons.local_gas_station_outlined),
                      ),
                      title: Text(
                        '$vehicleName - $formattedDate',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      subtitle: Text(
                        '$formattedLiters | $formattedValue | $formattedKm\nConsumo: $formattedConsumo',
                      ),
                      isThreeLine: true,

                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () {
                          _showDeleteConfirmation(context, viewModel, fueling);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Diálogo de confirmação para excluir
  void _showDeleteConfirmation(
    BuildContext context,
    FuelingViewModel viewModel,
    Fueling fueling,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Tem certeza que deseja excluir este registro de ${DateFormat('dd/MM/yyyy').format(fueling.data.toDate())}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(
                'Excluir',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onPressed: () {
                if (fueling.id != null) {
                  viewModel.deleteFueling(context, fueling.id!);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
