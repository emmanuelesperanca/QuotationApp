# ConfigService - Controle Remoto de Versões e Notificações

## Visão Geral
O `ConfigService` é responsável por verificar periodicamente (a cada 30 minutos) uma configuração remota que permite:
- Bloquear versões específicas do app
- Definir versão mínima permitida
- Mostrar notificações/avisos para os usuários
- Controlar quando essas verificações acontecem

## API Endpoint
```
URL: https://default1900aa23cb5a4a458ad0968d229e95.5f.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/695fc5ae53844e5d88894c5ace45b9e2/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=ismWhvgPgIWB13wDUhIYekdrHL_8qIsXrnrNXzXFe1Y
Método: POST
Content-Type: application/json
```

## Schema JSON de Requisição (enviado para a API)
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Config Request Schema",
  "description": "Schema para requisição de configuração remota do app",
  "type": "object",
  "properties": {
    "action": {
      "description": "Ação solicitada à API",
      "type": "string",
      "const": "get_active_config"
    },
    "app_name": {
      "description": "Nome do aplicativo solicitando a configuração",
      "type": "string",
      "const": "Order Simulator"
    },
    "timestamp": {
      "description": "Timestamp da requisição em formato ISO 8601",
      "type": "string",
      "format": "date-time"
    }
  },
  "required": ["action", "app_name", "timestamp"]
}
```

**Exemplo de Requisição:**
```json
{
  "action": "get_active_config",
  "app_name": "Order Simulator", 
  "timestamp": "2025-09-05T10:30:00Z"
}
```

## Schema JSON de Resposta (esperado da API)
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Config Response Schema",
  "description": "Schema para resposta da configuração remota do app",
  "type": "object",
  "properties": {
    "min_allowed_version": {
      "description": "Versão mínima permitida para o app funcionar (formato X.Y.Z)",
      "type": "string"
    },
    "blocked_versions": {
      "description": "Lista de versões bloqueadas separadas por vírgula (ex: '1.0.2,1.0.4')",
      "type": "string"
    },
    "notification_title": {
      "description": "Título do pop-up de notificação (se vazio, não mostra notificação)",
      "type": ["string", "null"],
      "maxLength": 100
    },
    "notification_message": {
      "description": "Mensagem do pop-up de notificação",
      "type": ["string", "null"]
    },
    "force_update_message": {
      "description": "Mensagem para quando o app for bloqueado por versão",
      "type": ["string", "null"]
    },
    "is_active": {
      "description": "Flag para ativar/desativar esta configuração (1=Ativa, 0=Inativa)",
      "type": "boolean"
    },
    "last_modified": {
      "description": "Data da última modificação da configuração",
      "type": "string",
      "format": "date-time"
    }
  },
  "required": ["min_allowed_version", "is_active"]
}
```

## 🔧 **Schema Simplificado para Power Automate**
**(Use este schema no Power Automate para evitar erros de pattern)**

```json
{
  "type": "object",
  "properties": {
    "min_allowed_version": {
      "type": "string"
    },
    "blocked_versions": {
      "type": "string"
    },
    "notification_title": {
      "type": "string"
    },
    "notification_message": {
      "type": "string"
    },
    "force_update_message": {
      "type": "string"
    },
    "is_active": {
      "type": "boolean"
    },
    "last_modified": {
      "type": "string"
    }
  },
  "required": ["min_allowed_version", "is_active"]
}
```

**Exemplo de Resposta:**
```json
{
  "min_allowed_version": "1.0.0",
  "blocked_versions": "1.0.2,1.0.4",
  "notification_title": "Nova Atualização Disponível",
  "notification_message": "Uma nova versão do aplicativo está disponível com melhorias importantes.",
  "force_update_message": "Esta versão não é mais suportada. Entre em contato com o suporte para atualizar.",
  "is_active": true,
  "last_modified": "2025-09-05T10:00:00Z"
}
```

## Estrutura da Tabela de Banco de Dados
```sql
CREATE TABLE RPA_PROJ_FINANCE_EXCELLENCE.dbo.[RPA_448_Order Simulator_Config] (
    id INT IDENTITY(1,1) PRIMARY KEY,
    min_allowed_version VARCHAR(20) NOT NULL,
    blocked_versions VARCHAR(255) NULL,
    notification_title NVARCHAR(100) NULL,
    notification_message NVARCHAR(MAX) NULL,
    force_update_message NVARCHAR(MAX) NULL,
    is_active BIT DEFAULT 1 NOT NULL,
    last_modified DATETIME DEFAULT GETDATE()
);
```

## 🗄️ **Exemplos de INSERT para Testes**

