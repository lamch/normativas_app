// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:back_button_interceptor/back_button_interceptor.dart';
//*import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:normativas_app/models/treeList.dart';
import 'package:normativas_app/temas/theme.dart';
import 'package:normativas_app/utils/copiar_database.dart';
import 'package:normativas_app/models/articulo.dart';

import 'package:sqflite/sqflite.dart';

//ScrollController _scrollController;
const TIMEOUT = Duration(seconds: 10);
const TIMEOUT2 = Duration(seconds: 6);
const TIMEOUT3 = Duration(seconds: 5);
SwiperController _controller = SwiperController();
List<Articulo> noteListFiltro;

GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

//HiddenDrawerController controller;

class ListaJson extends StatefulWidget {
  final int idlibro;
  final int id;
  final String titleLibro;
  final int mostrarComercial;

  // ignore: use_key_in_widget_constructors
  const ListaJson(
      this.idlibro, this.titleLibro, this.id, this.mostrarComercial);

  @override
  State<StatefulWidget> createState() {
    // _scrollController = new ScrollController();
    // ignore: no_logic_in_create_state
    return ListaJsonState(idlibro, titleLibro, id, mostrarComercial);
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

const String testDevice = '3EDDCC19D91A776B4398594BD1DCB24C';

class ListaJsonState extends State<ListaJson> {
  ArticulosLista databaseHelper = ArticulosLista();
  List<Articulo> noteList;
  List<TreeList> treeListNuevo;
  BannerAd _bannerAd;
  bool _isAdLoaded = false;
  Future<List<TreeList>> treeList;
  int posicionarSuma = 0;
  int count = 0;
  int countTreelist = 0;
  int idlibro;
  int id;
  String title = "";
  int mostrarComercial;
  int compraLibros = 0;

  @override
  void dispose() {
    super.dispose();
  }

  ThemeNotifier notifier;

  ListaJsonState(this.idlibro, this.title, this.id, this.mostrarComercial);

  Icon cusIcon = const Icon(Icons.search);
  final _debouncer = Debouncer(milliseconds: 300);
  bool filtro = false;

  Widget cusSearchBar = Text("123");
  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      // ignore: deprecated_member_use
      noteList = <Articulo>[];
      noteListFiltro = <Articulo>[];
      cusSearchBar = Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13));
      treeListNuevo = <TreeList>[];
    }

