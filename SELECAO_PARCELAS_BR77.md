# Implementação de Seleção de Parcelas para BR77 - Cartão de Crédito Manual

## Resumo das Alterações

Foi implementada uma funcionalidade específica para a condição de pagamento BR77 (Cartão de Crédito Manual) que permite ao vendedor escolher o número de parcelas desejado, de 1x até 21x.

## Mudanças Realizadas

### 1. Modelo de Condições de Pagamento (`lib/models/condicoes_pagamento.dart`)
- **BR77 - Cartão de Crédito Manual**: Atualizado para permitir até 21 parcelas (era 12x anteriormente)
```dart
CondicaoPagamento(
  codigo: 'BR77',
  descricao: 'Cartão de Crédito Manual',
  categoria: 'Cartão',
  permiteParcelamento: true,
  parcelasMaximas: 21, // ← Aumentado de 12 para 21
),
```

### 2. Provider do Pedido (`lib/providers/pedido_provider.dart`)
Adicionadas novas propriedades e métodos para gerenciar a seleção de parcelas:

**Novas Propriedades:**
- `int? _parcelasSelecionadas` - Armazena o número de parcelas escolhido pelo vendedor
- `int? get parcelasSelecionadas` - Getter para acessar as parcelas selecionadas

**Novos Métodos:**
- `setParcelasSelecionadas(int? parcelas)` - Define o número de parcelas selecionado
- Atualização em `setCondicaoPagamento()` - Reset automático das parcelas ao trocar condição
- Atualização em `limparPedido()` - Limpa as parcelas selecionadas

### 3. Seletor de Condições (`lib/widgets/seletor_condicoes_pagamento.dart`)
Implementado seletor específico para BR77 com suporte responsivo:

**Funcionalidade Condicional:**
- Para **BR77**: Exibe dropdown com opções de 1x até 21x
- Para **outras condições**: Mantém exibição estática do número máximo de parcelas

**Interface Responsiva:**
- **Desktop (>600px)**: Dropdown horizontal junto com categoria
- **Mobile (<600px)**: Dropdown em linha separada para melhor visualização
- Design integrado com Material Design 3
- Lista de 1 a 21 parcelas
- Placeholder "Selecione" quando nenhuma opção escolhida
- Estilo consistente com o resto da aplicação

**Implementação Responsiva:**
```dart
// Versão Mobile
if (isMobile) ...[
  // Categoria
  Text('Categoria: ...'),
  // Seletor de parcelas para BR77
  if (codigo == 'BR77') ...[
    Row([Dropdown de 1x a 21x])
  ]
]
// Versão Desktop  
else ...[
  Row([
    Text('Categoria: ...'),
    if (codigo == 'BR77') ...[
      Row([Dropdown de 1x a 21x])
    ]
  ])
]
```

### 4. Tela de Pedido (`lib/screens/pedido/tela_de_pedido.dart`)
Implementada lógica para usar as parcelas selecionadas:

**Novo Método Helper:**
```dart
int _getParcelasParaEnvio(PedidoProvider provider) {
  // Para BR77, usa as parcelas selecionadas pelo usuário
  if (provider.condicaoPagamentoSelecionada?.codigo == 'BR77') {
    return provider.parcelasSelecionadas ?? 1;
  }
  // Para outras condições, usa o máximo de parcelas definido
  return provider.condicaoPagamentoSelecionada?.parcelasMaximas ?? 1;
}
```

**Validação Obrigatória:**
- Verifica se o vendedor selecionou parcelas quando escolher BR77
- Exibe mensagem de erro específica se parcelas não forem escolhidas

**Atualização de Envio:**
- API recebe o número correto de parcelas (selecionadas ou máximas)
- Histórico local armazena o número correto de parcelas

## Fluxo de Uso

1. **Vendedor seleciona BR77** (Cartão de Crédito Manual)
2. **Sistema exibe dropdown** com opções de 1x a 21x
3. **Vendedor escolhe** o número desejado de parcelas
4. **Sistema valida** se parcelas foram selecionadas antes de enviar
5. **Pedido é enviado** com o número correto de parcelas

## Benefícios da Implementação

✅ **Flexibilidade**: Vendedor pode escolher parcelas conforme necessidade do cliente  
✅ **Validação**: Sistema garante que parcelas sejam selecionadas para BR77  
✅ **Interface Responsiva**: Funciona perfeitamente em mobile e desktop  
✅ **Design Intuitivo**: Dropdown integrado ao design existente  
✅ **Compatibilidade**: Não afeta outras condições de pagamento  
✅ **Rastreabilidade**: Número correto de parcelas salvo no histórico  
✅ **UX Mobile**: Layout otimizado para dispositivos móveis  

## Condições de Negócio

- **Específico para BR77**: Outras condições mantêm comportamento anterior
- **Limite de 21x**: Conforme solicitado pelo usuário
- **Validação Obrigatória**: Parcelas devem ser selecionadas para BR77
- **Reset Automático**: Parcelas são limpas ao trocar condição de pagamento

## Arquivos Modificados

1. `lib/models/condicoes_pagamento.dart` - Aumento limite para 21x
2. `lib/providers/pedido_provider.dart` - Gestão de parcelas selecionadas
3. `lib/widgets/seletor_condicoes_pagamento.dart` - Interface de seleção
4. `lib/screens/pedido/tela_de_pedido.dart` - Validação e envio

## Status da Implementação

✅ **Modelo atualizado** - BR77 com 21 parcelas máximas  
✅ **Provider implementado** - Gestão de estado das parcelas  
✅ **Interface responsiva** - Dropdown funcional em mobile e desktop  
✅ **Validação adicionada** - Verificação obrigatória para BR77  
✅ **Envio atualizado** - API e histórico com dados corretos  
✅ **UX Mobile** - Layout otimizado para smartphones  

A funcionalidade está completamente implementada e pronta para uso em produção.
