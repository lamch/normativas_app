import 'package:normativas_app/models/libros.dart';

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

import 'dart:typed_data';
import 'package:normativas_app/models/articulo.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String noteTable = 'articulo';
  String librosTable = 'libros';
  String colId = 'id';
  String colDescripcion = 'descripcion';
  String colCabecera = 'cabecera';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
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

   Future<Database> get database2 async {
    if (_database == null) {
      _database = await abrirBaseDatos();
    }
    return _database;
  }

  Future<Database> abrirBaseDatos() async {
  
     return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    var databasesPath = await getDatabasesPath();
    //String path = directory.path + 'prueba.db';

    var path = join(databasesPath, "prueba.db");

    try{
       var db = await openDatabase(path, version: 2);
        return db;
    }
     catch (e) {
  print(e);
}


    await deleteDatabase(path);

    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "prueba.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
// open the database
    var db = await openDatabase(path, version: 2);

    // Open/create the database at a given path
    //var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return db;
  }




  

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colId ASC');
    
    return result;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertNote(Articulo note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateNote(Articulo note) async {
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCountLibros() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $librosTable');
    int result = Sqflite.firstIntValue(x);
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

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getLibrosMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(librosTable, orderBy: '$colId ASC');
    
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
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




}