/*
    var _asyncLoader = new AsyncLoader(
      key: _asyncLoaderState,
      initState: () async => await updateListView2(),
      renderLoad: () => new CircularProgressIndicator(),
      renderError: ([error]) =>
          new Text('Sorry, there was an error loading your joke'),
      renderSuccess: ({data}) => getListViewHorizontal(),
    );
    */

    notifier ??= ThemeNotifier();

    posicionarSuma++;
    if (posicionarSuma == 3) {
      posicionar(id);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: notifier.darkTheme ? dark : light,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        //*resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        endDrawer: listaDrawer(),
        appBar: AppBar(
            titleSpacing: 0,
            actions: <Widget>[
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (this.cusIcon.icon == Icons.search) {
                        this.cusIcon = Icon(Icons.cancel);
                        this.cusSearchBar = TextField(
                          autofocus: true,
                          textInputAction: TextInputAction.go,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: "Buscar articulo",
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                          onChanged: (string) {
                            _debouncer.run(() {
                              setState(() {
                                noteListFiltro = this
                                    .noteList
                                    .where((u) => (u.cabecera
                                            .toLowerCase()
                                            .contains(string.toLowerCase()) ||
                                        u.descripcion
                                            .toLowerCase()
                                            .contains(string.toLowerCase())))
                                    .toList();
                              });
                            });
                          },
                        );
                      } else {
                        this.cusIcon = Icon(Icons.search);
                        this.cusSearchBar = Text(this.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13));
                        noteListFiltro = noteList;
                      }
                    });
                  },
                  icon: cusIcon),
              IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState.openEndDrawer();
                  })
            ],
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: cusSearchBar),
        body: noteList.isNotEmpty
            ? Container(child: getListViewHorizontal())
            : const Center(
                child: CircularProgressIndicator(),
              ),
        bottomNavigationBar: compraLibros > 0
            ? _isAdLoaded
                ? SizedBox(
                    height: _bannerAd.size.height.toDouble(),
                    width: _bannerAd.size.width.toDouble(),
                    child: AdWidget(ad: _bannerAd),
                  )
                : const SizedBox()
            : const SizedBox(),
      ),
    );
  }

  Future<List<TreeList>> getListaExpandible(int idLibro) async {
    //await wait(4);
    String jSonText = "";
    switch (idLibro) {
      case 1:
        jSonText = await rootBundle.loadString('assets/constitucionList.json');
        break;
      case 2:
        jSonText = await rootBundle.loadString('assets/civilList.json');
        break;
      case 3:
        jSonText = await rootBundle.loadString('assets/comercioList.json');
        break;
      case 4:
        jSonText = await rootBundle.loadString('assets/procesalcivilList.json');
        break;
      case 5:
        jSonText = await rootBundle.loadString('assets/transitoList.json');
        break;
      case 6:
        jSonText =
            await rootBundle.loadString('assets/serviciosfinancierosList.json');
        break;
      case 7:
        jSonText = await rootBundle.loadString('assets/mineriaList.json');
        break;

      case 8:
        jSonText = await rootBundle.loadString('assets/corrupcionList.json');
        break;
      case 9:
        jSonText = await rootBundle.loadString('assets/ninoList.json');
        break;

      case 10:
        jSonText = await rootBundle.loadString('assets/educacionList.json');
        break;

      case 11:
        jSonText = await rootBundle.loadString('assets/bebidasList.json');
        break;

      case 12:
        jSonText = await rootBundle.loadString('assets/seguridadList.json');
        break;

      case 13:
        jSonText = await rootBundle.loadString('assets/trabajoList.json');
        break;

      case 14:
        jSonText =
            await rootBundle.loadString('assets/discriminacionList.json');
        break;

      case 15:
        jSonText = await rootBundle.loadString('assets/autonomiasList.json');
        break;

      case 16:
        jSonText = await rootBundle.loadString('assets/codigopenalList.json');
        break;
    }

    //return parseJonsTreeList(jSonText);

    Future<List<TreeList>> noteListFuture = parseJonsTreeList(jSonText);
    noteListFuture.then((noteList) {
      setState(() {
        treeListNuevo = noteList;
        countTreelist = noteList.length;
      });
    });

    return noteListFuture;
  }

  Future<List<TreeList>> parseJonsTreeList(String response) async {
    if (response == null) {
      return [];
    }
    final parsed =
        json.decode(response.toString()).cast<Map<String, dynamic>>();
    return parsed.map<TreeList>((json) => new TreeList.fromJson(json)).toList();
  }

  Future wait(int seconds) {
    return new Future.delayed(Duration(seconds: seconds), () => {});
  }

  ListView getNoteListView() {
    final screenSize = MediaQuery.of(context).size;
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: count,
      physics: ClampingScrollPhysics(),
      itemBuilder: (BuildContext context, int position) {
        return Container(
          color: Colors.white,
          width: screenSize.width,
          height: screenSize.height * 0.35,
          child: Card(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ListTile(
                title: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      "Value 1",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0),
                    )
                  ],
                ),
                subtitle: Text(this.noteList[position].descripcion),
                dense: true,
              ),
            ),
          ),
        );
        //	subtitle: Text(this.noteList[position].descripcion),
      },
    );
  }

  @override
  void initState() {
    //* BackButtonInterceptor.add(myInterceptor);

    //*if (this.mostrarComercial > 0) {
    //*   createInterstitialAd()
    //*     ..load()
    //*    ..show();
    //*}

    //futureWidgetViewHorizontal();
    carga();
    super.initState();
    _initBannerAd();
    updateListView2();
    //posicionar(id);
  }

  Future<void> carga() async {
    int valor = await verificaCompraPaquetes2();

    setState(() {
      compraLibros = valor;
    });
  }

  Future<int> verificaCompraPaquetes2() async {
    databaseHelper.initializeDatabase();

    return databaseHelper.verificaCompraPaquete();
  }

  _initBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-9577139226355545/6387942352",
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {},
      ),
      request: AdRequest(),
    );
    _bannerAd.load();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    if (_scaffoldKey.currentState.isDrawerOpen) {
      Navigator.pop(context);
      return false;
    } else {
      _scaffoldKey.currentState.openDrawer();
      return true;
    }
  }

  void actualizaFavorito(int favorito, int id) async {
    //  this.id = 0;

    await databaseHelper.actualizaFavorito(favorito, id);

    await updateListView(id);

    //updateListView(id);

    //posicionar(id);

    if (favorito == 1) {
      _showAlertDialog('Información', 'Se agregó el articulo a favoritos');
    } else {
      _showAlertDialog('Información', 'Se quitó de la lista de favoritos');
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 0:
        return Icon(
          Icons.favorite,
          color: Colors.white,
        );
        break;
      case 1:
        return Icon(
          Icons.favorite,
          color: Colors.yellowAccent,
        );
        break;

      default:
        return Icon(
          Icons.favorite,
          color: Colors.white,
        );
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  updateListView(int ids) async {
    //await wait(2);
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Articulo>> noteListFuture =
          databaseHelper.getNoteList(this.idlibro);
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          noteListFiltro = noteList;
          this.count = noteList.length;

          //  wait(2);

          if (ids > 0) {
            if (noteListFiltro.length > 0) {
              var index = noteListFiltro.firstWhere((p) => p.id == ids);
              var rr = noteListFiltro.indexOf(index);

              if (rr != null) {
                if (ids > 0) {
                  //  setState(() {
                  Future.delayed(Duration.zero,
                      () => {_controller.move(rr, animation: true)});

                  //  this.id = 0;
                  //     });
                }
              }
            }
          }
        });
      });
    });
  }

  updateListView2() async {
    await getListaExpandible(this.idlibro);

    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Articulo>> noteListFuture =
          databaseHelper.verificaCargaLeyes2(this.idlibro);
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          noteListFiltro = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

/*
  share(BuildContext context, Articulo alligator) {
    //final RenderBox box = context.findRenderObject();

    Share.share("${this.title} - ${alligator.cabecera}",
        : alligator.descripcion);
        //sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
*/
  Future<void> share(BuildContext context, Articulo alligator) async {
    String texto = "";
    if (alligator.subtitulo != "") {
      texto = title +
          " - " +
          alligator.cabecera +
          alligator.subtitulo +
          "\n" +
          alligator.descripcion;
    } else {
      texto = title + " - " + alligator.cabecera + "\n" + alligator.descripcion;
    }

    await FlutterShare.share(
        title: title + " " + alligator.cabecera + alligator.subtitulo,
        text: texto +
            "Encuentra la aplicacion en: https://play.google.com/store/apps/details?id=com.bolivia.normativas_app",
        chooserTitle: 'Leyes Bolivia');
  }

  Drawer listaDrawer() {
    return new Drawer(
        child: treeListNuevo.length > 0
            ? ListView.builder(
                itemBuilder: (BuildContext context, int index) =>
                    EntryItem(treeListNuevo[index]),
                itemCount: countTreelist,
                shrinkWrap: true,
              )
            : futureWidget());
  }

  Widget futureWidget() {
    return new FutureBuilder<List>(
        future: getListaExpandible(this.idlibro),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    child: EntryItem(snapshot.data[index]),
                  );
                });
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 40.0,
                width: 40.0,
                child: CircularProgressIndicator(),
              ),
            ],
          );
        });
  }

  Widget futureWidget2() {
    return FutureBuilder<List>(
        future: getListaExpandible(this.idlibro),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    child: EntryItem(snapshot.data[index]),
                  );
                });
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              SizedBox(
                height: 40.0,
                width: 40.0,
                child: CircularProgressIndicator(),
              ),
            ],
          );
        });
  }

  Swiper getListViewHorizontal() {
    return Swiper(
      controller: _controller,
      key: UniqueKey(),
      autoplayDisableOnInteraction: true,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AppBar(
                  automaticallyImplyLeading: false,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(noteListFiltro[index].cabecera,
                          style: TextStyle(
                            color: notifier.darkTheme
                                ? Colors.yellow
                                : Colors.white,
                          )),
                    ],
                  ),
                  flexibleSpace: Container(
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[Colors.red, Colors.blue]))),
                  actions: <Widget>[
                    IconButton(
                        icon: getPriorityIcon(noteListFiltro[index].favorito),
                        onPressed: () {
                          //  createInterstitialAd()
                          //   ..load()
                          //   ..show();

                          actualizaFavorito(
                              noteListFiltro[index].favorito == 1 ? 0 : 1,
                              noteListFiltro[index].id);
                        }),
                    IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          share(context, noteListFiltro[index]);
                        }),
                  ],
                ),
                noteListFiltro[index].subtitulo != ""
                    ? ListTile(
                        title: Text(
                          noteListFiltro[index].subtitulo,
                          style: TextStyle(
                              color: notifier.darkTheme
                                  ? Colors.yellow
                                  : Colors.blue,
                              fontSize: 20),
                        ),
                        subtitle: Text(noteListFiltro[index].descripcion,
                            style: TextStyle(fontSize: 20)),
                      )
                    : ListTile(
                        subtitle: Text(noteListFiltro[index].descripcion,
                            style: const TextStyle(fontSize: 20)),
                      )
              ],
            ),
          ),
        );
      },
      itemCount: noteListFiltro.length,
      control: new SwiperControl(),
      loop: false,
      onIndexChanged: (int index) {},
    );
  }

  void posicionar(int ids) {
    if (ids > 0) {
      if (noteListFiltro.isNotEmpty) {
        var index = noteListFiltro.firstWhere((p) => p.id == ids);
        var rr = noteListFiltro.indexOf(index);

        if (rr != null) {
          if (ids > 0) {
            setState(() {
              Future.delayed(
                  Duration.zero, () => {_controller.move(rr, animation: true)});

              //  this.id = 0;
            });
          }
        }
      }
    }
  }

  posicionar2(int ids) async {
//await wait(4);

    if (ids > 0) {
      if (noteListFiltro.isNotEmpty) {
        var index = noteListFiltro.firstWhere((p) => p.id == ids);
        var rr = noteListFiltro.indexOf(index);

        if (rr != null) {
          if (ids > 0) {
            setState(() {
              Future.delayed(
                  Duration.zero, () => {_controller.move(rr, animation: true)});

              //  this.id = 0;
            });
          }
        }
      }
    }
  }
}

class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final TreeList entry;

  Widget _buildTiles(TreeList root) {
    if (root.treeList == null)
      // ignore: curly_braces_in_flow_control_structures
      return ListTile(
        title: Text(root.cabecera),
        onTap: () {
          if (root.id == 0) {
            debugPrint("Cabecera");
          } else {
            debugPrint(root.id.toString());

            var index = noteListFiltro.firstWhere((p) => p.id == root.id);
            var rr = noteListFiltro.indexOf(index);

            if (_controller != null) {
              // ignore: invalid_use_of_protected_member
              if (_controller.hasListeners) {
                Future.delayed(Duration.zero,
                    () => {_controller.move(rr, animation: true)});
              }

              _scaffoldKey.currentState.openDrawer();
            }
          }
        },
      );
    return ExpansionTile(
      key: PageStorageKey<TreeList>(root),
      title: Text("${root.cabecera}\n${root.descripcion}"),
      children: root.treeList.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}
