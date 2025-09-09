import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/campanha_promocional.dart';
import '../../utils/responsive_utils.dart';
import '../../providers/favorites_provider.dart';
import 'dart:math';

class TelaCatalogoPromocoes extends StatefulWidget {
  const TelaCatalogoPromocoes({super.key});

  @override
  State<TelaCatalogoPromocoes> createState() => _TelaCatalogoPromocoesState();
}

class _TelaCatalogoPromocoesState extends State<TelaCatalogoPromocoes>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<CampanhaPromocional>> _campanhasPorCategoria = {
    'Neodent': campanhasNeodent,
    'Straumann': campanhasStraumann,
    'Enterprise': campanhasEnterprise,
    'Biomateriais': campanhasBiomateriais,
    'Eshop': campanhasEshop,
    'Cursos': campanhasCursos,
    'Financiamento': campanhasFinanciamento,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _campanhasPorCategoria.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Catálogo de Promoções',
          style: GoogleFonts.leagueSpartan(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.leagueSpartan(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 12 : 14,
          ),
          tabs: _campanhasPorCategoria.keys.map((categoria) {
            return Tab(text: categoria);
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _campanhasPorCategoria.values.map((campanhas) {
          return _buildCampanhasList(campanhas, isMobile);
        }).toList(),
      ),
    );
  }

  Widget _buildCampanhasList(List<CampanhaPromocional> campanhas, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 2,
          childAspectRatio: isMobile ? 1.2 : 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: campanhas.length,
        itemBuilder: (context, index) {
          return _buildCampanhaCard(campanhas[index], isMobile);
        },
      ),
    );
  }

  Widget _buildCampanhaCard(CampanhaPromocional campanha, bool isMobile) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (Random().nextInt(500))),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: _buildCardContent(campanha, isMobile),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(CampanhaPromocional campanha, bool isMobile) {
    final cardColor = _getCardColor(campanha.categoria);
    
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(campanha.promocode);
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor.withOpacity(0.1),
                cardColor.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: isFavorite 
                  ? Colors.amber.withOpacity(0.8)
                  : cardColor.withOpacity(0.3),
              width: isFavorite ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
              if (isFavorite)
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _mostrarDetalhes(campanha),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header com categoria e botão de favoritar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: cardColor.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              campanha.categoria,
                              style: GoogleFonts.leagueSpartan(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: cardColor,
                              ),
                            ),
                          ),
                          // Botão de favoritar
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                favoritesProvider.toggleFavorite(campanha.promocode);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.amber : Colors.white70,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Tag de destaque para favoritos
                      if (isFavorite) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'FAVORITO',
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Título da campanha
                      Expanded(
                        child: Text(
                          campanha.titulo,
                          style: GoogleFonts.leagueSpartan(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Valor e promocode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VALOR FINAL',
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'R\$ ${campanha.valorFinal.toStringAsFixed(2)}',
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: isMobile ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: cardColor,
                                ),
                              ),
                            ],
                          ),
                          if (campanha.promocode.isNotEmpty)
                            GestureDetector(
                              onTap: () => _copiarParaClipboard(campanha.promocode, 'Promocode'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      campanha.promocode,
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.copy,
                                      size: 12,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Botão de visualizar detalhes
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _mostrarDetalhes(campanha),
                          icon: const Icon(Icons.visibility, size: 18),
                          label: Text(
                            'Visualizar Detalhes',
                            style: GoogleFonts.leagueSpartan(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cardColor.withOpacity(0.2),
                            foregroundColor: cardColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: cardColor.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _copiarParaClipboard(String texto, String tipo) async {
    await Clipboard.setData(ClipboardData(text: texto));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$tipo copiado: $texto',
            style: GoogleFonts.leagueSpartan(
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Color _getCardColor(String categoria) {
    switch (categoria) {
      case 'Neodent':
        return const Color(0xFF9C4D8B);
      case 'Straumann':
        return const Color(0xFF003D7D);
      case 'Enterprise':
        return const Color(0xFF2D7662);
      case 'Biomateriais':
        return const Color(0xFF009FE3);
      case 'Eshop':
        return const Color(0xFF47B48A);
      case 'Cursos':
        return const Color(0xFF8B5D33);
      case 'Financiamento':
        return const Color(0xFF6B1E3F);
      default:
        return Colors.blue;
    }
  }

  void _mostrarDetalhes(CampanhaPromocional campanha) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: isMobile ? double.infinity : 600,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: _getCardColor(campanha.categoria).withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getCardColor(campanha.categoria).withOpacity(0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getCardColor(campanha.categoria).withOpacity(0.9),
                    _getCardColor(campanha.categoria).withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _getCardColor(campanha.categoria).withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                campanha.categoria,
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _getCardColor(campanha.categoria),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                campanha.titulo,
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: isMobile ? 18 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  
                  // Conteúdo
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Informações principais
                          _buildCopyableInfoRow('Promocode:', campanha.promocode, 'Promocode'),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Valor Final:', 
                            'R\$ ${campanha.valorFinal.toStringAsFixed(2)}',
                          ),
                          if (campanha.observacao != null) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow('Observação:', campanha.observacao!),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Lista de itens
                          Text(
                            'Itens da Campanha',
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          ...campanha.itens.map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Código: ',
                                      style: GoogleFonts.leagueSpartan(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _copiarParaClipboard(item.codigo, 'Código do produto'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getCardColor(campanha.categoria).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: _getCardColor(campanha.categoria).withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                item.codigo,
                                                style: GoogleFonts.robotoMono(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _getCardColor(campanha.categoria),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.copy,
                                                size: 12,
                                                color: _getCardColor(campanha.categoria).withOpacity(0.7),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Qtd: ${item.quantidade}',
                                      style: GoogleFonts.leagueSpartan(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.descricao,
                                  style: GoogleFonts.leagueSpartan(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Valor Unit.: R\$ ${item.valorUnitario.toStringAsFixed(2)}',
                                      style: GoogleFonts.leagueSpartan(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    if (item.desconto > 0) ...[
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${item.desconto.toStringAsFixed(0)}% OFF',
                                          style: GoogleFonts.leagueSpartan(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          )),
                          
                          const SizedBox(height: 24),
                          
                          // Botão de fechar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getCardColor(campanha.categoria),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Fechar',
                                style: GoogleFonts.leagueSpartan(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.leagueSpartan(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.leagueSpartan(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCopyableInfoRow(String label, String value, String tipo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.leagueSpartan(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _copiarParaClipboard(value, tipo),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.robotoMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
