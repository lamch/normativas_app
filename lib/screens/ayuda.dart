import 'package:flutter/material.dart';
import 'package:normativas_app/temas/theme.dart';
import 'package:provider/provider.dart';

class Ayuda extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AyudaState();
  }
}

class AyudaState extends State<Ayuda> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          return MaterialApp(
            theme: notifier.darkTheme ? dark : light,
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  title: Text("Ayuda")),
              body: Container(
                margin: const EdgeInsets.only(bottom: 50.0, left: 7, right: 7),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('\nAcerca de la aplicación\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: notifier.darkTheme
                                ? Colors.yellow
                                : Colors.blueAccent,
                          )),
                      Text(
                          '- El árbol con la estructura de la normativa le mostrara los libros, partes, capítulos, secciones y artículos que tiene la normativa y si desea ir específicamente a un artículo especifico es necesario que despliegue el nodo y darle click al artículo para llevarlo automáticamente a la posición deseada.'),
                      Text(
                          '- Existe la posibilidad de realizar la búsqueda de algún artículo las normas para lo cual haga click en el icono de la lupa e ingrese el número de articulo o la palabra que desea filtrar.'),
                      Text(
                          '- Para cancelar la búsqueda presione el icono con una cruz para que cargue nuevamente toda la normativa.'),
                      Text(
                          '- Cuando está en la opción de búsqueda no funcionara el Árbol con la estructura de la normativa por lo que es necesario que cancele la búsqueda.'),
                      Text('\nAdvertencia\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: notifier.darkTheme
                                ? Colors.yellow
                                : Colors.blueAccent,
                          )),
                      Text(
                          'Es muy importante que no elimine los datos de la aplicación desde los Ajuste de aplicacion de Android, debido a que se eliminaran las normativas cargadas, preferencias y lista de favoritos.'),
                      Text('\nSoporte\n',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: notifier.darkTheme
                                ? Colors.yellow
                                : Colors.blueAccent,
                          )),
                      Text(
                          'Si existe algún error en la transcripción de las normas o en el funcionamiento de app por favor envié un correo a desarrolloboliviano@gmail.com'),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
