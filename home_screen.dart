import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';
import '../widgets/pokemon_card.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Estado local da tela: lista acumulada + controle de paginação.
  final List<Map<String, String>> _pokemonList = [];
  final ScrollController _scrollController = ScrollController();

  int _offset = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore(); // Carrega a primeira página ao iniciar

    // Detecta quando o usuário chegou ao fim da lista → carrega mais.
    // Isso é "infinite scroll" — padrão comum em apps móveis.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    // SEMPRE limpe controllers no dispose para evitar memory leaks.
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isLoading) return; // Evita chamadas duplas simultâneas
    setState(() => _isLoading = true);

    try {
      final items = await PokeApiService.instance.fetchList(offset: _offset);
      setState(() {
        _pokemonList.addAll(items);
        _offset += PokeApiService.pageSize;
        _hasMore = items.length == PokeApiService.pageSize;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    // Pull-to-refresh: reseta e recarrega do zero.
    setState(() {
      _pokemonList.clear();
      _offset = 0;
      _hasMore = true;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pokédex',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFCC0000),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favoritos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _pokemonList.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _pokemonList.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Último item = indicador de carregamento
                  if (index == _pokemonList.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final item = _pokemonList[index];
                  final id = Pokemon.idFromUrl(item['url']!);
                  final name = item['name']!.toCapitalized();

                  // Card temporário: usa ID para montar URL do sprite sem API extra.
                  // Tipos são preenchidos depois, na tela de detalhe.
                  return PokemonCard(
                    id: id,
                    name: name,
                    types: const ['normal'], // placeholder visual
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(
                          pokemonUrl: item['url']!,
                          pokemonId: id,
                          pokemonName: name,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
