# Plan de estudio: estado, reactividad y temas en DaisyUI

## Objetivo

Comprender los conceptos utilizados en el proyecto y poder explicar exactamente qué ocurre desde que se pulsa un botón para cambiar el tema hasta que Flutter actualiza los widgets que lo utilizan.

El centro del estudio es `Listenable`, `ValueListenable`, señales, controladores, scopes, dependencias y ciclo de vida. Los conceptos de Dart que necesitamos se introducen antes de utilizarlos. La organización de paquetes aparece al final como complemento.

Este documento es el temario para estudiar poco a poco. Cada unidad puede ocupar varias conversaciones; no hay que aprender todo su contenido de una vez.

## Cómo trabajaremos cada unidad

1. Explicar qué problema resuelve el concepto, con palabras sencillas.
2. Dar una definición precisa y explicar los términos nuevos.
3. Utilizar una analogía cuando ayude, indicando dónde deja de ser exacta.
4. Mostrar un ejemplo pequeño y ejecutarlo mentalmente, paso a paso.
5. Relacionarlo con el código real de DaisyUI.
6. Predecir el resultado de una pequeña modificación antes de ejecutarla.
7. Resolver el ejercicio y comentar los errores de razonamiento.
8. Marcar la unidad como dominada cuando puedas explicar y aplicar la idea sin copiar la solución.

No daremos por explicado un mecanismo diciendo solamente que ocurre «automáticamente»: identificaremos quién conserva el dato, quién registra la dependencia, quién avisa y quién solicita reconstruir la interfaz.

Las guías siguen el formato de las unidades 07–09: presentan una idea cada vez con ejemplos pequeños, salida o resultado esperado y explicación paso a paso. Cada apartado incluye una práctica breve y su respuesta explicada en un desplegable próximo; el ejercicio final también tiene una solución accesible. Los ejemplos completos indican cómo ejecutarlos, los fragmentos se identifican como tales y las pruebas de widget explican qué demuestran. Ajustaremos la profundidad al tema sin adelantar mecanismos de unidades posteriores como si ya se conocieran.

## Bloque 1. Las bases para comprender la observación

### 1. Estado, valor actual y cambio

- **Conceptos:** estado de una aplicación, valor actual, lectura puntual, cambio de valor y fuente de verdad.
- **Debes comprender:** consultar un dato una vez y enterarte de sus cambios futuros son necesidades diferentes. Cambiar un dato y actualizar una pantalla son pasos diferentes del proceso.
- **Práctica:** guardar un nombre de tema en una variable, leerlo, modificarlo y predecir qué contiene cada variable después.
- [X] **Dominado cuando:** puedes señalar dónde vive el dato original y qué lecturas son solamente valores obtenidos en un momento concreto.

**Guía y materiales:** [01. Estado, valor actual y cambio](temarios/01-estado-valor-actual-y-cambio.md).

### 2. Funciones como valores: callbacks y listeners

- **Conceptos:** función, referencia a una función, ejecución, callback, listener, función anónima, closure, sintaxis `=>`, `void`, `VoidCallback` y `void Function()`.
- **Debes comprender:** la diferencia entre entregar `avisar` y ejecutar `avisar()`. Qué conserva una closure del contexto donde fue creada.
- **Práctica:** entregar una función a otra, ejecutarla más tarde y observar qué ocurre cuando cambia una variable capturada. Registrar y retirar la misma función.
- [X] **Dominado cuando:** puedes explicar quién ejecuta el callback y por qué crear otra función anónima no equivale necesariamente a retirar la que registraste.

**Guía y materiales:** [02. Funciones como valores: callbacks y listeners](temarios/02-funciones-como-valores-callbacks-y-listeners.md).

### 3. Objetos, referencias, tipos y contratos

