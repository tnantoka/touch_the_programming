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
  Widget build(BuildContext context) {
    var theme = ThemeData(primaryColor: Colors.grey[50]);
    return MaterialApp(title: title, theme: theme, home: Page());
  }
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
  var _shapes = [Shape()];
  var menu = toL(
      ['Comments', 'Assign', 'Loop', 'If', 'Wrap-up'].map((m) => Tab(text: m)));
  TabController _tabCon;

  @override
  void initState() {
    super.initState();
    _root.addChild(_shapes[0]);
    _tabCon = TabController(length: 5, vsync: this)..addListener(_syncTab);
    rootBundle.loadString('assets/data.json').then((d) => setState(() => data =
        toL((json.decode(d) as List).map((t) => toL((t as List)
            .map((l) => toL((l as List).map((c) => Code.fromJson(c)))))))));
  }

  @override
  Widget build(BuildContext context) {
    _syncTab();
    var tabs = toL(data.map((t) => ListView(
        padding: EdgeInsets.zero,
        children: toL(t.map((l) => Container(
            height: 30,
            padding: EdgeInsets.only(left: 10),
            child: Row(children: toL(l.map((c) => _codeSpan(c))))))))));
    var tabBar = TabBar(
        controller: _tabCon,
        isScrollable: true,
        tabs: menu,
        indicatorColor: Colors.black);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(title), elevation: 0, actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetTab)
        ]),
        body: Column(
          children: [
            AspectRatio(aspectRatio: 1.3, child: SpriteWidget(_root)),
            Container(color: Colors.grey[50], child: tabBar),
            Expanded(child: TabBarView(controller: _tabCon, children: tabs)),
          ],
        ));
  }

  void _resetTab() {
    _syncTab();
    _shapes.forEach((s) => s.reset());
  }

  void _syncTab() {
    var tab = toL(data[_tabCon.index].expand((l) => l));
    var n = code(tab, 'num');
    _root.removeAllChildren();
    for (var i = 0; i < (n != null ? int.parse(n) : 1); i++) {
      _shapes.add(Shape());
      _root.addChild(_shapes.last);
    }
    _shapes.forEach((s) => s.tab = toL(tab.map((c) => c.clone())));
  }

  Widget _codeSpan(Code code) => code.opts.isEmpty
      ? Text(code.val)
      : DropdownButton(
          value: code.val,
          onChanged: (v) => setState(() => code.val = v),
          items: toL(
              code.opts.map((o) => DropdownMenuItem(value: o, child: Text(o)))),
          iconSize: 0,
          style: TextStyle(color: Colors.red, fontSize: 16));
}

class Shape extends Node {
  Shape() {
    reset();
  }

  var tab = <Code>[];
  double vx, vy;

  void reset() {
    _move(0, 0);
    vx = vy = 0;
    tab.forEach((c) => c.cache = null);
  }

  @override
  void update(double dt) {
    position = Offset(position.dx + vx * 100 * dt, position.dy + vy * 100 * dt);
    if (_val('l') == 'true') {
      parent.addChild(Dot()
        ..position = position
        ..color = _col('str'));
    }
    super.update(dt);
  }

  @override
  void paint(Canvas canvas) {
    if (_val('x') != null && _val('y') != null) _move(_dbl('x'), _dbl('y'));

    vx = _dbl('vx');
    vy = _dbl('vy');
    if (_val('if1') != null) {
      vx = 1;
      if (position.dx > 512 + _dbl('if1')) _move(_dbl('if1x'), _dbl('if1y'));
    }

    [
      ['fill', PaintingStyle.fill],
      ['str', PaintingStyle.stroke]
    ].forEach((l) {
      canvas.drawCircle(
          Offset.zero,
          _dbl('r', or: 100),
          Paint()
            ..color = _col(l[0])
            ..style = l[1]);
    });
  }

  void _move(double x, double y) => position = Offset(512 + x, 512 + y);
  Color _col(String id) => _val(id) != null
      ? Color(int.parse(_val(id), radix: 16)).withOpacity(_dbl('${id}opa'))
      : Colors.grey;
  double _dbl(String id, {double or = 0}) =>
      _val(id) != null ? double.parse(_val(id)) : or;
  String _val(String id) => code(tab, id);
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
  Code clone() => Code(val: val, id: id, noCache: noCache, opts: opts);
  String parse() {
    if (val != 'Random') return val;
    if (cache != null) return cache;
    var i = _rand.nextInt(opts.length - 1);
    var _cache = toL(opts.where((o) => o != 'Random'))[i];
    return noCache ? _cache : cache = _cache;
  }
}

class Dot extends Node {
  Color color;
  void paint(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 1, Paint()..color = color);
  }
}

String code(List<Code> tab, String id) =>
    tab.firstWhere((c) => c.id == id, orElse: () => null)?.parse();
List<E> toL<E>(Iterable<E> i) => i.toList();
