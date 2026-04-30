import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

// "Service" = camada que faz comunicação externa (API, banco, storage).
// As telas NÃO fazem http.get diretamente — elas delegam ao service.
// Por quê? Se a API mudar, você altera UM arquivo, não todas as telas.

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const int pageSize = 20;

  // Singleton: garante que há apenas uma instância deste serviço.
  // Útil para serviços stateless — economiza memória e é previsível.
  PokeApiService._();
  static final PokeApiService instance = PokeApiService._();

  // Retorna pares {name, url} — lista leve, sem detalhes ainda.
  Future<List<Map<String, String>>> fetchList({int offset = 0}) async {
    final uri = Uri.parse(
      '$_baseUrl/pokemon?limit=$pageSize&offset=$offset',
    );

    final response = await http.get(uri);

    // Lança exceção com mensagem clara — facilita debug e tratamento na UI.
    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar lista: status ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['results'] as List)
        .cast<Map<String, dynamic>>()
        .map((p) => {
              'name': p['name'] as String,
              'url': p['url'] as String,
            })
        .toList();
  }

  // Busca os detalhes completos de um Pokémon pela URL canônica.
  Future<Pokemon> fetchDetail(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar detalhe: status ${response.statusCode}');
    }

    return Pokemon.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
