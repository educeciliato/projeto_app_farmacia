import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class UrlLauncherService {
  // Fazer chamada telefônica
  static Future<void> fazerLigacao(String telefone) async {
    final url = Uri.parse('tel:$telefone');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Não foi possível fazer a ligação para $telefone';
    }
  }

  // Enviar SMS
  static Future<void> enviarSMS(String telefone, [String? mensagem]) async {
    String url = 'sms:$telefone';
    if (mensagem != null && mensagem.isNotEmpty) {
      url += '?body=${Uri.encodeComponent(mensagem)}';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Não foi possível enviar SMS para $telefone';
    }
  }

  // Enviar email
  static Future<void> enviarEmail(
    String email, {
    String? assunto,
    String? corpo,
    List<String>? cc,
    List<String>? bcc,
  }) async {
    String url = 'mailto:$email';
    List<String> params = [];

    if (assunto != null && assunto.isNotEmpty) {
      params.add('subject=${Uri.encodeComponent(assunto)}');
    }
    if (corpo != null && corpo.isNotEmpty) {
      params.add('body=${Uri.encodeComponent(corpo)}');
    }
    if (cc != null && cc.isNotEmpty) {
      params.add('cc=${cc.join(',')}');
    }
    if (bcc != null && bcc.isNotEmpty) {
      params.add('bcc=${bcc.join(',')}');
    }

    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Não foi possível enviar email para $email';
    }
  }

  // Abrir WhatsApp
  static Future<void> abrirWhatsApp(String telefone, [String? mensagem]) async {
    // Remove caracteres especiais do telefone
    String numeroLimpo = telefone.replaceAll(RegExp(r'[^\d]'), '');

    String url = 'https://wa.me/$numeroLimpo';
    if (mensagem != null && mensagem.isNotEmpty) {
      url += '?text=${Uri.encodeComponent(mensagem)}';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir WhatsApp';
    }
  }

  // Abrir URL no navegador
  static Future<void> abrirURL(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir a URL: $url';
    }
  }

  // Compartilhar via sistema
  static Future<void> compartilhar(String texto) async {
    // Para compartilhamento simples, usamos intent no Android
    final url = 'https://wa.me/?text=${Uri.encodeComponent(texto)}';
    await abrirURL(url);
  }

  // Abrir configurações do sistema
  static Future<void> abrirConfiguracoes() async {
    const url = 'app-settings:';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Não foi possível abrir as configurações';
    }
  }

  // Métodos de conveniência com tratamento de erro
  static Future<void> contatarLaboratorio(
      BuildContext context, String telefone, String email, String nome) async {
    try {
      final escolha = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Contatar $nome'),
            content: const Text('Como deseja entrar em contato?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('telefone'),
                child: const Text('Telefone'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('email'),
                child: const Text('Email'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('whatsapp'),
                child: const Text('WhatsApp'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );

      if (escolha == 'telefone') {
        await fazerLigacao(telefone);
      } else if (escolha == 'email') {
        await enviarEmail(email, assunto: 'Contato - Sistema Farmácia');
      } else if (escolha == 'whatsapp') {
        await abrirWhatsApp(
            telefone, 'Olá, entro em contato através do sistema de farmácia.');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Reportar problema por email
  static Future<void> reportarProblema(String descricao) async {
    const email = 'suporte@farmacia.com';
    const assunto = 'Relatório de Problema - Sistema Farmácia';

    final corpo = '''
Descrição do Problema:
$descricao

---
Informações do Sistema:
Data: ${DateTime.now()}
Versão: 1.0.0
    ''';

    await enviarEmail(email, assunto: assunto, corpo: corpo);
  }
}
