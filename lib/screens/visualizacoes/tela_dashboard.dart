import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database.dart';
import '../../providers/theme_notifier.dart';

// Modelo para agregar os dados do dashboard
class _DashboardData {
  final int totalPedidosEnviados;
  final double valorTotalFaturado;
  final int totalPedidosPendentes;
  final List<RankingItem> topProdutos;
  final List<RankingItem> topClientes;
  final Map<DateTime, int> pedidosUltimos7Dias;

  _DashboardData({
    required this.totalPedidosEnviados,
    required this.valorTotalFaturado,
    required this.totalPedidosPendentes,
    required this.topProdutos,
    required this.topClientes,
    required this.pedidosUltimos7Dias,
  });
}

class TelaDashboard extends StatefulWidget {
  final AppDatabase database;
  const TelaDashboard({super.key, required this.database});

  @override
  State<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends State<TelaDashboard> {
  late Future<_DashboardData> _dashboardDataFuture;

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _loadDashboardData();
  }

  Future<_DashboardData> _loadDashboardData() async {
    final totalPedidosEnviados = await widget.database.countPedidosEnviados();
    final valorTotalFaturado = await widget.database.sumTotalPedidosEnviados();
    final totalPedidosPendentes = await widget.database.countPedidosPendentes();
    final topProdutos = await widget.database.getTopProdutosVendidos(5);
    final topClientes = await widget.database.getTopClientes(5);
    final pedidosUltimos7Dias = await widget.database.getPedidosNosUltimosDias(7);

    return _DashboardData(
      totalPedidosEnviados: totalPedidosEnviados,
      valorTotalFaturado: valorTotalFaturado,
      totalPedidosPendentes: totalPedidosPendentes,
      topProdutos: topProdutos,
      topClientes: topClientes,
      pedidosUltimos7Dias: pedidosUltimos7Dias,
    );
  }

  void _refreshData() {
    setState(() {
      _dashboardDataFuture = _loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Dashboard de Vendas'),
        backgroundColor: Colors.black.withOpacity(0.5),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Atualizar Dados',
          ),
        ],
      ),
      body: FutureBuilder<_DashboardData>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum dado para exibir.'));
          }

          final data = snapshot.data!;
          final themeNotifier = Provider.of<ThemeNotifier>(context);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKpiGrid(data, themeNotifier),
                const SizedBox(height: 24),
                _buildChartSection(data, themeNotifier),
                const SizedBox(height: 24),
                _buildRankingSection(data, themeNotifier),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiGrid(_DashboardData data, ThemeNotifier themeNotifier) {
    final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildKpiCard(
          title: 'Pedidos Enviados',
          value: data.totalPedidosEnviados.toString(),
          icon: Icons.check_circle,
          color: themeNotifier.currentTheme.secondaryColor,
        ),
        _buildKpiCard(
          title: 'Valor Total Faturado',
          value: formatadorMoeda.format(data.valorTotalFaturado),
          icon: Icons.monetization_on,
          color: Colors.green.shade400,
        ),
        _buildKpiCard(
          title: 'Pedidos Pendentes',
          value: data.totalPedidosPendentes.toString(),
          icon: Icons.pending_actions,
          color: Colors.orange.shade400,
        ),
      ],
    );
  }

  Widget _buildChartSection(_DashboardData data, ThemeNotifier themeNotifier) {
    return _buildDashboardCard(
      title: 'Atividade nos Últimos 7 Dias',
      icon: Icons.bar_chart,
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (data.pedidosUltimos7Dias.values.isEmpty ? 0 : data.pedidosUltimos7Dias.values.reduce(max)).toDouble() * 1.2 + 2,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final dia = data.pedidosUltimos7Dias.keys.elementAt(groupIndex);
                  return BarTooltipItem(
                    '${DateFormat('dd/MM').format(dia)}\n',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                        text: rod.toY.round().toString(),
                        style: TextStyle(
                          color: themeNotifier.currentTheme.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final dias = data.pedidosUltimos7Dias.keys.toList();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4,
                      child: Text(DateFormat('dd/MM').format(dias[value.toInt()]), style: const TextStyle(fontSize: 10)),
                    );
                  },
                  reservedSize: 20,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                  reservedSize: 28,
                  interval: 5,
                ),
              ),
            ),
            gridData: const FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5,
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(data.pedidosUltimos7Dias.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data.pedidosUltimos7Dias.values.elementAt(index).toDouble(),
                    color: themeNotifier.currentTheme.primaryColor,
                    width: 20,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildRankingSection(_DashboardData data, ThemeNotifier themeNotifier) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildDashboardCard(
            title: 'Top 5 Produtos',
            icon: Icons.star,
            child: _buildRankingList(data.topProdutos, 'unidades'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDashboardCard(
            title: 'Top 5 Clientes',
            icon: Icons.person,
            child: _buildRankingList(data.topClientes, 'pedidos'),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 4,
      color: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 4,
      color: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.white70),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildRankingList(List<RankingItem> items, String unit) {
    if (items.isEmpty) {
      return const Center(child: Text('Nenhum dado disponível.', style: TextStyle(fontSize: 12)));
    }
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.nome,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('${item.contagem} $unit', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
