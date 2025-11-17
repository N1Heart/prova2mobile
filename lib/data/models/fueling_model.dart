import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p2mobile/core/utils/fuel_type_enum.dart';

class Fueling {
  final String? id;
  final String veiculoId;
  final Timestamp data; // Usar Timestamp para facilitar a ordenação
  final double quantidadeLitros;
  final double valorPago;
  final int quilometragem; // KM no momento do abastecimento
  final FuelType tipoCombustivel;
  final String? observacao;

  // Este campo será calculado e salvo no momento do registro
  final double? consumo; // km/L

  Fueling({
    this.id,
    required this.veiculoId,
    required this.data,
    required this.quantidadeLitros,
    required this.valorPago,
    required this.quilometragem,
    required this.tipoCombustivel,
    this.observacao,
    this.consumo, // Opcional no construtor
  });

  // Helper para criar uma cópia com o consumo calculado
  Fueling copyWith({double? consumo}) {
    return Fueling(
      id: id,
      veiculoId: veiculoId,
      data: data,
      quantidadeLitros: quantidadeLitros,
      valorPago: valorPago,
      quilometragem: quilometragem,
      tipoCombustivel: tipoCombustivel,
      observacao: observacao,
      consumo: consumo ?? this.consumo, // Atualiza o consumo
    );
  }

  // Converte um Objeto Fueling em um Map (para enviar ao Firestore)
  Map<String, dynamic> toMap() {
    return {
      'veiculoId': veiculoId,
      'data': data,
      'quantidadeLitros': quantidadeLitros,
      'valorPago': valorPago,
      'quilometragem': quilometragem,
      'tipoCombustível': tipoCombustivel.name,
      'observacao': observacao,
      'consumo': consumo,
    };
  }

  // Cria um Objeto Fueling a partir de um Snapshot do Firestore
  factory Fueling.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Fueling(
      id: doc.id,
      veiculoId: data['veiculoId'] ?? '',
      data: data['data'] as Timestamp,
      quantidadeLitros: (data['quantidadeLitros'] ?? 0.0).toDouble(),
      valorPago: (data['valorPago'] ?? 0.0).toDouble(),
      quilometragem: data['quilometragem'] ?? 0,
      tipoCombustivel: FuelType.values.firstWhere(
        (e) => e.name == data['tipoCombustível'],
        orElse: () => FuelType.flex,
      ),
      observacao: data['observacao'],
      consumo: (data['consumo'] ?? 0.0).toDouble(),
    );
  }
}
