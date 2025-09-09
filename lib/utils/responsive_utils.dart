import 'package:flutter/material.dart';

class ResponsiveUtils {
  /// Verifica se o dispositivo é considerado mobile baseado na largura da tela
  /// Considera mobile quando a largura é menor que 600px
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Verifica se o dispositivo é considerado tablet baseado na largura da tela
  /// Considera tablet quando a largura é maior ou igual a 600px
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Retorna o breakpoint atual baseado na largura da tela
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}
