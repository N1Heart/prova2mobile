import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:p2mobile/data/models/fueling_model.dart';
import 'package:p2mobile/viewmodels/chart_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pega o ViewModel
    final chartViewModel = context.read<ChartViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      // Ouve o stream principal de abastecimentos
      body: StreamBuilder<List<Fueling>>(
        stream: chartViewModel.fuelingStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Sem dados suficientes para gerar gráficos.\nRegistre alguns abastecimentos primeiro.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Temos os dados!
          final fuelings = snapshot.data!;

          // 1. Processa os dados para o gráfico
          final monthlyData = chartViewModel.processMonthlyCosts(fuelings);
          final barGroups = chartViewModel.getMonthlyCostBarData(
            fuelings,
            context,
          );

          if (barGroups.isEmpty) {
            return const Center(child: Text("Sem dados para o gráfico."));
          }

          // Encontra o valor máximo para ajustar o eixo Y
          double maxY = 0;
          for (var data in monthlyData.values) {
            if (data > maxY) maxY = data;
          }
          // Adiciona uma "folga" de 20% no topo do gráfico
          maxY = maxY * 1.2;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Custo Total por Mês (R\$)',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // O Widget do Gráfico
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        // Configura os títulos (nomes) dos eixos
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),

                        // Eixo Y (Valores R$)
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60, // Espaço para "R$ 1.000"
                            getTitlesWidget: (value, meta) {
                              // Mostra apenas alguns valores para não poluir
                              if (value == 0 ||
                                  value == maxY / 2 ||
                                  value >= maxY * 0.99) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    // Formato compacto (ex: R$ 1,5mil)
                                    NumberFormat.compactCurrency(
                                      locale: 'pt_BR',
                                      symbol: 'R\$',
                                    ).format(value),
                                    style: theme.textTheme.bodySmall,
                                    textAlign: TextAlign.right,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),

                        // Eixo X (Meses)
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              // Pede ao ViewModel o nome do mês (ex: "Nov")
                              String text = chartViewModel.getMonthLabel(
                                value,
                                monthlyData,
                              );
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 4.0,
                                child: Text(
                                  text,
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false), // Sem borda
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY / 4, // Linhas horizontais
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 1,
                            dashArray: [2, 4], // Linha tracejada
                          );
                        },
                      ),
                      barTouchData: BarTouchData(
                        // Tooltip (dica) ao tocar na barra
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final monthKey = (monthlyData.keys.toList()
                              ..sort())[group.x.toInt()];
                            final value = rod.toY;
                            return BarTooltipItem(
                              '${DateFormat('MM/yyyy').format(DateFormat('yyyy-MM').parse(monthKey))}\n'
                              '${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value)}',
                              TextStyle(
                                color: theme.colorScheme.surface,
                              ), // Texto branco
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
