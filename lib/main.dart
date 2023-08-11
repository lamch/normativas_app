import 'package:flutter/material.dart';
import 'package:normativas_app/screens/carga.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

void main() {
  // ignore: deprecated_member_use
  InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(Carga());
//runApp(MyApp());
}
