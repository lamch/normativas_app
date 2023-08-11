class TreeListHijo {
  int _id;
  int _idlibro;  
  String _descripcion;
  String _cabecera;
  
  TreeListHijo(this._id, this._cabecera, this._descripcion, this._idlibro);

  
  
  int get id => _id;

  int get id_libro => _idlibro; 

  set id_libro(int newDescription) {
    this._idlibro = newDescription;
  } 

set id(int newDescription) {
    this._id = newDescription;
  } 
  String get descripcion => _descripcion;

  set descripcion(String newDescription) {
    this._descripcion = newDescription;
  }

  String get cabecera => _cabecera;

  set cabecera(String newDescription) {
    this._cabecera = newDescription;
  }


  factory TreeListHijo.fromJson(Map<String, dynamic> json) {

    var articulo = new TreeListHijo(   
     json['id'] as int,
     json['cabecera'] as String,  
     json['descripcion'] as String, 
     json['idlibro'] as int
    
    );
    return articulo;
  }



}
