import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  // Verificar permissões de localização
  static Future<bool> verificarPermissoes() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Obter localização atual
  static Future<Position?> obterLocalizacaoAtual() async {
    try {
      bool permissao = await verificarPermissoes();
      if (!permissao) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  // Calcular distância entre dois pontos
  static double calcularDistancia(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Abrir no Google Maps
  static Future<void> abrirNoMaps(
      double latitude, double longitude, String label) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$label';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // Obter direções no Google Maps
  static Future<void> obterDirecoes(double origemLat, double origemLon,
      double destinoLat, double destinoLon) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$origemLat,$origemLon&destination=$destinoLat,$destinoLon&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // Encontrar farmácias próximas (simulado)
  static List<Map<String, dynamic>> encontrarFarmaciasProximas(
      Position posicaoAtual) {
    // Dados simulados de farmácias próximas
    return [
      {
        'nome': 'Farmácia Central',
        'endereco': 'Rua Principal, 123',
        'latitude': posicaoAtual.latitude + 0.001,
        'longitude': posicaoAtual.longitude + 0.001,
        'telefone': '(11) 1234-5678',
        'horario': '08:00 - 22:00',
        'distancia': calcularDistancia(
            posicaoAtual.latitude,
            posicaoAtual.longitude,
            posicaoAtual.latitude + 0.001,
            posicaoAtual.longitude + 0.001),
      },
      {
        'nome': 'Drogaria São Paulo',
        'endereco': 'Av. Paulista, 456',
        'latitude': posicaoAtual.latitude - 0.002,
        'longitude': posicaoAtual.longitude + 0.002,
        'telefone': '(11) 9876-5432',
        'horario': '24 horas',
        'distancia': calcularDistancia(
            posicaoAtual.latitude,
            posicaoAtual.longitude,
            posicaoAtual.latitude - 0.002,
            posicaoAtual.longitude + 0.002),
      },
      {
        'nome': 'Farmácia Popular',
        'endereco': 'Rua do Comércio, 789',
        'latitude': posicaoAtual.latitude + 0.003,
        'longitude': posicaoAtual.longitude - 0.001,
        'telefone': '(11) 5555-1234',
        'horario': '07:00 - 23:00',
        'distancia': calcularDistancia(
            posicaoAtual.latitude,
            posicaoAtual.longitude,
            posicaoAtual.latitude + 0.003,
            posicaoAtual.longitude - 0.001),
      },
    ]..sort((a, b) => a['distancia'].compareTo(b['distancia']));
  }

  // Formatar distância para exibição
  static String formatarDistancia(double distanciaMetros) {
    if (distanciaMetros < 1000) {
      return '${distanciaMetros.round()}m';
    } else {
      return '${(distanciaMetros / 1000).toStringAsFixed(1)}km';
    }
  }

  // Verificar se está dentro de um raio específico
  static bool estaDentroDoRaio(Position posicaoAtual, double latDestino,
      double lonDestino, double raioMetros) {
    double distancia = calcularDistancia(
        posicaoAtual.latitude, posicaoAtual.longitude, latDestino, lonDestino);
    return distancia <= raioMetros;
  }
}
