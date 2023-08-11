import 'package:flutter/services.dart' show rootBundle;
import 'package:normativas_app/models/articulo.dart';
import 'package:normativas_app/models/libros.dart';
import 'package:normativas_app/models/treeList.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ArticulosLista {
  static ArticulosLista _databaseHelper;
  static Database _database;
  String noteTable = 'articulos';
  String colId = 'id';
  String colTitle = 'cabecera';
  String colSubtitulo = 'subtitulo';
  String colDescription = 'descripcion';

  ArticulosLista._createInstance();

  factory ArticulosLista() {
    if (_databaseHelper == null) {
      _databaseHelper = ArticulosLista
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.

    //loadJsonData();

    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'note.db';

    // Open/create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 2, onCreate: _createDb);

    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER, $colTitle TEXT, subtitulo TEXT, '
        '$colDescription TEXT, idlibro INTEGER, favorito INTEGER)');

    await db.execute('CREATE TABLE libros(id INTEGER, $colTitle TEXT, '
        '$colDescription TEXT, estado INTEGER)');
  }

  Future<bool> loadJsonData(Database db) async {
    //var jSonText = await rootBundle.loadString('assets/constitucion.json');
    //  var lista = parseJosn(jSonText);
    await deleteLibros(db);

    var jSonText2 = await rootBundle.loadString('assets/libros.json');
    var lista2 = parseJosnLibro(jSonText2);
    Set<Libros> set2 = Set.from(lista2);
    set2.forEach((element) => db.insert("libros", element.toMap()));

    return true;
  }

  Future<bool> deleteLibros(Database db) async {
    await db.delete("libros");

    return true;
  }

  Future<int> verificaVersion() async {
    Database db = await this.database;

    var result = await db.query("libros", orderBy: '$colId ASC');
    if (result.length > 0) {
      return 3;
    }

    loadJsonData(db);
    return 10;
  }

  List<Articulo> parseJosn(String response) {
    if (response == null) {
      return [];
    }
    final parsed =
        json.decode(response.toString()).cast<Map<String, dynamic>>();
    return parsed.map<Articulo>((json) => new Articulo.fromJson(json)).toList();
  }

  List<TreeList> parseJonsTreeList(String response) {
    if (response == null) {
      return [];
    }
    final parsed =
        json.decode(response.toString()).cast<Map<String, dynamic>>();
    return parsed.map<TreeList>((json) => new TreeList.fromJson(json)).toList();
  }

  List<Libros> parseJosnLibro(String response) {
    if (response == null) {
      return [];
    }
    final parsed =
        json.decode(response.toString()).cast<Map<String, dynamic>>();
    return parsed.map<Libros>((json) => new Libros.fromJson(json)).toList();
  }

// Insert Operation: Insert a Note object to database
  Future<int> insertNote(Articulo note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList(int idLibro) async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable,
        where: 'idlibro = ?', whereArgs: [idLibro], orderBy: '$colId ASC');
    return result;
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getLibrosMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query("libros", orderBy: '$colId ASC');
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
  Future<List<Articulo>> getNoteList(int idLibro) async {
    var noteMapList =
        await getNoteMapList(idLibro); // Get 'Map List' from database
    int count =
        noteMapList.length; // Count the number of map entries in db table

    List<Articulo> noteList = List<Articulo>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Articulo.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

  Future<List<Libros>> getLibrosList() async {
    var noteMapList = await getLibrosMapList(); // Get 'Map List' from database
    int count =
        noteMapList.length; // Count the number of map entries in db table

    List<Libros> noteList = List<Libros>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Libros.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> actualizaFavorito(int favorito, int id) async {
    var db = await this.database;

    int count = await db.rawUpdate(
        'UPDATE articulos SET favorito = ? WHERE id = ?', [favorito, id]);

    return count;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> actualizaLibros() async {
    var db = await this.database;

    int count = await db.rawUpdate('UPDATE libros SET estado = 1 ');

    return count;
  }

  Future<int> verificaCompraPaquete() async {
    var db = await this.database;
    var results = await db
        .rawQuery('SELECT count(*) as total from libros where estado = 0');

    if (results.isNotEmpty) {
      for (var result in results) {
        return int.parse(result["total"].toString());
      }
    }

    return 0;
  }

  Future wait(int seconds) {
    return new Future.delayed(Duration(seconds: seconds), () => {});
  }

  cargaLeyes(int idLibro) async {
    var db = await this.database;
    String ley = "";

    switch (idLibro) {
      case 1:
        ley = 'assets/constitucion.json';
        break;

      case 2:
        ley = 'assets/civil.json';
        break;

      case 3:
        ley = 'assets/comercio.json';
        break;
      case 4:
        ley = 'assets/procesalcivil.json';
        break;
      case 5:
        ley = 'assets/transito.json';
        break;
      case 6:
        ley = 'assets/serviciosfinancieros.json';
        break;
      case 7:
        ley = 'assets/mineria.json';
        break;
      case 8:
        ley = 'assets/corrupcion.json';
        break;
      case 9:
        ley = 'assets/nino.json';
        break;
      case 10:
        ley = 'assets/educacion.json';
        break;
      case 11:
        ley = 'assets/bebidas.json';
        break;
      case 12:
        ley = 'assets/seguridad.json';
        break;
      case 13:
        ley = 'assets/trabajo.json';
        break;
      case 14:
        ley = 'assets/discriminacion.json';
        break;
      case 15:
        ley = 'assets/autonomias.json';
        break;
      case 16:
        ley = 'assets/codigopenal.json';
        break;
    }

    var jSonText2 = await rootBundle.loadString(ley);
    var listaCivl = parseJosn(jSonText2);

    await db.transaction((txn) async {
      var batch = txn.batch();
      Set<Articulo> set = Set.from(listaCivl);
      set.forEach(
        (element) => batch.insert(noteTable, element.toMap()),
      );

      await batch.commit(noResult: true);
    });
  }

  // Update Operation: Update a Note object and save it to database
  Future<List<Articulo>> verificaCargaLeyes2(int idLibro) async {
    try {
      final id = await valor(idLibro);
      if (id == 0) {
        await cargaLeyes(idLibro);
      }

      return await getNoteList(idLibro);
    } on Exception catch (err) {
      print("Error $err");
      return null;
    } finally {
      print("Extio");
    }
  }

  Future<int> valor(int idLibro) async {
    var db = await this.database;
    var results = await db.rawQuery(
        'SELECT count(*) as total from articulos WHERE idLibro = ' +
            idLibro.toString());

    if (results.isNotEmpty) {
      for (var result in results) {
        return int.parse(result["total"].toString());
      }
    }

    return 0;
  }

// Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
  Future<List<TreeList>> getListaExpandible(int idLibro) async {
    String jSonText = "";
    //verificaCargaLeyes(idLibro);
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
    }

    return parseJonsTreeList(jSonText);
  }

// Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
  Future<List<Articulo>> getListaFavoritos() async {
    List<Articulo> lista = new List<Articulo>();
    var db = await this.database;
    var results = await db.rawQuery(
        'SELECT libros.id as idlibro, articulos.id, articulos.cabecera, articulos.subtitulo, libros.cabecera as cabeceraLibro FROM articulos INNER JOIN libros ON articulos.idLibro = libros.id WHERE articulos.favorito = '
        '1'
        '');

    if (results.isNotEmpty) {
      for (var result in results) {
        Articulo fila = new Articulo.withId(result["id"], result["cabecera"],
            result["subtitulo"], result["cabeceraLibro"], result["idlibro"], 1);

        lista.add(fila);
      }
    }

    return lista;
  }
}
