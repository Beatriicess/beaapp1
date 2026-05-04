import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/utils.dart';
import 'package:mysql1/mysql1.dart';

//ESTA CLASE REPRESENTA LOS PERSONAJES O PELICULAS DISNEY
//INTEGRA DATOS EXTERNOS EN TIEMPO REAL DENTRO DE LA APP
class Contenido extends ModelClass {
  int? idContenido;
  String nombre;
  String descripcion;
  String tipo; // personaje o  pelicula.
  int? precio;
  @override
  String tableName = 'disney';
  @override
  String primaryKey = "idContenido";
  //le paso argumentos posicionales y le digo q idContenido es opcional
  Contenido(this.nombre, this.descripcion, this.tipo,this.precio, [this.idContenido]);
  // Constructor desde base de datos
  Contenido.fromDataBase(ResultRow row)
  //obtiene el valor de la bbdd y le dice si es null que sea -1, un string o 0
    : idContenido = row['idContenido'] ?? -1,
      nombre = row['nombre'] ?? "",
      descripcion = row['descripcion'] ?? "",
      tipo = row['tipo'] ?? "",
      precio = row['precio'] as int? ?? 0;
//Dame una fila de la base de datos (row) y te devuelvo un objeto Contenido construido a partir de ella
  @override
  Contenido fromDatabase(ResultRow row) => Contenido.fromDataBase(row);

  //Declaramos la funcion contenido para obtenerContenido
  static Future<Contenido?> obtenerContenido(String identificador) async {
    //SE CONECTA A UNA API EXTERNA
    //PRIMERO BUSCA POR NOMBRE DE PERSONAJE
    var url = Uri.parse(
      "https://api.disneyapi.dev/character?name=$identificador",
    );
    //response es la respuesta del servidor 
    var response = await http.get(url);
   
    if (response.statusCode == 200) {
      //los datos de la API
      var data = jsonDecode(response.body);
      // La API de Disney devuelve los resultados en data['data']
      var lista = data['data'];

 // SI NO ENCUENTA POR NOMBRE, BUSCA POR PELICULA
    if (lista == null || lista.isEmpty) {
      url = Uri.parse(
        "https://api.disneyapi.dev/character?films=$identificador",
      );
      response = await http.get(url);
      data = jsonDecode(response.body);
      lista = data['data'];
    }
 if (lista == null || lista.isEmpty) {
      print("No se encontró ningún personaje o película con ese nombre");
      return null;
    }

//coge el primer elemento de la lista y guardalo en item
      var item = lista[0];
// le damos con las "" un valor de cadena vacia para q empieze por algo y no sea null
       String descripcion = "";
       //CONSTRUYE LA DESCRIPCION DE LOS BUSCADO

if (item == null) {
  descripcion = "Sin información disponible";
} 
// 2. Usamos ? para acceder de forma segura a las llaves
else if (item['films'] != null && (item['films'] as List).isNotEmpty) {
  descripcion = "Aparece en: ${item['films'].join(', ')}";
} else if (item['tvShows'] != null && (item['tvShows'] as List).isNotEmpty) {
  descripcion = "Serie: ${item['tvShows'].join(', ')}";
} else if (item['videoGames'] != null && (item['videoGames'] as List).isNotEmpty) {
  descripcion = "Videojuegos: ${item['videoGames'].join(', ')}";
} else if (item['allies'] != null && (item['allies'] as List).isNotEmpty) {
  descripcion = "Aliados: ${item['allies'].join(', ')}";
} else {
  descripcion = "Personaje Disney";
}
return Contenido(
  item['name'] ?? "Sin nombre",
  descripcion,
  item['films'] != null && item['films'].isNotEmpty
      ? "Película"
      : "Personaje",
      item['id'] ?? -1, //La API sí devuelve un id

);
  
    }
    return null;
  }
}
