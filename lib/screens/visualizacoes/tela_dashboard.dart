import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database.dart';
import '../../providers/app_data_notifier.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme.dart';
import '../../providers/theme_notifier.dart';

class TelaDashboard extends StatefulWidget {
  final AppDatabase database;
  const TelaDashboard({super.key, required this.database});

  @override
  State<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends State<TelaDashboard> {
  Future<int>? _totalPedidosFuture;
  Future<double>? _valorTotalFuture;
  Future<List<RankingItem>>? _topProdutosFuture;
  Future<List<RankingItem>>? _topClientesFuture;
  Future<Map<String, int>>? _pedidosSemanaFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    setState(() {
      _totalPedidosFuture = widget.database.countPedidosEnviados();
      _valorTotalFuture = widget.database.sumTotalPedidosEnviados();
      _topProdutosFuture = widget.database.getTopProdutosVendidos(5);
      _topClientesFuture = widget.database.getTopClientes(5);
      _pedidosSemanaFuture = widget.database.getPedidosNosUltimosDias(7);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppDataNotifier>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = themeNotifier.currentTheme;

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
        // LAYOUT ATUALIZADO PARA GRELHA 3x2x1
        child: Column(
          children: [
            // --- LINHA 1: KPIs ---
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Total de Pedidos Enviados',
                    future: _totalPedidosFuture,
                    formatter: (value) => (value as int).toString(),
                    icon: Icons.shopping_cart,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Valor Total Faturado',
                    future: _valorTotalFuture,
                    formatter: (value) => 'R\$ ${NumberFormat.compact().format(value)}',
                    icon: Icons.attach_money,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Pedidos Pendentes',
                    value: appData.pendingOrderCount,
                    formatter: (value) => (value as int).toString(),
                    icon: Icons.pending_actions,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // --- LINHA 2: Rankings ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildRankingCard(
                    title: 'Top 5 Produtos Mais Vendidos',
                    future: _topProdutosFuture,
                    icon: Icons.inventory_2,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRankingCard(
                    title: 'Top 5 Clientes',
                    future: _topClientesFuture,
                    icon: Icons.people,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // --- LINHA 3: Gráfico de Barras ---
            _buildSectionCard(
              title: 'Pedidos nos Últimos 7 Dias',
              child: FutureBuilder<Map<String, int>>(
                future: _pedidosSemanaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Sem dados recentes.'));
                  }
                  return SizedBox(
                    height: 300,
                    child: _buildBarChart(snapshot.data!, theme),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildKpiCard({
    required String title,
    Future<num>? future,
    num? value,
    required String Function(num) formatter,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            if (future != null)
              FutureBuilder<num>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(color: Colors.white));
                  }
                  final displayValue = formatter(snapshot.data ?? 0);
                  return Text(displayValue, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white));
                },
              )
            else
              Text(formatter(value ?? 0), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      color: Colors.black.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildRankingCard({
    required String title,
    required Future<List<RankingItem>>? future,
    required IconData icon,
  }) {
    return _buildSectionCard(
      title: title,
      child: FutureBuilder<List<RankingItem>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Sem dados.'));
          }
          return Column(
            children: snapshot.data!.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item.nome, overflow: TextOverflow.ellipsis),
                trailing: Text(item.contagem.toString(), style: Theme.of(context).textTheme.bodyLarge),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data, AppTheme theme) {
    final barGroups = data.entries.map((entry) {
      final x = data.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: theme.primaryColor,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (data.values.isEmpty ? 10 : data.values.reduce((a, b) => a > b ? a : b)) * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dia = data.keys.elementAt(group.x);
              return BarTooltipItem(
                '$dia\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                    text: rod.toY.toInt().toString(),
                    style: TextStyle(
                      color: theme.secondaryColor,
                      fontSize: 16,
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
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.keys.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(data.keys.elementAt(index)),
                  );
                }
                return const Text('');
              },
              reservedSize: 38,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
      ),
    );
  }
}

