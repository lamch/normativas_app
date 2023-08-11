import 'dart:async';
import 'package:flutter/material.dart';
import 'package:normativas_app/models/articulo.dart';
import 'package:normativas_app/temas/theme.dart';
import 'package:normativas_app/utils/copiar_database.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'lista_json.dart';

class Favoritos extends StatefulWidget {
final int mostrarComercial;

Favoritos(this.mostrarComercial);

  @override
  State<StatefulWidget> createState() {
    return FavoritosState(this.mostrarComercial);
  }
}

class FavoritosState extends State<Favoritos> {
  final _debouncer = Debouncer(milliseconds: 500);
  ArticulosLista databaseHelper = ArticulosLista();
  List<Articulo> noteList;
  List<Articulo> noteListFiltro;
  int count = 0;
int mostrarComercial;
  Icon cusIcon = Icon(Icons.search);
  Widget cusSearchBar = Text("Favoritos");

FavoritosState(this.mostrarComercial);



  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          if (noteList == null) {
            noteList = List<Articulo>();
            noteListFiltro = List<Articulo>();
            getListaFavoritos();
          }

          return MaterialApp(
            theme: notifier.darkTheme ? dark : light,
            debugShowCheckedModeBanner: false,
            home: Scaffold(
            
              appBar: AppBar(actions: <Widget>[
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
                              hintText: "Buscar Favorito",
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
                          this.cusSearchBar = Text("Favoritos");
                          noteListFiltro = noteList;
                        }
                      });
                    },
                    icon: cusIcon)
              ], 
                    leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {               
                  Navigator.pop(context);
                }),
        
              
              title: cusSearchBar),
              body:  Container(
                  margin: const EdgeInsets.only(bottom: 50.0),
                  child: getNoteListView()
              ),
            ),
          );
        },
      ),
    );
  }

  ListView getNoteListView() {
    // TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: noteListFiltro.length,
      itemBuilder: (BuildContext context, int position) {
        return Container(
          //elevation: 2.0,
          child: ListTile(
            title: Text(
              this.noteListFiltro[position].cabecera,
              //style: titleStyle,
            ),
            subtitle: Text(this.noteListFiltro[position].descripcion),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(
                  this.noteListFiltro[position].id_libro,
                  this.noteListFiltro[position].descripcion,
                  this.noteListFiltro[position].id);
            },
          ),
        );
      },
    );
  }

  void navigateToDetail(int idlibro, String title, int id) async {
    
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ListaJson(idlibro, title, id, mostrarComercial);
    }));

    getListaFavoritos();
  }

  void getListaFavoritos() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Articulo>> noteListFuture =
          databaseHelper.getListaFavoritos();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.noteListFiltro = this.noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
