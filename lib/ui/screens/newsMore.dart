import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newz/model/news.dart';
import 'package:newz/ui/widgets/newsList.dart';

class NewsMore extends StatefulWidget {
  final News news;
  NewsMore({
    @required this.news
  });
  @override
  _NewsMoreState createState() => _NewsMoreState();
}

class _NewsMoreState extends State < NewsMore > {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace, color: Colors.black,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.news.source, style: TextStyle(color: Colors.black),),
        centerTitle: true,
        actions: < Widget > [
          IconButton(
            icon: Icon(Icons.bookmark_border, color: Colors.black,),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.black,),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: < Widget > [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: < Widget > [
                    Image.asset('assets/img/default.jpg', height: 300, width: 0.95 * MediaQuery.of(context).size.width, fit: BoxFit.cover, filterQuality: FilterQuality.low, ),
                    Image.network(widget.news.urlToImage ?? '', height : 300, width : 0.95 * MediaQuery.of(context).size.width, fit: BoxFit.cover, filterQuality: FilterQuality.low, ),
                  ],
                )
              ),
              SizedBox(height: 10, ),
              Text(widget.news.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800), ),
              SizedBox(height: 10, ),
              Row(
                children: < Widget > [
                  Text('Trending', style: TextStyle(color: Colors.blue[700], fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 20,
                    child: Center(child: Text('•', style: TextStyle(color: Colors.grey[600], fontSize: 14), )),
                  ),
                  Text(findTime(widget.news.publishedAt), style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.bold), )
                ],
              ),
              SizedBox(height: 10, ),
              Text(widget.news.description, style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: 10, ),
              Text(widget.news.content.replaceRange(widget.news.content.indexOf('['), widget.news.content.length, 'Read More'))
            ],
          ),
        ),
      ),
    );
  }
}