import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _showBottomSheetCallback = _showBottomSheet;
  }

  void _showBottomSheet() {
    setState(() {
      _showBottomSheetCallback = null;
    });
    _scaffoldKey.currentState
        .showBottomSheet<void>((BuildContext context) {
          final ThemeData themeData = Theme.of(context);
          return Container(
              height: 300,
              child: DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.directions_car), text: "test 2"),
                      Tab(icon: Icon(Icons.directions_transit), text: "test 2"),
                      Tab(icon: Icon(Icons.directions_bike), text: "test 2"),
                    ],
                    labelColor: Colors.blue,
                  ),
                  body: TabBarView(
                    children: [
                      Icon(Icons.directions_car),
                      Icon(Icons.directions_transit),
                      Icon(Icons.directions_bike),
                    ],
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
            onPressed: () {},
          );
        })
      ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[]..addAll(<Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
            ]),
        ),
      ),
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