### Exemplo 1: Notificação de Teste (Recomendado para testar)
```sql
INSERT INTO RPA_PROJ_FINANCE_EXCELLENCE.dbo.[RPA_448_Order Simulator_Config] 
(
    min_allowed_version,
    blocked_versions,
    notification_title,
    notification_message,
    force_update_message,
    is_active
)
VALUES 
(
    '1.0.0',                                          -- Permite todas as versões 1.0.0+
    '',                                               -- Nenhuma versão bloqueada
    'Teste de Notificação',                          -- Título do popup
    'Esta é uma mensagem de teste do sistema de configuração remota. Se você está vendo isso, o ConfigService está funcionando corretamente!', -- Mensagem
    NULL,                                             -- Sem bloqueio
    1                                                 -- Configuração ativa
);
```

### Exemplo 2: Configuração de Produção (Sem notificação)
```sql
INSERT INTO RPA_PROJ_FINANCE_EXCELLENCE.dbo.[RPA_448_Order Simulator_Config] 
(
    min_allowed_version,
    blocked_versions,
    notification_title,
    notification_message,
    force_update_message,
    is_active
)
VALUES 
(
    '1.0.0',                                          -- Versão mínima permitida
    '',                                               -- Nenhuma versão bloqueada
    NULL,                                             -- Sem notificação
    NULL,                                             -- Sem notificação
    'Esta versão do aplicativo não é mais suportada. Entre em contato com o suporte técnico para atualizar.', -- Mensagem de bloqueio
    1                                                 -- Configuração ativa
);
```

### Exemplo 3: Bloquear versão específica
```sql
INSERT INTO RPA_PROJ_FINANCE_EXCELLENCE.dbo.[RPA_448_Order Simulator_Config] 
(
    min_allowed_version,
    blocked_versions,
    notification_title,
    notification_message,
    force_update_message,
    is_active
)
VALUES 
(
    '1.0.0',                                          -- Versão mínima
    '1.0.2,1.0.4',                                    -- Bloqueia versões específicas
    NULL,                                             -- Sem notificação
    NULL,                                             -- Sem notificação
    'A versão que você está usando contém bugs críticos. Por favor, atualize para a versão mais recente.', -- Mensagem de bloqueio
    1                                                 -- Configuração ativa
);
```

### Exemplo 4: Manutenção programada
```sql
INSERT INTO RPA_PROJ_FINANCE_EXCELLENCE.dbo.[RPA_448_Order Simulator_Config] 
(
    min_allowed_version,
    blocked_versions,
    notification_title,
    notification_message,
    force_update_message,
    is_active
)
VALUES 
(
    '1.0.0',                                          -- Versão mínima
    '',                                               -- Nenhuma versão bloqueada
    'Manutenção Programada',                          -- Título
    'Atenção: Haverá uma manutenção programada no sistema no dia 15/09/2025 das 02:00 às 04:00. Durante este período, algumas funcionalidades podem estar indisponíveis.', -- Mensagem
    NULL,                                             -- Sem bloqueio
    1                                                 -- Configuração ativa
);
```

### Desativar configuração (limpar tabela)
```sql
-- Para desativar todas as configurações ativas
UPDATE RPA_PROJ_FINANCE_EXCELLENCE.dbo.[RPA_448_Order Simulator_Config] 
SET is_active = 0 
WHERE is_active = 1;

-- Ou deletar todos os registros
DELETE FROM RPA_PROJ_FINANCE_EXCELLENCE.dbo.[RPA_448_Order Simulator_Config];
```

## 🔧 **Query SQL para Power Automate**
**(Use esta query na atividade "Executar uma consulta SQL (V2)")**

```sql
SELECT TOP 1
    min_allowed_version,
    ISNULL(blocked_versions, '') AS blocked_versions,
    ISNULL(notification_title, '') AS notification_title,
    ISNULL(notification_message, '') AS notification_message,
    ISNULL(force_update_message, '') AS force_update_message,
    CAST(is_active AS bit) AS is_active,
    FORMAT(last_modified, 'yyyy-MM-ddTHH:mm:ss.fffZ') AS last_modified
FROM RPA_PROJ_FINANCE_EXCELLENCE.dbo.[RPA_448_Order Simulator_Config]
WHERE is_active = 1
ORDER BY last_modified DESC;
```

### **📋 Explicação da Query:**

- **`TOP 1`**: Retorna apenas a configuração mais recente ativa
- **`ISNULL(..., '')`**: Converte valores NULL em strings vazias (compatível com Power Automate)
- **`CAST(is_active AS bit)`**: Garante que o valor seja boolean
- **`FORMAT(last_modified, ...)`**: Converte data para ISO 8601 string
- **`WHERE is_active = 1`**: Apenas configurações ativas
- **`ORDER BY last_modified DESC`**: Mais recente primeiro

