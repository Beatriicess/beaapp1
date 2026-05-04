import 'utils/utils.dart';

void main() async {
  await DataBase.instalacion(); // instalar la bbdd
  String menu = Navegacion.inicio; //Aquí declaramos nuestra primera pantalla
  while (true) {
    //la maquina de estados es un bucle infinito
    //Aquí activamos la máquina de estados de la pantalla, con un bucle, dentro un switch donde evaluamos la variable menú
    //es un bucle infinito, porque nunca deja de cumplirse
    switch (menu) {
      //En cada case tenemos una pantalla (menú) cada uno de esos menús, nos dice cuál es la siguiente pantalla
      case "principal":
        menu = Navegacion.principal();
        break;

      //REGISTRO
      case "registro":
        menu = await Navegacion.registro();
        break;
      //LOGIN
      case "login":
        menu = await Navegacion.login();
        break;
      //HOME
      case "home":
        menu = await Navegacion.home();
      //BUSCAR
      case "buscar":
        menu = await Navegacion.buscar();
    }
    //SALIR
    if (menu == "salir") {
      print("Has elegido salir");
      break;
    }
  }
}
