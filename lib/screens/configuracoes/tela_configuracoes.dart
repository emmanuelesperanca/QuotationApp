import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme.dart';
import '../../providers/theme_notifier.dart';
import '../../database.dart';
import '../../providers/app_data_notifier.dart';
import '../../services/config_service.dart';
import '../../utils/responsive_helper.dart';

class TelaConfiguracoes extends StatelessWidget {
  final AppDatabase database;
  const TelaConfiguracoes({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: ResponsiveHelper.isMobile(context) ? AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.black.withOpacity(0.8),
        foregroundColor: Colors.white,
      ) : null,
      body: ResponsiveScrollView(
        child: ResponsiveHelper.responsiveContainer(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!ResponsiveHelper.isMobile(context)) ...[
                Text(
                  'Configurações de Tema',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
              ],
              ...availableThemes.map((theme) {
                return Card(
                  color: Colors.black.withOpacity(0.5),
                  margin: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.getSpacing(context, base: 4.0),
                  ),
                  child: RadioListTile<String>(
                    title: Text(
                      theme.name,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Container(
                          width: ResponsiveHelper.isMobile(context) ? 16 : 20,
                          height: ResponsiveHelper.isMobile(context) ? 16 : 20,
                          color: theme.primaryColor,
                        ),
                        SizedBox(width: ResponsiveHelper.getSpacing(context, base: 8.0)),
                        Container(
                          width: ResponsiveHelper.isMobile(context) ? 16 : 20,
                          height: ResponsiveHelper.isMobile(context) ? 16 : 20,
                          color: theme.secondaryColor,
                        ),
                      ],
                    ),
                    value: theme.id,
                    groupValue: themeNotifier.currentThemeId,
                    activeColor: theme.primaryColor,
                    onChanged: (value) {
                      if (value != null) {
                        themeNotifier.updateTheme(value);
                      }
                    },
                  ),
                );
              }).toList(),
              
              SizedBox(height: ResponsiveHelper.getSpacing(context, base: 32.0)),
              const Divider(color: Colors.white54),
              SizedBox(height: ResponsiveHelper.getSpacing(context)),
              
              // Seção de Desenvolvimento/Debug
              Card(
                color: Colors.red.withOpacity(0.1),
                child: ExpansionTile(
                  leading: const Icon(Icons.build, color: Colors.orange),
                  title: Text(
                    'Ferramentas de Desenvolvimento',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    ),
                  ),
                  subtitle: Text(
                    '⚠️ Use apenas se houver problemas',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                    ),
                  ),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.refresh, color: Colors.red),
                      title: Text(
                        'Reset Completo do Banco de Dados',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                        ),
                      ),
                      subtitle: Text(
                        'Apaga todos os dados e recria as tabelas',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                        ),
                      ),
                      onTap: () => _confirmarResetBanco(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.sync_problem, color: Colors.orange),
                      title: Text(
                        'Forçar Reset Sincronização',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                        ),
                      ),
                      subtitle: Text(
                        'Reset do estado de sincronização',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                        ),
                      ),
                      onTap: () => _forcarResetSync(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.cloud_sync, color: Colors.blue),
                      title: Text(
                        'Testar Configuração Remota',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                        ),
                      ),
                      subtitle: Text(
                        'Força verificação da configuração na API',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                        ),
                      ),
                      onTap: () => _testarConfigRemota(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarResetBanco(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('⚠️ Reset do Banco'),
          ],
        ),
        content: const Text(
          'ATENÇÃO: Esta ação irá apagar TODOS os dados do aplicativo (clientes, produtos, pedidos, etc.) e recriar as tabelas.\n\n'
          'Use apenas se houver problemas de corrupção no banco de dados.\n\n'
          'Tem certeza que deseja continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, Reset Completo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await _executarResetBanco(context);
    }
  }

  Future<void> _executarResetBanco(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Resetando banco de dados...'),
            ],
          ),
        ),
      );

      await database.resetDatabase();

      if (context.mounted) {
        Navigator.pop(context); // Fechar loading
        messenger.showSnackBar(
          const SnackBar(
            content: Text('✅ Reset do banco de dados concluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fechar loading
        messenger.showSnackBar(
          SnackBar(
            content: Text('❌ Erro durante reset: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _forcarResetSync(BuildContext context) {
    final appData = Provider.of<AppDataNotifier>(context, listen: false);
    appData.forceResetSyncState();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Estado de sincronização resetado!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _testarConfigRemota(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Testando configuração remota...'),
            ],
          ),
        ),
      );

      // Força a próxima verificação
      await ConfigService.forceNextCheck();
      
      // Chama a verificação
      await ConfigService.checkRemoteConfig(context);

      if (context.mounted) {
        Navigator.pop(context); // Fechar loading
        messenger.showSnackBar(
          const SnackBar(
            content: Text('✅ Teste de configuração remota concluído! Verifique os logs no console.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fechar loading
        messenger.showSnackBar(
          SnackBar(
            content: Text('❌ Erro durante teste: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
