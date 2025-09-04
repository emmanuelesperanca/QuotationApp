import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../database.dart';
import '../../providers/app_data_notifier.dart';
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
  Future<int>? _pedidosPendentesFuture;
  Future<List<RankingItem>>? _topProdutosFuture;
  Future<List<RankingItem>>? _topClientesFuture;
  Future<Map<String, int>>? _pedidosSemanaFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _totalPedidosFuture = widget.database.countPedidosEnviados();
      _valorTotalFuture = widget.database.sumTotalPedidosEnviados();
      _pedidosPendentesFuture = widget.database.countPedidosPendentes();
      _topProdutosFuture = widget.database.getTopProdutosVendidos(5);
      _topClientesFuture = widget.database.getTopClientes(5);
      _pedidosSemanaFuture = widget.database.getPedidosNosUltimosDias(7);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appData = Provider.of<AppDataNotifier>(context, listen: false);
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
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<double>(
                    future: _valorTotalFuture,
                    builder: (context, snapshot) => _buildKpiCard(
                      title: 'Valor Total Faturado',
                      value: snapshot.hasData ? currencyFormat.format(snapshot.data) : '...',
                      icon: Icons.monetization_on,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _totalPedidosFuture,
                    builder: (context, snapshot) => _buildKpiCard(
                      title: 'Total de Pedidos Enviados',
                      value: snapshot.hasData ? snapshot.data.toString() : '...',
                      icon: Icons.check_circle,
                      color: themeNotifier.currentTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Pedidos Pendentes',
                    value: appData.pendingOrderCount.toString(),
                    icon: Icons.warning,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- RANKINGS ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildRankingCard<RankingItem>(
                    title: 'Top 5 Produtos Mais Vendidos',
                    future: _topProdutosFuture,
                    itemBuilder: (item) => ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text(item.nome),
                      trailing: Text(item.contagem.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRankingCard<RankingItem>(
                    title: 'Top 5 Clientes',
                    future: _topClientesFuture,
                    itemBuilder: (item) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(item.nome),
                      trailing: Text('${item.contagem} pedidos', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- GRÁFICO DE ATIVIDADE SEMANAL ---
            _buildChartCard(),
          ],
        ),
      ),
    );
  }
  
  // --- WIDGETS AUXILIARES ---
  Widget _buildKpiCard({required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingCard<T>({required String title, required Future<List<T>?>? future, required Widget Function(T) itemBuilder}) {
    return Card(
      elevation: 4,
      color: Colors.black.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            FutureBuilder<List<T>?>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Nenhum dado disponível.'));
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => itemBuilder(snapshot.data![index]),
                  separatorBuilder: (context, index) => const Divider(),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Card(
      elevation: 4,
      color: Colors.black.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Atividade nos Últimos 7 Dias', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: FutureBuilder<Map<String, int>>(
                future: _pedidosSemanaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Nenhum dado.'));
                  
                  final data = snapshot.data!;
                  final maxValue = data.values.fold(0, (max, v) => v > max ? v : max).toDouble();

                  return BarChart(
                    BarChartData(
                      maxY: maxValue * 1.2, // Um pouco de espaço no topo
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                            '${rod.toY.round()} pedidos',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => SideTitleWidget(axisSide: meta.axisSide, child: Text(data.keys.elementAt(value.toInt()), style: const TextStyle(fontSize: 10))),
                            reservedSize: 38,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: data.entries.map((e) {
                        final index = data.keys.toList().indexOf(e.key);
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.toDouble(),
                              color: themeNotifier.currentTheme.secondaryColor,
                              width: 22,
                              borderRadius: BorderRadius.circular(4),
                            )
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

