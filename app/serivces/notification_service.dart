import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../model/medicamento.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static void _onNotificationTap(NotificationResponse notificationResponse) {
    // Implementar navegação quando a notificação for tocada
    debugPrint('Notificação tocada: ${notificationResponse.payload}');
  }

  // Notificação para medicamentos próximos ao vencimento
  static Future<void> notificarMedicamentosProximosVencimento(
      List<Medicamento> medicamentos) async {
    if (medicamentos.isEmpty) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medicamentos_vencimento',
      'Medicamentos próximos ao vencimento',
      channelDescription:
          'Notificações sobre medicamentos próximos ao vencimento',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    String titulo = 'Atenção: Medicamentos próximos ao vencimento';
    String corpo = medicamentos.length == 1
        ? '${medicamentos.first.nome} vence em breve'
        : '${medicamentos.length} medicamentos vencem em breve';

    await _notifications.show(
      0,
      titulo,
      corpo,
      platformChannelSpecifics,
      payload: 'medicamentos_vencimento',
    );
  }

  // Notificação para estoque baixo
  static Future<void> notificarEstoqueBaixo(
      List<Medicamento> medicamentos) async {
    if (medicamentos.isEmpty) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'estoque_baixo',
      'Estoque baixo',
      channelDescription: 'Notificações sobre medicamentos com estoque baixo',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    String titulo = 'Alerta: Estoque baixo';
    String corpo = medicamentos.length == 1
        ? '${medicamentos.first.nome} está com estoque baixo (${medicamentos.first.quantidade})'
        : '${medicamentos.length} medicamentos com estoque baixo';

    await _notifications.show(
      1,
      titulo,
      corpo,
      platformChannelSpecifics,
      payload: 'estoque_baixo',
    );
  }

  // Notificação para medicamentos vencidos
  static Future<void> notificarMedicamentosVencidos(
      List<Medicamento> medicamentos) async {
    if (medicamentos.isEmpty) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medicamentos_vencidos',
      'Medicamentos vencidos',
      channelDescription: 'Notificações sobre medicamentos vencidos',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    String titulo = 'URGENTE: Medicamentos vencidos';
    String corpo = medicamentos.length == 1
        ? '${medicamentos.first.nome} está vencido'
        : '${medicamentos.length} medicamentos vencidos no estoque';

    await _notifications.show(
      2,
      titulo,
      corpo,
      platformChannelSpecifics,
      payload: 'medicamentos_vencidos',
    );
  }

  // Notificação de sincronização completada
  static Future<void> notificarSincronizacaoCompleta(
      int itensAtualizados) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sincronizacao',
      'Sincronização',
      channelDescription: 'Notificações sobre sincronização de dados',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notifications.show(
      3,
      'Sincronização completada',
      '$itensAtualizados itens foram atualizados com sucesso',
      platformChannelSpecifics,
      payload: 'sincronizacao_completa',
    );
  }

  // Agendar notificação recorrente para verificação de estoque
  static Future<void> agendarVerificacaoEstoque() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'verificacao_estoque',
      'Verificação de estoque',
      channelDescription: 'Lembrete para verificar o estoque',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notifications.periodicallyShow(
      4,
      'Lembrete: Verificar estoque',
      'É hora de verificar medicamentos vencidos e estoque baixo',
      RepeatInterval.daily,
      platformChannelSpecifics,
      payload: 'verificacao_estoque',
    );
  }

  // Cancelar todas as notificações
  static Future<void> cancelarTodasNotificacoes() async {
    await _notifications.cancelAll();
  }

  // Cancelar notificação específica
  static Future<void> cancelarNotificacao(int id) async {
    await _notifications.cancel(id);
  }

  // Verificar permissões de notificação
  static Future<bool> verificarPermissoes() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestPermission();
      return granted ?? false;
    }

    return true;
  }
}
