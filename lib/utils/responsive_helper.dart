import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints para diferentes tamanhos de tela
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  // Verifica se é tablet ou maior (versão segura)
  static bool isTablet(BuildContext context) {
    try {
      return MediaQuery.of(context).size.width >= tabletBreakpoint;
    } catch (e) {
      // Fallback para tablet se não conseguir acessar MediaQuery
      return true;
    }
  }

  // Verifica se é desktop (versão segura)
  static bool isDesktop(BuildContext context) {
    try {
      return MediaQuery.of(context).size.width >= desktopBreakpoint;
    } catch (e) {
      return false;
    }
  }

  // Verifica se é celular (versão segura)
  static bool isMobile(BuildContext context) {
    try {
      return MediaQuery.of(context).size.width < tabletBreakpoint;
    } catch (e) {
      // Fallback para mobile se não conseguir acessar MediaQuery
      return false;
    }
  }

  // Versão alternativa usando LayoutBuilder (mais segura)
  static bool isTabletLayout(double maxWidth) {
    return maxWidth >= tabletBreakpoint;
  }

  static bool isMobileLayout(double maxWidth) {
    return maxWidth < tabletBreakpoint;
  }

  // Retorna padding responsivo
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    }
    return const EdgeInsets.all(16.0);
  }

  // Retorna largura máxima para formulários
  static double getFormMaxWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isTablet(context)) {
      return screenWidth * 0.7; // 70% da tela em tablets
    }
    return screenWidth * 0.9; // 90% da tela em celulares
  }

  // Retorna número de colunas para grids responsivos
  static int getGridColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 3;
    if (screenWidth > 600) return 2;
    return 1;
  }

  // Widget container responsivo para formulários
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    bool centerContent = true,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= tabletBreakpoint;
        final maxWidth = isTablet ? constraints.maxWidth * 0.7 : constraints.maxWidth * 0.9;
        final padding = isTablet ? const EdgeInsets.all(24.0) : const EdgeInsets.all(16.0);
        
        final content = Container(
          width: maxWidth,
          padding: padding,
          child: child,
        );

        if (centerContent && isTablet) {
          return Center(child: content);
        }
        return content;
      },
    );
  }

  // Tamanho de fonte responsivo
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize * 0.9;
    }
    return baseFontSize;
  }

  // TextStyle responsivo com fallback seguro
  static TextStyle? getResponsiveTextStyle(BuildContext context, TextStyle? baseStyle, double baseFontSize) {
    if (baseStyle == null) return null;
    
    try {
      final responsiveFontSize = getResponsiveFontSize(context, baseFontSize);
      return baseStyle.copyWith(fontSize: responsiveFontSize);
    } catch (e) {
      // Fallback para tamanho fixo se houver erro
      return baseStyle.copyWith(fontSize: baseFontSize);
    }
  }

  // Altura de botões responsiva
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 48.0; // Mais alto para touch em celulares
    }
    return 40.0;
  }

  // Espaçamento entre elementos
  static double getSpacing(BuildContext context, {double base = 16.0}) {
    if (isMobile(context)) {
      return base * 0.8; // Menos espaço em celulares
    }
    return base;
  }
}

// Widget wrapper para scrolling responsivo
class ResponsiveScrollView extends StatelessWidget {
  final Widget child;
  final bool alwaysScrollable;

  const ResponsiveScrollView({
    super.key,
    required this.child,
    this.alwaysScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < ResponsiveHelper.tabletBreakpoint;
        
        if (isMobile || alwaysScrollable) {
          return SingleChildScrollView(
            child: child,
          );
        }
        return child;
      },
    );
  }
}

// Widget para campos de formulário responsivos
class ResponsiveFormField extends StatelessWidget {
  final String label;
  final Widget field;
  final bool isRequired;

  const ResponsiveFormField({
    super.key,
    required this.label,
    required this.field,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getSpacing(context, base: 8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: Theme.of(context).textTheme.labelLarge,
              children: isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context, base: 4.0)),
          field,
        ],
      ),
    );
  }
}
