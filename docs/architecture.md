# Arquitectura de la aplicación


*Views y components:* 
- Lo máximo que se puede hacer es llamar a un método privado y referenciar a algún provider, controllers.
- No se hace lógica de nada, todos los endpoints se llaman por debajo.
- Solo puede haber llamadas a rutas o de widgets.
- No puede haber una llamadas al dart.io o al data, a la dependencia del repositorio.
- Aquí solo se llama a providers, widgets o rutas.

*Controller:*
- Solo lógica, sumas, restas.
- Está enlazado con peticiones.
- Esto es cuando la app está corriendo. Cuando ya se está en la pantalla creada y quieres hacer algo en esa pantalla creada.
- Es el orquestador, el que realiza las peticiones al state para que cambie o actualice sus estados. O al store para que vuelva a llamar a algún repository o para que actualice algún valor.
- Contiene la lógica de negocio y dentro de esta puede llamar a métodos del state y store para que actualicen su estado.

*Store:*
- Esto se inicia, en cuanto se inicia la app.
- Llamadas a la base de datos (enpoints)
- Son llamados desde la vista para obtener datos que no cambian mucho.

*States:*
- Son para cosas que van a variar en tiempo real, providers, por ejemplo.
- Switchs para true o false, por ejemplo.
- Loadings.
- Son llamados desde la vista.

--------------------
La aplicación debe tener un diseño limpio y moderno, utilizando los colores de la marca. Debes crear los archivos necesarios para que la aplicación funcione correctamente. No debes incluir ningún comentario en el código, ya que el código debe ser autoexplicativo. Además, debes seguir las mejores prácticas de programación y asegurarte de que el código sea fácil de mantener y escalar en el futuro. Recuerda que el código debe ser limpio y eficiente, sin redundancias ni errores. NO DEBES INCLUIR NINGÚN COMENTARIO EN EL CÓDIGO Y NO COMETES EL CÓDIGO.

--------------------

Actúa como un desarrollador senior de Flutter y arquitecto de software. Tu misión principal es analizar el proyecto Flutter proporcionado, identificar cualquier archivo que se desvíe del estándar arquitectónico descrito y refactorizarlo para cumplir estrictamente con dichas reglas, usando el código existente como guía para el estilo y la implementación. La arquitectura es la siguiente: la capa de Presentación dicta que las Vistas y Widgets deben ser componentes "tontos" que solo construyen la UI; su única responsabilidad es suscribirse al store de estado para obtener datos reactivos y llamar a métodos en el Controller para ejecutar acciones, sin contener lógica de negocio. El Controller (<feature>_controller.dart) centraliza toda la lógica de negocio y las interacciones, y dentro de este mismo archivo se define un Loader Provider que inicia la carga de datos de la pantalla a través de un método del Controller. Crucialmente, el Controller orquesta la lógica pero no almacena estado persistente, delegando la gestión de datos a dos componentes distintos: el Store (<feature>_store.dart) que maneja datos no reactivos (como TextEditingController, GlobalKey, catálogos) y es el único que invoca a los repositorios de la capa de data; mientras que el estado reactivo se gestiona a través de un store de Zustand (<feature>_states.dart), que reemplaza el patrón de múltiples notifiers y centraliza los datos que, al cambiar, provocan una reconstrucción de la UI (elementos seleccionados, flags, estados de carga). En la capa de data, los DTOs de respuesta de la API deben tener todos sus campos como opcionales (nullable) para prevenir errores y deben incluir un método toModel() para convertirlos a los modelos puros del domain. Finalmente, aplica estas reglas absolutas: el código debe ser autoexplicativo sin ningún comentario, sin logs (print, debugPrint), sin warnings del analizador de Dart, y sin generar comandos de git. Los únicos providers que son "keepAlive = true" son los repositories. Debes saber que el <Feature>LoaderProvider llama al método de initialize() del <Feature>ControllerProvider y que este llama al método de initialize() del <Feature>StoreProvider, siempre, no hay excepeción, siempre se mantiene ese estándar. El Loader se llama en el cascarón (<Feature>View) una vez cargado se llama al se llama al <Feature>Layout y este ya podría tener la seguridad de que el store y el state están completos. El view es un Caparazón, es donde se mantiene escuchando al Controller y al Store, además es allí donde se cargan los datos con el <Feature>Loader, con este método cargado se da pase al <Feature>Layout, que es este quien escucha a los datos reactivos con el <Feature>State. Por regla general siempre, siempre, siempre, La view llama al controller si quiere actualizar algún dato del <Feature>Store o del <Feature>State. Además debes saber que el <Feature>Layout se debe crear en la subcarpeta widgets junto con los demás widget de la <Feature>.