import '../entities/entities.dart';
import 'utils.dart';
import 'package:mysql1/mysql1.dart';

//GESTIONA EL USUARIO LOGUEADO ACTUALMENTE
abstract class Sesion {
  //VARIABLE LOCAL
  static Usuario? usuario;
  // COMPRUEBA EL USUARIO, VALIDA LA CONTRASEÑA Y GUARDA SESION
  static Future<bool> login(String nick, String password) async {
    //Al método login le mando el nick y el password
    //le digo q se conecte a la bbdd
    MySqlConnection conn = await DataBase.obtenerConexion();

    var respuesta = await conn.query('SELECT * FROM users WHERE nick = ?', [
      nick,
    ]); //Busca en la tabla user un registro con lo que ha puesto el usuario

    bool noExiste =
        respuesta.isEmpty; //Si la respuesta está vacía, no existe, es true

    if (noExiste || respuesta.first[4] != password) {
      // Respuesta.first me refiero al primer registro, es el primer elemento de una lista
      //Como el usuario no existe o la contraseña no coincide, devolvemos false
      await conn.close();
      return false;
    }
    //Como el usuario existe y la contraseña coincide, devuelvo true
    await conn.close();
    usuario = Usuario.fromDatabase(respuesta.first);
    return true;
  }
}
