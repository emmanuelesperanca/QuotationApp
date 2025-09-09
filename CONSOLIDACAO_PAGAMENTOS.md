# Consolidação das Condições de Pagamento

## Resumo das Alterações

Foram realizadas duas consolidações principais para organizar melhor as condições de pagamento:

### 1ª Consolidação: Categoria Boleto
As seguintes categorias foram unificadas na categoria **"Boleto"**:
- **Com Entrada** (12 condições)
- **Sem Entrada** (15 condições) 
- **Boleto** (2 condições existentes)

### 2ª Consolidação: Categoria Cartão
As seguintes categorias foram unificadas na categoria **"Cartão"**:
- **Cartão** (4 condições existentes)
- **Link de Pagamento** (13 condições)

## Totais por Categoria Consolidada

### Categoria Boleto - 29 condições
#### Condições Com Entrada (mantidas as propriedades `temEntrada: true`)
- BR06: Entrada + 1 (7+30)
- BR08: Entrada + 2 (7+30+30)
- BR09: Entrada + 3 (7+30+30+30)
- BR10: Entrada + 4 (7+30+30+30+30)
- BR11: Entrada + 5 (7+30+30+30+30+30)
- BR12: Entrada + 6 (7+30+30+30+30...)
- BR13: Entrada + 7 (7+30+30+30+30...)
- BR14: Entrada + 8 (7+30+30+30...)
- BR15: Entrada + 9 (7+30+30+30+30...)
- BR07: Entrada + 10 (7+30+30+30+30...)
- BR16: Entrada + 11 (7+30+30+30+30...)

#### Condições Sem Entrada
- BR19: S/ Entrada 2x30 Dias
- BR20: S/ Entrada 3x30 Dias
- BR21: S/ Entrada 4x30 Dias
- BR22: S/ Entrada 5x30 Dias
- BR25: S/ Entrada 6x30 Dias
- BR26: S/ Entrada 7x30 Dias
- BR27: S/ Entrada 8x30 Dias
- BR28: S/ Entrada 9x30 Dias
- BR18: S/ Entrada 10x30 Dias
- BR23: S/ Entrada 11x30 Dias
- BR24: S/ Entrada 12x30 Dias
- BR94: S/ Entrada 14x30 Dias
- BRBY: S/ Entrada 15x30 Dias
- BR96: S/ Entrada 18x30 Dias

#### Condições Originais de Boleto
- BR57: Clube do Boleto
- BRBD: 12x - primeira pra 60 dias

### Categoria Cartão - 17 condições

#### Condições Originais de Cartão
- BR77: Cartão de Crédito Manual
- BR78: Cartão de Débito
- BRCC: Credit Card
- ETCC: Clear Correct Credit card payment via DELEGO

#### Condições de Link de Pagamento (consolidadas)
- BRL1: Link de Pagamento manual 1x
- BRL2: Link de Pagamento manual 2x
- BRL3: Link de Pagamento manual 3x
- BRL4: Link de Pagamento manual 4x
- BRL5: Link de Pagamento manual 5x
- BRL6: Link de Pagamento manual 6x
- BRL7: Link de Pagamento manual 7x
- BRL8: Link de Pagamento manual 8x
- BRL9: Link de Pagamento manual 9x
- BRLA: Link de Pagamento manual 10x
- BRLB: Link de Pagamento manual 11x
- BRLC: Link de Pagamento manual 12x
- BRPS: Link de Pagamento - Cartão de Crédito

### Arquivos Modificados

1. **lib/models/condicoes_pagamento.dart**
   - **1ª Consolidação**: Movidas todas as condições "Com Entrada" e "Sem Entrada" para categoria "Boleto"
   - **2ª Consolidação**: Movidas todas as condições "Link de Pagamento" para categoria "Cartão"
   - Atualizada lista de categorias removendo "Com Entrada", "Sem Entrada" e "Link de Pagamento"
   - Mantidas as propriedades específicas (`temEntrada`, `permiteParcelamento`, `parcelasMaximas`)

2. **lib/widgets/seletor_condicoes_pagamento.dart**
   - Removidas as cores específicas para categorias consolidadas
   - Mantida a cor teal para categoria "Boleto"
   - Mantida a cor azul para categoria "Cartão"

### Categorias Finais

Após as consolidações, as categorias disponíveis são:
1. À Vista (5 condições)
2. **Cartão (17 condições)** ← *Categoria consolidada com Link de Pagamento*
3. Prazo Direto (8 condições)
4. **Boleto (29 condições)** ← *Categoria consolidada com Com Entrada e Sem Entrada*
5. Parcelamento Especial (10 condições)
6. Cashback (3 condições)
7. Especial (6 condições)

### Benefícios das Consolidações

1. **Organização Mais Simples**: Redução de 10 para 7 categorias
2. **Agrupamento Lógico**: 
   - Boleto: Todas as condições bancárias em um lugar
   - Cartão: Todas as condições de pagamento por cartão (físico ou link)
3. **Manutenção de Funcionalidades**: Propriedades específicas preservadas
4. **Interface Mais Limpa**: Menos filtros de categoria no seletor
5. **Navegação Simplificada**: Usuários encontram opções relacionadas mais facilmente

### Compatibilidade

- Todos os códigos de condição existentes mantidos
- Funcionalidades de parcelamento preservadas
- Propriedade `temEntrada` mantida para diferenciação
- Interface responsiva mantida
- Todas as funcionalidades do sistema preservadas

### Resumo das Mudanças

**Antes**: 10 categorias
- À Vista, Cartão, Prazo Direto, Com Entrada, Sem Entrada, Parcelamento Especial, Boleto, Cashback, Link de Pagamento, Especial

**Depois**: 7 categorias  
- À Vista, Cartão (consolidado), Prazo Direto, Boleto (consolidado), Parcelamento Especial, Cashback, Especial

**Resultado**: Interface mais organizada e intuitiva para seleção de condições de pagamento.
