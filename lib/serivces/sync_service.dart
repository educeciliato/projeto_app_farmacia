import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../dao/medicamento_dao.dart';
import '../dao/laboratorio_dao.dart';
import '../database/database_helper.dart';
import '../model/medicamento.dart';
import '../model/laboratorio.dart';
import 'api_service.dart';
import 'notification_service.dart';

class SyncService {
  final ApiService _apiService = ApiService();
  final MedicamentoDAO _medicamentoDAO = MedicamentoDAO();
  final LaboratorioDAO _laboratorioDAO = LaboratorioDAO();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Sincronizar dados com API externa
  Future<SyncResult> sincronizarDados() async {
    try {
      debugPrint('Iniciando sincronização com API externa...');

      // 1. Buscar medicamentos da API externa
      final medicamentosExternos =
          await _apiService.buscarMedicamentosExternos();
      int medicamentosAdicionados = 0;
      int medicamentosAtualizados = 0;

      for (var dadosMedicamento in medicamentosExternos) {
        // Verificar se o laboratório existe, senão criar
        final nomeLaboratorio = dadosMedicamento['laboratorio'];
        Laboratorio? laboratorio =
            await _laboratorioDAO.getLaboratorioByNome(nomeLaboratorio);

        if (laboratorio == null) {
          laboratorio = Laboratorio(nome: nomeLaboratorio);
          await _laboratorioDAO.insertLaboratorio(laboratorio);
          laboratorio =
              await _laboratorioDAO.getLaboratorioByNome(nomeLaboratorio);
        }

        // Verificar se o medicamento já existe
        final medicamentoExistente =
            await _medicamentoDAO.getMedicamentoById(dadosMedicamento['id']);

        final medicamento = Medicamento(
          id: dadosMedicamento['id'],
          nome: dadosMedicamento['nome'],
          tipo: dadosMedicamento['tipo'],
          doseMg: dadosMedicamento['doseMg'],
          descricao: dadosMedicamento['descricao'],
          laboratorio: nomeLaboratorio,
          dataFabricacao: dadosMedicamento['dataFabricacao'],
          dataValidade: dadosMedicamento['dataValidade'],
          lote: dadosMedicamento['lote'],
          quantidade: dadosMedicamento['quantidade'],
          isMedicamentoControlado: dadosMedicamento['isMedicamentoControlado'],
        );

        if (medicamentoExistente == null) {
          await _medicamentoDAO.insertMedicamento(
              medicamento, laboratorio!.id!);
          medicamentosAdicionados++;
        } else {
          await _medicamentoDAO.updateMedicamento(
              medicamento, laboratorio!.id!);
          medicamentosAtualizados++;
        }

        // Registrar sincronização
        await _registrarSincronizacao('medicamentos', medicamento.id);
      }

      // 2. Buscar preços atualizados
      final medicamentosLocais = await _medicamentoDAO.getAllMedicamentos();
      final ids = medicamentosLocais.map((m) => m.id).toList();

      if (ids.isNotEmpty) {
        try {
          final precos = await _apiService.buscarPrecosMedicamentos(ids);
          debugPrint('Preços obtidos da API: ${precos.length} itens');
        } catch (e) {
          debugPrint('Erro ao buscar preços: $e');
        }
      }

      // 3. Verificar disponibilidade
      if (ids.isNotEmpty) {
        try {
          final disponibilidade =
              await _apiService.verificarDisponibilidade(ids);
          debugPrint(
              'Disponibilidade verificada para ${disponibilidade.length} medicamentos');
        } catch (e) {
          debugPrint('Erro ao verificar disponibilidade: $e');
        }
      }

      // 4. Limpar dados antigos de sincronização
      await _databaseHelper.cleanOldSyncData();

      // 5. Notificar sobre a sincronização
      final totalItens = medicamentosAdicionados + medicamentosAtualizados;
      if (totalItens > 0) {
        await NotificationService.notificarSincronizacaoCompleta(totalItens);
      }

      return SyncResult(
        sucesso: true,
        itensAdicionados: medicamentosAdicionados,
        itensAtualizados: medicamentosAtualizados,
        mensagem: 'Sincronização completada com sucesso!',
      );
    } catch (e) {
      debugPrint('Erro na sincronização: $e');
      return SyncResult(
        sucesso: false,
        erro: e.toString(),
        mensagem: 'Erro na sincronização: $e',
      );
    }
  }

  // Sincronização incremental (apenas mudanças)
  Future<SyncResult> sincronizacaoIncremental() async {
    try {
      // Verificar último sync
      final ultimoSync = await _obterUltimoSync();
      debugPrint('Última sincronização: $ultimoSync');

      // Implementar lógica de sincronização incremental
      // Por simplicidade, faremos sync completo
      return await sincronizarDados();
    } catch (e) {
      return SyncResult(
        sucesso: false,
        erro: e.toString(),
        mensagem: 'Erro na sincronização incremental: $e',
      );
    }
  }

