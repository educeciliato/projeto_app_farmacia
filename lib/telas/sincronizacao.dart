import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../serivces/sync_service.dart';

class Sincronizacao extends StatefulWidget {
  const Sincronizacao({super.key});

  @override
  State<Sincronizacao> createState() => _SincronizacaoState();
}

class _SincronizacaoState extends State<Sincronizacao> {
  final SyncService _syncService = SyncService();
  bool _sincronizando = false;
  bool _conectado = false;
  EstatisticasSync? _estatisticas;
  List<ConflitoDados> _conflitos = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _sincronizando = true;
    });

    try {
      final conectividade = await _syncService.verificarConectividade();
      final estatisticas = await _syncService.obterEstatisticas();
      final conflitos = await _syncService.verificarConflitos();

      setState(() {
        _conectado = conectividade;
        _estatisticas = estatisticas;
        _conflitos = conflitos;
      });
    } catch (e) {
      _mostrarErro('Erro ao carregar dados: $e');
    } finally {
      setState(() {
        _sincronizando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronização'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
          ),
        ],
      ),
      body: _sincronizando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status de conectividade
                  _buildStatusCard(),

                  const SizedBox(height: 20),

                  // Estatísticas
                  if (_estatisticas != null) _buildEstatisticasCard(),

                  const SizedBox(height: 20),

                  // Conflitos
                  if (_conflitos.isNotEmpty) _buildConflitosCard(),

                  const SizedBox(height: 20),

                  // Ações de sincronização
                  _buildAcoesCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status da Conexão',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _conectado ? Icons.cloud_done : Icons.cloud_off,
                  color: _conectado ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _conectado ? 'Conectado' : 'Desconectado',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _conectado ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        _conectado
                            ? 'API externa acessível'
                            : 'Verifique sua conexão com a internet',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstatisticasCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas de Sincronização',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Itens Sincronizados',
                    '${_estatisticas!.totalItensSincronizados}',
                    Icons.sync_alt,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Conflitos',
                    '${_conflitos.length}',
                    Icons.warning,
                    _conflitos.isEmpty ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_estatisticas!.ultimaSincronizacao != null)
              Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Última sincronização: ${DateFormat('dd/MM/yyyy HH:mm').format(_estatisticas!.ultimaSincronizacao!)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              )
            else
              const Row(
                children: [
                  Icon(Icons.info, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Nenhuma sincronização realizada ainda',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConflitosCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Conflitos de Sincronização',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resolverTodosConflitos,
                  child: const Text('Resolver Todos'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_conflitos.map((conflito) => _buildConflitoItem(conflito))),
          ],
        ),
      ),
    );
  }

  Widget _buildConflitoItem(ConflitoDados conflito) {
    return Card(
      color: Colors.orange.shade50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${conflito.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Campo: ${conflito.campoConflito}'),
            Text('Valor Local: ${conflito.valorLocal}'),
            Text('Valor Remoto: ${conflito.valorRemoto}'),
            Text(
              'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(conflito.dataConflito)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _resolverConflito(conflito, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Manter Local'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _resolverConflito(conflito, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Usar Remoto'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcoesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ações de Sincronização',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _conectado ? _sincronizarCompleto : null,
                icon: const Icon(Icons.sync),
                label: const Text('Sincronização Completa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _conectado ? _sincronizarIncremental : null,
                icon: const Icon(Icons.sync_alt),
                label: const Text('Sincronização Incremental'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _conectado ? _enviarDados : null,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Enviar Dados para API'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Configurações',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Sincronização Automática'),
              subtitle:
                  const Text('Sincronizar dados automaticamente a cada 24h'),
              value: true, // Implementar lógica de preferências
              onChanged: (value) {
                // Implementar toggle de sync automático
                _mostrarMensagem('Configuração salva!');
              },
            ),
            SwitchListTile(
              title: const Text('Apenas com WiFi'),
              subtitle:
                  const Text('Sincronizar apenas quando conectado ao WiFi'),
              value: false, // Implementar lógica de preferências
              onChanged: (value) {
                // Implementar toggle de WiFi apenas
                _mostrarMensagem('Configuração salva!');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sincronizarCompleto() async {
    setState(() {
      _sincronizando = true;
    });

    try {
      final resultado = await _syncService.sincronizarDados();

      if (resultado.sucesso) {
        _mostrarSucesso(resultado.mensagem);
        await _carregarDados();
      } else {
        _mostrarErro(resultado.mensagem);
      }
    } catch (e) {
      _mostrarErro('Erro na sincronização: $e');
    } finally {
      setState(() {
        _sincronizando = false;
      });
    }
  }

  Future<void> _sincronizarIncremental() async {
    setState(() {
      _sincronizando = true;
    });

    try {
      final resultado = await _syncService.sincronizacaoIncremental();

      if (resultado.sucesso) {
        _mostrarSucesso(resultado.mensagem);
        await _carregarDados();
      } else {
        _mostrarErro(resultado.mensagem);
      }
    } catch (e) {
      _mostrarErro('Erro na sincronização incremental: $e');
    } finally {
      setState(() {
        _sincronizando = false;
      });
    }
  }

  Future<void> _enviarDados() async {
    setState(() {
      _sincronizando = true;
    });

    try {
      final resultado = await _syncService.enviarDadosParaAPI();

      if (resultado.sucesso) {
        _mostrarSucesso(resultado.mensagem);
      } else {
        _mostrarErro(resultado.mensagem);
      }
    } catch (e) {
      _mostrarErro('Erro ao enviar dados: $e');
    } finally {
      setState(() {
        _sincronizando = false;
      });
    }
  }

  Future<void> _resolverConflito(
      ConflitoDados conflito, bool manterLocal) async {
    try {
      final sucesso =
          await _syncService.resolverConflito(conflito, manterLocal);

      if (sucesso) {
        setState(() {
          _conflitos.remove(conflito);
        });
        _mostrarSucesso('Conflito resolvido com sucesso!');
      } else {
        _mostrarErro('Erro ao resolver conflito');
      }
    } catch (e) {
      _mostrarErro('Erro ao resolver conflito: $e');
    }
  }

  Future<void> _resolverTodosConflitos() async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolver Todos os Conflitos'),
        content: const Text(
          'Esta ação irá resolver todos os conflitos mantendo os valores locais. '
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      for (var conflito in List.from(_conflitos)) {
        await _resolverConflito(conflito, true);
      }
    }
  }

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
