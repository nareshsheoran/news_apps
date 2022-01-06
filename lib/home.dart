import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart';
import 'package:news_apps/category.dart';
import 'package:news_apps/model.dart';
import 'package:news_apps/news_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  List<NewsQueryModel> newsModelList = <NewsQueryModel>[];
  List<NewsQueryModel> newsModelListCarousel = <NewsQueryModel>[];

  List<String> navBarItem = [
    'Top News',
    'India',
    'World',
    'Finance',
    'Technology',
    'Business',
    'Health'
  ];

  bool isLoading = true;

  getNewsByQuery(String query) async {
    Map element;
    int i = 0;
    String url =
        'https://newsapi.org/v2/everything?q=$query&from=2022-01-01&sortBy=publishedAt&apiKey=993a52977efd4711883137a3e13b3343';
    Response response = await get(Uri.parse(url));
    Map data = jsonDecode(response.body);
    setState(() {
      // data['articles'].forEach((element)
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

  getNewsOfIndia() async {
    Map element;
    int i = 0;
    String url =
        'https://newsapi.org/v2/top-headlines?country=in&apiKey=993a52977efd4711883137a3e13b3343';
    Response response = await get(Uri.parse(url));
    Map data = jsonDecode(response.body);
    setState(() {
      // data['articles'].forEach((element) {
      for (element in data['articles']) {
        try {
          i++;
          NewsQueryModel newsQueryModel = NewsQueryModel();
          newsQueryModel = NewsQueryModel.fromMap(element);
          newsModelListCarousel.add(newsQueryModel);
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
    getNewsByQuery('India');
    getNewsOfIndia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News App'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              //Search Container

              padding: const EdgeInsets.symmetric(horizontal: 8),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if ((searchController.text).replaceAll('', '') == '') {
                        print('Blank Search');
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Category(Query: searchController.text)));
                      }
                    },
                    child: Container(
                      child: const Icon(
                        Icons.search,
                        color: Colors.blueAccent,
                      ),
                      margin: const EdgeInsets.fromLTRB(3, 0, 7, 0),
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      if (value == '') {
                        print("Please Enter Text To Search");
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Category(Query: value)));
                      }
                    },
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Search News'),
                  )),
                ],
              ),
            ),
            Container(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: navBarItem.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Category(
                            Query: navBarItem[index],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                        child: Text(
                          navBarItem[index],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        autoPlay: true,
                        enableInfiniteScroll: false,
                        enlargeCenterPage: true,
                      ),
                      items: newsModelListCarousel.map((instance) {
                        return Builder(
                          builder: (BuildContext context) {
                            try {
                              return Container(
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
                                                :
                                            NewsView(instance.newsUrl)));
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            instance.newsImg,
                                            fit: BoxFit.fitHeight,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                        Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.black12
                                                          .withOpacity(0),
                                                      Colors.black12
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  )),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 10),
                                                child: Container(
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: Text(
                                                    instance.newsHead,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ))
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
                        );
                      }).toList(),
                    ),
            ),
            Container(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 25, 0, 0),
                    child: Row(
                      children: const [
                        Text(
                          'Latest news',
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  if (isLoading) Container(
                          height: MediaQuery.of(context).size.height - 450,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ) else ListView.builder(
                          itemCount: newsModelList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            try {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: InkWell(onTap: (){
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
                                              :
                                          NewsView(newsModelList[index].newsUrl)));
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
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Category(Query: "Technology")));
                          },
                          child: const Text('Show More'),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