- **Conceptos:** clase, instancia, referencia, campo, método, tipo declarado, objeto real, genéricos `<T>`, interfaz, `implements`, `extends` y `@override`.
- **Debes comprender:** qué promete un contrato y qué aporta una implementación. Qué significa sustituir `T` por `DaisyThemeModel`.
- **Práctica:** definir un contrato mínimo de lectura de un número e implementarlo con dos clases diferentes.
- [X] **Dominado cuando:** puedes distinguir las operaciones que permite el tipo de una variable de las capacidades del objeto que contiene.

**Guía y materiales:** [03. Objetos, referencias, tipos y contratos](temarios/03-objetos-referencias-tipos-y-contratos.md).

## Bloque 2. El sistema de notificaciones de Flutter

### 4. `Listenable`: recibir avisos

- **Conceptos:** objeto observable, suscripción, `addListener`, `removeListener` y notificación.
- **Debes comprender:** `Listenable` permite registrar funciones para recibir avisos; el contrato no especifica un valor actual ni la política que provoca esos avisos. [Referencia oficial](https://api.flutter.dev/flutter/foundation/Listenable-class.html).
- **Práctica:** seguir el recorrido de dos listeners, retirar uno y predecir cuáles reciben el siguiente aviso.
- [X] **Dominado cuando:** puedes describir el registro y la retirada de listeners sin atribuirles por sí solos una reconstrucción de pantalla.

**Guía y materiales:** [04. Listenable: recibir avisos](temarios/04-listenable-recibir-avisos.md).

### 5. `ChangeNotifier`: producir avisos

- **Conceptos:** implementación de `Listenable`, `notifyListeners()` y notificación explícita.
- **Debes comprender:** la diferencia entre permitir que alguien escuche y disponer del mecanismo que llama a los listeners. [Referencia oficial](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html).
- **Práctica:** construir un contador pequeño que notifique después de incrementarse; observar qué ocurre si se modifica el contador sin notificar.
- [X] **Dominado cuando:** puedes explicar quién decide emitir el aviso y dónde se toma esa decisión.

El controlador actual no usa `ChangeNotifier`: guarda el tema en una `FlutterSignal`, que aporta sus propios avisos.

**Guía y materiales:** [05. ChangeNotifier: producir avisos](temarios/05-change-notifier-producir-avisos.md).

### 6. `ValueListenable<T>`: avisos y valor actual

- **Conceptos:** extensión del contrato de escucha, getter `value` y valor tipado.
- **Debes comprender:** un `ValueListenable` añade la posibilidad de consultar el valor actual. El listener sigue siendo una función sin argumentos: puede leer `.value` cuando recibe el aviso. [Referencia oficial](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html).
- **Práctica:** observar un valor y, dentro del callback, imprimir su valor actual.
- [X] **Dominado cuando:** puedes distinguir «me avisaron de un cambio» de «consulté el valor que tiene ahora».

**Guía y materiales:** [06. ValueListenable: avisos y valor actual](temarios/06-value-listenable-avisos-y-valor-actual.md).

### 7. `ValueNotifier<T>`: un valor mutable que notifica

- **Conceptos:** almacenamiento de un valor, setter `value`, comparación mediante `==` y notificaciones asociadas a asignaciones.
- **Debes comprender:** la diferencia entre `ValueListenable`, como contrato de lectura y escucha, y una implementación que permite cambiar el valor.
- **Práctica:** comparar asignar un número nuevo, asignar el mismo número, modificar una lista por dentro y sustituirla por otra lista.
- [X] **Dominado cuando:** puedes predecir cuándo se produce una notificación en esos ejemplos y justificar tu respuesta.

**Guía y materiales:** [07. ValueNotifier: un valor mutable que notifica](temarios/07-value-notifier-un-valor-mutable-que-notifica.md).

### 8. Identidad, igualdad e inmutabilidad

- **Conceptos:** `identical`, `==`, igualdad por contenido, coherencia con `hashCode`, referencia compartida, `final`, `const` y objeto inmutable.
- **Debes comprender:** que una referencia sea `final` no hace inmutable cualquier objeto al que apunte. La igualdad influye en si un cambio merece una notificación.
- **Práctica:** comparar el mismo objeto, dos objetos con los mismos datos y una copia con un campo distinto.
- [X] **Dominado cuando:** puedes separar «es el mismo objeto», «tiene los mismos datos» y «no se puede modificar».

**Guía y materiales:** [08. Identidad, igualdad e inmutabilidad](temarios/08-identidad-igualdad-e-inmutabilidad.md).

## Bloque 3. Signals: almacenar y relacionar estado

### 9. Señales: `signal<T>` y `FlutterSignal<T>`

- **Conceptos:** celda de estado observable, función de creación, lectura de `.value`, escritura de `.value` e integración con Flutter.
- **Debes comprender:** qué objeto crean `signal<DaisyThemeModel>(initialTheme)` y `FlutterSignal<DaisyThemeModel>(initialTheme)`, y cómo se relaciona con los contratos que Flutter puede escuchar.
- **Práctica:** crear una señal con el tema claro, registrar un listener, cambiar al tema oscuro y comprobar el orden de ejecución.
- [X] **Dominado cuando:** puedes explicar cómo una señal de ejemplo almacena el valor y avisa a sus observadores.

El controlador actual guarda el tema en una `FlutterSignal` y lo expone mediante el adaptador `_ThemeListenable`.

**Guía y materiales:** [09. Señales: `signal<T>` y `FlutterSignal<T>`](temarios/09-senales-signal-y-flutter-signal.md).

### 10. Dependencias reactivas y contextos de observación

- **Conceptos:** dependencia, lectura rastreada, contexto reactivo, lectura puntual y `SignalBuilder`.
- **Debes comprender:** cómo un consumidor reactivo descubre qué señales utiliza. Una lectura ordinaria de un valor no registra por sí sola una dependencia de reconstrucción en Flutter.
- **Práctica:** comparar una lectura en un widget sin observación con una lectura dentro de un consumidor reactivo. Mover una lectura fuera de su callback y analizar el resultado. Observar el tema real por el scope y con `SignalBuilder`.
- [ ] **Dominado cuando:** puedes identificar quién registra la dependencia en cada alternativa.

**Guía y materiales:** [10. Dependencias reactivas y contextos de observación](temarios/10-dependencias-reactivas-y-contextos-de-observacion.md).

### 11. `computed`: estado derivado

- **Conceptos:** valor derivado, dependencias de cálculo, caché, evaluación bajo demanda y recomputación.
- **Debes comprender:** cuándo tiene sentido calcular un dato a partir de otros y por qué `computed(() => otraSenal.value)` puede añadir una capa innecesaria si solo se necesita una vista de lectura.
- **Práctica:** derivar un texto a partir del tema y comprobar cuándo se evalúa el cálculo al leer y observar el resultado.
- [ ] **Dominado cuando:** puedes justificar si necesitas un dato almacenado, un dato calculado o una vista de lectura.

El controlador actual no necesita un `computed`, pero uno que lea `controller.theme.value` se actualiza porque esa vista lee una señal. Leer un `ValueNotifier` corriente desde un cálculo de Signals no registra una dependencia reactiva.

**Guía y materiales:** [11. `computed`: estado derivado](temarios/11-computed-estado-derivado.md).

### 12. Efectos y suscripciones

- **Conceptos:** efecto secundario, `effect`, suscripción y limpieza de una observación.
- **Debes comprender:** la diferencia entre calcular un valor y ejecutar una acción cuando cambia una dependencia. Quién es responsable de detener esa observación.
- **Práctica:** registrar los cambios de una señal y detener el registro; comprobar que los cambios posteriores ya no producen ese efecto.
- [ ] **Dominado cuando:** puedes separar cálculo, efecto y reconstrucción de interfaz.

Es una profundización del ecosistema Signals; nuestro flujo actual de temas no necesita un `effect` propio.

**Guía y materiales:** [12. Efectos y suscripciones](temarios/12-efectos-y-suscripciones.md).

### 13. Propiedad de los recursos y `dispose`

- **Conceptos:** propietario, recurso prestado, registro de listeners, retirada de listeners y liberación.
- **Debes comprender:** por qué crear, escuchar, dejar de escuchar y liberar un objeto son operaciones distintas. El propietario decide cuándo termina su vida útil.
- **Práctica:** crear un controlador y un consumidor; retirar el consumidor, reutilizar el controlador y liberarlo cuando termina su uso.
- [ ] **Dominado cuando:** puedes identificar qué objeto debes liberar y cuál solamente debes dejar de escuchar.

**Guía y materiales:** [13. Propiedad de los recursos y `dispose`](temarios/13-propiedad-de-los-recursos-y-dispose.md).

## Bloque 4. Controladores, encapsulación y servicio global

### 14. El concepto de controller

- **Conceptos:** responsabilidad del controlador, operaciones de cambio, estado administrado y separación de datos e interfaz.
- **Debes comprender:** que `controller` describe una responsabilidad de diseño; escribir esa palabra en el nombre no añade comportamiento por sí mismo. `DaisyThemeController` es una clase propia del proyecto.
- **Práctica:** describir qué corresponde a `DaisyThemeModel`, qué corresponde al controlador y qué corresponde al widget.
- [ ] **Dominado cuando:** puedes explicar por qué dos controladores pueden administrar temas diferentes.

**Guía y materiales:** [14. El concepto de controller](temarios/14-el-concepto-de-controller.md).

### 15. Construcción del controlador y sintaxis de Dart

- **Conceptos:** constructor, parámetro nombrado, `required`, valor predeterminado, lista de inicialización `:`, parámetros de inicialización `this.campo`, reenvío con `super`, campos privados `_`, `final class` y campos `final`.
- **Debes comprender:** cómo se crea `_palette` utilizando `initialTheme`. La privacidad de los nombres que empiezan por `_` pertenece a la biblioteca de Dart.
- **Práctica:** recorrer la creación de un controlador sin argumentos y otro con un tema inicial explícito; distinguir objetos y referencias.
- [ ] **Dominado cuando:** puedes explicar cada parte del constructor y cuándo existe cada objeto.

**Guía y materiales:** [15. Construcción del controlador y sintaxis de Dart](temarios/15-construccion-del-controlador-y-sintaxis-de-dart.md).

### 16. Vistas de lectura, getters y delegación

- **Conceptos:** encapsulación, getter `get`, `late final`, inicialización diferida, adaptador, delegación y composición.
- **Debes comprender:** cómo `theme` devuelve un adaptador `_ThemeListenable` que delega en la señal privada. Limitar el tipo de una referencia deja debajo el mismo objeto, que un cast puede recuperar; un adaptador es otro objeto y ese cast falla.
- **Práctica:** dibujar el controlador, su señal y el adaptador; comparar esa estructura con una vista hipotética que devuelva la señal con el tipo `ValueListenable`.
- [ ] **Dominado cuando:** puedes distinguir una interfaz de lectura de un objeto que realmente oculta la fuente mutable.

**Guía y materiales:** [16. Vistas de lectura, getters y delegación](temarios/16-vistas-de-lectura-getters-y-delegacion.md).

### 17. Instancias, `static` y servicio global

- **Conceptos:** estado de una instancia, miembro estático, `abstract final class`, inicialización de campos estáticos y fuente global de estado.
- **Debes comprender:** cómo `DaisyThemeService` conserva un controlador predeterminado y delega en él. Qué comparten dos consumidores del servicio y qué conservan por separado dos controladores propios.
- **Práctica:** utilizar el servicio global y dos controladores locales; predecir los tres valores después de cambiar solamente uno.
- [ ] **Dominado cuando:** puedes justificar cuándo compartir estado y cuándo crear una instancia independiente.

**Guía y materiales:** [17. Instancias, `static` y servicio global](temarios/17-instancias-static-y-servicio-global.md).

## Bloque 5. Cómo se conecta el estado con Flutter

### 18. Widgets, elementos, estado y reconstrucción

- **Conceptos:** interfaz declarativa, `Widget`, noción de `Element`, `State`, `StatelessWidget`, `StatefulWidget`, `build`, `setState` y reconstrucción.
- **Debes comprender:** cómo una descripción de interfaz se vuelve a producir utilizando datos actuales. Reconstruir widgets y volver a pintar son partes diferentes del trabajo de Flutter.
- **Práctica:** registrar llamadas a `build` y comparar cambios de datos con solicitudes de reconstrucción. Observar que un `StatelessWidget` también puede reconstruirse. Conectar un notifier a `ValueListenableBuilder` y contrastarlo con una actualización mediante `setState`.
- [ ] **Dominado cuando:** puedes explicar qué conserva `State` y qué papel tiene `build`.

**Guía y materiales:** [18. Widgets, elementos, estado y reconstrucción](temarios/18-widgets-elementos-estado-y-reconstruccion.md).

### 19. Ciclo de vida y lugar correcto para crear recursos

- **Conceptos:** `initState`, `didChangeDependencies`, `didUpdateWidget`, `dispose`, montaje y desmontaje.
- **Debes comprender:** por qué un controlador debe conservarse entre reconstrucciones, cuándo actualizar dependencias y cuándo liberar lo que posee un widget.
- **Práctica:** seguir el ciclo de vida de una vista previa con su propio controlador, reproducida en la guía a partir de la versión anterior del ejemplo, y observar qué problema introduciría crear su controlador dentro de `build`.
- [ ] **Dominado cuando:** puedes colocar creación, actualización y limpieza en el lugar adecuado y explicar el motivo.

**Guía y materiales:** [19. Ciclo de vida y lugar correcto para crear recursos](temarios/19-ciclo-de-vida-y-lugar-correcto-para-crear-recursos.md).

### 20. `BuildContext` y el árbol de widgets

- **Conceptos:** ubicación en el árbol, ancestro, descendiente, contexto de construcción y `Builder`.
- **Debes comprender:** por qué un contexto puede encontrar datos de sus ancestros y por qué el contexto que crea un scope todavía puede estar por encima de él.
- **Práctica:** colocar una lectura de tema encima y debajo de un scope, identificar qué ancestros tiene cada contexto y corregir una lectura mal ubicada.
- [ ] **Dominado cuando:** puedes señalar qué scope puede encontrar cada contexto sin ejecutar el programa.

**Guía y materiales:** [20. `BuildContext` y el árbol de widgets](temarios/20-build-context-y-el-arbol-de-widgets.md).

### 21. `InheritedWidget` y registro de dependencias

- **Conceptos:** datos compartidos por un subárbol, consulta de un ancestro, dependencia y `dependOnInheritedWidgetOfExactType`.
- **Debes comprender:** cómo una consulta puede registrar que un consumidor necesita actualizarse cuando cambia una dependencia heredada.
- **Práctica:** identificar consumidores que dependen de un valor heredado y otros que no lo leen. Comparar consultar un valor con consultarlo registrando una dependencia.
- [ ] **Dominado cuando:** puedes explicar qué relación se establece entre el consumidor y el proveedor.

**Guía y materiales:** [21. `InheritedWidget` y registro de dependencias](temarios/21-inherited-widget-y-registro-de-dependencias.md).

### 22. `InheritedNotifier`: unir avisos y dependencias

- **Conceptos:** notifier observado, dependientes heredados, cambio de notifier y agrupación de notificaciones entre frames.
- **Debes comprender:** cómo esta pieza conecta un `Listenable` con los widgets que declararon una dependencia. Varios avisos entre frames pueden agruparse en una reconstrucción del dependiente. [Referencia oficial](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html).
- **Práctica:** hacer varios cambios antes de un `pump`, observar las reconstrucciones y reemplazar el notifier para comprobar qué fuente se escucha después.
- [ ] **Dominado cuando:** puedes seguir el aviso hasta la reconstrucción sin afirmar que el notifier reconstruye directamente toda la aplicación.

**Guía y materiales:** [22. `InheritedNotifier`: unir avisos y dependencias](temarios/22-inherited-notifier-unir-avisos-y-dependencias.md).

### 23. `DaisyThemeScope.of`, nullabilidad y errores

- **Conceptos:** patrón `of(context)`, scope más cercano, búsqueda por tipo, parámetro opcional, `?`, `?.`, `??`, `!`, `null` y `FlutterError`.
- **Debes comprender:** cómo el constructor selecciona el controlador explícito o el servicio global, y cómo `of` obtiene el tema desde el ancestro correspondiente.
- **Práctica:** ejecutar mentalmente una consulta con scope, otra sin scope y otra con scopes anidados; justificar el `!` del notifier a partir del constructor actual.
- [ ] **Dominado cuando:** puedes explicar cada rama del flujo y por qué registrar dependencias se hace desde lugares adecuados del ciclo de vida.

**Guía y materiales:** [23. `DaisyThemeScope.of`, nullabilidad y errores](temarios/23-daisy-theme-scope-of-nullabilidad-y-errores.md).

### 24. Extensiones y `context.daisyTheme`

- **Conceptos:** `extension`, getter de extensión y acceso abreviado a una operación existente.
- **Debes comprender:** que `context.daisyTheme` ejecuta la consulta de `DaisyThemeScope.of(context)`. No guarda un segundo estado de tema dentro del contexto.
- **Práctica:** sustituir el getter por la llamada explícita, seguir la misma dependencia y comprobar que el comportamiento se conserva.
- [ ] **Dominado cuando:** puedes distinguir comodidad de escritura de almacenamiento o reactividad adicional.

**Guía y materiales:** [24. Extensiones y `context.daisyTheme`](temarios/24-extensiones-y-context-daisy-theme.md).

### 25. Scopes anidados e independencia

- **Conceptos:** alcance de un valor, controlador compartido, controladores independientes, dependencia más cercana y aislamiento de reconstrucciones.
- **Debes comprender:** qué sucede cuando aplicación y vista previa utilizan controladores diferentes. Qué cambiaría si ambos scopes recibieran la misma instancia.
- **Práctica:** cambiar por separado el tema global y el de la vista previa. Reemplazar un controlador y desmontar un scope sin liberar el controlador prestado.
- [ ] **Dominado cuando:** puedes predecir qué consumidores se actualizan en cada escenario y quién conserva la responsabilidad de liberar los controladores.

**Guía y materiales:** [25. Scopes anidados e independencia](temarios/25-scopes-anidados-e-independencia.md).

## Bloque 6. Los datos que se observan

### 26. Temas, tokens semánticos y colores

- **Conceptos:** token de diseño, rol semántico, superficie, contenido, paleta, `DaisyThemeColorPair`, radios, tamaños, grosor de borde y unidades.
- **Debes comprender:** por qué agrupamos colores por función y por qué existen pares de fondo y contenido. Qué representa cada dato de un tema.
- **Práctica:** localizar los tokens que utilizan el texto y el contenedor de la vista previa, reproducida en el [apartado 8 de la unidad 25](temarios/25-scopes-anidados-e-independencia.md#8-el-ejemplo-anterior-completo), y el radio que usa `_ButtonContent` en el ejemplo actual, y calcular `md` a partir de `DaisyThemeSizeConfig.base`. Convertir un `RayOklch` a `Color` con `.toColor()`.
- [ ] **Dominado cuando:** puedes elegir el token apropiado y distinguir los datos de DaisyUI de su aplicación explícita a widgets o a `ThemeData`.

Profundización de color: componentes L, C y H de OKLCH, opacidad, conversión a RGB, límites de representación y contraste. Se estudian por separado, después de dominar el flujo reactivo.

### 27. Modelos inmutables y Freezed

- **Conceptos:** modelo, `@freezed`, anotación, `abstract class`, constructor `factory`, constructor `const`, constructor privado, mixin `with`, `copyWith` e igualdad generada.
- **Debes comprender:** qué escribimos nosotros y qué produce Freezed. Cómo un nuevo modelo sustituye al anterior sin modificarlo y cómo su igualdad participa en las notificaciones.
- **Práctica:** crear una copia de un tema con otro borde, comprobar que el original se conserva y comparar una copia equivalente con una copia modificada.
- [ ] **Dominado cuando:** puedes explicar la relación entre inmutabilidad, igualdad y cambio de estado.

### 28. Mapas, JSON y serialización anidada

- **Conceptos:** `Map<String, Object?>`, `dynamic`, texto JSON, serializar, deserializar, `toJson`, `fromJson`, `jsonEncode`, `jsonDecode` y objetos anidados.
- **Debes comprender:** la diferencia entre un mapa Dart y texto JSON. Por qué todos los niveles deben convertirse cuando se necesita un mapa formado por valores JSON.
- **Práctica:** recorrer tema, colores y pares de color hasta los números. Probar el ciclo directo `fromJson(theme.toJson())` y el ciclo a través de texto JSON.
- [ ] **Dominado cuando:** puedes localizar en qué nivel se quedó un objeto sin convertir y explicar cómo se conservan valores opcionales y números.

### 29. Generación de código y configuración

- **Conceptos:** `build_runner`, Freezed, `json_serializable`, archivos `part`, archivos generados, `../../build.yaml` y `explicit_to_json`.
- **Debes comprender:** cómo una definición de modelo y su configuración producen los serializadores. Por qué los archivos generados se regeneran en lugar de corregirse manualmente.
- **Práctica:** relacionar una propiedad del modelo con su salida generada y ejecutar `dart run build_runner build` en una copia de práctica del proyecto.
- [ ] **Dominado cuando:** puedes decidir qué archivo fuente cambiar para modificar el resultado generado.

## Bloque 7. Verificación y comprensión del recorrido completo

### 30. Pruebas de estado, listeners y widgets

- **Conceptos:** prueba unitaria, prueba de widget, preparación y limpieza, `expect`, `testWidgets`, `pumpWidget`, `pump` y aislamiento entre pruebas.
- **Debes comprender:** qué prueba una notificación, qué prueba una reconstrucción y qué requiere observar la aplicación ejecutándose. Un resultado no demuestra por sí solo los otros.
- **Práctica:** escribir una prueba de listeners, una de scopes independientes y una de serialización. Predecir qué falla si se registra dos veces un callback o se omite una limpieza.
- [ ] **Dominado cuando:** puedes escoger la prueba que demuestra el comportamiento que estás afirmando.

### 31. Ejercicio final: explicar todo el flujo

Recorre un cambio de tema utilizando los archivos reales de `lib/`. El ejemplo actual ya no tiene un botón que cambie el tema, de modo que para la interfaz usa la aplicación reproducida en el [apartado 8 de la unidad 25](temarios/25-scopes-anidados-e-independencia.md#8-el-ejemplo-anterior-completo). Distingue la preparación de la observación de lo que sucede después del cambio:

1. Creación del controlador y de su `FlutterSignal`.
2. Obtención de su vista pública de lectura, el adaptador `_ThemeListenable`.
3. Montaje del scope y escucha de la vista, que reenvía el listener a la señal.
4. Lectura de `context.daisyTheme` y registro de la dependencia del consumidor.
5. Pulsación del botón y ejecución de `setTheme`.
6. Asignación del valor y decisión de notificar según la igualdad aplicable.
7. La señal llama a los listeners registrados mediante `theme`.
8. Solicitud de actualización de los dependientes por parte de Flutter.
9. Reconstrucción y nueva lectura de los tokens que se muestran.
10. Desmontaje, retirada de listeners y liberación por el propietario cuando corresponde.

Variantes que debes resolver:

- Volver a asignar un tema equivalente al actual.
- Cambiar el tema de la vista previa manteniendo el tema global.
- Pasar el mismo controlador a dos scopes.
- Sustituir un controlador por otro.
- Consultar el tema usando un contexto sin scope ancestro.
- Conservar una lectura antigua en una variable y compararla con una lectura nueva.

- [ ] **Dominado cuando:** puedes explicar cada objeto, valor, relación y llamada sin utilizar «ocurre automáticamente» para saltarte un paso.

## Complemento final. API pública y organización del paquete

### 32. Imports, exports y límites del paquete

- **Conceptos:** biblioteca Dart, paquete Flutter, plugin, `import`, `export`, `show`, API pública, dependencias de ejecución y de desarrollo, y `../../pubspec.yaml`.
- **Debes comprender:** cómo una aplicación consume `package:daisy_ui/daisy_ui.dart` y por qué publicar una API no requiere exponer toda la implementación.
- **Práctica:** localizar qué símbolos se exportan y qué tipos pueden utilizar los consumidores. Relacionar cada dependencia del paquete con su responsabilidad.
- [ ] **Dominado cuando:** puedes explicar cómo otra aplicación utiliza los temas a través de la API pública y qué límites de encapsulación ofrecen los tipos expuestos.

## Archivos para acompañar el estudio

- [Controlador y adaptador de lectura](../../lib/themes/application/daisy_theme_controller.dart): unidades 9–16.
- [Servicio global](../../lib/themes/application/daisy_theme_service.dart): unidad 17.
- [Scope](../../lib/themes/application/daisy_theme_scope.dart): unidades 20–23 y 25.
- [Extensión de BuildContext](../../lib/themes/core/extension/build_context.dart): unidad 24.
- [Modelo de tema](../../lib/themes/domain/theme.dart): unidades 8 y 27–29.
- [Colores y pares de color](../../lib/themes/domain/theme/theme_color.dart), [radios](../../lib/themes/domain/theme/theme_radius.dart), [tamaños](../../lib/themes/domain/theme/theme_size.dart) y [bordes](../../lib/themes/domain/theme/theme_border.dart): unidad 26.
- [Catálogo de temas](../../lib/themes/application/daisy_themes.dart): datos para los ejercicios.
- [Ejemplo de aplicación](../../example/lib/main.dart): unidades 18, 20, 21, 23 y 24.
- Vista previa y botones de cambio de tema de la versión anterior del ejemplo (`git show 41fe41f~1:example/lib/main.dart`), reproducidos en el [apartado 8 de la unidad 25](temarios/25-scopes-anidados-e-independencia.md#8-el-ejemplo-anterior-completo): unidades 19, 25, 26 y 31.
- [Pruebas de controladores](../../test/themes/daisy_theme_controller_test.dart), [scopes](../../test/themes/daisy_theme_scope_test.dart), [JSON](../../test/themes/daisy_theme_json_test.dart) y [ejemplo](../../example/test/widget_test.dart): unidad 30.
- [API pública](../../lib/daisy_ui.dart), [dependencias](../../pubspec.yaml) y [configuración de generación](../../build.yaml): unidades 29 y 32.

## Referencia para profundizar en Signals

Usar la [documentación oficial de Signals](https://dartsignals.dev/) para ampliar las unidades 9–13, contrastando los ejemplos con la versión instalada del proyecto. El rango declarado en `../../pubspec.yaml` y la versión efectivamente resuelta pueden ser distintos.

## Cómo decidir si podemos avanzar

Para cada concepto, debes poder responder:

1. ¿Qué es, explicado con tus palabras?
2. ¿Qué problema resuelve?
3. ¿Quién lo crea y quién lo utiliza?
4. ¿Qué ocurre paso a paso cuando actúa?
5. ¿Dónde aparece en DaisyUI?
6. ¿Qué error concreto cometerías si lo entendieras mal?
7. ¿Qué ejercicio o prueba demuestra que lo has comprendido?

El punto de partida es la unidad 1. Si ya dominas alguna base de Dart, la comprobamos con un ejercicio breve y avanzamos; conservamos el orden de las dependencias entre conceptos.
