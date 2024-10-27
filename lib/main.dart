import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api_dsm/services/character_service.dart';

import 'models/character.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CharacterService service = CharacterService();

  late Future<List<Character>> _personagensFuture;
  late List<Character> _personagens;
  late List<Character> _personagensFiltrados;

  @override
  void initState() {
    super.initState();
    _personagensFuture = _getCharacters();
  }

  Future<List<Character>> _getCharacters() async {
    _personagens = (await service.getCharacters()).cast<Character>();
    _personagensFiltrados = _personagens;
    return _personagens;
  }

  void _filtroPersonagens(String filtro) {
    setState(() {
      _personagensFiltrados = _personagens
          .where((item) => item.name.toLowerCase().contains(filtro.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Personagem"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextField(
                onChanged: (value) {
                  _filtroPersonagens(value);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Filtro",
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Character>>(
                future: _personagensFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    debugPrint(snapshot.error.toString());
                    return const Center(child: Text("Error"));
                  }
                  if (_personagensFiltrados.isEmpty) {
                    return const Center(child: Text("Nenhum personagem encontrado"));
                  }
                  return ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_personagensFiltrados[index].name),
                        leading: Image.network(_personagensFiltrados[index].image),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: _personagensFiltrados.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
