# Order to Smile 📱

Um aplicativo Flutter para criação e gerenciamento de pedidos de produtos odontológicos da Straumann Group.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Características](#características)
- [Tecnologias](#tecnologias)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Uso](#uso)
- [API](#api)
- [Base de Dados](#base-de-dados)
- [Releases](#releases)
- [Contribuição](#contribuição)

## 🎯 Visão Geral

O **Order to Smile** é um aplicativo móvel desenvolvido em Flutter para automatizar o processo de criação de pedidos de produtos odontológicos. O app permite aos usuários visualizar catálogos de produtos, criar pedidos personalizados e gerenciar clientes de forma eficiente.

### Principais Funcionalidades

- ✅ **Gestão de Pedidos**: Criação, edição e finalização de pedidos
- ✅ **Catálogo de Produtos**: Visualização completa com busca avançada
- ✅ **Gestão de Clientes**: Cadastro e busca de clientes (PF/PJ)
- ✅ **Endereços Alternativos**: Gestão de múltiplos endereços de entrega
- ✅ **Sincronização Dual (Online e Offline)**: Suporte a API online e CSV offline
- ✅ **Geração de PDF**: Pedidos exportados em formato profissional
- ✅ **Múltiplas Marcas**: Suporte a diferentes linhas de produtos
- ✅ **Interface Responsiva**: Design adaptativo para tablets e smartphones

## 🚀 Características

### Interface do Usuário
- **Material Design 3** com temas customizados por marca
- **Navegação Intuitiva** com bottom navigation e drawer
- **Busca Avançada** com autocomplete e filtros
- **Tabelas Responsivas** para visualização de dados
- **Validação em Tempo Real** de formulários

### Gestão de Dados
- **Fonte Dual de Dados**: API REST + CSV de fallback
- **Banco Local**: SQLite com Drift ORM
- **Sincronização Inteligente**: Automática ou manual
- **Cache Otimizado**: Performance melhorada offline

### Funcionalidades Avançadas
- **Geração de PDF**: Pedidos formatados profissionalmente
- **Busca de CEP**: Integração com ViaCEP
- **Validação CPF/CNPJ**: Validação automática de documentos
- **Estado Persistente**: Pedidos salvos automaticamente

## 🛠️ Tecnologias

### Framework e Linguagem
- **Flutter 3.x** - Framework multiplataforma
- **Dart 3.x** - Linguagem de programação

### Gerenciamento de Estado
- **Provider** - Gerenciamento de estado reativo
- **SharedPreferences** - Persistência de configurações

### Base de Dados
- **Drift** - ORM para SQLite
- **SQLite** - Banco de dados local

### Networking
- **HTTP** - Requisições REST API
- **Dio** - Cliente HTTP avançado

### UI/UX
- **Material Design 3** - Design system
- **Flutter Launcher Icons** - Ícones personalizados
- **Responsive Framework** - Layout responsivo

### Utilitários
- **PDF** - Geração de documentos
- **CSV** - Parsing de arquivos
- **Image Picker** - Seleção de imagens
- **Package Info** - Informações do app

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── api_service.dart         # Serviços de API REST
├── database.dart            # Configuração do banco Drift
├── database.g.dart          # Código gerado do Drift
├── pdf_service.dart         # Geração de PDFs
│
├── connection/              # Conectividade e rede
│   ├── api_config.dart     # Configurações de API
│   └── connectivity_service.dart
│
├── models/                  # Modelos de dados
│   ├── app_theme.dart      # Temas da aplicação
│   ├── cliente.dart        # Modelo de cliente
│   ├── endereco_alternativo.dart
│   ├── item_pedido.dart    # Item do pedido
│   ├── pedido.dart         # Modelo de pedido
│   ├── pre_cadastro.dart   # Pré-cadastro de cliente
│   └── produto.dart        # Modelo de produto
│
├── providers/               # Gerenciamento de estado
│   ├── app_data_notifier.dart    # Estado global da app
│   ├── connectivity_notifier.dart # Estado de conectividade
│   └── pedido_provider.dart      # Estado do pedido
│
├── screens/                 # Telas da aplicação
│   ├── home/               # Tela inicial
│   │   ├── branding_page.dart
│   │   └── home_screen.dart
│   │
│   ├── pedido/             # Criação de pedidos
│   │   ├── tela_de_pedido.dart
│   │   └── visualizar_pedido.dart
│   │
│   ├── produtos/           # Catálogo de produtos
│   │   └── produtos_screen.dart
│   │
│   └── visualizacoes/      # Telas de dados base
│       ├── tela_base_clientes.dart
│       ├── tela_base_enderecos.dart
│       └── tela_base_produtos.dart
│
├── services/               # Serviços da aplicação
│   ├── csv_service.dart   # Manipulação de CSV
│   ├── notification_service.dart
│   └── sync_service.dart  # Sincronização de dados
│
├── utils/                  # Utilitários
│   ├── constants.dart     # Constantes globais
│   ├── formatters.dart    # Formatadores de texto
│   └── validators.dart    # Validadores
│
└── widgets/               # Componentes reutilizáveis
    ├── autocomplete_cliente.dart
    ├── brand_selector.dart
    ├── custom_app_bar.dart
    ├── custom_drawer.dart
    └── responsive_table.dart
```

## 📦 Instalação

### Pré-requisitos
- Flutter SDK 3.x ou superior
- Dart SDK 3.x ou superior
- Android Studio / VS Code
- Git

### Passos de Instalação

1. **Clone o repositório**
```bash
git clone <repository-url>
cd order_to_smile
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Gere os arquivos necessários**
```bash
flutter packages pub run build_runner build
```

4. **Execute o aplicativo**
```bash
flutter run
```

### Build para Produção

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (necessário macOS)
flutter build ios --release
```

## ⚙️ Configuração

### Configuração de API

Edite o arquivo `lib/connection/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://sua-api.com';
  static const String clientesEndpoint = '/clientes';
  static const String produtosEndpoint = '/produtos';
  static const String enderecosEndpoint = '/enderecos';
}
```

### Configuração de CSV

Coloque os arquivos CSV na pasta `assets/csv/`:
- `clientes.csv` - Base de clientes (15 campos)
- `produtos.csv` - Catálogo de produtos (4 campos)
- `enderecos_alternativos.csv` - Endereços alternativos (15 campos)

### Estrutura do CSV de Clientes
```csv
CPF,CNPJ,NumeroCliente,Nome1,Nome2,Rua,NumeroEndereco,Complemento,Cidade,Bairro,CodigoPostal,Telefone1,Telefone2,EquipeVendas,Email
```

### Estrutura do CSV de Produtos
```csv
Referencia,Descricao,Preco,Categoria
```

## 📱 Uso

### Primeira Execução

1. **Carregamento Inicial**: O app carrega dados do CSV automaticamente
2. **Configuração**: Acesse configurações para definir preferências
3. **Sincronização**: Configure fonte de dados (CSV/API)

### Criando um Pedido

1. **Selecione o Cliente**: Use o autocomplete para buscar
2. **Configure Entrega**: Defina endereço e condições
3. **Adicione Produtos**: Use busca por código ou descrição
4. **Finalize**: Gere PDF e envie o pedido

### Gerenciamento de Dados

- **Acesso Rápido**: Use o botão "Carregar CSV" na tela inicial
- **Switches**: Alterne entre CSV/API em cada tela base
- **Sincronização**: Configure sincronização automática

## 🔌 API

### Endpoints Esperados

#### Clientes
```
GET /clientes
POST /clientes
PUT /clientes/{id}
DELETE /clientes/{id}
```

#### Produtos
```
GET /produtos
GET /produtos/search?q={termo}
```

#### Endereços
```
GET /enderecos
GET /enderecos/cliente/{clienteId}
```

### Formato de Resposta

#### Cliente
```json
{
  "id": 1,
  "cpf": "123.456.789-00",
  "cnpj": null,
  "numeroCliente": "C001",
  "nome1": "João",
  "nome2": "Silva",
  "rua": "Rua das Flores, 123",
  "cidade": "São Paulo",
  "telefone1": "(11) 99999-9999",
  "email": "joao@email.com"
}
```

## 🗄️ Base de Dados

### Tabelas Principais

#### clientes
- `id` (INTEGER PRIMARY KEY)
- `cpf` (TEXT)
- `cnpj` (TEXT)
- `numeroCliente` (TEXT)
- `nome1` (TEXT)
- `nome2` (TEXT)
- `rua` (TEXT)
- `numeroEndereco` (TEXT)
- `complemento` (TEXT)
- `cidade` (TEXT)
- `bairro` (TEXT)
- `codigoPostal` (TEXT)
- `telefone1` (TEXT)
- `telefone2` (TEXT)
- `equipeVendas` (TEXT)
- `email` (TEXT)

#### produtos
- `id` (INTEGER PRIMARY KEY)
- `referencia` (TEXT)
- `descricao` (TEXT)
- `preco` (REAL)
- `categoria` (TEXT)

#### pedidos
- `id` (INTEGER PRIMARY KEY)
- `clienteId` (INTEGER)
- `dataCreation` (DATETIME)
- `status` (TEXT)
- `valorTotal` (REAL)
- `observacoes` (TEXT)

#### itensPedido
- `id` (INTEGER PRIMARY KEY)
- `pedidoId` (INTEGER)
- `produtoId` (INTEGER)
- `quantidade` (INTEGER)
- `precoUnitario` (REAL)
- `desconto` (REAL)

## 📅 Releases

### v1.0.4+5 (Atual)
- ✅ Campo de busca de produto com botão clear (X)
- ✅ Limpeza automática de campos após enviar pedido
- ✅ Coluna "Código" na tabela de itens
- ✅ Melhoria na UX de adição de produtos

### v1.0.3+4
- ✅ Correção: Primeira execução usa CSV ao invés de API
- ✅ Configuração de sincronização desabilitada por padrão
- ✅ Melhorias na estabilidade

### v1.0.2+3
- ✅ Switches CSV/API em todas as telas base
- ✅ Atualização da estrutura CSV (15 campos)
- ✅ Botão "Carregar CSV" de acesso rápido
- ✅ Autocomplete com CPF/CNPJ

### v1.0.1+2
- ✅ Implementação inicial completa
- ✅ Gestão de pedidos
- ✅ Sincronização dual (API/CSV)
- ✅ Geração de PDF
- ✅ Interface responsiva

## 🤝 Contribuição

### Como Contribuir

1. **Fork** o projeto
2. **Crie** uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. **Push** para a branch (`git push origin feature/AmazingFeature`)
5. **Abra** um Pull Request

### Padrões de Código

- Use **linting** do Flutter (`flutter analyze`)
- Siga **convenções Dart** de nomenclatura
- **Documente** funções públicas
- **Teste** antes de fazer commit

### Estrutura de Commits

```
tipo(escopo): descrição

[corpo opcional]

[rodapé opcional]
```

Tipos: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## 📄 Licença

Este projeto é propriedade da **Straumann Group** e destinado ao uso interno.

## 📞 Suporte

Para dúvidas ou suporte técnico, entre em contato com a equipe de desenvolvimento.

---

**Order to Smile** - Transformando pedidos em sorrisos! 😊
