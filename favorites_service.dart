import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pokemon.dart';

// Este serviço isola toda a lógica do Firebase.
// Se amanhã você trocar Firestore por Hive (local) ou Supabase,
// só este arquivo muda — as telas permanecem intactas.

class FavoritesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Nome da coleção como constante: evita typos espalhados pelo código.
  static const String _collection = 'favorites';

  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  // Usa o ID do Pokémon como ID do documento — garante que não há duplicatas.
  // set() com merge faz upsert: cria se não existe, sobrescreve se existe.
  Future<void> add(Pokemon pokemon) => _db
      .collection(_collection)
      .doc(pokemon.id.toString())
      .set(pokemon.toMap());

  Future<void> remove(int pokemonId) => _db
      .collection(_collection)
      .doc(pokemonId.toString())
      .delete();

  Future<bool> isFavorite(int pokemonId) async {
    final doc = await _db
        .collection(_collection)
        .doc(pokemonId.toString())
        .get();
    return doc.exists;
  }

  // Stream é o padrão reativo do Firestore: atualiza a UI automaticamente
  // quando os dados mudam, sem polling (verificação periódica manual).
  Stream<List<Map<String, dynamic>>> watchAll() => _db
      .collection(_collection)
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.data()).toList());
}
