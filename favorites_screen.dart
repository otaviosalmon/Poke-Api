import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/type_colors.dart';
import '../services/favorites_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: const Color(0xFFCC0000),
        foregroundColor: Colors.white,
      ),
      // StreamBuilder ouve o Firestore em tempo real.
      // Quando um favorito é adicionado/removido em qualquer tela,
      // esta lista atualiza automaticamente — sem polling, sem setState manual.
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FavoritesService.instance.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.catching_pokemon, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Nenhum favorito ainda.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final f = favorites[index];
              final types = List<String>.from(f['types'] as List);
              final color = typeColor(types.first);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: CachedNetworkImage(
                      imageUrl: f['imageUrl'] as String,
                      height: 36,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.catching_pokemon),
                    ),
                  ),
                  title: Text(
                    f['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(types.join(' / ').toUpperCase()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () =>
                        FavoritesService.instance.remove(f['id'] as int),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
