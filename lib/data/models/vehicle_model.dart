import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p2mobile/core/utils/fuel_type_enum.dart';

class Vehicle {
  final String? id; // ID do documento no Firestore
  final String modelo;
  final String marca;
  final String placa;
  final int ano;
  final FuelType tipoCombustivel;

  Vehicle({
    this.id,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.ano,
    required this.tipoCombustivel,
  });

  // Converte um Objeto Vehicle em um Map (para enviar ao Firestore)
  Map<String, dynamic> toMap() {
    return {
      'modelo': modelo,
      'marca': marca,
      'placa': placa,
      'ano': ano,
      // Salva o nome do enum como String (ex: 'gasolina')
      'tipoCombustivel': tipoCombustivel.name,
    };
  }

  // Cria um Objeto Vehicle a partir de um Snapshot do Firestore
  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      modelo: data['modelo'] ?? '',
      marca: data['marca'] ?? '',
      placa: data['placa'] ?? '',
      ano: data['ano'] ?? 0,
      // Converte a String do Firestore (ex: 'gasolina') de volta para o Enum
      tipoCombustivel: FuelType.values.firstWhere(
        (e) => e.name == data['tipoCombustivel'],
        orElse: () => FuelType.flex, // Valor padrão em caso de erro
      ),
    );
  }
}
