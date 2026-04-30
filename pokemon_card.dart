import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/type_colors.dart';
import '../models/pokemon.dart';

// Widget extraído da tela → reutilizável e fácil de testar isoladamente.
// Se HomeScreen e FavoritesScreen usam o mesmo card, ele vive AQUI.

class PokemonCard extends StatelessWidget {
  final String name;
  final int id;
  final List<String> types;
  final VoidCallback onTap;

  const PokemonCard({
    super.key,
    required this.name,
    required this.id,
    required this.types,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = typeColor(types.first);
    final imageUrl = Pokemon.spriteUrlFromId(id);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hero: anima a imagem entre telas (toque profissional simples).
              Hero(
                tag: 'pokemon-$id',
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 90,
                  width: 90,
                  placeholder: (_, __) => const SizedBox(
                    height: 90,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.catching_pokemon,
                    size: 60,
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '#${id.toString().padLeft(3, '0')}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Chips de tipo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: types
                    .map(
                      (t) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
