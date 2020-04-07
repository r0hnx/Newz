import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:newz/bloc/news_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:newz/model/news.dart';
import 'package:newz/repository/news_repo.dart';
import 'package:newz/ui/screens/newsHome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'
as http;

class NewsList extends StatefulWidget {
  final BaseCacheManager baseCacheManager = DefaultCacheManager();
  final List < News > news;
  final List < Source > sources;
  final String category;
  final InAppBrowser browser = new InAppBrowser();
  NewsList({
    Key key,
    @required this.news,
    @required this.sources,
    @required this.category
  }): super(key: key);
  @override
  _NewsListState createState() => _NewsListState();
}

String findTime(String s) {
  int parsedTime = DateTime.parse(s).difference(DateTime.now()).inMinutes.abs();
  if (parsedTime > (60 * 24 * 30)) {
    return (parsedTime / (60 * 24 * 30)).toStringAsFixed(0) + 'M ago';
  } if (parsedTime > (60 * 24)) {
    return (parsedTime / (60 * 24)).toStringAsFixed(0) + 'd ago';
  } else if (parsedTime < 1) {
    return parsedTime.toStringAsFixed(0) + 's ago';
  } else if (parsedTime > (60)) {
    return (parsedTime / 60).toStringAsFixed(0) + 'h ago';
  } else if (parsedTime > (60 * 24 * 365)) {
    return (parsedTime / (60 * 24 * 365)).toStringAsFixed(0) + 'y ago';
  } else return parsedTime.toStringAsFixed(0) + 'm ago';
}

class _NewsListState extends State < NewsList > {

  static List < String > countryList = ["Argentina", "Australia", "Austria", "Belgium", "Brazil", "Bulgaria", "Canada", "China", "Colombia", "Cuba", "Czech Republic", "Egypt", "France", "Germany", "Greece", "Hong Kong", "Hungary", "India", "Indonesia", "Ireland", "Israel", "Italy", "Japan", "Latvia", "Lithuania", "Malaysia", "Mexico", "Morocco", "Netherlands", "New Zealand", "Nigeria", "Norway", "Philippines", "Poland", "Portugal", "Romania", "Russia", "Saudi Arabia", "Serbia", "Singapore", "Slovakia", "Slovenia", "South Africa", "South Korea", "Sweden", "Switzerland", "Taiwan", "Thailand", "Turkey", "UAE", "Ukraine", "United Kingdom", "United States", "Venuzuela"];
  static List < String > codeList = ["ar", "au", "at", "be", "br", "bg", "ca", "cn", "co", "cu", "cz", "eg", "fr", "de", "gr", "hk", "hu", "in", "id", "ie", "il", "it", "jp", "lv", "lt", "my", "mx", "ma", "nl", "nz", "ng", "no", "ph", "pl", "pt", "ro", "ru", "sa", "rs", "sg", "sk", "si", "za", "kr", "se", "ch", "tw", "th", "tr", "ae", "ua", "gb", "us", "ve"];

  final Future < SharedPreferences > _prefs = SharedPreferences.getInstance();
  List < DropdownMenuItem > countryListItems = List < DropdownMenuItem > ();

