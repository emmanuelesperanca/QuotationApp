# Validação de Endereços para Pessoa Jurídica

## Resumo da Implementação

Foi implementada uma validação de segurança que **desabilita o campo "Outro..." de endereços alternativos** para clientes Pessoa Jurídica (código SAP iniciando com "4452"), visando evitar fraudes.

## Funcionalidade Implementada

### Identificação de Pessoa Jurídica
- **Critério**: Clientes com código SAP que **inicia com "4452"**
- **Detecção Automática**: O sistema identifica automaticamente o tipo de cliente

### Restrições Aplicadas
- ❌ **Opção "Outro..." removida** do dropdown de endereços alternativos
- ❌ **Campo de texto personalizado desabilitado** 
- ✅ **Apenas endereços cadastrados** são permitidos para entrega

### Interface de Usuário
- **Aviso Visual**: Mensagem informativa para o vendedor
- **Design Integrado**: Alerta com ícone e cores do Material Design 3

## Código Implementado

### 1. Provider (`lib/providers/pedido_provider.dart`)

**Novo Getter para Identificação:**
```dart
bool get clienteEhPessoaJuridica {
  if (_clienteSelecionado == null) return false;
  final numeroCliente = _clienteSelecionado!.numeroCliente as String?;
  return numeroCliente?.startsWith('4452') == true;
}
```

**Método Atualizado:**
```dart
void setEnderecoAlternativo(EnderecoAlternativo? endereco) {
  _enderecoAlternativoSelecionado = endereco;
  // Para pessoa jurídica, não permite o modo "Outro endereço"
  _mostrarCampoOutroEndereco = (endereco == null) && !clienteEhPessoaJuridica;
  // ... resto da lógica
}
```

### 2. Interface (`lib/screens/pedido/tela_de_pedido.dart`)

**Dropdown Condicional:**
```dart
items: [
  ...provider.enderecosAlternativos.map((e) => DropdownMenuItem(...)),
  // Só mostra "Outro..." se não for pessoa jurídica
  if (!provider.clienteEhPessoaJuridica)
    const DropdownMenuItem(value: null, child: Text('Outro...')),
],
```

**Aviso Visual:**
```dart
if (provider.clienteEhPessoaJuridica)
  Container(
    // Design: Container com bordas, ícone e texto informativo
    child: Row([
      Icon(Icons.info_outline),
      Text('Cliente Pessoa Jurídica: Apenas endereços cadastrados são permitidos para entrega.')
    ])
  )
```

**Campo de Texto Condicional:**
```dart
if (!provider.usarEnderecoPrincipal && 
    provider.mostrarCampoOutroEndereco && 
    !provider.clienteEhPessoaJuridica)
  TextField(...)
```

## Fluxo de Funcionamento

### Para Cliente Pessoa Física (código ≠ 4452xxx)
1. ✅ Dropdown mostra endereços cadastrados + "Outro..."
2. ✅ Vendedor pode selecionar "Outro..." 
3. ✅ Campo de texto aparece para endereço personalizado
4. ✅ Funcionalidade normal mantida

### Para Cliente Pessoa Jurídica (código = 4452xxx)
1. 🔒 Dropdown mostra **apenas endereços cadastrados**
2. 🚫 Opção "Outro..." **não está disponível**
3. ℹ️ **Aviso visual** informa a restrição ao vendedor
4. 🔒 Campo de texto personalizado **nunca aparece**

## Medidas de Segurança

### Validação Frontend
- **Remoção de Interface**: Opção "Outro..." não aparece
- **Campo Bloqueado**: Texto personalizado desabilitado
- **Feedback Visual**: Vendedor informado sobre a restrição

### Validação Backend (Provider)
- **Lógica de Estado**: `mostrarCampoOutroEndereco` considera pessoa jurídica
- **Consistência**: Garante que estado interno respeita a regra
- **Automático**: Funciona sem intervenção manual

## Benefícios da Implementação

🔐 **Segurança**: Previne uso de endereços não cadastrados para PJ  
📋 **Conformidade**: Garante uso apenas de endereços oficiais  
👁️ **Transparência**: Vendedor ciente da restrição  
🎯 **Automático**: Detecção baseada no código SAP  
🛡️ **Dupla Validação**: Frontend + Backend  
📱 **Responsivo**: Funciona em mobile e desktop  

## Critérios de Negócio

- **Escopo**: Apenas clientes com código SAP iniciando com "4452"
- **Restrição**: Campo "Outro..." completamente removido
- **Alternativa**: Apenas endereços alternativos cadastrados no sistema
- **Comunicação**: Aviso claro ao vendedor sobre a restrição
- **Segurança**: Prevenção de fraudes em entregas PJ

## Arquivos Modificados

1. `lib/providers/pedido_provider.dart`
   - Novo getter `clienteEhPessoaJuridica`
   - Método `setEnderecoAlternativo` atualizado

2. `lib/screens/pedido/tela_de_pedido.dart`
   - Dropdown condicional sem "Outro..." para PJ
   - Aviso visual para pessoa jurídica
   - Campo de texto condicional

## Status da Implementação

✅ **Detecção Automática** - Identifica PJ por código SAP  
✅ **Interface Bloqueada** - Remove opção "Outro..." para PJ  
✅ **Aviso Informativo** - Vendedor ciente da restrição  
✅ **Validação Dupla** - Frontend e Provider sincronizados  
✅ **Design Integrado** - Aviso com Material Design 3  

A funcionalidade está **totalmente implementada** e garante que clientes Pessoa Jurídica (4452xxx) só possam usar endereços oficialmente cadastrados no sistema.
