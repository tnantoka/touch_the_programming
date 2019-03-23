import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter_shapes/flutter_shapes.dart';

main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(App()));
}

var title = 'Touch the Programming';
var rand = Random();

class App extends StatelessWidget {
  build(_) {
    var theme = ThemeData(primaryColor: Colors.grey[50]);
    return MaterialApp(title: title, theme: theme, home: Page());
  }
}

class Page extends StatefulWidget {
  _State createState() => _State();
}

class _State extends State<Page> with SingleTickerProviderStateMixin {
  List<List<List<Code>>> data = [
    [[]]
  ];
  var demo = Demo(Size(512, 512));
  var menu = toL(
      '1. Hello,2. Comments,3. Position,4. Numbers,5. Styles,6. Loop,7. Line,8. If,9. Wrap-up'
          .split(',')
          .map((m) => Tab(text: m)));
  var _tab;
  initState() {
    super.initState();
    _tab = TabController(length: 8, vsync: this)
      ..addListener(() {
        if (_tab.indexIsChanging) _syncTab();
      });
    rootBundle.loadString('assets/data.json').then((d) => setState(() => data =
        toL((json.decode(d) as List).map((t) => toL((t as List)
            .map((l) => toL((l as List).map((c) => Code.fromJson(c)))))))));
  }

  build(_) {
    _syncTab();
    var tabs = toL(data.map((t) => ListView(
        children: toL(t.map((l) => Container(
            height: 30,
            padding: EdgeInsets.only(left: 10),
            child: Row(children: toL(l.map((c) => _codeSpan(c))))))))));
    var tabBar = TabBar(
        controller: _tab,
        isScrollable: true,
        tabs: menu,
        indicatorColor: Colors.black);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(title), elevation: 0, actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _syncTab)
        ]),
        body: Column(
          children: [
            AspectRatio(
                aspectRatio: 1.3, child: ClipRect(child: SpriteWidget(demo))),
            Container(color: Colors.grey[50], child: tabBar),
            Expanded(child: TabBarView(controller: _tab, children: tabs))
          ],
        ));
  }

  _syncTab() => demo.init(toL(data[_tab.index].expand((l) => l)));
  _codeSpan(Code c) => c.opts.isEmpty || c.hide
      ? Text(c.hide ? '' : c.val,
          style: c.val.contains(new RegExp(r'[,!/\.]'))
              ? TextStyle(color: Colors.green)
              : null)
      : DropdownButton(
          value: c.val,
          onChanged: (v) => setState(() => c.val = v),
          items: toL(
              c.opts.map((o) => DropdownMenuItem(value: o, child: Text(o)))),
          iconSize: 0,
          style: TextStyle(color: Colors.red, fontSize: 16));
}

class Demo extends NodeWithSize {
  Demo(s) : super(s);
  int n, i, f;
  List nodes, tabs, v;
  init(tab) {
    n = int.parse(find(tab, 'n') ?? '1');
    nodes = [];
    tabs = [];
    v = [];
    removeAllChildren();
    for (i = 0; i < n; i++) {
      tabs.add(toL(tab.map((c) => c.clone())));
      nodes.add(Offset(256 + _dbl('x'), 256 + _dbl('y')));
      v.add([_dbl('vx'), _dbl('vy')]);
    }
    f = 0;
  }

  paint(c) {
    for (i = 0; i < n && i * 10 < f; i++) _draw(c);
    f++;
  }

  _draw(c) {
    var pos = nodes[i];

    [
      ['ifx', pos.dx, 0],
      ['ify', pos.dy, 1]
    ].forEach((p) {
      if (p[1] > 256 + _dbl('${p[0]}1')) v[i][p[2]] = _dbl('${p[0]}v1');
      if (p[1] < 256 + _dbl('${p[0]}2')) v[i][p[2]] = _dbl('${p[0]}v2');
    });

    nodes[i] = Offset(pos.dx + v[i][0], pos.dy + v[i][1]);

    if (_val('l') == 'true') {
      addChild(Dot()
        ..position = pos
        ..col = _col('line')
        ..w = _dbl('linew'));
    }
    [
      ['fill', 0],
      ['str', 1]
    ].forEach((l) {
      var p = Paint()
        ..color = _col(l[0])
        ..style = PaintingStyle.values[l[1]]
        ..strokeWidth = _dbl('strw');
      Shapes(canvas: c, radius: _dbl('r'), paint: p, center: pos)
          .draw(_val('sh'));
    });
  }

  _val(id) => find(tabs[i], id);
  _dbl(id) => double.parse(_val(id) ?? '0');
  _col(id) => Color(int.parse(_val(id) ?? '0', radix: 16))
      .withOpacity(_dbl('${id}opa'));
}

class Dot extends Node {
  var col, w;
  paint(c) => c.drawCircle(Offset.zero, w, Paint()..color = col);
}

class Code {
  Code({this.val, this.id, this.opts, this.noCache, this.hide});
  var val, id, cache, noCache, hide;
  List opts;
  factory Code.fromJson(json) => Code(
      val: json['val'],
      id: json['id'],
      noCache: json['noCache'],
      hide: json['hide'],
      opts: (json['opts'] as List).cast<String>());
  clone() => Code(val: val, id: id, noCache: noCache, hide: hide, opts: opts);
  parse() {
    if (val != 'Random') return val;
    if (cache != null) return cache;
    var i = rand.nextInt(opts.length - 1);
    var c = toL(opts.where((o) => o != 'Random'))[i];
    return noCache ? c : cache = c;
  }
}

find<E>(tab, id) =>
    tab.firstWhere((c) => c.id == id, orElse: () => null)?.parse();
List<E> toL<E>(Iterable<E> i) => i.toList();
