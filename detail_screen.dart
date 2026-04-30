import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/type_colors.dart';
import '../models/pokemon.dart';
import '../services/favorites_service.dart';
import '../services/poke_api_service.dart';

class DetailScreen extends StatefulWidget {
  final String pokemonUrl;
  final int pokemonId;
  final String pokemonName;

  const DetailScreen({
    super.key,
    required this.pokemonUrl,
    required this.pokemonId,
    required this.pokemonName,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Pokemon? _pokemon;
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  // Carrega dados em paralelo com Future.wait — mais eficiente que sequencial.
  // Sem isso, esperaríamos o detalhe da API E DEPOIS checaríamos o favorito.
  Future<void> _init() async {
    final results = await Future.wait([
      PokeApiService.instance.fetchDetail(widget.pokemonUrl),
      FavoritesService.instance.isFavorite(widget.pokemonId),
    ]);

    if (mounted) {
      setState(() {
        _pokemon = results[0] as Pokemon;
        _isFavorite = results[1] as bool;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_pokemon == null) return;

    // Atualiza UI imediatamente (optimistic update) → parece mais rápido.
    setState(() => _isFavorite = !_isFavorite);

    try {
      if (_isFavorite) {
        await FavoritesService.instance.add(_pokemon!);
      } else {
        await FavoritesService.instance.remove(_pokemon!.id);
      }
    } catch (e) {
      // Reverte se falhar
      setState(() => _isFavorite = !_isFavorite);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _pokemon != null
        ? typeColor(_pokemon!.types.first)
        : const Color(0xFFBDBDBD);

    return Scaffold(
      backgroundColor: color.withOpacity(0.15),
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text(
          widget.pokemonName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            tooltip: _isFavorite ? 'Remover favorito' : 'Favoritar',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(color),
    );
  }

  Widget _buildContent(Color color) {
    final p = _pokemon!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Hero tag deve ser IGUAL ao da HomeScreen para a animação funcionar.
          Hero(
            tag: 'pokemon-${p.id}',
            child: CachedNetworkImage(
              imageUrl: p.imageUrl,
              height: 200,
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.catching_pokemon, size: 120),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '#${p.id.toString().padLeft(3, '0')}',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          Text(
            p.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Chips de tipo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: p.types
                .map(
                  (t) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor(t),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          // Medidas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoChip('Altura', '${p.height / 10} m'),
              _infoChip('Peso', '${p.weight / 10} kg'),
            ],
          ),
          const SizedBox(height: 24),
          // Stats
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Base Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          ...p.stats.entries.map((e) => _statRow(e.key, e.value, color)),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Column(
      children: [
        Text(value,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _statRow(String name, int value, Color color) {
    // Normaliza para 0-1 assumindo max de 255 (Pokémon padrão)
    final ratio = (value / 255).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              _statLabel(name),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mapeia nomes técnicos da API para labels amigáveis.
  String _statLabel(String stat) {
    const labels = {
      'hp': 'HP',
      'attack': 'Ataque',
      'defense': 'Defesa',
      'special-attack': 'Sp. Ataque',
      'special-defense': 'Sp. Defesa',
      'speed': 'Velocidade',
    };
    return labels[stat] ?? stat;
  }
}
