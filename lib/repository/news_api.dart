part of 'news_repo.dart';

class NewsApiClient {
  static const baseUrl = 'https://newsapi.org/v2';
  static const apiKey = '6cef641c2ac14ce5956cf3344407dc59';
  final http.Client httpClient;

  NewsApiClient({
    @required this.httpClient,
  }): assert(httpClient != null);

  Future<List<News>> fetchTopHeadLinesByCountry(String country) async {
    final newsUrl = '$baseUrl/top-headlines?country=$country&apiKey=$apiKey&pageSize=20';
    final newsResponse = await this.httpClient.get(newsUrl);
    List<News> newsList = List<News>();
    if (newsResponse.statusCode != 200) {
      throw Exception('error getting news for category');
    }
    final newsJson = jsonDecode(newsResponse.body);
    final List articles = newsJson['articles'];
    for (var i = 0; i < articles.length; i++) {
      newsList.add(
        News.fromJson(articles[i])
      );
    }
    
    return newsList;  
  }  
  // business entertainment general health science sports technology
  Future<List<News>> fetchTopHeadLinesByCategory(String country, String category) async {
    final newsUrl = '$baseUrl/top-headlines?country=$country&category=$category&apiKey=$apiKey&pageSize=20';
    final newsResponse = await this.httpClient.get(newsUrl);
    List<News> newsList = List<News>();
    if (newsResponse.statusCode != 200) {
      throw Exception('error getting news for category');
    }
    final newsJson = jsonDecode(newsResponse.body);
    final List articles = newsJson['articles'];
    for (var i = 0; i < articles.length; i++) {
      newsList.add(
        News.fromJson(articles[i])
      );
    }
    return newsList;    
  } 

  Future<List<News>> fetchTopHeadLinesByQuery(String query) async {
    final newsUrl = '$baseUrl/top-headlines?q=$query&apiKey=$apiKey&pageSize=20';
    final newsResponse = await this.httpClient.get(newsUrl);
    if (newsResponse.statusCode != 200) {
      throw Exception('error getting news for query');
    }
    final newsJson = jsonDecode(newsResponse.body);
    List<News> newsList = List<News>();
    final List articles = newsJson['articles'];
    for (var i = 0; i < articles.length; i++) {
      newsList.add(
        News.fromJson(articles[i])
      );
    }
    return newsList;    
  } 

  Future<List<News>> fetchTopHeadLinesBySources(String source) async {
    final newsUrl = '$baseUrl/top-headlines?sources=$source&apiKey=$apiKey';
    final newsResponse = await this.httpClient.get(newsUrl);
    if (newsResponse.statusCode != 200) {
      throw Exception('error getting news for query');
    }
    final newsJson = jsonDecode(newsResponse.body);
    List<News> newsList = List<News>();
    final List articles = newsJson['articles'];
    for (var i = 0; i < articles.length; i++) {
      newsList.add(
        News.fromJson(articles[i])
      );
    }
    return newsList;    
  } 
  
  Future<List<Source>> fetchSources(String category, String country) async {      
    final newsUrl = category == "all" ? '$baseUrl/sources?apiKey=$apiKey&country=$country' : category == "general" ? '$baseUrl/sources?apiKey=$apiKey&category=$category&country=$country' : '$baseUrl/sources?apiKey=$apiKey&category=$category';
    final newsResponse = await this.httpClient.get(newsUrl);
    if (newsResponse.statusCode != 200) {
      throw Exception('error getting news for query');
    }
    final newsJson = jsonDecode(newsResponse.body);
    List<Source> sourceList = List<Source>();
    final List sources = newsJson['sources'];
    for (var i = 0; i < sources.length; i++) {
      sourceList.add(
        Source.fromJson(sources[i])
      );
    }
    return sourceList;    
  } 
}