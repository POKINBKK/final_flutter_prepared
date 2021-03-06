import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import './commentPage.dart';

Future<List<Posts>> fetchPosts(int userid) async {
  final response = await http.get('https://jsonplaceholder.typicode.com/users/${userid}/posts');

  List<Posts> postsApi = [];

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    var body = json.decode(response.body);
    for(int i = 0; i< body.length;i++){
      var posts = Posts.fromJson(body[i]);
      if(posts.userid == userid){
        postsApi.add(posts);
      }
    }
    return postsApi;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}


class Posts{
  final int userid;
  final int id;
  final String title;
  final String body;

  Posts({this.userid, this.id, this.title, this.body});

  factory Posts.fromJson(Map<String, dynamic> json) {
      return Posts(
      userid: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

class PostPage extends StatelessWidget {
  // Declare a field that holds the Todo
  final int id;
  // In the constructor, require a Todo
  PostPage({Key key, @required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create our UI
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text("BACK"),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            FutureBuilder(
              future: fetchPosts(this.id),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return new Text('loading...');
                  default:
                    if (snapshot.hasError){
                      return new Text('Error: ${snapshot.error}');
                    } else {
                      return createListView(context, snapshot);
                    }
                }
              },
            ),
            
          ],
        ),
      ),
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Posts> values = snapshot.data;
    return new Expanded(
      child: new ListView.builder(
        itemCount: values.length,
        itemBuilder: (BuildContext context, int index) {
          return new Card(
            child: InkWell(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${(values[index].id).toString()} : ${values[index].title}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24
                  ),
                ),
                Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 10)),
                Text(
                  values[index].body,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentPage(id: values[index].id),
                ),
              );
              },
            ),
          );
        },
      ),
    );
  }

}