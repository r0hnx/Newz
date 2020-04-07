part of 'newsHome.dart';

class SourceNews extends StatefulWidget {
  final Source source;
  final InAppBrowser browser = new InAppBrowser();
  final BaseCacheManager baseCacheManager = DefaultCacheManager();
  SourceNews({
    @required this.source
  });
  @override
  _SourceNewsState createState() => _SourceNewsState();
}

class _SourceNewsState extends State < SourceNews > {

  @override
  void initState() { 
    super.initState();
    BlocProvider.of<NewsBloc>(context).add(FetchSourceNews(source: widget.source.id));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace, color: Colors.black, ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.source.name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
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
            onPressed: () {
              BlocProvider.of<NewsBloc>(context).add(FetchSourceNews(source: widget.source.name));
            },
          )
        ],
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
                color: Colors.transparent,
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
            if (state is SourceNewsLoaded) {
              final newsList = state.news;
              print(newsList);
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            width: 0.5 * size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(widget.source.name, style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),),
                                Text(widget.source.description, maxLines: 3, overflow: TextOverflow.ellipsis,),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 0.3 * size.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: CachedNetworkImage(
                                cacheManager: widget.baseCacheManager,
                                imageUrl: "https://logo.clearbit.com/${widget.source.url.splitMapJoin(RegExp(r'^(?:https?:)?(?:\/\/)?(?:[^@\n]+@)?(?:www\.)?([^:\/\n]+)'),onMatch: (m) => '${m.group(0)}', onNonMatch: (n) => '').replaceAll('https://', '').replaceAll('http://', '').replaceAll('www.', '')}",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: newsList.map((n) => Column(
                        children: < Widget > [
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
                                          cacheManager: widget.baseCacheManager, imageUrl: n.urlToImage ?? '', fadeInDuration : Duration(milliseconds: 400), height : 150, width: 0.4 * size.width, fit: BoxFit.cover, filterQuality: FilterQuality.low, )
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
                                          child: Text(n.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800), maxLines: 3, overflow: TextOverflow.ellipsis, )),
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
                                              if (n.urlToImage != null) {
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
                        ],
                      )).toList(),
                    ),
                  ],
                ),
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
    );
  }
}