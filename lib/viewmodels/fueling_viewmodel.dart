import 'dart:async';
import 'package:flutter/material.dart';
import 'package:p2mobile/data/models/fueling_model.dart';
import 'package:p2mobile/data/services/firestore_service.dart';

// Enum para o estado da UI
enum FuelingStatus { initial, loading, success, error }

class FuelingViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  FuelingStatus _status = FuelingStatus.initial;
  String _errorMessage = '';

  // Stream para o histórico
  late Stream<List<Fueling>> _fuelingStream;

  // Getters
  FuelingStatus get status => _status;
  String get errorMessage => _errorMessage;
  Stream<List<Fueling>> get fuelingStream => _fuelingStream;

  // Construtor
  FuelingViewModel(this._firestoreService) {
    _fetchFuelings();
  }

  // Busca (ouve) o histórico
  void _fetchFuelings() {
    try {
      _fuelingStream = _firestoreService.getFuelingsStream();
    } catch (e) {
      _fuelingStream = Stream.error(e.toString());
      _errorMessage = e.toString();
    }
  }

  // Adicionar Abastecimento
  Future<bool> addFueling(BuildContext context, Fueling fueling) async {
    _status = FuelingStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // A lógica de cálculo de consumo está no Service!
      await _firestoreService.addFueling(fueling);
      _status = FuelingStatus.success;
      notifyListeners();
      _showSnackbar(
        context,
        'Abastecimento salvo com sucesso!',
        isError: false,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = FuelingStatus.error;
      notifyListeners();
      _showSnackbar(context, "Erro ao salvar: $e", isError: true);
      return false;
    }
  }

  // Excluir Abastecimento
  Future<void> deleteFueling(BuildContext context, String fuelingId) async {
    try {
      await _firestoreService.deleteFueling(fuelingId);
      _showSnackbar(context, 'Registro excluído.', isError: false);
    } catch (e) {
      _errorMessage = e.toString();
      _showSnackbar(context, "Erro ao excluir: $e", isError: true);
    }
    // O StreamBuilder vai atualizar a UI
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
