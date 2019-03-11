import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(App()));
}

var title = 'Touch the Programming';
var _rand = Random();

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: title,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Page(),
      );
}

class Page extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Page> with SingleTickerProviderStateMixin {
  List<List<List<Code>>> data = [
    [[]]
  ];
  var _root = NodeWithSize(Size(1024, 1024));
  var _shape = Shape();
  var menu = ['Comments', 'Assignment', 'While', 'If', 'Wrap-up']
      .map((m) => Tab(text: m))
      .toList();
  TabController _tabCon;

  @override
  void initState() {
    super.initState();
    _root.addChild(_shape);
    _tabCon = TabController(length: 5, vsync: this)..addListener(_syncTab);
    rootBundle.loadString('assets/data.json').then((d) {
      setState(() {
        data = (json.decode(d) as List).map((t) {
          return (t as List).map((l) {
            return (l as List).map((c) => Code.fromJson(c)).toList();
          }).toList();
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _syncTab();
    var tabViews = data.map((t) {
      return ListView(
          padding: EdgeInsets.zero,
          children: t.map((l) {
            return ListTile(
                title: Row(children: l.map((c) => _codeSpan(c)).toList()));
          }).toList());
    }).toList();
    var editor = Column(
      children: [
        Container(
          color: Colors.blue,
          child: TabBar(controller: _tabCon, isScrollable: true, tabs: menu),
        ),
        Expanded(child: TabBarView(controller: _tabCon, children: tabViews)),
      ],
    );
    return Scaffold(
        appBar: AppBar(title: Text(title), actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _shape.reset)
        ]),
        body: Column(
          children: [
            AspectRatio(aspectRatio: 1.3, child: SpriteWidget(_root)),
            Expanded(child: editor),
          ],
        ));
  }

  void _syncTab() => _shape.tab = data[_tabCon.index].expand((l) => l).toList();
  Widget _codeSpan(Code code) {
    if (code.opts.isEmpty) {
      return Text(code.val);
    }
    return DropdownButton(
        value: code.val,
        onChanged: (val) => setState(() => code.val = val),
        items: code.opts
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        iconSize: 0,
        style: TextStyle(color: Colors.red, fontSize: 16));
  }
}

class Shape extends Node {
  Shape() {
    reset();
  }

  var tab = <Code>[];
  double r, vx, vy;

  void reset() {
    _setPos(0, 0);
    vx = vy = 0;
    r = 100;
    tab.forEach((c) => c.cache = null);
  }

  @override
  void update(double dt) {
    position = Offset(position.dx + vx * dt, position.dy + vy * dt);
    super.update(dt);
  }

  @override
  void paint(Canvas canvas) {
    if (_val('x') != null) {
      _setPos(_dbl('x'), 0);
    }
    if (_val('y') != null) {
      _setPos(0, _dbl('y'));
    }

    vx = _val('vx') != null ? _dbl('vx') * 100 : 0;
    vy = _val('vy') != null ? _dbl('vy') * 100 : 0;

    if (_val('if1') != null) {
      vx = 100;
      if (position.dx > 512 + _dbl('if1')) {
        _setPos(_dbl('if1x'), _dbl('if1y'));
      }
    }

    r = _val('r') != null ? _dbl('r') : 100;
    [
      [_col(_val('fill')), PaintingStyle.fill],
      [_col(_val('stroke')), PaintingStyle.stroke]
    ].forEach((l) {
      canvas.drawCircle(
          Offset.zero,
          r,
          Paint()
            ..color = l[0]
            ..style = l[1]);
    });
  }

  void _setPos(double x, double y) => position = Offset(512 + x, 512 + y);
  Color _col(String v) => v != null
      ? Color(int.parse(v, radix: 16) + 0xFF000000).withOpacity(_dbl('opacity'))
      : Colors.red;
  double _dbl(String id) => double.parse(_val(id));
  String _val(String id) {
    return tab.firstWhere((c) => c.id == id, orElse: () => null)?.parse();
  }
}

class Code {
  Code({this.val, this.id, this.opts, this.noCache});

  String val, id, cache;
  List<String> opts;
  bool noCache;

  factory Code.fromJson(Map<String, dynamic> json) => Code(
      val: json['val'],
      id: json['id'],
      noCache: json['noCache'],
      opts: (json['opts'] as List).cast<String>());

  String parse() {
    if (val != 'Random') {
      return val;
    }
    if (cache != null) {
      return cache;
    }
    var i = _rand.nextInt(opts.length - 1);
    var _cache = opts.where((o) => o != 'Random').toList()[i];
    return noCache ? _cache : cache = _cache;
  }
}
