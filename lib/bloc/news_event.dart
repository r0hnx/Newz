part of 'news_bloc.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();
}

class FetchNewsList extends NewsEvent {
  final String country;
  const FetchNewsList({@required this.country,}) : assert(country != null);

  @override
  List<Object> get props => [country];
}

class FetchSourceNews extends NewsEvent {
  final String source;
  const FetchSourceNews({@required this.source}) : assert(source != null);

  @override
  List<Object> get props => [source];
}

class FetchCategory extends NewsEvent {
  final String country;
  final String category;
  const FetchCategory({@required this.country, @required this.category}) : assert(country != null), assert(category != null);

  @override
  List<Object> get props => [country, category];
}

class FetchQuery extends NewsEvent {
  final String query;
  const FetchQuery({@required this.query}) : assert(query != null);

  @override
  List<Object> get props => [query];
}

class RefreshNews extends NewsEvent {
  final String country;

  final String category;
  const RefreshNews({@required this.country, @required this.category}) : assert(country != null), assert(category != null);

  @override
  List<Object> get props => [country];
}
