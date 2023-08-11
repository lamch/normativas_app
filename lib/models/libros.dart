class Libros {
  int _id;
  String _descripcion;
  String _cabecera;
  int _estado;

  Libros(this._id, this._descripcion, this._cabecera, this._estado);

  Libros.withId(this._id,
      [this._descripcion, this._cabecera]);

  int get id => _id;  

  int get estado => _estado; 

  String get descripcion => _descripcion;

  set descripcion(String newDescription) {
    this._descripcion = newDescription;
  }

  String get cabecera => _cabecera;

  set cabecera(String newDescription) {
    this._cabecera = newDescription;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }

    map['descripcion'] = _descripcion;
    map['cabecera'] = _cabecera;    
    map['estado'] = _estado;
    return map;
  }

  // Extract a Note object from a Map object
  Libros.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._descripcion = map['descripcion'];
    this._cabecera = map['cabecera'];   
    this._estado = map['estado'];   
  }

factory Libros.fromJson(Map<String, dynamic> json) {
    var articulo = new Libros(      
      json['id'] as int,
     json['descripcion'] as String,  
     json['cabecera'] as String,
     json['estado'] as int   
    );
    return articulo;
  }

}
