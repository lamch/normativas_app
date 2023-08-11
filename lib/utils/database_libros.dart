import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:normativas_app/models/libros.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class DatabaseLibros {

	static DatabaseLibros _databaseHelper;    // Singleton DatabaseHelper
	static Database _database;                // Singleton Database

	String noteTable = 'libros';
	String colId = 'id';
	String colDescripcion = 'descripcion';
  String colCabecera = 'cabecera';
	

	DatabaseLibros._createInstance(); // Named constructor to create instance of DatabaseHelper

	factory DatabaseLibros() {

		if (_databaseHelper == null) {
			_databaseHelper = DatabaseLibros._createInstance(); // This is executed only once, singleton object
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
		//String path = directory.path + 'prueba.db';

    var path = join(databasesPath, "prueba.db");

await  deleteDatabase (path);

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
/*
	void _createDb(Database db, int newVersion) async {

		await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colDescripcion TEXT)');
	}
*/
	// Fetch Operation: Get all note objects from database
	Future<List<Map<String, dynamic>>> getNoteMapList() async {
		Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
		var result = await db.query(noteTable, orderBy: '$colId ASC');
		return result;
	}

	// Get number of Note objects in database
	Future<int> getCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
		int result = Sqflite.firstIntValue(x);
		return result;
	}

	// Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
	Future<List<Libros>> getNoteList() async {

		var noteMapList = await getNoteMapList(); // Get 'Map List' from database
		int count = noteMapList.length;         // Count the number of map entries in db table

		List<Libros> noteList = List<Libros>();
		// For loop to create a 'Note List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			noteList.add(Libros.fromMapObject(noteMapList[i]));
		}

		return noteList;
	}
}

