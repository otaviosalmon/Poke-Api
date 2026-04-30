// Um "model" representa os dados da sua aplicação.
// Ele NÃO sabe nada sobre UI ou banco de dados — só sobre estrutura de dados.
// Esse é o princípio de responsabilidade única (Single Responsibility).

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height; // em decímetros
  final int weight; // em hectogramas
  final Map<String, int> stats;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.stats,
  });

  // Factory constructor: padrão comum em Dart para converter JSON em objeto.
  // Usamos "factory" porque pode retornar uma instância existente ou null em
  // variações do padrão — e semanticamente indica "conversão de formato".
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      name: (json['name'] as String).toCapitalized(),
      // Preferimos o artwork oficial; fallback para o sprite padrão
      imageUrl: (json['sprites']['other']['official-artwork']['front_default']
              as String?) ??
          (json['sprites']['front_default'] as String? ?? ''),
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      height: json['height'] as int,
      weight: json['weight'] as int,
      stats: Map.fromEntries(
        (json['stats'] as List).map(
          (s) => MapEntry(
            s['stat']['name'] as String,
            s['base_stat'] as int,
          ),
        ),
      ),
    );
  }

  // toMap() é necessário para persistir no Firestore.
  // Salvamos apenas o necessário — não precisamos de stats nos favoritos.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'types': types,
      };

  // Extrai o ID diretamente da URL da lista da PokéAPI, sem chamada extra.
  // Ex: "https://pokeapi.co/api/v2/pokemon/25/" → 25
  // Essa otimização evita 20 chamadas de rede na tela inicial!
  static int idFromUrl(String url) {
    final segments = Uri.parse(url).pathSegments;
    return int.parse(segments[segments.length - 2]);
  }

  // Monta a URL do sprite diretamente pelo ID — sem chamada à API.
  static String spriteUrlFromId(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/'
      'sprites/other/official-artwork/$id.png';
}

// Extension para capitalizar strings — Dart não tem isso nativamente.
// Colocar como extension mantém o código limpo: name.toCapitalized()
extension StringCapitalize on String {
  String toCapitalized() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
