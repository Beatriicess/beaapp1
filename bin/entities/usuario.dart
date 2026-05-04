import 'package:mysql1/mysql1.dart';
import '../utils/utils.dart'; //los dos puntos son para salir de la carpeta entities donde se encuentra usuario.dart
import 'contenido.dart';
//REPRESENTA AL USER DE LA APP
class Usuario extends ModelClass{ //El main recoge los datos y la clase los comprueba para decidir sobre ellos
  int idusuario =0;
  String? nombre;
  String? nick;
  String? password;
  int monedas = 0;
  @override
  String tableName = 'users';
  @override
  String primaryKey = "idusuario";

  Usuario(this.idusuario, this.nombre, this.nick, this.password, this.monedas); //Este es el constructor con argumentos posicionales
//CONTRUCTOR NOMBRADO
  Usuario.fromDatabase(ResultRow row){
     
    idusuario = row['idusuario'] ?? -1;
    nombre = row['nombre']?? "";
    nick = row['nick'] ?? "";
    password = row['password']?? "";
    monedas = row['monedas']??"";
   
  }
  @override
  Usuario fromDatabase (ResultRow row) => Usuario.fromDatabase(row);
  static Future<bool> registro(Map<String,String>datos) async { //Cuando no necesita argumentos es por que no necesita datos del exterior, en este caso sí que son necesarios,
   // porque el usuario tiene que meter datos desde fuera.
  
    MySqlConnection conn = await DataBase.obtenerConexion();
    var respuesta = await conn.query('SELECT * FROM users WHERE nick = ?', [datos['nick']]);
    bool existe = respuesta.isNotEmpty;
    if(existe){ 
      //Como el usuario ya existe, no lo registramos
      await conn.close();
      return false; //Devuelve false porque cuando yo llame a este método me interesa saber si se ha hecho el registro o no
    }
    //Como el usuario no existe, se registra
    await conn.query('INSERT INTO users (nombre, nick, password, monedas) VALUES(?, ?, ?,?)', 
    [datos['nombre'],datos['nick'],datos['password'],100]
    );
    await conn.close(); //Creo el usuario de la sesión y devuelvo true
    return true; //En este caso devuelve true porque sí ha hecho el registro
    
  }
 // este se crea en la clase hijas y no hace falta ya el all

   List<Contenido>equipo = [];

  void agregarContenido(Contenido contenido){
    equipo.add(contenido);
  }

  void restarMonedas(int cantidad){
    monedas -= cantidad;
  }
}
//Las propiedades y los métodos pueden ser estáticos
//Significa que no corresponde a los objetos, yo puedo llamar a una propiedad o método estático sin crear el objeto de esa clase
//podemos acceder a ellos sin crear un objeto de esa clase