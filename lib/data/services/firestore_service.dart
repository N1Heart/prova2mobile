import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:p2mobile/data/models/fueling_model.dart'; // [NOVO] Import
import 'package:p2mobile/data/models/vehicle_model.dart';
import 'package:flutter/foundation.dart'; // [NOVO] Import

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Pega o UID do usuário logado
  String? get _uid => _auth.currentUser?.uid;

  // --- Veículos (Da Etapa 3) ---

  CollectionReference<Vehicle> _getVehiclesCollection() {
    if (_uid == null) throw Exception('Usuário não autenticado.');

    return _db
        .collection('usuarios')
        .doc(_uid)
        .collection('veiculos')
        .withConverter<Vehicle>(
          fromFirestore: (snapshot, _) => Vehicle.fromFirestore(snapshot),
          toFirestore: (vehicle, _) => vehicle.toMap(),
        );
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      await _getVehiclesCollection().add(vehicle);
    } catch (e) {
      throw Exception('Erro ao adicionar veículo: $e');
    }
  }

  Stream<List<Vehicle>> getVehiclesStream() {
    // [ATUALIZAÇÃO] Adicionando ordenação por marca
    return _getVehiclesCollection().orderBy('marca').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _getVehiclesCollection().doc(vehicleId).delete();
      // TODO: Opcional - Excluir abastecimentos associados
    } catch (e) {
      throw Exception('Erro ao excluir veículo: $e');
    }
  }

  // --- [NOVO] Abastecimentos ---

  // Helper para pegar a COLEÇÃO DE ABASTECIMENTOS do usuário logado
  // Estrutura: /usuarios/{uid}/abastecimentos
  CollectionReference<Fueling> _getFuelingsCollection() {
    if (_uid == null) throw Exception('Usuário não autenticado.');

    return _db
        .collection('usuarios')
        .doc(_uid)
        .collection('abastecimentos')
        .withConverter<Fueling>(
          fromFirestore: (snapshot, _) => Fueling.fromFirestore(snapshot),
          toFirestore: (fueling, _) => fueling.toMap(),
        );
  }

  // Ler (ouvir) o histórico de abastecimentos (todos, ordenados por data)
  Stream<List<Fueling>> getFuelingsStream() {
    return _getFuelingsCollection()
        .orderBy('data', descending: true) // Mais recentes primeiro
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  // Excluir um abastecimento
  Future<void> deleteFueling(String fuelingId) async {
    try {
      await _getFuelingsCollection().doc(fuelingId).delete();
    } catch (e) {
      throw Exception('Erro ao excluir abastecimento: $e');
    }
  }

  // Adicionar Abastecimento (COM CÁLCULO DE CONSUMO)
  Future<void> addFueling(Fueling newFueling) async {
    if (_uid == null) throw Exception('Usuário não autenticado.');

    // 1. Encontrar o último abastecimento DESTE VEÍCULO
    //    para calcular o consumo
    final lastFuelingSnapshot = await _getFuelingsCollection()
        .where(
          'veiculoId',
          isEqualTo: newFueling.veiculoId,
        ) // Apenas deste veículo
        .where(
          'data',
          isLessThan: newFueling.data,
        ) // Apenas registros ANTES deste
        .orderBy('data', descending: true) // O último mais recente
        .orderBy('quilometragem', descending: true) // Pega o último KM
        .limit(1) // Apenas o último
        .get();

    double? consumoCalculado;

    if (lastFuelingSnapshot.docs.isNotEmpty) {
      // Se JÁ EXISTE um abastecimento para este carro
      final lastFueling = lastFuelingSnapshot.docs.first.data();
      final int kmAnterior = lastFueling.quilometragem;
      final int kmAtual = newFueling.quilometragem;

      // Usa os litros do abastecimento ANTERIOR para calcular o consumo ATUAL
      // Isso é mais preciso (ex: encheu o tanque, rodou, encheu de novo)
      final double litrosAbastecimentoAnterior = lastFueling.quantidadeLitros;

      if (kmAtual > kmAnterior && litrosAbastecimentoAnterior > 0) {
        // Cálculo de consumo
        final kmRodados = kmAtual - kmAnterior;
        consumoCalculado = kmRodados / litrosAbastecimentoAnterior;
        debugPrint('Consumo calculado: $consumoCalculado km/L');
      } else {
        // Quilometragem menor ou igual. Não calcula.
        debugPrint(
          'Não foi possível calcular o consumo (KM atual menor ou igual, ou litros = 0)',
        );
        consumoCalculado = 0.0; // Salva 0 para indicar que não houve cálculo
      }
    } else {
      // É o PRIMEIRO abastecimento deste carro. Consumo não pode ser calculado.
      debugPrint('Primeiro abastecimento do veículo. Consumo não calculado.');
      consumoCalculado = 0.0; // Salva 0
    }

    // 2. Cria o objeto final com o consumo calculado
    // [IMPORTANTE] Estamos salvando o consumo calculado no *novo* registro
    final fuelingToAdd = newFueling.copyWith(consumo: consumoCalculado);

    // 3. Salva no banco de dados
    try {
      await _getFuelingsCollection().add(fuelingToAdd);
    } catch (e) {
      throw Exception('Erro ao salvar abastecimento: $e');
    }
  }
}
