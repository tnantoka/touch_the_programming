import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:spritewidget/spritewidget.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touch the Programming',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyWidget(title: 'Touch the Programming'),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  List<List<List<Line>>> lines = [];
  NodeWithSize _rootNode;
  TabController _tabController;
  RedCircle circle;

  @override
  void initState() {
    super.initState();
    _rootNode = NodeWithSize(const Size(1024.0, 1024.0));
    circle = RedCircle(100.0);
    circle.position = const Offset(512.0, 512.0);
    _rootNode.addChild(circle);

    _tabController = TabController(length: 6, vsync: this);
    _tabController.index = 0;
    _tabController.addListener(onChangeTab);

    _loadJson();
  }

  void _loadJson() async {
    String data = await rootBundle.loadString("assets/data.json");
    List tabs = json.decode(data);
    setState(() {
      lines = tabs.map((dynamic tab) {
        List lines = tab;
        return lines.map((dynamic line) {
          List items = line;
          return items.map((dynamic item) => Line.fromJson(item)).toList();
        }).toList();
      }).toList();
    });
  }

  void onChangeTab() {
    if (!lines.isEmpty) {
      circle.lines = lines[_tabController.index];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!lines.isEmpty) {
      circle.lines = lines[_tabController.index];
    }
    List<Widget> listViews = lines.isEmpty
        ? []
        : lines
            .map((items) => ListView(
                padding: EdgeInsets.zero,
                children: items.map((line) {
                  return ListTile(
                      title: Row(
                    children: line.map((item) {
                      if (item.options.isEmpty) {
                        return Text(item.text);
                      } else {
                        return DropdownButton<String>(
                            value: item.text,
                            onChanged: (String newValue) {
                              setState(() {
                                item.text = newValue;
                              });
                            },
                            items: item.options.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            iconSize: 0,
                            style: TextStyle(
                                color: Colors.red,
                                //fontWeight: FontWeight.bold,
                                fontSize: 16.0));
                      }
                    }).toList(),
                  ));
                }).toList()))
            .toList();

    Widget editor = Column(
      children: <Widget>[
        Container(
          color: Theme.of(context).accentColor,
          child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: ["Comments", "Constants", "Assign", "Loop", "If", "Whole"]
                  .map((tab) => Tab(text: tab))
                  .toList()),
        ),
        Expanded(
          child: TabBarView(controller: _tabController, children: listViews),
        ),
      ],
    );

    return Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.refresh, semanticLabel: 'Refresh'),
              onPressed: () {
                setState(() {});
              },
            );
          })
        ]),
        body: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.3,
              child: ClipRect(
                child: Container(
                    child: Stack(children: <Widget>[SpriteWidget(_rootNode)])),
              ),
            ),
            Expanded(
              child: editor,
            ),
          ],
        ));
  }
}

class RedCircle extends Node {
  RedCircle(this.radius);
  List<List<Line>> lines = [];

  double radius;

  @override
  void paint(Canvas canvas) {
    if (!lines.isEmpty) {
      radius = double.parse(findLine("radius").text);
    }
    canvas.drawCircle(
        Offset.zero, radius, Paint()..color = const Color(0xffff0000));
  }

  Line findLine(String key) {
    return lines
        .expand((l) => l)
        .toList()
        .firstWhere((line) => line.key == key);
  }
}

class Line {
  String text;
  String key;
  List<String> options;

  Line({this.text, this.key, this.options});

  factory Line.fromJson(Map<String, dynamic> json) {
    List options = json['options'];
    return Line(
        text: json['text'].toString(),
        key: json['key'].toString(),
        options: options.map((dynamic option) => option.toString()).toList());
  }
}
