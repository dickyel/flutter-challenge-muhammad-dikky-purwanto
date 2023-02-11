import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class SimpleDashboard extends StatefulWidget {
  @override
  State<SimpleDashboard> createState() => _SimpleDashboardState();
}

class Debouncer {
  int? milliseconds;
  VoidCallback? action;
  Timer? timer;

  run(VoidCallback action) {
    if (null != timer) {
      timer!.cancel();
    }
    timer = Timer(
      Duration(milliseconds: Duration.millisecondsPerSecond),
      action,
    );
  }
}

class _SimpleDashboardState extends State<SimpleDashboard> {
  final _debouncer = Debouncer();
  Box? box = Hive.box('favorites');
  final String apiUrl = "https://dummyjson.com/products/";

  _fecthDataProducts() async {
    var result = await http.get(Uri.parse(apiUrl));
    return json.decode(result.body)['products'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Dashboard'),
        backgroundColor: Color(0xff7E00B3),
      ),
      body: ListView(
        children: [
          Container(
            child: FutureBuilder(
              future: _fecthDataProducts(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    padding: EdgeInsets.all(8),
                    itemBuilder: (BuildContext context, int index) {
                      final api = apiUrl[index];
                      final _isFavorite = box?.get(index) != null;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Card(
                                  child: Image.network(
                                    snapshot.data[index]['thumbnail'],
                                    height: 60,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            snapshot.data[index]["title"],
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              if (_isFavorite) {
                                                await box?.delete(index);
                                              } else {
                                                await box?.put(index, api);
                                              }

                                              const snackBar = SnackBar(
                                                content: Text(
                                                    'Tambahkan Telah Berhasil'),
                                                backgroundColor: Colors.blue,
                                              );

                                              ScaffoldMessenger.of(context)
                                                  .clearSnackBars();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);
                                            },
                                            icon: Icon(
                                              _isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        snapshot.data[index]["brand"],
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        snapshot.data[index]["category"],
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                          height: 100,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                snapshot.data[index]
                                                    ["description"],
                                                style: TextStyle(
                                                  color: Color(0xff868597),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                            ],
                          )
                        ],
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
