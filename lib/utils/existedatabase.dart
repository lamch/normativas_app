import 'dart:async';

import 'package:normativas_app/models/articulo.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

class SQLiteDbProvider {
  static SQLiteDbProvider _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String noteTable = 'articulo';
  String librosTable = 'libros';
  String colId = 'id';
  String colDescripcion = 'descripcion';
  String colCabecera = 'cabecera';

  SQLiteDbProvider._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory SQLiteDbProvider() {
    if (_databaseHelper == null) {
      _databaseHelper = SQLiteDbProvider
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
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "prueba.db");

    // Open/create the database at a given path
    var notesDatabase = await openDatabase(path, version: 2);
    return notesDatabase;
  } 

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colId ASC');   
    return result;
  }

   // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
  Future<List<Articulo>> getNoteList() async {
    var noteMapList = await getNoteMapList(); // Get 'Map List' from database
    int count =
        noteMapList.length; // Count the number of map entries in db table

    List<Articulo> noteList = List<Articulo>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Articulo.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}
