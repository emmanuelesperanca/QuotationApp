// Ficheiro: lib/connection/web.dart
// ATUALIZADO: Esta implementação agora lança um erro, desativando o suporte web.

import 'package:drift/drift.dart';

QueryExecutor openConnection() {
  // Lança um erro explícito para indicar que a web não é uma plataforma suportada
  // para este aplicativo, conforme solicitado.
  throw UnsupportedError(
      'Esta aplicação não suporta a plataforma web e requer um dispositivo móvel.');
}
