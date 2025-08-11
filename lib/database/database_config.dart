import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'dart:io';

class DatabaseConfig {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      debugPrint('Usando IndexedDB via sqflite_common_ffi_web');
      _isInitialized = true;
      return;
    }

    try {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        debugPrint('SQLite FFI inicializado para desktop');
      } else {
        debugPrint('Usando SQLite nativo para mobile');
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Erro ao inicializar configuração do banco: $e');
      _isInitialized = true;
    }
  }

  static bool get isWebPlatform => kIsWeb;
  static bool get isInitialized => _isInitialized;

  static bool get isDatabaseSupported => true; // agora é suportado no web
}
