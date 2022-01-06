import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:news_apps/model.dart';

import 'news_view.dart';

class Category extends StatefulWidget {
  String Query;

  Category({required this.Query});

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  List<NewsQueryModel> newsModelList = <NewsQueryModel>[];
  bool isLoading = true;

  getNewsByQuery(String query) async {
    Map element;
    int i = 0;
    String url = '';
    if (query == 'Top News' || query == 'India') {
      url =
          'https://newsapi.org/v2/top-headlines?country=in&apiKey=993a52977efd4711883137a3e13b3343';
    } else {
      url =
          'https://newsapi.org/v2/everything?q=$query&from=2022-01-01&sortBy=publishedAt&apiKey=993a52977efd4711883137a3e13b3343';
    }

    Response response = await get(Uri.parse(url));
    Map data = jsonDecode(response.body);
    setState(() {
      // data['articles'].forEach((element) {
      for (element in data['articles']) {
        try {
          i++;
          NewsQueryModel newsQueryModel = NewsQueryModel();
          newsQueryModel = NewsQueryModel.fromMap(element);
          newsModelList.add(newsQueryModel);
          setState(() {
            isLoading = false;
          });
          // newsModelList.sublist(0,5);
          if (i == 5) {
            break;
          }
        } catch (e) {
          print(e);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getNewsByQuery(widget.Query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(15, 10, 0, 0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.Query,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              isLoading
                  ? Container(
                      height: MediaQuery.of(context).size.height - 500,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ListView.builder(
                      itemCount: newsModelList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        try {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => isLoading
                                            ? Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    500,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )
                                            : NewsView(
                                                newsModelList[index].newsUrl)));
                              },
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        newsModelList[index].newsImg,
                                        fit: BoxFit.fitHeight,
                                        height: 230,
                                        width: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          gradient: LinearGradient(
                                              colors: [
                                                Colors.black12.withOpacity(0),
                                                Colors.black
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter),
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 15, 10, 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              newsModelList[index].newsHead,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              newsModelList[index]
                                                          .newsDes
                                                          .length >
                                                      50
                                                  ? '${newsModelList[index].newsDes.substring(0, 55)}....'
                                                  : newsModelList[index]
                                                      .newsDes,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } catch (e) {
                          print(e);
                          return Container();
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
