import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class News extends Equatable {
  final String source;
  final String id;
  final String author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String content;

  const News({
    @required this.title,
    @required this.content,
    @required this.urlToImage,
    @required this.url,
    @required this.description,
    this.author,
    this.publishedAt,
    this.source,
    this.id
  });

  @override
  List<Object> get props => [
    source,
    id,
    author,
    title,
    description,
    url,
    urlToImage,
    publishedAt,
    content
  ];

  static News fromJson(Map<String, dynamic> json) {
    return new News(
      title: json['title'],          
      author: json['author'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      description: json['description'],
      publishedAt: json['publishedAt'],
      content: json['content'],
      id: json['source']['id'],
      source: json['source']['name'],
    );
  }
}

class Source extends Equatable{  
  final String id;
  final String name;
  final String description;
  final String url;
  final String category;
  final String language;
  final String country;

  const Source({
    this.id,
    this.name,
    this.description,
    this.url,
    this.category,
    this.language,
    this.country
  });

  @override
  List<Object> get props => [
    id,
    name,
    description,
    url,
    category,
    language,
    country
  ];

  static Source fromJson(Map<String, dynamic> json) {
    return new Source(
      id: json['id'],          
      name: json['name'],
      description: json['description'],
      url: json['url'],
      category: json['category'],
      language: json['language'],
      country: json['country'],
    );
  }
}