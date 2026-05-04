import 'package:mysql1/mysql1.dart';

//AQUI GESTIONO TODA LA CONEXION CON MYSQL
//SEPARA LA LOGICA DE LA BBDD DEL RESTO DE PROGRAMA
abstract class DataBase {
  //Las clases abstractas impiden crear objetos de esa clase (INSTANCIAR -> CREAR OBJETOS)
  //Un método es estático significa que podemos utilizarlos o ejercutarlos sin la necesidad de crear un objeto de esa clase
  //Lo normal es que cuando una clase como esta es abstracta, es que tenga propiedades static
  //Cuál es la idea de las propiedades y métodos static? Que no son parte de los objetos, están como por encima de los objetos,
  //en el sentido de que, si yo creo objeto tipo alumno, guardo ese objeto, y el metodo se ejecuta sobre el propio objeto,
  //los static, da igual que objeto le ejecuta, la ejecución sería la misma
  static final String _host =
      "localhost"; //127.0.0.1, es nuesto servidor, si es otro servidor, es con la IP
  static final int _port =
      3306; // Históricamente, MYSQL ocupa el puerto 3306, es el habitual
  static final String _user = "root";
  static final String _dbName = "miprimeraapiDISNEY";

  //Final y cons para impedir que los valores de la variables cambien

  static Future<void> instalacion() async {
    //El método instalación, lo 1º que ejecuta mi app
    // El void significa que no devuelve nada
    //Cuando ponemos un método async le tenemos que dar el Future, porque nos lo dará en el futuro
    var settings = ConnectionSettings(host: _host, port: _port, user: _user);
    MySqlConnection conn = await MySqlConnection.connect(settings);
    // CREA LA BBDD SI NO EXISTE
    await conn.query(
      "CREATE DATABASE IF NOT EXISTS $_dbName",
    ); //Query se utiliza para lanzar sentencias a la bbdd
    await conn.query("USE $_dbName");
    await crearTablaUsers(conn);
    await crearTablaContenido(conn);
    await crearTablaUsuariosContenido(conn);
    await crearTablaFavoritos(conn);
    await crearTablaCompras(conn);
    await crearTablaAlquileres(conn);
    await conn.close();
  }
  //CONEXION

  static Future<MySqlConnection> obtenerConexion() async {
    var settings = ConnectionSettings(
      //lo siguiente es un constructor con argumentos nombrados
      host: _host,
      port: _port,
      user: _user,
      db: _dbName,
    );
    MySqlConnection conn = await MySqlConnection.connect(settings);
    return conn; //La función crea la conexión y con el return me lo devuelve
  }

  //CREA LA TABLA USUARIO
  static Future<void> crearTablaUsers(MySqlConnection conn) async {
    await conn.query("""CREATE TABLE IF NOT EXISTS users (
    iduser INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(20) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    nick VARCHAR(10) NOT NULL,
    password VARCHAR(10) NOT NULL,
    monedas INT
    )""");
  }

  //CREA LA TABLA CONTENIDO
  static Future<void> crearTablaContenido(MySqlConnection conn) async {
    await conn.query("""CREATE TABLE IF NOT EXISTS contenido (
    idcontenido INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    descripcion TEXT
    )""");
  }

  //CREA LA TABLA USUARIOSDISNEY
  static Future<void> crearTablaUsuariosContenido(MySqlConnection conn) async {
    await conn.query("""CREATE TABLE IF NOT EXISTS usuarioscontenido (
    idu INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    iduser INT,
    idcontenido INT,
    apodo VARCHAR(50)
    )""");
  }

  //CREA LA TABLA FAVORITOS
  static Future<void> crearTablaFavoritos(MySqlConnection conn) async {
    await conn.query("""
      CREATE TABLE IF NOT EXISTS favoritos (
        id INT AUTO_INCREMENT PRIMARY KEY,
        idusuario INT,
        idcontenido INT,
        nombre VARCHAR(50) 
      )
    """);
  }

  //CREA LA TABLA COMPRAS
  static Future<void> crearTablaCompras(MySqlConnection conn) async {
    await conn.query("""
      CREATE TABLE IF NOT EXISTS compras (
        id INT AUTO_INCREMENT PRIMARY KEY,
        idusuario INT,
        idcontenido INT,
        precio INT,
        nombre VARCHAR(50) 
      )
    """);
  }

  static Future<void> crearTablaAlquileres(MySqlConnection conn) async {
    await conn.query("""
    CREATE TABLE IF NOT EXISTS alquileres (
      id INT AUTO_INCREMENT PRIMARY KEY,
      idusuario INT,
      idcontenido INT,
      nombre VARCHAR(50)
    )
  """);
  }

  //GUARDA FAVORITO EN LA BBDD
  static Future<void> guardarFavorito(
    int idUsuario,
    int idContenido,
    String nombre,
  ) async {
    try {
      print("Conectando...");
      var conn = await obtenerConexion();
      print("INSERTANDO...");
      await conn.query("SET autocommit = 1");
      await conn.query(
        "INSERT INTO favoritos (idusuario, idcontenido, nombre) VALUES (?, ?,?)",
        [idUsuario, idContenido, nombre],
      );
      print("✔ Añadido a FAV.");
      await conn.close();
    } catch (error) {
      print("$error");
    }
  }

  //ALQUILA Y GUARDA EN LA BBDD
  static Future<void> guardarAlquiler(
    int idUsuario,
    int idContenido,
    String nombre,
  ) async {
    final conn = await obtenerConexion();
    await conn.query(
      'INSERT INTO alquileres (idUsuario, idContenido, nombre) VALUES (?, ?, ?)',
      [idUsuario, idContenido, nombre],
    );
    await conn.close();
  }

  //  GUARDA COMPRA EN LA BBDD
  static Future<void> guardarCompra(
    int idUsuario,
    int idContenido,
    int precio,
    String nombre,
  ) async {
    try {
      print("➡️ CONECTANDO COMPRA");

      var conn = await obtenerConexion();

      await conn.query("SET autocommit = 1");

      print("➡️ INSERTANDO COMPRA");

      await conn.query(
        "INSERT INTO compras (idusuario, idcontenido, precio, nombre) VALUES (?, ?, ?,?)",
        [idUsuario, idContenido, precio, nombre],
      );

      print("✔ COMPRA GUARDADA");

      await conn.close();
    } catch (e) {
      print("❌ ERROR COMPRA: $e");
    }
  }

  //OJO -> Es estático cuando podemos acceder a él sin necesidad de crear un objeto, se usa para métodos y propiedades
  //que no dependen de esos objetos
  //ASYNC-AWAIT -> Await es una palabra reservada que detiene la ejecución hasta que se completa el método que lleva detrás
  //Cuando en un método tengo que hacer alguna instrucción que se ejecuta FUERA de mi aplicación pierdo la sincronía
  //
}