  Future < void > _shareImageFromUrl(News news, BuildContext context) async {
    try {
      await widget.baseCacheManager
          .getFile(news.urlToImage)
          .first
          .then((info) {
            info.file.readAsBytes().then((bytes) => Share.file(
              '${news.title ?? ""}', 
              '${news.hashCode}.jpg', 
              bytes, 
              'image/jpg', 
              text: "${news.description}\n\nRead here : ${news.url}\n\nShared via *NEWZ*",
            )
          );
        }
      );
      Navigator.pop(context);
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _shareDefaultImage(News news, BuildContext context) async {
    // final ByteData bytes = await rootBundle.load('assets/img/default.png');
    try {
      await rootBundle.load('assets/img/default.png').then((bytes) => Share.file(
          '${news.title ?? ""}', 
          '${news.hashCode}.jpg', 
          bytes.buffer.asUint8List(), 
          'image/jpg', 
          text: "${news.description}\n\nRead here : ${news.url}\n\nShared via *NEWZ*",
        )
      );
      Navigator.pop(context);
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  void initState() {
    for (var i = 0; i < countryList.length; i++) {
      countryListItems.add(DropdownMenuItem(child: Text(countryList[i]), value: codeList[i]));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ListView(
      children: < Widget > [
        if (widget.category == 'local')...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: < Widget > [
                    FutureBuilder(
                      future: SharedPreferences.getInstance(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          SharedPreferences prefs = snapshot.data;
                          return Row(
                            children: <Widget>[
                              Image.network(
                                'https://www.countryflags.io/${prefs.containsKey('country') ? prefs.getString('country') : 'in'}/shiny/64.png',
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 10,),
                              Text('${prefs.containsKey('country') ? prefs.getString('country') : 'in'}'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold),)
                            ],
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      }
                    ),        
                    DropdownButton(
                      underline: Divider(color: Colors.transparent,),
                      items: countryListItems, 
                      onChanged: (v) async {
                        final SharedPreferences prefs = await _prefs;
                        prefs.setString('country', v);
                        BlocProvider.of < NewsBloc > (context).add(FetchNewsList(country: prefs.getString('country') ?? 'in'), );
                      },
                      hint: Text('Change Country'),
                    )
                  ],
                ),
            ),
          ],
          InkWell(
            onTap: () {
              widget.browser.open(
                url: widget.news[0].url,
                options: InAppBrowserClassOptions()
              );
            },
            onLongPress: () {
              Clipboard.setData(new ClipboardData(text: widget.news[0].url));
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Link Copied To Clipboard'),
                  action: SnackBarAction(
                    label: 'Done',
                    onPressed: () {},
                  ),
                )
              );
            },
            child: Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: < Widget > [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: < Widget > [
                        Image.asset('assets/img/default.png', height: 300, width: 0.95 * size.width, fit: BoxFit.cover, filterQuality: FilterQuality.low, ),
                        CachedNetworkImage(
                          cacheManager: widget.baseCacheManager,                          
                          imageUrl: widget.news[0].urlToImage ?? '', 
                          height : 300, 
                          width : 0.95 * size.width, 
                          fit: BoxFit.cover, 
                          filterQuality: FilterQuality.low,
                        )
                        // Image.network(widget.news[0].urlToImage ?? '', height : 300, width : 0.95 * size.width, fit: BoxFit.cover, filterQuality: FilterQuality.low, ),                        
                      ],
                    )
                  ),
                  SizedBox(height: 10, ),
                  Text(widget.news[0].source, style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.bold), ),
                  SizedBox(height: 10, ),
                  Text(widget.news[0].title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800), ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: < Widget > [
                      Row(
                        children: < Widget > [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: CachedNetworkImage(
                                cacheManager: widget.baseCacheManager,
                                imageUrl: "https://logo.clearbit.com/${widget.news[0].url.splitMapJoin(RegExp(r'^(?:https?:)?(?:\/\/)?(?:[^@\n]+@)?(?:www\.)?([^:\/\n]+)'),onMatch: (m) => '${m.group(0)}', onNonMatch: (n) => '').replaceAll('https://', '').replaceAll('http://', '').replaceAll('www.', '')}",
                              ),
                              // child: Image.network("https://icon-locator.herokuapp.com/icon?url=${widget.news[0].url.splitMapJoin(RegExp(r'^.+?[^\/:](?=[?\/]|$)'),onMatch: (m) => '${m.group(0)}', onNonMatch: (n) => '')}&size=70..120..200")),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                            child: Center(child: Text('•', style: TextStyle(color: Colors.grey[600], fontSize: 14), )),
                          ),
                          Text('Trending', style: TextStyle(color: Colors.blue[700], fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(
                            width: 20,
                            child: Center(child: Text('•', style: TextStyle(color: Colors.grey[600], fontSize: 14), )),
                          ),
                          Text(findTime(widget.news[0].publishedAt), style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.bold), )
                        ],
                      ),
                      IconButton(icon: Icon(Icons.more_horiz), onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          child: Center(
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                  child: CircularProgressIndicator(strokeWidth: 8.0, valueColor: AlwaysStoppedAnimation(Colors.white), ),
                              ),
                            ),
                          ));
                          if(widget.news[0].urlToImage != null) {
                            _shareImageFromUrl(widget.news[0], context);
                          } else {
                            _shareDefaultImage(widget.news[0], context);                                     
                          }
                      }, )
                    ],
                  )
                ],
              ),
            ),
          ),
          if(widget.sources.isNotEmpty) ...[
            Divider(),
            SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.sources.map((s) => InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(
                    create: (context) => NewsBloc(newsRepository: NewsRepository(
                      newsApiClient: NewsApiClient(
                        httpClient: http.Client(),
                      ),
                    )),
                    child: SourceNews(source: s,),
                  ),)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.grey.withOpacity(0.5),
                            offset: Offset(5,5)
                          )
                        ]
                      ),
                      child: SizedBox(
                        height: 120,
                        width: 120,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: CachedNetworkImage(
                            cacheManager: widget.baseCacheManager,
                            imageUrl: "https://logo.clearbit.com/${s.url.splitMapJoin(RegExp(r'^(?:https?:)?(?:\/\/)?(?:[^@\n]+@)?(?:www\.)?([^:\/\n]+)'),onMatch: (m) => '${m.group(0)}', onNonMatch: (n) => '').replaceAll('https://', '').replaceAll('http://', '').replaceAll('www.', '') }",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ).toList(),
              ),
            ),
          ],
          Column(
            children: widget.news.map((n) => Column(
              children: < Widget > [
                if (n.id != widget.news[0].id)...[
                  Divider(),
                  InkWell(
                    onTap: () {
                      widget.browser.open(
                        url: n.url,
                        options: InAppBrowserClassOptions()
                      );
                    },
                    onLongPress: () {
                      Clipboard.setData(new ClipboardData(text: n.url));
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Link Copied To Clipboard'),
                          action: SnackBarAction(
                            label: 'Done',
                            onPressed: () {},
                          ),
                        )
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: < Widget > [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: < Widget > [
                                Image.asset('assets/img/default.png', height: 150, width: 0.4 * size.width, fit: BoxFit.cover, filterQuality: FilterQuality.low, ),
                                // Image.network(n.urlToImage ?? '', height : 150, width : 0.4 * size.width, fit: BoxFit.cover, filterQuality: FilterQuality.low, ),
                                CachedNetworkImage(
                                  cacheManager: widget.baseCacheManager,imageUrl: n.urlToImage ?? '', fadeInDuration: Duration(milliseconds: 400), height : 150, width : 0.4 * size.width, fit: BoxFit.cover, filterQuality: FilterQuality.low,)
                              ],
                            )),
                          SizedBox(
                            width: 0.5 * size.width,
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: < Widget > [
                                Text(n.source, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                SizedBox(
                                  width: 0.5 * size.width,
                                  child: Text(n.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800), maxLines: 4, overflow: TextOverflow.ellipsis, )),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: < Widget > [
                                    Row(
                                      children: < Widget > [
                                        // Text('Trending', style: TextStyle(color: Colors.blue[700], fontSize: 12)),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: SizedBox(
                                            height: 30,                                            
                                            width: 30,
                                            child: CachedNetworkImage(
                                              cacheManager: widget.baseCacheManager,
                                              imageUrl: "https://logo.clearbit.com/${n.url.splitMapJoin(RegExp(r'^(?:https?:)?(?:\/\/)?(?:[^@\n]+@)?(?:www\.)?([^:\/\n]+)'),onMatch: (m) => '${m.group(0)}', onNonMatch: (n) => '').replaceAll('https://', '').replaceAll('http://', '').replaceAll('www.', '')}",
                                            ),
                                            // child: Image.network("https://icon-locator.herokuapp.com/icon?url=${n.url.splitMapJoin(RegExp(r'^.+?[^\/:](?=[?\/]|$)'),onMatch: (m) => '${m.group(0)}', onNonMatch: (n) => '')}&size=70..120..200")),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                          child: Center(child: Text('•', style: TextStyle(color: Colors.grey[600], fontSize: 12), )),
                                        ),
                                        Text(findTime(n.publishedAt), style: TextStyle(color: Colors.grey[600], fontSize: 12), )
                                      ],
                                    ),
                                    IconButton(icon: Icon(Icons.more_horiz), onPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        child: Center(
                                          child: SizedBox(
                                            width: 100,
                                            height: 100,
                                            child: Padding(
                                              padding: const EdgeInsets.all(18.0),
                                                child: CircularProgressIndicator(strokeWidth: 8.0, valueColor: AlwaysStoppedAnimation(Colors.white), ),
                                            ),
                                          ),
                                        ));
                                      if(n.urlToImage != null) {
                                        _shareImageFromUrl(n, context);
                                      } else {
                                        _shareDefaultImage(n, context);                                     
                                      }
                                    }, )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            )).toList(),
          )
      ],
    );
  }
}