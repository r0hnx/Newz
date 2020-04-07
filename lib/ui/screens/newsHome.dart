import 'package:cached_network_image/cached_network_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flare_loading/flare_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:newz/bloc/news_bloc.dart';
import 'package:newz/model/news.dart';
import 'package:newz/repository/news_repo.dart';
import 'package:newz/ui/widgets/newsList.dart';
import 'package:public_suffix/public_suffix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'
as http;

part 'newsSource.dart';

class NewsHome extends StatefulWidget {
  @override
  _NewsHomeState createState() => _NewsHomeState();
}

List < String > category = [
  'latest',
  'local',
  'technology',
  'business',
  'sports',
  'entertainment',
  'health',
  'science'
];

class CustomSearchHintDelegate extends SearchDelegate {
  CustomSearchHintDelegate({
    String hintText,
  }): super(
    searchFieldLabel: hintText,
    keyboardType: TextInputType.text,
    textInputAction: TextInputAction.search,
  );

  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: Icon(Icons.keyboard_backspace, color: Colors.black, ), onPressed: () {
    Navigator.pop(context);
  }, );

  @override
  Widget buildSuggestions(BuildContext context) => Text("");

  @override
  Widget buildResults(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Search News',
      home: BlocProvider(
        create: (context) => NewsBloc(newsRepository: NewsRepository(
          newsApiClient: NewsApiClient(
            httpClient: http.Client(),
          ),
        )),
        child: SearchWidget(query: query, ),
      ),
    );
  }

  @override
  List < Widget > buildActions(BuildContext context) => [];
}

class SearchWidget extends StatefulWidget {
  final String query;
  const SearchWidget({
    @required this.query,
    Key key,
  }): super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State < SearchWidget > {
  @override
  void initState() {
    BlocProvider.of < NewsBloc > (context).add(FetchQuery(query: widget.query));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer < NewsBloc, NewsState > (
        listener: (context, state) {
          if (state is QueryLoaded) {
            // widget._refreshCompleter ?.complete();
            // widget._refreshCompleter = Completer();
          }
        },
        builder: (context, state) {
          if (state is NewsLoading) {
            return Center(child: FlareLoading(
              name: 'assets/search.flr',
              loopAnimation: 'Untitled',
              isLoading: true,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              // until: () => Future.delayed(Duration(seconds: 10)),
              onSuccess: (_) {
                print('Finished');
              },
              onError: (err, stack) {
                print(err);
              },
            ));
          }
          if (state is QueryLoaded) {
            final newsList = state.newsList;
            if (newsList.length == 0) {
              return Container(
                color: Colors.white,
                child: Center(child: Image.asset('assets/img/404.png', fit: BoxFit.cover), )
              );
            } else {
              return NewsList(category: 'search', news: newsList, sources: null,);
            }
          } else {
            return Center(child: FlareLoading(
              name: 'assets/noWifi.flr',
              loopAnimation: 'Untitled',
              isLoading: true,
              fit: BoxFit.cover,
              // until: () => Future.delayed(Duration(seconds: 10)),
              onSuccess: (_) {
                print('Finished');
              },
              onError: (err, stack) {
                print(err);
              },
            ));
          }
        }
      ),
    );
  }
}

Future < SharedPreferences > _prefs = SharedPreferences.getInstance();
Future < void > getCountry(BuildContext context) async {
  final SharedPreferences prefs = await _prefs;
  BlocProvider.of < NewsBloc > (context).add(FetchNewsList(country: prefs.getString('country') ?? 'in'), );
}

class _NewsHomeState extends State < NewsHome > with SingleTickerProviderStateMixin {

  final List < Tab > tabs = < Tab > [
    new Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: < Widget > [
          Text('Latest'),
        ],
      ),
    ),
    new Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: < Widget > [
          Text('Local'),
        ],
      ),
    ),
    new Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: < Widget > [
          Text('Tech'),
        ],
      ),
    ),
    new Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: < Widget > [
          Text('Business'),
        ],
      ),
    ),
    new Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: < Widget > [
          Text('Sports'),
        ],
      ),
    ),
    new Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: < Widget > [
          Text('Lifestyle'),
        ],
      ),
    ),
    new Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: < Widget > [
          Text('Health'),
        ],
      ),
    ),
    new Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: < Widget > [
          Text('Science'),
        ],
      ),
    ),
  ];

  // Completer < void > _refreshCompleter;
  TabController _tabController;

  @override
  void initState() {
    // _refreshCompleter = Completer < void > ();
    // BlocProvider.of < NewsBloc > (context).add(FetchNews(country: 'us'));
    getCountry(context);
    super.initState();
    _tabController = new TabController(vsync: this, length: tabs.length, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace, color: Colors.black, ),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
        title: Text('Welcome', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 20)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: < Widget > [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black, ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchHintDelegate(hintText: 'Search'),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black87, ),
            onPressed: () async {
              final SharedPreferences prefs = await _prefs;
              BlocProvider.of < NewsBloc > (context).add(FetchNewsList(country: prefs.getString('country') ?? 'in'));
            },
          )
        ],
      ),
      body: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          flexibleSpace: Row(
            children: < Widget > [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TabBar(
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
                  indicatorWeight: 0.001,
                  labelColor: Colors.blue[800],
                  labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  labelPadding: EdgeInsets.symmetric(horizontal: 10),
                  unselectedLabelColor: Colors.black,
                  controller: _tabController,
                  tabs: tabs
                ),
              ),
            ],
          ),
        ),
        body: BlocConsumer < NewsBloc, NewsState > (
          listener: (context, state) {
            if (state is CategoryLoaded) {
              // widget._refreshCompleter ?.complete();
              // widget._refreshCompleter = Completer();
            }
          },
          builder: (context, state) {
            if (state is NewsLoading) {
              return Container(
                color: Colors.white,
                child: Center(child: FlareLoading(
                  name: 'assets/loading.flr',
                  loopAnimation: 'active',
                  isLoading: true,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  // until: () => Future.delayed(Duration(seconds: 10)),
                  onSuccess: (_) {
                    print('Finished');
                  },
                  onError: (err, stack) {
                    print(err);
                  },
                )),
              );
            }
            if (state is NewsListLoaded) {
              final newsList = state.newsList;
              final sourceList = state.sourceList;
              return TabBarView(
                controller: _tabController,
                children: < Widget > [
                  for (var i = 0; i < 8; i++)...[
                    SizedBox.expand(
                      // child: StateHandler(refreshCompleter: _refreshCompleter, category: category[i], ),
                      child: Container(
                        color: Colors.white,
                        child: NewsList(news: newsList[i], category: category[i], sources: sourceList[i])),
                    ),
                  ],
                ],
              );
            } else {
              return Container(
                color: Colors.white,
                child: FlareLoading(
                  name: 'assets/noWifi.flr',
                  loopAnimation: 'Untitled',
                  isLoading: true,
                  fit: BoxFit.fill,
                  // until: () => Future.delayed(Duration(seconds: 10)),
                  onSuccess: (_) {
                    print('Finished');
                  },
                  onError: (err, stack) {
                    print(err);
                  },
                ),
              );
            }
          }
        ),
      )
    );
  }
}