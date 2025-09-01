import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme.dart';
import '../../providers/theme_notifier.dart';

class TelaConfiguracoes extends StatelessWidget {
  const TelaConfiguracoes({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Configurações de Tema'),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: availableThemes.map((theme) {
            return Card(
              color: Colors.black.withOpacity(0.5),
              child: RadioListTile<String>(
                title: Text(theme.name),
                subtitle: Row(
                  children: [
                    Container(width: 20, height: 20, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Container(width: 20, height: 20, color: theme.secondaryColor),
                  ],
                ),
                value: theme.id,
                groupValue: themeNotifier.currentThemeId,
                onChanged: (value) {
                  if (value != null) {
                    themeNotifier.updateTheme(value);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