### **🎯 Resultado Esperado:**
```json
{
  "min_allowed_version": "1.0.0",
  "blocked_versions": "",
  "notification_title": "Teste de Notificação",
  "notification_message": "Esta é uma mensagem de teste...",
  "force_update_message": "",
  "is_active": true,
  "last_modified": "2025-09-05T10:30:00.000Z"
}

## Como Usar no Código

### 1. Verificação Automática (já implementado)
```dart
// No MainLayout (após login)
WidgetsBinding.instance.addPostFrameCallback((_) {
  ConfigService.checkRemoteConfig(context);
});

// Na tela de pedidos (verificação periódica)
WidgetsBinding.instance.addPostFrameCallback((_) {
  ConfigService.checkRemoteConfig(context);
});
```

### 2. Verificação Manual
```dart
// Para verificar a configuração manualmente
await ConfigService.checkRemoteConfig(context);
```

## Lógica de Funcionamento

### ⚡ **Comportamento Offline (FAIL-SAFE)**
**O app SEMPRE funciona offline, mesmo sem verificar configurações!**

- **✅ Sem internet**: App funciona 100% offline, nenhuma verificação é feita
- **✅ API fora do ar**: Erro é ignorado silenciosamente, app continua normal
- **✅ Timeout (20s)**: Desiste da verificação, app continua funcionando
- **✅ Resposta inválida**: Ignora a resposta, app continua normal
- **✅ Primeira vez**: Mesmo sem nunca ter verificado, app funciona

**IMPORTANTE**: O bloqueio só acontece se:
1. Houver internet disponível
2. A API responder corretamente
3. A configuração indicar bloqueio para a versão atual

### Intervalos de Verificação
- **Primeira verificação**: Sempre que o usuário faz login (MainLayout)
- **Verificações periódicas**: A cada 30 segundos, nas telas principais ⚠️ **MODO TESTE**
- **Não bloqueia o app**: Se a API não responder, o app continua funcionando normalmente

> ⚠️ **IMPORTANTE**: O intervalo está configurado para 30 segundos apenas para testes. Em produção, altere para 30 minutos!

### Tipos de Bloqueio
1. **Versão específica bloqueada**: Se a versão atual estiver na lista `blocked_versions`
2. **Versão abaixo da mínima**: Se a versão atual for menor que `min_allowed_version`

### Comportamentos
- **App bloqueado**: Mostra popup que não pode ser fechado
- **Notificação simples**: Mostra popup informativo que pode ser fechado
- **Sem configuração ativa**: Nada acontece, app funciona normalmente

## Logs de Debug
O serviço gera logs detalhados para debug:
```
ConfigService: Verificando configuração remota...
ConfigService: Versão atual do app: 1.0.5
ConfigService: Versão mínima permitida: 1.0.0
ConfigService: Versões bloqueadas: [1.0.2, 1.0.4]
ConfigService: Configuração recebida, processando...
```

## Exemplos de Configuração

### Bloquear versão específica
```json
{
  "min_allowed_version": "1.0.0",
  "blocked_versions": "1.0.3",
  "force_update_message": "A versão 1.0.3 contém um bug crítico. Por favor, atualize para a versão mais recente.",
  "is_active": true
}
```

### Definir versão mínima
```json
{
  "min_allowed_version": "1.2.0",
  "blocked_versions": "",
  "force_update_message": "Versões anteriores à 1.2.0 não são mais suportadas.",
  "is_active": true
}
```

### Mostrar notificação
```json
{
  "min_allowed_version": "1.0.0",
  "blocked_versions": "",
  "notification_title": "Manutenção Programada",
  "notification_message": "Haverá uma manutenção no sistema no dia 15/09 das 02:00 às 04:00.",
  "is_active": true
}
```

### Desabilitar controle
```json
{
  "is_active": false
}
```

## 🔒 **Cenários de Funcionamento Offline**

### Cenário 1: Usuário sem internet
```
Usuário abre o app → Sem conexão → Nenhuma verificação → App funciona normalmente
```

### Cenário 2: API fora do ar
```
Usuário abre o app → Tem internet → API não responde → Timeout 20s → App funciona normalmente
```

### Cenário 3: Primeira instalação offline
```
App instalado → Nunca verificou config → Sem internet → App funciona normalmente
```

### Cenário 4: Versão bloqueada, mas sem internet
```
Versão 1.0.3 (bloqueada) → Sem internet → Não verifica → App funciona normalmente
```

### Cenário 5: Voltou a ter internet com versão bloqueada
```
Versão 1.0.3 (bloqueada) → Conectou internet → Verifica config → Mostra bloqueio
```

**Resumo**: O bloqueio só acontece quando há internet E a API confirma o bloqueio!
