import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:p2mobile/data/models/fueling_model.dart';
import 'package:p2mobile/data/services/firestore_service.dart';
import 'package:intl/intl.dart';

class ChartViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  // O ViewModel "ouve" o stream de abastecimentos
  late Stream<List<Fueling>> _fuelingStream;

  // Getters para a UI
  Stream<List<Fueling>> get fuelingStream => _fuelingStream;

  ChartViewModel(this._firestoreService) {
    _fuelingStream = _firestoreService.getFuelingsStream();
  }

  // --- Lógica para o Gráfico de Custo Mensal ---

  // 1. Processa a lista de abastecimentos e agrupa por mês
  Map<String, double> processMonthlyCosts(List<Fueling> fuelings) {
    // Usamos um Map para 'Ano-Mês' -> 'Valor Total'
    // ex: {"2025-11": 150.0, "2025-10": 300.50}
    final Map<String, double> monthlyTotals = {};

    for (var fueling in fuelings) {
      // Formata a data para 'yyyy-MM' (ex: "2025-11")
      final key = DateFormat('yyyy-MM').format(fueling.data.toDate());

      // Adiciona o valor pago ao total daquele mês
      monthlyTotals.update(
        key,
        (value) => value + fueling.valorPago,
        ifAbsent: () => fueling.valorPago,
      );
    }
    return monthlyTotals;
  }

  // 2. Converte o Map em dados para o Gráfico de Barras
  //    Esta função será chamada diretamente da UI (tela)
  List<BarChartGroupData> getMonthlyCostBarData(
    List<Fueling> fuelings,
    BuildContext context,
  ) {
    final monthlyData = processMonthlyCosts(fuelings);

    if (monthlyData.isEmpty) {
      return [];
    }

    // Precisamos ordenar as chaves (ex: "2025-10", "2025-11")
    final sortedKeys = monthlyData.keys.toList()..sort();

    // Vamos mostrar apenas os últimos 12 meses, se houver mais que isso
    final keysToShow = sortedKeys.length > 12
        ? sortedKeys.sublist(sortedKeys.length - 12)
        : sortedKeys;

    List<BarChartGroupData> barGroups = [];
    int counter = 0;

    // Pega a cor primária (Vermelho) do tema
    final barColor = Theme.of(context).colorScheme.primary;

    for (var key in keysToShow) {
      final totalValue = monthlyData[key] ?? 0.0;

      final barGroup = BarChartGroupData(
        x: counter, // Posição no eixo X
        barRods: [
          BarChartRodData(
            toY: totalValue, // Altura da barra (o valor R$)
            color: barColor, // Cor do tema
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
        showingTooltipIndicators: [],
      );

      barGroups.add(barGroup);
      counter++;
    }

    return barGroups;
  }

  // 3. Helper para gerar os títulos do eixo X (ex: "Nov", "Dez")
  //    Esta função também será chamada da UI
  String getMonthLabel(double value, Map<String, double> data) {
    final sortedKeys = data.keys.toList()..sort();
    final keysToShow = sortedKeys.length > 12
        ? sortedKeys.sublist(sortedKeys.length - 12)
        : sortedKeys;

    int index = value.toInt();
    if (index < 0 || index >= keysToShow.length) {
      return '';
    }

    // Converte a chave "2025-11" para "Nov"
    try {
      final date = DateFormat('yyyy-MM').parse(keysToShow[index]);
      // Usamos 'MMM' para o nome curto do mês (ex: Nov)
      return DateFormat('MMM', 'pt_BR').format(date);
    } catch (e) {
      return '';
    }
  }
}
