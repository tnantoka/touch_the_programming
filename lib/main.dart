import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

void main() => runApp(MyApp());

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

class _MyWidgetState extends State<MyWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  VoidCallback _showBottomSheetCallback;
  NodeWithSize rootNode;
  List<Line> lines;

  @override
  void initState() {
    super.initState();
    rootNode = NodeWithSize(const Size(1024.0, 1024.0));
    _initializeFields();
  }

  @override
  void reassemble() {
    _initializeFields();
    super.reassemble();
  }

  void _initializeFields() {
    _showBottomSheetCallback = _showBottomSheet;
    _refresh();
  }

  void _refresh() {
    final Node circle = RedCircle(100.0);
    circle.position = const Offset(300.0, 300.0);

    rootNode.removeAllChildren();
    rootNode.addChild(circle);

    _loadJson();
  }

  void _loadJson() async {
    String constantsJson = await rootBundle.loadString("assets/constants.json");
    List constants = json.decode(constantsJson);
    lines =
        constants.map((dynamic constant) => Line.fromJson(constant)).toList();
  }

  void _showBottomSheet() {
    setState(() {
      _showBottomSheetCallback = null;
    });
    final List<Widget> tabBars = <Widget>[
      const Tab(icon: Icon(Icons.directions_car), text: 'test 2'),
      const Tab(icon: Icon(Icons.directions_transit), text: 'test 2'),
      const Tab(icon: Icon(Icons.directions_bike), text: 'test 2'),
    ];
    List<Widget> tabViews = <Widget>[
      Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: lines.map((line) {
            return ListTile(
                title: Row(
              children: line.items.map((item) {
                if (item.options.isEmpty) {
                  return Text(item.text);
                } else {
                  return DropdownButton<String>(
                      value: item.text,
                      onChanged: (String newValue) {
                        setState(() {
                          print("newValue");
                          print(newValue);
                          item.text = newValue;
                          print(item.text);
                        });
                      },
                      items: item.options
                          .map<DropdownMenuItem<String>>((String value) {
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
          }).toList()),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ListTile(
              title: Row(
            children: <Widget>[
              const Text('WDITH = ',
                  style: const TextStyle(fontFamily: 'monospace')),
              DropdownButton<String>(
                  value: "One",
                  onChanged: (String newValue) {
                    setState(() {
                      //dropdown1Value = newValue;
                    });
                  },
                  items: <String>['One', 'Two', 'Free', 'Four']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  iconSize: 0,
                  style: TextStyle(
                      color: Colors.red,
                      //fontWeight: FontWeight.bold,
                      fontSize: 16.0)),
              const Text('// test'),
            ],
          )),
          ListTile(
              title: Row(
            children: <Widget>[
              const Text('WDITH = ',
                  style: const TextStyle(fontFamily: 'monospace')),
              DropdownButton<String>(
                value: "One",
                onChanged: (String newValue) {
                  setState(() {
                    //dropdown1Value = newValue;
                  });
                },
                items: <String>['One', 'Two', 'Free', 'Four']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                iconSize: 0,
              ),
              const Text('// test'),
            ],
          )),
          ListTile(
              title: const Text('Simple dropdown:'),
              trailing: DropdownButton<String>(
                value: "One",
                onChanged: (String newValue) {
                  setState(() {
                    //dropdown1Value = newValue;
                  });
                },
                items: <String>['One', 'Two', 'Free', 'Four']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ))
        ],
      ),
      const Icon(Icons.directions_transit),
    ];
    _scaffoldKey.currentState
        .showBottomSheet<void>((BuildContext context) {
          return Container(
              height: 300,
              child: DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: TabBar(
                    tabs: tabBars,
                    labelColor: Colors.blue,
                  ),
                  body: TabBarView(
                    children: tabViews,
                  ),
                ),
              ));
        })
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              // re-enable the button
              _showBottomSheetCallback = _showBottomSheet;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(widget.title), actions: <Widget>[
        Builder(builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.refresh, semanticLabel: 'Refresh'),
            onPressed: () {
              setState(() {
                _refresh();
              });
            },
          );
        })
      ]),
      body: SpriteWidget(rootNode),
      floatingActionButton: _showBottomSheetCallback == null
          ? null
          : FloatingActionButton(
              onPressed: _showBottomSheetCallback,
              tooltip: 'Code',
              child: const Icon(Icons.code),
            ),
    );
  }
}

class RedCircle extends Node {
  RedCircle(this.radius);

  double radius;

  @override
  void paint(Canvas canvas) {
    canvas.drawCircle(
        Offset.zero, radius, Paint()..color = const Color(0xffff0000));
  }
}

class Line {
  List<LineItem> items;

  Line({this.items});

  factory Line.fromJson(Map<String, dynamic> json) {
    List items = json['items'];
    return Line(
        items: items.map((dynamic item) => LineItem.fromJson(item)).toList());
  }
}

class LineItem {
  String text;
  List<String> options;

  LineItem({this.text, this.options});

  factory LineItem.fromJson(Map<String, dynamic> json) {
    List options = json['options'];
    return LineItem(
        text: json['text'].toString(),
        options: options.map((dynamic option) => option.toString()).toList());
  }
}
