import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database.dart';
import '../../providers/app_data_notifier.dart';
import '../../providers/theme_notifier.dart';

// Classe auxiliar para os dados do ranking
class RankingItem {
  final String nome;
  final int contagem;
  RankingItem({required this.nome, required this.contagem});
}

class TelaDashboard extends StatefulWidget {
  final AppDatabase database;
  const TelaDashboard({super.key, required this.database});

  @override
  State<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends State<TelaDashboard> {
  late Future<int> _totalPedidosFuture;
  late Future<double> _valorTotalFuture;
  late Future<Map<String, int>> _topProdutosFuture;
  late Future<Map<String, int>> _topClientesFuture;
  late Future<Map<DateTime, int>> _pedidosSemanaFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _totalPedidosFuture = widget.database.getTotalPedidosEnviados();
      _valorTotalFuture = widget.database.getValorTotalFaturado();
      _topProdutosFuture = widget.database.getTopProdutos();
      _topClientesFuture = widget.database.getTopClientes();
      _pedidosSemanaFuture = widget.database.getPedidosUltimos7Dias();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    final appData = Provider.of<AppDataNotifier>(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Dashboard de Vendas'),
        backgroundColor: Colors.black.withOpacity(0.5),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Atualizar Dados',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- KPIs ---
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2,
              children: [
                _buildKpiCard(
                  title: 'Pedidos Enviados',
                  future: _totalPedidosFuture,
                  formatter: (value) => (value as int).toString(),
                  icon: Icons.receipt_long,
                  color: theme.primaryColor,
                ),
                _buildKpiCard(
                  title: 'Valor Total Faturado',
                  future: _valorTotalFuture,
                  formatter: (value) => currencyFormat.format(value),
                  icon: Icons.monetization_on,
                  color: Colors.green.shade600,
                ),
                _buildKpiCard(
                  title: 'Pedidos Pendentes',
                  value: appData.pendingOrderCount.toDouble(),
                  formatter: (value) => (value as double).toInt().toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange.shade600,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Rankings ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildRankingCard(
                    title: 'Top 5 Produtos Mais Vendidos',
                    future: _topProdutosFuture,
                    icon: Icons.star,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRankingCard(
                    title: 'Top 5 Clientes',
                    future: _topClientesFuture,
                    icon: Icons.person_pin,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Gráfico de Atividade ---
            _buildChartCard(
              title: 'Pedidos nos Últimos 7 Dias',
              future: _pedidosSemanaFuture,
              themeNotifier: Provider.of<ThemeNotifier>(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    Future<num>? future,
    double? value,
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 4),
            if (future != null)
              FutureBuilder<num>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Text('Erro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white));
                  }
                  return Text(
                    formatter(snapshot.data!),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                },
              )
            else
              Text(
                formatter(value!),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingCard({required String title, required Future<Map<String, int>> future, required IconData icon}) {
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
                Icon(icon, color: Colors.white70),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            FutureBuilder<Map<String, int>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum dado disponível.'));
                }
                final items = snapshot.data!.entries.map((e) => RankingItem(nome: e.key, contagem: e.value)).toList();
                return Column(
                  children: items.map((item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      child: Text((items.indexOf(item) + 1).toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    title: Text(item.nome, overflow: TextOverflow.ellipsis),
                    trailing: Text(item.contagem.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({required String title, required Future<Map<DateTime, int>> future, required ThemeNotifier themeNotifier}) {
    return Card(
      elevation: 4,
      color: Colors.black.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: FutureBuilder<Map<DateTime, int>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum dado disponível.'));
                  }
                  final data = snapshot.data!;
                  final sortedKeys = data.keys.toList()..sort();
                  final maxY = (data.values.reduce((a, b) => a > b ? a : b) * 1.2).toDouble();

                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY > 5 ? maxY : 6,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(DateFormat('dd/MM').format(sortedKeys[value.toInt()]), style: const TextStyle(fontSize: 10)),
                            reservedSize: 20,
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
                      borderData: FlBorderData(show: false),
                      barGroups: sortedKeys.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: data[entry.value]!.toDouble(),
                              color: themeNotifier.currentTheme.primaryColor,
                              width: 20,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                            ),
                          ],
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

