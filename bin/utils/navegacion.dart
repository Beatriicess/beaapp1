import 'dart:async';
import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'dart:math';
import '../entities/entities.dart';
import 'utils.dart';


//EL PROGRAMA FUNCIONA COMO UNA MAQUINA DE ESTADOS QUE CAMBIAN DE FLUJO
//TB HAY SIMULADO UN SISTEMA DE ECONOMIA 

abstract class Navegacion {
  //Una clase abstracta es una clase de la que no podemos crear objetos
  //Por ejemplo, clase VEHÍCULOS, creamos coche, avión, moto, etc
  //En la clase Navegación no podemos concretar nada, es como un concepto, algo más conceptual que físico

  //METODO AUXILIAR
  static bool opcionInvalida(String? opcion, int numero) {
    return (int.tryParse(opcion ?? "") ?? 0) > numero ||
        (int.tryParse(opcion ?? "") ?? 0) < 1;
  }

  static String inicio =
      "principal"; // la declaramos para empezar la maquina de estados

  static String principal() {
    String opcion;
    do {
      print("HOLA SOY BEA Y ESTE ES MI PEQUEÑO PROYECTO. EMPECEMOS");
      //Capturamos lo que el user escriba y nos aseguramos con do while que solo escoja una de las tres
      stdout.writeln("""Elige una opción:
    1. Iniciar sesión
    2. Registrarse
    3. Salir""");
      opcion = stdin.readLineSync() ?? "Error";
      if (opcion != "1" && opcion != "2" && opcion != "3") {
        stdout.writeln("Opción no válida");
      }
    } while (opcionInvalida(opcion, 3));
    if (opcion == "1") {
      return "login";
    } else if (opcion == "2") {
      return "registro";
    } else {
      return "salir";
    }
  }

  //registro
  static Future<String> registro() async {
    String nombre;
    String nick;
    String password;
    Map<String, String> datos = {};
    do {
      stdout.writeln("""Registro: Introduce tu nombre""");
      nombre = stdin.readLineSync() ?? "Error";
      stdout.writeln("Introduce tu usuario");
      nick = stdin.readLineSync() ?? "Error";
      stdout.writeln("Introduce tu contraseña");
      password = stdin.readLineSync() ?? "Error";
      if (nombre.isEmpty || nick.isEmpty || password.isEmpty) {
        //Compruebo que los campos no estén vacíos
        stdout.writeln("Ningún campo puede estar vacío");
      }
      if (password.length < 6) {
        //Compruebo que la contraseña no sea menor de 6 caracteres
        stdout.writeln("La contraseña no puede tener menos de 6 caracteres");
      }
    } while (nombre
            .isEmpty || //De estar algún campo vacío o password menor de 6 caracteres, le repito al user
        nick.isEmpty ||
        password.isEmpty ||
        password.length < 6);
    datos = {
      "nombre": nombre,
      "nick": nick,
      "password": password,
    }; //si está todo OK lo meto en un mapa con los datos introducidos
    bool registrado = await Usuario.registro(
      datos,
    ); //Si registrado es true es que se ha registrado y vuelve al menú principal para poder hacer el login
    if (registrado) {
      print(
        "Te has registrado correctamente, y hemos ingresado 100 monedas en tu cuenta pokemon de relagalo",
      );
      return "principal"; //Cuando el user se registra va a la pantalla principal, para dar la opción de hacer login
    } else {
      //Aquí el menú sigue valiendo registro, por lo tanto el user sigue intentando haciendo el registro
      print("El usuario ya existe, vuelve a intentarlo");
      return "registro";
    }
  }

