import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../serivces/location_service.dart';
import '../serivces/url_launcher_service.dart';

class FarmaciasProximas extends StatefulWidget {
  const FarmaciasProximas({super.key});

  @override
  State<FarmaciasProximas> createState() => _FarmaciasProximasState();
}

class _FarmaciasProximasState extends State<FarmaciasProximas> {
  Position? _posicaoAtual;
  List<Map<String, dynamic>> _farmacias = [];
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _obterLocalizacao();
  }

  Future<void> _obterLocalizacao() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final permissao = await LocationService.verificarPermissoes();
      if (!permissao) {
        throw Exception('Permissão de localização negada');
      }

      final posicao = await LocationService.obterLocalizacaoAtual();
      if (posicao != null) {
        setState(() {
          _posicaoAtual = posicao;
          _farmacias = LocationService.encontrarFarmaciasProximas(posicao);
        });
      } else {
        throw Exception('Não foi possível obter a localização');
      }
    } catch (e) {
      setState(() {
        _erro = e.toString();
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmácias Próximas'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _obterLocalizacao,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centralizarLocalizacao,
          ),
        ],
      ),
      body: _carregando
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Obtendo localização...'),
                ],
              ),
            )
          : _erro != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro: $_erro',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _obterLocalizacao,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Informações da localização atual
                    if (_posicaoAtual != null) _buildInfoLocalizacao(),

                    // Lista de farmácias
                    Expanded(
                      child: _farmacias.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhuma farmácia encontrada na região',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _farmacias.length,
                              itemBuilder: (context, index) {
                                final farmacia = _farmacias[index];
                                return _buildFarmaciaCard(farmacia);
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: _posicaoAtual != null
          ? FloatingActionButton(
              onPressed: _abrirMapa,
              backgroundColor: Colors.teal.shade700,
              child: const Icon(Icons.map, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildInfoLocalizacao() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.my_location, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Sua Localização',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Latitude: ${_posicaoAtual!.latitude.toStringAsFixed(6)}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Longitude: ${_posicaoAtual!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Precisão: ${_posicaoAtual!.accuracy.toStringAsFixed(0)}m',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmaciaCard(Map<String, dynamic> farmacia) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade700,
          child: const Icon(Icons.local_pharmacy, color: Colors.white),
        ),
        title: Text(
          farmacia['nome'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(farmacia['endereco']),
            Text(
              'Telefone: ${farmacia['telefone']}',
              style: const TextStyle(color: Colors.blue),
            ),
            Text('Horário: ${farmacia['horario']}'),
            Text(
              'Distância: ${LocationService.formatarDistancia(farmacia['distancia'])}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _acaoFarmacia(value, farmacia),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'ligar',
              child: Row(
                children: [
                  Icon(Icons.phone, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Ligar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'whatsapp',
              child: Row(
                children: [
                  Icon(Icons.message, color: Colors.green),
                  SizedBox(width: 8),
                  Text('WhatsApp'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'direcoes',
              child: Row(
                children: [
                  Icon(Icons.directions, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Direções'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'mapa',
              child: Row(
                children: [
                  Icon(Icons.map, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Ver no Mapa'),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        ),
        isThreeLine: true,
      ),
    );
  }

  Future<void> _acaoFarmacia(String acao, Map<String, dynamic> farmacia) async {
    try {
      switch (acao) {
        case 'ligar':
          await UrlLauncherService.fazerLigacao(farmacia['telefone']);
          break;

        case 'whatsapp':
          await UrlLauncherService.abrirWhatsApp(
            farmacia['telefone'],
            'Olá! Gostaria de informações sobre medicamentos disponíveis.',
          );
          break;

        case 'direcoes':
          if (_posicaoAtual != null) {
            await LocationService.obterDirecoes(
              _posicaoAtual!.latitude,
              _posicaoAtual!.longitude,
              farmacia['latitude'],
              farmacia['longitude'],
            );
          }
          break;

        case 'mapa':
          await LocationService.abrirNoMaps(
            farmacia['latitude'],
            farmacia['longitude'],
            farmacia['nome'],
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _abrirMapa() async {
    if (_posicaoAtual != null) {
      await LocationService.abrirNoMaps(
        _posicaoAtual!.latitude,
        _posicaoAtual!.longitude,
        'Minha Localização',
      );
    }
  }

  Future<void> _centralizarLocalizacao() async {
    await _obterLocalizacao();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localização atualizada!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
