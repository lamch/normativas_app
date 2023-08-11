import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//*import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:normativas_app/models/libros.dart';

import 'package:normativas_app/screens/favoritos_list.dart';
import 'package:normativas_app/screens/opciones.dart';
import 'package:normativas_app/temas/theme.dart';
import 'package:normativas_app/utils/consumable.dart';

import 'package:normativas_app/utils/copiar_database.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'ayuda.dart';
import 'compra.dart';
import 'lista_json.dart';
//*import 'package:firebase_admob/firebase_admob.dart';
import 'package:store_redirect/store_redirect.dart';

const String testDevice = '3EDDCC19D91A776B4398594BD1DCB24C';

const bool kAutoConsume = true;

const String _kConsumableId = 'normativas_adicionales';
const List<String> _kProductIds = <String>[
  _kConsumableId,
];

final AdRequest request = AdRequest(
  keywords: <String>['foo', 'bar'],
  contentUrl: 'http://foo.com/bar.html',
  nonPersonalizedAds: true,
);

//const String testDevice = '';
//const String testDevice = 'Mobile_id';

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

GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

class Principal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PrincipalState();
  }
}

class PrincipalState extends State<Principal> {
  BannerAd _bannerAd;

  InterstitialAd _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  RewardedAd _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  RewardedInterstitialAd _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  bool _isAdLoaded = false;
  //*InterstitialAd _interstitialAd;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  //*final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  //*StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  //*List<ProductDetails> _products = [];
  //*List<PurchaseDetails> _purchases = [];
  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;
  int compraLibros = 0;

