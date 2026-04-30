# 📱 Pokédex Flutter

> Aplicação mobile desenvolvida em Flutter que consome a [PokéAPI](https://pokeapi.co/) e utiliza Firebase Firestore para persistência de favoritos.

---

## 📸 Prints da Aplicação

> *(Substitua pelas suas capturas de tela)*

| Tela Inicial | Detalhes | Favoritos |
|---|---|---|
| ![home](prints/home.png) | ![detail](prints/detail.png) | ![favorites](prints/favorites.png) |

---

## 🏗️ Arquitetura

```
lib/
├── core/
│   └── type_colors.dart        # Constantes de cores por tipo Pokémon
├── models/
│   └── pokemon.dart            # Entidade de domínio
├── services/
│   ├── poke_api_service.dart   # Integração com PokéAPI (REST)
│   └── favorites_service.dart  # Integração com Firebase Firestore
├── screens/
│   ├── home_screen.dart        # Lista paginada de Pokémon
│   ├── detail_screen.dart      # Detalhes + favoritar
│   └── favorites_screen.dart   # Lista de favoritos (stream)
├── widgets/
│   └── pokemon_card.dart       # Card reutilizável
└── main.dart                   # Entry point + inicialização Firebase
```

Consulte o [desenho de arquitetura](architecture.png) para o diagrama visual.

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Uso |
|---|---|
| Flutter 3.x | Framework mobile |
| Dart 3.x | Linguagem |
| [PokéAPI](https://pokeapi.co/) | API REST de dados Pokémon |
| Firebase Firestore | Banco de dados NoSQL (favoritos) |
| `http` | Requisições HTTP |
| `cached_network_image` | Cache de imagens da rede |

---

## ⚙️ Como Rodar o Projeto

### Pré-requisitos

- Flutter SDK `>=3.0.0` instalado → [Guia de instalação](https://docs.flutter.dev/get-started/install)
- Conta no [Firebase](https://firebase.google.com/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) instalado

### 1. Clone o repositório

```bash
git clone https://github.com/SEU_USUARIO/pokedex.git
cd pokedex
```

### 2. Configure o Firebase

```bash
# Instale a FlutterFire CLI (se ainda não tiver)
dart pub global activate flutterfire_cli

# Configure seu projeto Firebase (siga as instruções interativas)
flutterfire configure
```

> Isso gera automaticamente o arquivo `lib/firebase_options.dart`.  
> No Firebase Console, crie um projeto e ative o **Cloud Firestore** em modo de teste.

### 3. Instale as dependências

```bash
flutter pub get
```

### 4. Execute o app

```bash
# Listar dispositivos disponíveis
flutter devices

# Rodar no dispositivo/emulador
flutter run

# Rodar na web
flutter run -d chrome
```

### 5. Gerar APK

```bash
flutter build apk --release
# APK gerado em: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔗 Links

- 📦 [Download APK]() ← *adicione o link*
- 🌐 [Versão Web]() ← *adicione o link (Firebase Hosting ou GitHub Pages)*

---

## 🌐 API Utilizada

**PokéAPI** — `https://pokeapi.co/api/v2`

| Endpoint | Uso |
|---|---|
| `GET /pokemon?limit=20&offset=N` | Lista paginada |
| `GET /pokemon/{id}` | Detalhes completos |

---

## 📦 Firebase

- **Cloud Firestore** — coleção `favorites`
- Documentos identificados pelo ID do Pokémon
- Atualização reativa via `Stream` (sem polling)

---

## 👨‍💻 Autor

**Seu Nome** — [GitHub](https://github.com/SEU_USUARIO)
