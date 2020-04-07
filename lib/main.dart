import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart'
as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newz/bloc/bloc_delegate.dart';
import 'package:newz/bloc/news_bloc.dart';
import 'package:newz/repository/news_repo.dart';
import 'package:newz/ui/screens/newsHome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]
  );
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final NewsRepository newsRepository = NewsRepository(
    newsApiClient: NewsApiClient(
      httpClient: http.Client(),
    ),
  );
  runApp(App(newsRepository: newsRepository));
}

class App extends StatelessWidget {
  final NewsRepository newsRepository;
  App({
      Key key,
      @required this.newsRepository
    }): assert(newsRepository != null),
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter News',
      home: BlocProvider(
        create: (context) => NewsBloc(newsRepository: newsRepository),
        child: NewsHome(),
      ),
      // darkTheme: ThemeData(
      //   scaffoldBackgroundColor: Colors.black,
      //   textTheme: TextTheme(
      //     body1: TextStyle(color: Colors.white)
      //   ),
      //   dividerColor: Colors.grey
      // ),      
      // theme: ThemeData(                
      //   textTheme: Theme.of(context).textTheme.apply(
      //     fontFamily: 'Nunito',
      //   )
      // ),
    );
  }
}