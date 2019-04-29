import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter_shapes/flutter_shapes.dart';

void main() {
  SystemChrome.setPreferredOrientations(
          <DeviceOrientation>[DeviceOrientation.portraitUp])
      .then((_) => runApp(App()));
}

String title = 'Touch the Programming';
Random rand = Random();

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(primaryColor: Colors.grey[50]);
    return MaterialApp(title: title, theme: theme, home: Page());
  }
}

class Page extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Page> with SingleTickerProviderStateMixin {
  List<List<List<Code>>> data = <List<List<Code>>>[
    <List<Code>>[<Code>[]]
  ];
  Demo demo = Demo(Size(512, 512));
  List<Tab> menu = toL(
      '1. Hello,2. Comments,3. Position,4. Numbers,5. Styles,6. Loop,7. Line,8. If,9. Wrap-up'
          .split(',')
          .map((String m) => Tab(text: m)));
  TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 9, vsync: this)
      ..addListener(() {
        if (_tab.indexIsChanging) {
          _reset();
        }
      });
    rootBundle.loadString('assets/data.json').then((String d) => setState(() {
          final List<dynamic> decoded = json.decode(d);
          data = toL(decoded.map((dynamic t) {
            final List<dynamic> tab = t;
            return toL(tab.map((dynamic l) {
              final List<dynamic> line = l;
              return toL(line.map((dynamic c) => Code.json(c)));
            }));
          }));
        }));
  }

  @override
  Widget build(BuildContext context) {
    _reset();
    final List<ListView> tabs = toL(data.map((List<List<Code>> t) => ListView(
        children: toL(t.map((List<Code> l) => Container(
            height: 30,
            padding: EdgeInsets.only(left: 10),
            child: Row(children: toL(l.map((Code c) => _span(c))))))))));
    final TabBar bar = TabBar(
        controller: _tab,
        isScrollable: true,
        tabs: menu,
        indicatorColor: Colors.black);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(title), elevation: 0, actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _reset)
        ]),
        body: Column(
          children: <Widget>[
            AspectRatio(
                aspectRatio: 1.3, child: ClipRect(child: SpriteWidget(demo))),
            Container(color: Colors.grey[50], child: bar),
            Expanded(child: TabBarView(controller: _tab, children: tabs))
          ],
        ));
  }

  void _reset() => demo.init(toL(data[_tab.index].expand((List<Code> l) => l)));
  Widget _span(Code c) => c.opts.isEmpty || c.hide
      ? Text(c.hide ? '' : c.val,
          style: c.val.contains(RegExp(r'[,!/\.]'))
              ? TextStyle(color: Colors.green)
              : null)
      : DropdownButton<String>(
          value: c.val,
          onChanged: (String v) => setState(() => c.val = v),
          items: toL(c.opts.map((String o) =>
              DropdownMenuItem<String>(value: o, child: Text(o)))),
          iconSize: 0,
          style: TextStyle(color: Colors.red, fontSize: 16));
}

class Demo extends NodeWithSize {
  Demo(Size s) : super(s);
  int n, i, f;
  List<Offset> pos;
  List<List<double>> v;
  List<List<Offset>> l;
  List<List<Code>> tabs;
  void init(List<Code> tab) {
    n = int.parse(find(tab, 'n') ?? '1');
    pos = <Offset>[];
    tabs = <List<Code>>[];
    v = <List<double>>[];
    l = <List<Offset>>[];
    for (i = 0; i < n; i++) {
      tabs.add(toL(tab.map((Code c) => c.clone())));
      pos.add(Offset(256 + _dbl('x'), 256 + _dbl('y')));
      v.add(<double>[_dbl('vx'), _dbl('vy')]);
      l.add(<Offset>[]);
    }
    f = 0;
  }

  @override
  void paint(Canvas canvas) {
    for (i = 0; i < n && i * 10 < f; i++) {
      _draw(canvas);
    }
    f++;
  }

  void _draw(Canvas c) {
    for (dynamic p in <List<dynamic>>[
      <dynamic>[pos[i].dx, 'ifx', 0],
      <dynamic>[pos[i].dy, 'ify', 1]
    ]) {
      final double position = p[0];
      if (position > 256 + _dbl('${p[1]}1')) {
        v[i][p[2]] *= _dbl('${p[1]}v1');
      }
      if (position < 256 + _dbl('${p[1]}2')) {
        v[i][p[2]] *= _dbl('${p[1]}v2');
      }
    }
    pos[i] = pos[i].translate(v[i][0], v[i][1]);

    if (_dbl('liw') > 0) {
      l[i].add(pos[i]);
    }
    for (int j = 1; j < l[i].length; j += 1) {
      final Paint p = Paint()
        ..color = _col('li')
        ..strokeWidth = _dbl('liw');
      c.drawLine(l[i][j - 1], l[i][j], p);
    }

    for (dynamic l in <List<dynamic>>[
      <dynamic>['fi', 0],
      <dynamic>['st', 1]
    ]) {
      final Paint p = Paint()
        ..color = _col(l[0])
        ..style = PaintingStyle.values[l[1]]
        ..strokeWidth = _dbl('stw');
      Shapes(canvas: c, radius: _dbl('r'), paint: p, center: pos[i])
          .draw(_val('sh'));
    }
  }

  String _val(String id) => find(tabs[i], id);
  double _dbl(String id) => double.parse(_val(id) ?? '0');
  Color _col(String id) =>
      Color(int.parse(_val(id) ?? '0', radix: 16)).withOpacity(_dbl('${id}op'));
}

class Code {
  Code({this.val, this.id, this.opts, this.noCache, this.hide});
  factory Code.json(Map<String, dynamic> j) {
    final List<dynamic> opts = j['opts'];
    return Code(
        val: j['val'],
        id: j['id'],
        noCache: j['noCache'],
        hide: j['hide'],
        opts: opts.cast<String>());
  }
  String val, id, cache;
  bool noCache, hide;
  List<String> opts;
  Code clone() =>
      Code(val: val, id: id, noCache: noCache, hide: hide, opts: opts);
  String parse() {
    if (val != 'Random') {
      return val;
    }
    if (cache != null) {
      return cache;
    }
    final int i = rand.nextInt(opts.length - 1);
    final String c = toL(opts.where((String o) => o != 'Random'))[i];
    return noCache ? c : cache = c;
  }
}

String find(List<Code> tab, String id) =>
    tab.firstWhere((Code c) => c.id == id, orElse: () => null)?.parse();
List<E> toL<E>(Iterable<E> i) => i.toList();
