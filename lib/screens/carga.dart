import 'dart:async';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:normativas_app/screens/principal.dart';
import 'package:normativas_app/temas/theme.dart';
import 'package:normativas_app/utils/copiar_database.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:normativas_app/models/libros.dart';

class Carga extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      /*
theme: ThemeData(
  
          primaryColor: Colors.green,
          scaffoldBackgroundColor: Colors.deepPurpleAccent,
          cardTheme: CardTheme(color: Colors.yellow, ),
          
          textTheme: TextTheme(
              body1: TextStyle(color: Colors.deepOrangeAccent, fontSize: 22.0),
              subtitle: TextStyle(color: Colors.yellow,  fontSize: 8,),
              body2: TextStyle(color: Colors.white,  fontSize: 8,),
              headline: TextStyle(color: Colors.orange),
              subhead: TextStyle(color: Colors.pink, fontSize: 16),
              title: TextStyle(color: Colors.yellow),
              display1: TextStyle(color: Colors.yellow),
              display2: TextStyle(color: Colors.yellow),
              display3: TextStyle(color: Colors.yellow),
              //display4: TextStyle(color: Colors.yellow),
              caption: TextStyle(color: Colors.green),

              ),
             
          iconTheme: IconThemeData(color: Colors.cyan),
          backgroundColor: Colors.indigo,
      
          
          ),
          */

//theme: ThemeData.from(colorScheme: ColorScheme.light()),
      //darkTheme: ThemeData.from(colorScheme: ColorScheme.dark()),

      routes: {'principal': (context) => Principal()},
      //   routes: {'opciones2': (context) => Opciones2()},
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ArticulosLista databaseHelper = ArticulosLista();
  int duracion = 3;
  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Libros>> noteListFuture = databaseHelper.getLibrosList();
      noteListFuture.then((noteList) {
        setState(() {
          if (noteList.length == 0) {
            //  this.duracion = 8;
            databaseHelper.loadJsonData(database);
          } else if (noteList.length == 15) {
            databaseHelper.loadJsonData(database);
          }
        });
      });
    });
  }

  void startTimer() {
    Timer(Duration(seconds: this.duracion), () {
      Navigator.of(context).pushReplacementNamed('principal');
      // Navigator.of(context).pushReplacementNamed('opciones2');
    });
  }

  @override
  void initState() {
    super.initState();
    updateListView();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
          builder: (context, ThemeNotifier notifier, child) {
        return MaterialApp(
            title: "Normativas Bolivianas",
            debugShowCheckedModeBanner: false,
            theme: notifier.darkTheme ? dark : light,
            home: Scaffold(
                //backgroundColor: Colors.blueGrey,
                body: FlareActor(
              "assets/animacion/normativa.flr",
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: "normativas",
            )));
      }),
    );
  }
}
