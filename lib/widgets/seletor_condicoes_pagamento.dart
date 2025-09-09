import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/condicoes_pagamento.dart';
import '../../providers/pedido_provider.dart';
import 'package:provider/provider.dart';

class SeletorCondicoesPagamento extends StatefulWidget {
  const SeletorCondicoesPagamento({super.key});

  @override
  State<SeletorCondicoesPagamento> createState() => _SeletorCondicoesPagamentoState();
}

class _SeletorCondicoesPagamentoState extends State<SeletorCondicoesPagamento> {
  String _filtroTexto = '';
  String? _categoriaSelecionada;

  List<CondicaoPagamento> get _condicoesFilteradas {
    var condicoes = CondicoesPagamento.todasCondicoes;
    
    // Filtro por categoria
    if (_categoriaSelecionada != null && _categoriaSelecionada != 'Todas') {
      condicoes = condicoes.where((c) => c.categoria == _categoriaSelecionada).toList();
    }
    
    // Filtro por texto
    if (_filtroTexto.isNotEmpty) {
      condicoes = condicoes.where((c) => 
        c.descricao.toLowerCase().contains(_filtroTexto.toLowerCase()) ||
        c.codigo.toLowerCase().contains(_filtroTexto.toLowerCase())
      ).toList();
    }
    
    return condicoes;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidoProvider>(
      builder: (context, provider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  'Condições de Pagamento',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filtros em layout responsivo
                if (isMobile) ...[
                  // Mobile: filtros em coluna
                  DropdownButtonFormField<String>(
                    value: _categoriaSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas as categorias')),
                      ...CondicoesPagamento.categorias.map(
                        (categoria) => DropdownMenuItem(
                          value: categoria,
                          child: Text(categoria),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _categoriaSelecionada = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar condição',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Digite código ou descrição...',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filtroTexto = value;
                      });
                    },
                  ),
                ] else ...[
                  // Desktop: filtros em linha
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _categoriaSelecionada,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Todas as categorias')),
                            ...CondicoesPagamento.categorias.map(
                              (categoria) => DropdownMenuItem(
                                value: categoria,
                                child: Text(categoria),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _categoriaSelecionada = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Buscar condição',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Digite código ou descrição...',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _filtroTexto = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                
                // Condição selecionada (se houver)
                if (provider.condicaoPagamentoSelecionada != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Condição Selecionada:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${provider.condicaoPagamentoSelecionada!.codigo} - ${provider.condicaoPagamentoSelecionada!.descricao}',
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        if (isMobile) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Categoria: ${provider.condicaoPagamentoSelecionada!.categoria}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          // Seletor de parcelas para mobile - BR77
                          if (provider.condicaoPagamentoSelecionada!.permiteParcelamento) ...[
                            const SizedBox(height: 4),
                            if (provider.condicaoPagamentoSelecionada!.codigo == 'BR77') ...[
                              Row(
                                children: [
                                  Text(
                                    'Parcelas:',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    height: 35,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: provider.parcelasSelecionadas,
                                        hint: Text(
                                          'Selecione',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                            fontSize: 14,
                                          ),
                                        ),
                                        items: List.generate(21, (index) => index + 1)
                                            .map((parcelas) => DropdownMenuItem<int>(
                                                  value: parcelas,
                                                  child: Text('${parcelas}x'),
                                                ))
                                            .toList(),
                                        onChanged: (parcelas) {
                                          provider.setParcelasSelecionadas(parcelas);
                                        },
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontSize: 14,
                                        ),
                                        dropdownColor: Theme.of(context).colorScheme.surface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Text(
                                'Parcelas: ${provider.condicaoPagamentoSelecionada!.parcelasMaximas}x',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ] else ...[
                          Row(
                            children: [
                              Text(
                                'Categoria: ${provider.condicaoPagamentoSelecionada!.categoria}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                              if (provider.condicaoPagamentoSelecionada!.permiteParcelamento) ...[
                                const SizedBox(width: 16),
                                // Seletor de parcelas especial para BR77
                                if (provider.condicaoPagamentoSelecionada!.codigo == 'BR77') ...[
                                  Row(
                                    children: [
                                      Text(
                                        'Parcelas:',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        height: 35,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: provider.parcelasSelecionadas,
                                            hint: Text(
                                              'Selecione',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                                fontSize: 14,
                                              ),
                                            ),
                                            items: List.generate(21, (index) => index + 1)
                                                .map((parcelas) => DropdownMenuItem<int>(
                                                      value: parcelas,
                                                      child: Text('${parcelas}x'),
                                                    ))
                                                .toList(),
                                            onChanged: (parcelas) {
                                              provider.setParcelasSelecionadas(parcelas);
                                            },
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              fontSize: 14,
                                            ),
                                            dropdownColor: Theme.of(context).colorScheme.surface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  // Exibição normal para outras condições
                                  Text(
                                    'Parcelas: ${provider.condicaoPagamentoSelecionada!.parcelasMaximas}x',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ],
                        if (provider.condicaoPagamentoSelecionada!.observacoes != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Obs: ${provider.condicaoPagamentoSelecionada!.observacoes}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Lista de condições - altura dinâmica baseada no conteúdo
                if (_condicoesFilteradas.isNotEmpty) ...[
                  Container(
                    height: _categoriaSelecionada != null || _filtroTexto.isNotEmpty 
                        ? math.min(300, (_condicoesFilteradas.length * 72.0) + 60) // Altura dinâmica
                        : 300, // Altura padrão
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Cabeçalho da tabela (responsivo)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: isMobile 
                            ? Row(
                                children: [
                                  const SizedBox(width: 60, child: Text('Código', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                                ],
                              )
                            : Row(
                                children: [
                                  SizedBox(width: 80, child: Text('Código', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                                  const SizedBox(width: 16),
                                  Expanded(child: Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                                  const SizedBox(width: 16),
                                  SizedBox(width: 120, child: Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                                  const SizedBox(width: 16),
                                  SizedBox(width: 80, child: Text('Parcelas', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
                                ],
                              ),
                        ),
                        
                        // Lista scrollável
                        Expanded(
                          child: ListView.builder(
                            itemCount: _condicoesFilteradas.length,
                            itemBuilder: (context, index) {
                              final condicao = _condicoesFilteradas[index];
                              final isSelected = provider.condicaoPagamentoSelecionada?.codigo == condicao.codigo;
                              
                              return Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
                                  border: Border(
                                    bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                                  ),
                                ),
                                child: ListTile(
                                  dense: isMobile,
                                  onTap: () {
                                    provider.setCondicaoPagamento(condicao);
                                  },
                                  leading: isSelected 
                                    ? Icon(Icons.radio_button_checked, color: Theme.of(context).colorScheme.primary)
                                    : Icon(Icons.radio_button_unchecked, color: Theme.of(context).colorScheme.outline),
                                  title: isMobile
                                    ? _buildMobileListItem(condicao, isSelected)
                                    : _buildDesktopListItem(condicao, isSelected),
                                  subtitle: (isMobile && condicao.observacoes != null)
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          condicao.observacoes!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      )
                                    : (!isMobile && condicao.observacoes != null)
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            condicao.observacoes!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Mensagem quando não há condições filtradas
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma condição encontrada',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tente ajustar os filtros',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                // Estatísticas
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'Mostrando ${_condicoesFilteradas.length} de ${CondicoesPagamento.todasCondicoes.length} condições',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMobileListItem(CondicaoPagamento condicao, bool isSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                condicao.codigo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                condicao.descricao,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getCategoriaColor(condicao.categoria),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                condicao.categoria,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              condicao.permiteParcelamento 
                ? '${condicao.parcelasMaximas ?? "N/A"}x'
                : 'À vista',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[200],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopListItem(CondicaoPagamento condicao, bool isSelected) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            condicao.codigo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            condicao.descricao,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 120,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getCategoriaColor(condicao.categoria),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              condicao.categoria,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 80,
          child: Text(
            condicao.permiteParcelamento 
              ? '${condicao.parcelasMaximas ?? "N/A"}x'
              : 'À vista',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Color _getCategoriaColor(String categoria) {
    // Usando cores mais harmônicas e modernas
    switch (categoria) {
      case 'À Vista':
        return const Color(0xFF4CAF50); // Verde moderno
      case 'Cartão':
        return const Color(0xFF2196F3); // Azul moderno
      case 'Prazo Direto':
        return const Color(0xFFFF9800); // Laranja moderno
      case 'Parcelamento Especial':
        return const Color(0xFFF44336); // Vermelho moderno
      case 'Boleto':
        return const Color(0xFF009688); // Teal moderno
      case 'Cashback':
        return const Color(0xFFE91E63); // Rosa moderno
      case 'Especial':
        return const Color(0xFF607D8B); // Azul acinzentado moderno
      default:
        return const Color(0xFF9E9E9E); // Cinza moderno
    }
  }
}
