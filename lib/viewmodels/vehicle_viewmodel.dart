import 'dart:async';
import 'package:flutter/material.dart';
import 'package:p2mobile/data/models/vehicle_model.dart';
import 'package:p2mobile/data/services/firestore_service.dart';

// Enum para o estado da UI
enum VehicleStatus { initial, loading, success, error }

class VehicleViewModel extends ChangeNotifier {
  // O ViewModel agora DEPENDE do FirestoreService
  final FirestoreService _firestoreService;

  VehicleStatus _status = VehicleStatus.initial;
  String _errorMessage = '';

  // Stream para a lista de veículos
  late Stream<List<Vehicle>> _vehiclesStream;

  // Getters
  VehicleStatus get status => _status;
  String get errorMessage => _errorMessage;
  Stream<List<Vehicle>> get vehiclesStream => _vehiclesStream;

  // Construtor que recebe o service e inicia a busca
  VehicleViewModel(this._firestoreService) {
    _fetchVehicles();
  }

  // Busca (ouve) a lista de veículos
  void _fetchVehicles() {
    try {
      _vehiclesStream = _firestoreService.getVehiclesStream();
    } catch (e) {
      _vehiclesStream = Stream.error(e.toString());
      _errorMessage = e.toString();
    }
    // Não precisa de notifyListeners() aqui, o StreamBuilder vai ouvir
  }

  // Adicionar Veículo
  Future<bool> addVehicle(BuildContext context, Vehicle vehicle) async {
    _status = VehicleStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await _firestoreService.addVehicle(vehicle);
      _status = VehicleStatus.success;
      notifyListeners();
      _showSnackbar(context, 'Veículo salvo com sucesso!', isError: false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = VehicleStatus.error;
      notifyListeners();
      _showSnackbar(context, _errorMessage, isError: true);
      return false;
    }
  }

  // Excluir Veículo
  Future<void> deleteVehicle(BuildContext context, String vehicleId) async {
    // Não precisa de "loading" aqui, a UI vai se atualizar via Stream
    try {
      await _firestoreService.deleteVehicle(vehicleId);
      _showSnackbar(context, 'Veículo excluído.', isError: false);
    } catch (e) {
      _errorMessage = e.toString();
      _showSnackbar(context, _errorMessage, isError: true);
    }
    // Não precisa de notifyListeners(), o StreamBuilder fará o trabalho
  }

  // Helper de Snackbar
  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : Colors.green[600],
        ),
      );
    }
  }
}
