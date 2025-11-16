import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:p2mobile/data/models/vehicle_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Veículos ---

  // Pega o UID do usuário logado
  String? get _uid => _auth.currentUser?.uid;

  // Helper para pegar a COLEÇÃO DE VEÍCULOS do usuário logado
  // Estrutura: /usuarios/{uid}/veiculos
  CollectionReference<Vehicle> _getVehiclesCollection() {
    if (_uid == null) throw Exception('Usuário não autenticado.');

    return _db
        .collection('usuarios') // Coleção raiz
        .doc(_uid) // Documento do usuário
        .collection('veiculos') // Subcoleção de veículos
        .withConverter<Vehicle>(
          // Converte automaticamente
          fromFirestore: (snapshot, _) => Vehicle.fromFirestore(snapshot),
          toFirestore: (vehicle, _) => vehicle.toMap(),
        );
  }

  // Adicionar um novo veículo
  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      await _getVehiclesCollection().add(vehicle);
    } catch (e) {
      throw Exception('Erro ao adicionar veículo: $e');
    }
  }

  // Ler (ouvir) a lista de veículos em tempo real (usa onSnapshot)
  Stream<List<Vehicle>> getVehiclesStream() {
    return _getVehiclesCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Excluir um veículo
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _getVehiclesCollection().doc(vehicleId).delete();
    } catch (e) {
      throw Exception('Erro ao excluir veículo: $e');
    }
  }
}
