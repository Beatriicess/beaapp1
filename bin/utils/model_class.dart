import 'package:mysql1/mysql1.dart';
import '../utils/database.dart';

//CLASE BASE PARA REUTILZAR CODIGO EN TODAS LAS ENTIDADES
abstract class ModelClass {
  abstract String
  tableName; //ES ABSTRACT PARA OBLIGAR A LOS HIJOS A QUE LA DEFINAN
  abstract String primaryKey;
  //FROMDATABASE ES ABSTRACT PORQUE NO ESTA DEFINIDO
  fromDatabase(ResultRow row);
  //EL METODO ALL ESTA DEFINIDO Y NO ES ABSTRACT
  Future<List> all() async {
    MySqlConnection? conn;
    List listado = [];
    try {
      conn = await DataBase.obtenerConexion();
      //manda a la bd q selecione todo desde tablaName
      var registros = await conn.query("SELECT * FROM $tableName");
      //recorre la lista para añadir luego
      for (ResultRow registro in registros) {
        listado.add(fromDatabase(registro));
      }
      return listado;
    } catch (error) {
      print(error);
      return listado;
    } finally {
      if (conn != null) {
        //ESTO ES IGUAL QUE PONER CONN?.CLASE();

        conn.close();
      }
      //CERAR LA CONEXION TANTO SI VA BIN COMO SI VA MAL
    }
  } // ESTE SE CREA EN LA CLASE HIJAS Y NO HACE FALTA YA EL ALL

  // ESTO ES PARA OBTENER EL ID POKEMON Y EL ID USUARIO
  Future get(int id) async {
    MySqlConnection? conn;
    try {
      conn = await DataBase.obtenerConexion();
      var registro = await conn.query(
        "SELECT * FROM $tableName WHERE $primaryKey = ?"[id],
      );
      return fromDatabase(registro.first);
    } catch (error) {
      print(error);
      return null;
    } finally {
      conn?.close();
    } // TRY-CATCH-FINALLY SE USA DONDE HAY ASYNC Y PARA BBDD
  }
}
