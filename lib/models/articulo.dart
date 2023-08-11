class Articulo {
  int _id;
  int _idlibro;
  int _favorito;
  String _descripcion;
  String _subtitulo;
  String _cabecera;
 
  Articulo([this._id, this._cabecera, this._subtitulo, this._descripcion,  this._idlibro, this._favorito]);

  Articulo.withId(this._id,
      [this._cabecera, this._subtitulo, this._descripcion, this._idlibro, this._favorito]);
  
  
  int get id => _id;

  int get id_libro => _idlibro;
  
  int get favorito => _favorito;
 

  set id_libro(int newDescription) {
    this._idlibro = newDescription;
  }

  set favorito(int newDescription) {
    this._favorito = newDescription;
  }

  String get descripcion => _descripcion;

  set descripcion(String newDescription) {
    this._descripcion = newDescription;
  }

  String get cabecera => _cabecera;

  set cabecera(String newDescription) {
    this._cabecera = newDescription;
  }

  String get subtitulo => _subtitulo;

  set subtitulo(String newDescription) {
    this._subtitulo = newDescription;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['cabecera'] = _cabecera;
    map['subtitulo'] = _subtitulo;
    map['descripcion'] = _descripcion;
    map['idlibro'] = _idlibro;
    map['favorito'] = _favorito;
    return map;
  }

  // Extract a Note object from a Map object
  Articulo.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._cabecera = map['cabecera'];
    this._subtitulo = map['subtitulo'];
    this._descripcion = map['descripcion'];
    this._idlibro = map['idlibro'];
    this._favorito = map['favorito'];
  }

factory Articulo.fromJson(Map<String, dynamic> json) {
    var articulo = new Articulo(
      
     json['id'] as int,
     json['cabecera'] as String, 
     json['subtitulo'] as String,  
     json['descripcion'] as String,  
     json['idlibro'] as int,    
     json['favorito'] as int,    
    );
    return articulo;
  }

}