  Future<void> carga() async {
    int valor = await verificaCompraPaquetes2();

    setState(() {
      compraLibros = valor;
    });
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<int> verificaCompraPaquetes2() async {
    databaseHelper.initializeDatabase();

    return databaseHelper.verificaCompraPaquete();
  }

  @override
  void initState() {
    carga();
    super.initState();
    _initBannerAd();
    _createInterstitialAd();
    _initPackageInfo();
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

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-9577139226355545/5556956851'
            : 'ca-app-pub-3940256099942544/4411468910',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }

  @override
  void dispose() {
    super.dispose();

    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
  }

  final _debouncer = Debouncer(milliseconds: 500);
  ArticulosLista databaseHelper = ArticulosLista();
  List<Libros> noteList;
  List<Libros> noteListFiltro;
  int count = 0;
  final FocusNode messageFocusNode = FocusNode();
  Icon cusIcon = const Icon(Icons.search);
  Widget cusSearchBar = const Text("Listado de Leyes");

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          if (noteList == null) {
            noteList = <Libros>[];
            noteListFiltro = <Libros>[];
            updateListView();
          }

          return MaterialApp(
            theme: notifier.darkTheme ? dark : light,
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(actions: <Widget>[
                IconButton(
                    onPressed: () {
                      setState(() {
                        if (cusIcon.icon == Icons.search) {
                          cusIcon = const Icon(Icons.cancel);
                          cusSearchBar = TextField(
                            textInputAction: TextInputAction.go,
                            // ignore: prefer_const_constructors
                            decoration: InputDecoration(
                              hintText: "Buscar Ley",
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            // ignore: prefer_const_constructors
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                            autofocus: true,
                            onChanged: (string) {
                              _debouncer.run(() {
                                setState(() {
                                  noteListFiltro = noteList
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
                          cusIcon = const Icon(Icons.search);
                          cusSearchBar = const Text("Listado de Leyes");
                          noteListFiltro = noteList;
                        }
                      });
                    },
                    icon: cusIcon)
              ], title: cusSearchBar),
              body: Container(
                child: getNoteListView(notifier.darkTheme),
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
              //: const SizedBox(),
              drawer: Drawer(
                child: ListView(
                  children: <Widget>[
                    const SizedBox(
                      height: 120.0,
                      // ignore: unnecessary_const
                      child: const DrawerHeader(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        child:
                            Text('Opciones', style: TextStyle(fontSize: 30.0)),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.favorite,
                        color: notifier.darkTheme
                            ? Colors.yellow
                            : Colors.blueAccent,
                        size: 32,
                      ),
                      title: const Text('Lista de Favoritos',
                          style: const TextStyle(fontSize: 20.0)),
                      onTap: () {
                        navigateToFavorito();
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.bookmark,
                        color: notifier.darkTheme
                            ? Colors.yellow
                            : Colors.blueAccent,
                        size: 32,
                      ),
                      title: const Text('Acerca del desarrollador',
                          style: TextStyle(fontSize: 20.0)),
                      onTap: () {
                        createAlertDialog(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.star,
                        color: notifier.darkTheme
                            ? Colors.yellow
                            : Colors.blueAccent,
                        size: 32,
                      ),
                      title: const Text('Califica la aplicación',
                          style: TextStyle(fontSize: 20.0)),
                      onTap: () {
                        StoreRedirect.redirect(
                            androidAppId: "com.bolivia.normativas_app",
                            iOSAppId: "585027354");
                      },
                    ),
                    /*ListTile(
                      leading: Icon(
                        Icons.add_shopping_cart,
                        color: notifier.darkTheme
                            ? Colors.yellow
                            : Colors.blueAccent,
                        size: 32,
                      ),
                      title: const Text('Colaboración y Compra de productos',
                          style: TextStyle(fontSize: 20.0)),
                      onTap: () {
                        navigateTocompra(context);
                      },
                    ),*/
                    ListTile(
                      leading: Icon(
                        Icons.other_houses_sharp,
                        color: notifier.darkTheme
                            ? Colors.yellow
                            : Colors.blueAccent,
                        size: 32,
                      ),
                      title: const Text('Otros productos',
                          style: TextStyle(fontSize: 20.0)),
                      onTap: () {
                        muestraproducosAlertDialog(context, notifier);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.help,
                        color: notifier.darkTheme
                            ? Colors.yellow
                            : Colors.blueAccent,
                        size: 32,
                      ),
                      title: const Text('Ayuda',
                          style: const TextStyle(fontSize: 20.0)),
                      onTap: () {
                        //compraLibros > 0 ? _showInterstitialAd() : "";
                        navigateToAyuda();
                      },
                    ),
                    Consumer<ThemeNotifier>(
                      builder: (context, notifier, child) => SwitchListTile(
                        title: const Text("Modo Oscuro",
                            style: TextStyle(fontSize: 20.0)),
                        onChanged: (val) {
                          notifier.toggleTheme();
                        },
                        value: notifier.darkTheme,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ListView getNoteListView(bool notifier) {
    return ListView.builder(
      itemCount: noteListFiltro.length,
      itemBuilder: (BuildContext context, int position) {
        return ListTile(
          title: Text(
            noteListFiltro[position].cabecera,
            style: TextStyle(
                color: notifier ? Colors.yellow[400] : Colors.blue,
                fontSize: 20),
          ),
          subtitle: Text(
            noteListFiltro[position].descripcion,
            style: TextStyle(fontSize: 15),
          ),
          onTap: () {
            compraLibros > 0 ? _showInterstitialAd() : "";
            navigateToDetail(
                noteListFiltro[position].id, noteListFiltro[position].cabecera);
          },
        );
      },
    );
  }

  void navigateToDetail(int id, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ListaJson(id, title, 0, compraLibros);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Libros>> noteListFuture = databaseHelper.getLibrosList();
      noteListFuture.then((noteList) {
        setState(() {
          noteList = noteList;
          noteListFiltro = noteList;
          count = noteList.length;
        });
      });
    });
  }

  void navigateToFavorito() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Favoritos(compraLibros);
    }));

    {
      _scaffoldKey.currentState.openEndDrawer();
    }
  }

  void navigateToAyuda() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Ayuda();
    }));

    {
      _scaffoldKey.currentState.openEndDrawer();
    }
  }

  void navigateTocompra(BuildContext context) async {
    carga();

    if (compraLibros > 0) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        //return DemoPage();
      }));

      carga();
    } else {
      ContieneNormativa(context);
    }

    _scaffoldKey.currentState.openEndDrawer();
  }

  void navigateToOpciones() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Opciones();
    }));
  }

  createAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: [
            Image.asset(
              'assets/images/logo1.png',
              fit: BoxFit.scaleDown,
            ),
            const Text('Normativas Bolivianas.',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ))
          ]),
          content: SizedBox(
            height: 170,

            child: Column(children: [
              const Padding(
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  "Copyright 2022 Desarrollo Boliviano. Todos los derechos reservados.",
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 15),
                ),
              ),
              const Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Gestión: 2022",
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Versión:${_packageInfo.version}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              )
            ]),
            // _infoTile('App version', _packageInfo.version),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  muestraproducosAlertDialog(BuildContext context, ThemeNotifier notifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: [
            const Text('Más aplicaciones',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ))
          ]),
          content: SizedBox(
            height: 300,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.games,
                    color: Colors.lightGreen,
                    size: 32,
                  ),
                  title: const Text('Juego para niños',
                      style: const TextStyle(fontSize: 20.0)),
                  onTap: () {
                    StoreRedirect.redirect(
                      androidAppId: "com.bo.animalgame",
                      //iOSAppId: "585027354"
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.orangeAccent,
                    size: 32,
                  ),
                  title: const Text('Aplicación Cristiana',
                      style: const TextStyle(fontSize: 20.0)),
                  onTap: () {
                    StoreRedirect.redirect(
                      androidAppId: "com.bo.appcristiana",
                      //iOSAppId: "585027354"
                    );
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  ContieneNormativa(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: [
            Image.asset(
              'assets/images/logo1.png',
              fit: BoxFit.scaleDown,
            ),
            const Text('Normativas Bolivianas.',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ))
          ]),
          content: SizedBox(
            height: 170,

            child: Column(children: [
              const Padding(
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  "Usted ya compro la aplicación que quita toda la publicidad de la aplicación",
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 20),
                ),
              ),
            ]),
            // _infoTile('App version', _packageInfo.version),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void actualizaLibros() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      databaseHelper.actualizaLibros();
    });
  }
}
