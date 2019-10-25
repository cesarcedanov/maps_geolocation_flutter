import 'package:flutter/material.dart';

class NewSightScreen extends StatelessWidget {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _snippet = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // title: Text('Create a new Place!'),
          elevation: 0,
          backgroundColor: Color.fromRGBO(40, 48, 72, 1),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 1],
              colors: [
                // Colors.blue,
                Color.fromRGBO(40, 48, 72, 1),
                Color.fromRGBO(133, 147, 152, 1),
              ],
            ),
          ),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.95),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(width: 1)),
              padding: const EdgeInsets.all(10),
              height: 250,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Create a new Place! ',
                    style: TextStyle(fontSize: 25, color: Colors.blueGrey),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _title,
                    maxLength: 60,
                    decoration: InputDecoration(
                      icon: Icon(Icons.pin_drop),
                      hintText: 'Enter the sight title',
                    ),
                  ),
                  TextField(
                    controller: _snippet,
                    maxLength: 250,
                    decoration: InputDecoration(
                      icon: Icon(Icons.description),
                      hintText: 'Enter a description',
                    ),
                  ),
                  FlatButton(
                    child: Text('Create'),
                    onPressed: () {
                      Navigator.of(context).pop({
                        'title': _title.text,
                        'snippet': _snippet.text,
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
