import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../database.dart';
import '../../models/app_theme.dart';
import '../../providers/theme_notifier.dart';

class TelaDashboard extends StatefulWidget {
  final AppDatabase database;
  const TelaDashboard({super.key, required this.database});

  @override
  State<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends State<TelaDashboard> {
  late Future<int> _totalPedidosFuture;
  late Future<double> _valorTotalFuture;
  late Future<int> _pedidosPendentesFuture;
  late Future<List<RankingItem>> _topProdutosFuture;
  late Future<List<RankingItem>> _topClientesFuture;
  late Future<Map<DateTime, int>> _pedidosSemanaFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    setState(() {
      _totalPedidosFuture = widget.database.countPedidosEnviados();
      _valorTotalFuture = widget.database.sumTotalPedidosEnviados();
      _pedidosPendentesFuture = widget.database.countPedidosPendentes();
      _topProdutosFuture = widget.database.getTopProdutosVendidos();
      _topClientesFuture = widget.database.getTopClientes();
      _pedidosSemanaFuture = widget.database.getPedidosNosUltimosDias();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Dashboard de Vendas'),
        backgroundColor: Colors.black.withOpacity(0.5),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Atualizar Dados',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildKpiRow(theme),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildRankingCard('Top 5 Produtos Mais Vendidos', Icons.star, _topProdutosFuture)),
                const SizedBox(width: 16),
                Expanded(child: _buildRankingCard('Top 5 Clientes', Icons.person, _topClientesFuture)),
              ],
            ),
            const SizedBox(height: 24),
            _buildChartCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiRow(AppTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: _buildKpiCard('Total de Pedidos Enviados', _totalPedidosFuture, Icons.shopping_cart, theme.primaryColor, isCurrency: false)),
        const SizedBox(width: 16),
        Expanded(child: _buildKpiCard('Valor Total Faturado', _valorTotalFuture, Icons.attach_money, Colors.green.shade800, isCurrency: true)),
        const SizedBox(width: 16),
        Expanded(child: _buildKpiCard('Pedidos Pendentes', _pedidosPendentesFuture, Icons.pending_actions, Colors.orange.shade800, isCurrency: false)),
      ],
    );
  }

  Widget _buildKpiCard(String title, Future<num>? future, IconData icon, Color cardColor, {bool isCurrency = false}) {
    return Card(
      elevation: 4,
      color: cardColor.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.white70),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.8))),
            const SizedBox(height: 8),
            FutureBuilder<num>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,));
                }
                if (snapshot.hasError) {
                  return const Text('Erro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
                }
                final value = snapshot.data ?? 0;
                final formattedValue = isCurrency 
                  ? NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value)
                  : value.toStringAsFixed(0);

                return Text(
                  formattedValue,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingCard(String title, IconData icon, Future<List<RankingItem>>? future) {
    return Card(
      elevation: 4,
      color: Colors.black.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.amber),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            FutureBuilder<List<RankingItem>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhum dado disponível.');
                }
                return _buildRankingList(snapshot.data!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingList(List<RankingItem> items) {
    return Column(
      children: items.asMap().entries.map((entry) {
        int idx = entry.key;
        RankingItem item = entry.value;
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8 - (idx * 0.15)),
            child: Text('${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          title: Text(item.nome, overflow: TextOverflow.ellipsis),
          trailing: Text(item.contagem.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }

  Widget _buildChartCard(AppTheme theme) {
    return Card(
       elevation: 4,
      color: Colors.black.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pedidos nos Últimos 7 Dias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: FutureBuilder<Map<DateTime, int>>(
                future: _pedidosSemanaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text('Erro ao carregar dados do gráfico.'));
                  }

                  final data = snapshot.data!;
                  final sortedKeys = data.keys.toList()..sort();
                  
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (data.values.isNotEmpty ? data.values.reduce((a, b) => a > b ? a : b) : 0) * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.round()}',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final day = sortedKeys[value.toInt()];
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(DateFormat('dd/MM').format(day), style: const TextStyle(fontSize: 12)),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white12, strokeWidth: 1),
                        drawVerticalLine: false
                      ),
                      barGroups: sortedKeys.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: data[entry.value]?.toDouble() ?? 0,
                              color: theme.primaryColor,
                              width: 20,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              )
                            )
                          ]
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

