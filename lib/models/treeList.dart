

class TreeList {
  int _id;
  int _idlibro;  
  String _descripcion;
  String _cabecera;
  List<TreeList> _treeList;
 
  TreeList(this._id, this._cabecera, this._descripcion, this._idlibro, [this._treeList = const<TreeList>[]]);

  
  
  int get id => _id;

  int get id_libro => _idlibro; 
 
 List<TreeList> get treeList => _treeList;

 set treeList(List<TreeList> newDescription) {
    this._treeList = newDescription;
  }

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


  factory TreeList.fromJson(Map<String, dynamic> json) {
var streetsFromJson = json['TreeList'];

if(streetsFromJson == null)
{

    var articulo = new TreeList(   
     json['id'] as int,
     json['cabecera'] as String,  
     json['descripcion'] as String, 
     json['idlibro'] as int,  
     null
     //json['treeList'] as TreeList[]     
    );
    return articulo;
  }
  
else
{
List<dynamic> streetsList = new List<dynamic>.from(streetsFromJson);
List<TreeList> intList = streetsList.map((s) => TreeList.fromJson(s)).toList();
    var articulo = new TreeList(   
     json['id'] as int,
     json['cabecera'] as String,  
     json['descripcion'] as String, 
     json['idlibro'] as int,  
     intList
     //json['treeList'] as TreeList[]     
    );
    return articulo;
  }
}


}