  // Enviar dados locais para API (upload)
  Future<SyncResult> enviarDadosParaAPI() async {
    try {
      final medicamentosLocais = await _medicamentoDAO.getAllMedicamentos();
      int itensSincronizados = 0;

      for (var medicamento in medicamentosLocais) {
        final dados = {
          'id': medicamento.id,
          'nome': medicamento.nome,
          'tipo': medicamento.tipo,
          'doseMg': medicamento.doseMg,
          'laboratorio': medicamento.laboratorio,
          'quantidade': medicamento.quantidade,
          'dataValidade': medicamento.dataValidade.toIso8601String(),
        };

        final sucesso = await _apiService.sincronizarDados(dados);
        if (sucesso) {
          itensSincronizados++;
          await _registrarSincronizacao('medicamentos', medicamento.id);
        }
      }

      return SyncResult(
        sucesso: true,
        itensAtualizados: itensSincronizados,
        mensagem: '$itensSincronizados itens enviados para a API',
      );
    } catch (e) {
      return SyncResult(
        sucesso: false,
        erro: e.toString(),
        mensagem: 'Erro ao enviar dados: $e',
      );
    }
  }

  // Verificar conflitos de sincronização
  Future<List<ConflitoDados>> verificarConflitos() async {
    try {
      final conflitos = <ConflitoDados>[];

      // Simular verificação de conflitos
      final medicamentosLocais = await _medicamentoDAO.getAllMedicamentos();

      for (var medicamento in medicamentosLocais.take(2)) {
        // Simular alguns conflitos
        if (medicamento.id.contains('API_')) {
          conflitos.add(ConflitoDados(
            id: medicamento.id,
            tabela: 'medicamentos',
            campoConflito: 'quantidade',
            valorLocal: medicamento.quantidade.toString(),
            valorRemoto: (medicamento.quantidade + 10).toString(),
            dataConflito: DateTime.now(),
          ));
        }
      }

      return conflitos;
    } catch (e) {
      debugPrint('Erro ao verificar conflitos: $e');
      return [];
    }
  }

  // Resolver conflito específico
  Future<bool> resolverConflito(
      ConflitoDados conflito, bool manterLocal) async {
    try {
      if (conflito.tabela == 'medicamentos') {
        final medicamento =
            await _medicamentoDAO.getMedicamentoById(conflito.id);
        if (medicamento != null) {
          if (!manterLocal) {
            // Aplicar valor remoto
            // Implementar lógica de atualização
            debugPrint('Aplicando valor remoto para ${conflito.id}');
          }
          await _registrarSincronizacao(conflito.tabela, conflito.id);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao resolver conflito: $e');
      return false;
    }
  }

  // Métodos auxiliares
  Future<void> _registrarSincronizacao(String tabela, String recordId) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'sync_data',
      {
        'table_name': tabela,
        'record_id': recordId,
        'last_sync': DateTime.now().toIso8601String(),
        'sync_status': 'synced',
      },
    );
  }

  Future<DateTime?> _obterUltimoSync() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'sync_data',
      columns: ['last_sync'],
      orderBy: 'last_sync DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return DateTime.parse(result.first['last_sync'] as String);
    }
    return null;
  }

  // Status da conectividade
  Future<bool> verificarConectividade() async {
    try {
      final medicamentos = await _apiService.buscarMedicamentosExternos();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Estatísticas de sincronização
  Future<EstatisticasSync> obterEstatisticas() async {
    final db = await _databaseHelper.database;

    final totalSynced = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sync_data WHERE sync_status = ?',
      ['synced'],
    );

    final lastSync = await _obterUltimoSync();

    return EstatisticasSync(
      totalItensSincronizados: totalSynced.first['count'] as int,
      ultimaSincronizacao: lastSync,
      statusConectividade: await verificarConectividade(),
    );
  }
}

// Classes de apoio
class SyncResult {
  final bool sucesso;
  final int itensAdicionados;
  final int itensAtualizados;
  final String? erro;
  final String mensagem;

  SyncResult({
    required this.sucesso,
    this.itensAdicionados = 0,
    this.itensAtualizados = 0,
    this.erro,
    required this.mensagem,
  });
}

class ConflitoDados {
  final String id;
  final String tabela;
  final String campoConflito;
  final String valorLocal;
  final String valorRemoto;
  final DateTime dataConflito;

  ConflitoDados({
    required this.id,
    required this.tabela,
    required this.campoConflito,
    required this.valorLocal,
    required this.valorRemoto,
    required this.dataConflito,
  });
}

class EstatisticasSync {
  final int totalItensSincronizados;
  final DateTime? ultimaSincronizacao;
  final bool statusConectividade;

  EstatisticasSync({
    required this.totalItensSincronizados,
    this.ultimaSincronizacao,
    required this.statusConectividade,
  });
}
