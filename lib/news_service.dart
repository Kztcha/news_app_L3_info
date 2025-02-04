import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article_model.dart';

class NewsService {
  final String apiKey = '1dbf5f22a7ef4e6ea7d301f1a405006d';
  final String baseUrl = 'https://newsapi.org/v2/top-headlines';

  Future<List<Article>> fetchNews({String category = 'general'}) async {
    final response = await http.get(Uri.parse('$baseUrl?country=us&category=$category&apiKey=$apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> articlesJson = data['articles'];
      return articlesJson.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de chargement des actualités');
    }
  }

  Future<List<Article>> fetchTrendingNews() async {
    final response = await http.get(Uri.parse('$baseUrl?country=us&apiKey=$apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> articlesJson = data['articles'];
      return articlesJson.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de chargement des actualités tendances');
    }
  }
}