  static Future<String> login() async {
    String? nick;
    String? password;
    do {
      stdout.writeln("""Logueate:
    Introduce tu usuario""");
      nick = stdin.readLineSync() ?? "Error";
      stdout.writeln("Introduce tu contraseña");
      password = stdin.readLineSync() ?? "Error";
      if (nick.isEmpty || password.isEmpty) {
        stdout.writeln("Ningún campo puede estar vacío");
      }
      if (password.length < 6) {
        stdout.writeln("La contraseña no puede tener menos de 6 caracteres");
      }
    } while (nick.isEmpty || password.isEmpty || password.length < 6);
    bool logueado = await Sesion.login(nick, password);
    if (logueado) {
      print("Has iniciado sesión correctamente, ${Sesion.usuario!.nombre}");
      return "home";
    } else {
      print("Datos incorrectos, vuelve a intentarlo");
      return "login";
    }
  }
//CREAMOS EL MENÚ HOME
  static Future<String> home() async {
    String? opcion;
    do {
      stdout.writeln("""Escoge una de estas opciones:
      1. Buscar contenido 
      2. 🚪 Salir """);
      opcion = stdin.readLineSync() ?? "Error";
    } while (opcionInvalida(opcion, 3));
    if (opcion == "1") {
      return "buscar";
    } else {
      print("👋 Hasta pronto!");
      return "salir";
    }
  }
//CREAMOS EL MENÚ BUSCAR
  static Future<String> buscar() async {
    //VARIABLES DE LISTAS DECLARADAS DENTRO DEL MÉTODO
    List<Contenido> favoritos = [];
    List<Contenido> compras = [];
    List<Contenido> alquileres = [];

    //PEDIMOS AL USUARIO EL NOMBRE O ID QUE QUIERE BUSCAR
    print("""Bienvenido al mundo Disney  🏰🪄🎥
  Escribe el nombre o id del personaje o pelicula  que quieres buscar""");
    String respuesta = stdin.readLineSync() ?? "Eror";

    Contenido? contenido = await Contenido.obtenerContenido(respuesta);
    if (contenido == null) {
      print("Eror algo ha ido mal, vuelve a intentarlo");
      return "buscar";
    } else {
      //IMPRIMIMOS LA INFO DEL POKEMON ENCONTRADO
      print("Has encontrado ${contenido.nombre}!!");
    }

    String? opcion;
    do {
      stdout.writeln("""¿Que quieres hacer con ${contenido.nombre} ?:
      1.🔍 Detalles.
      2. Añadir a Favoritos ⭐
      3. Comprar / Alquilar 💳
      4.Seguir buscando...""");
      opcion = stdin.readLineSync() ?? "Error";

      switch (opcion) {
        case "1":
          print("""
Nombre: ${contenido.nombre}
Descripción: ${contenido.descripcion}
Tipo: ${contenido.tipo}
""");
          break;

        case "2":
          print(
            "Genial, en un futuro se guardará a favoritos⭐",
          );
          favoritos.add(contenido); // memoria
          await DataBase.guardarFavorito(Sesion.usuario!.idusuario, contenido.idContenido ?? -1, contenido.nombre); // BD
          break;
        case "3":
  int precio = Random().nextInt(101) + 50;

  stdout.writeln("""
Has seleccionado: ${contenido.nombre}
Precio: $precio monedas

¿Qué quieres hacer?
1. Comprar
2. Alquilar
3. Cancelar
""");

  String eleccion = stdin.readLineSync() ?? "";

  switch (eleccion) {
    case "1":
      print("¿Confirmas la compra de ${contenido.nombre} por $precio? (si/no)");
      String confirmacion = stdin.readLineSync() ?? "";

      if (confirmacion.trim() == "si") {
        compras.add(contenido);
        await DataBase.guardarCompra(
          Sesion.usuario!.idusuario,
          contenido.idContenido ?? -1,
          precio, contenido.nombre
        );
        print("Has comprado ${contenido.nombre} 💳");
      } else {
        print("❌Compra cancelada");
      }
      break;

    case "2":
      print("¿Confirmas alquiler de ${contenido.nombre} por 20 monedas? (si/no)");
      String confirmacionAlquiler = stdin.readLineSync() ?? "";

      if (confirmacionAlquiler.trim() == "si") {
        alquileres.add(contenido);
        await DataBase.guardarAlquiler(
          Sesion.usuario!.idusuario,
          contenido.idContenido ?? -1,
          contenido.nombre,
        );
        print("Has alquilado ${contenido.nombre} 🎬");
      } else {
        favoritos.add(contenido);
        print("Guardado en favoritos ⭐");
      }
      break;

    case "3":
      print("❌Operación cancelada");
      break;
  }
  break;

        case "4":
          return "home";
      }
    } while (opcion != "4");

    return "home";
  } // fin buscar
}
