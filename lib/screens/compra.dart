import 'dart:async';
/*
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:normativas_app/temas/theme.dart';
import 'package:normativas_app/utils/copiar_database.dart';
import 'package:sqflite/sqflite.dart';

class DemoPage extends StatefulWidget {
  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final String _productID = 'quitapublicidad';
  ArticulosLista databaseHelper = ArticulosLista();
  bool _available = true;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  StreamSubscription<List<PurchaseDetails>> _subscription;
  ThemeNotifier notifier;
  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;

    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      setState(() {
        _purchases.addAll(purchaseDetailsList);
        _listenToPurchaseUpdated(purchaseDetailsList);
      });
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      _subscription.cancel();
    });

    _initialize();

    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _initialize() async {
    _available = await _inAppPurchase.isAvailable();

    List<ProductDetails> products = await _getProducts(
      productIds: Set<String>.from(
        [_productID],
      ),
    );

    setState(() {
      _products = products;
    });
  }

  void actualizaLibros() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      databaseHelper.actualizaLibros();
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          //  _showPendingUI();
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // bool valid = await _verifyPurchase(purchaseDetails);
          // if (!valid) {
          //   _handleInvalidPurchase(purchaseDetails);
          // }
          break;
        case PurchaseStatus.error:
          print(purchaseDetails.error);
          if (purchaseDetails.error.message ==
              "BillingResponse.itemAlreadyOwned") {
            actualizaLibros();
          }
          // _handleError(purchaseDetails.error!);
          break;
        default:
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
        actualizaLibros();
      }
    });
  }

  Future<List<ProductDetails>> _getProducts({Set<String> productIds}) async {
    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds);

    return response.productDetails;
  }

  ListTile _buildProduct({ProductDetails product}) {
    return ListTile(
      leading: Icon(Icons.attach_money),
      title: Text(
        '${product.title} - ${product.price}',
        style: TextStyle(fontSize: 24.0),
      ),
      subtitle: Text(
        product.description,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.green),
      ),
      trailing: ElevatedButton(
        onPressed: () {
          _subscribe(product: product);
        },
        child: Text(
          'Comprar',
        ),
      ),
    );
  }

  ListTile _buildPurchase({PurchaseDetails purchase}) {
    if (purchase.error != null) {
      return ListTile(
        title: Text('${purchase.error}'),
        subtitle: Text(purchase.status.toString()),
      );
    }

    String transactionDate;
    if (purchase.status == PurchaseStatus.purchased) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(purchase.transactionDate),
      );
      transactionDate = ' @ ' + DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    }

    return ListTile(
      title: Text('${purchase.productID} ${transactionDate ?? ''}'),
      subtitle: Text(purchase.status.toString()),
    );
  }

  void _subscribe({ProductDetails product}) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  @override
  Widget build(BuildContext context) {
    notifier ??= ThemeNotifier();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: notifier.darkTheme ? dark : light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Compra de productos'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: _available
            ? Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lista de productos',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 36.0),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              return _buildProduct(
                                product: _products[index],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  /* Expanded(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Compras Pasadas: ${_purchases.length}'),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _import 'package:in_app_purchase_android/in_app_purchase_android.dart';purchases.length,
                            itemBuilder: (context, index) {
                              return _buildPurchase(
                                purchase: _purchases[index],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),*/
                ],
              )
            : Center(
                child: Text('La tienda no esta habilitada'),
              ),
      ),
    );
  }
}
*/