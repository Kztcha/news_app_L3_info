import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'article_model.dart';
import 'news_service.dart';
import 'webview_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      home: SplashScreen(), // Affichage du splash screen au démarrage
    );
  }
}

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();
  late Future<List<Article>> _futureArticles;
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  String _selectedCategory = 'trending';
  TextEditingController _searchController = TextEditingController();

  final Map<String, String> categoryMapping = {
    'trending': 'Accueil',
    'business': 'Affaires',
    'entertainment': 'Divertissement',
    'health': 'Santé',
    'science': 'Science',
    'sports': 'Sports',
    'technology': 'Technologie'
  };

  List<String> mascottes = [
    'assets/mascotte1.gif',
    'assets/mascotte2.gif',
    'assets/mascotte3.gif',
    'assets/mascotte4.gif',
    'assets/mascotte5.gif',
    'assets/mascotte6.gif',
    'assets/mascotte7.gif',
    'assets/mascotte8.gif',
    'assets/mascotte9.gif',
  ];

  List<String> mascottesAffichees = [];
  Random random = Random();
  late Timer timer;
  int mascotteIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
    _searchController.addListener(_filterArticles);
    _afficherMascottes();
  }

  void _fetchArticles() {
    if (_selectedCategory == 'trending') {
      _futureArticles = _newsService.fetchTrendingNews();
    } else {
      _futureArticles = _newsService.fetchNews(category: _selectedCategory);
    }

    _futureArticles.then((articles) {
      setState(() {
        _allArticles = articles;
        _filteredArticles = articles;
      });
    }).catchError((error) {
      print("Erreur de chargement des articles: $error");
    });
  }

  void _filterArticles() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredArticles = _allArticles.where((article) {
        return article.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _changeCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _fetchArticles();
    });
    Navigator.pop(context);
  }

  void _afficherMascottes() {
    timer = Timer.periodic(Duration(seconds: 25), (timer) {
      // Afficher une mascotte toutes les 25 secondes : 5 sec visible + 20 sec d'attente
      setState(() {
        mascotteIndex = (mascotteIndex + 1) % mascottes.length;
        mascottesAffichees.add(mascottes[mascotteIndex]);
      });

      // Retirer la mascotte après 5 secondes
      Timer(Duration(seconds: 5), () {
        setState(() {
          mascottesAffichees.remove(mascottes[mascotteIndex]);
        });
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
            ),
            SizedBox(width: 10),
            Text(
              categoryMapping[_selectedCategory] ?? _selectedCategory.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              setState(() {
                _selectedCategory = 'trending';
                _fetchArticles();
              });
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Catégories',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Image.asset(
                      'assets/mascotte.gif',
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
            ...categoryMapping.entries.map((entry) => ListTile(
              title: Text(
                entry.value,
                style: TextStyle(fontSize: 14),
              ),
              onTap: () => _changeCategory(entry.key),
            ))
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchArticles();
        },
        child: Stack(
          children: [
            // Contenu principal (articles)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un article...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Article>>(
                    future: _futureArticles,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erreur : ${snapshot.error}'));
                      } else if (_filteredArticles.isEmpty) {
                        return Center(child: Text('Aucune actualité disponible'));
                      } else {
                        return ListView.builder(
                          itemCount: _filteredArticles.length,
                          itemBuilder: (context, index) {
                            final article = _filteredArticles[index];
                            return Card(
                              margin: EdgeInsets.all(8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                                      child: Image.network(
                                        article.urlToImage!,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article.title,
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          article.description,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => WebViewScreen(url: article.url),
                                                ),
                                              );
                                            },
                                            child: Text("Lire l'article"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),

            // Affichage des mascottes dans le coin inférieur gauche
            ...mascottesAffichees.map((mascotte) {
              return Positioned(
                bottom: 20.0,
                left: 20.0,
                child: Image.asset(mascotte, height: 50),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NewsScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 120, // Ajustez la taille si nécessaire
                ),
                SizedBox(height: 16),
                Text(
                  'News App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Text(
              'Made by Kztcha',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
