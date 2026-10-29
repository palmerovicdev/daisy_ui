# 02. Funciones como valores: callbacks y listeners

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 1](01-estado-valor-actual-y-cambio.md)

- **Bloque:** las bases para comprender la observación.
- **Estado de estudio:** pendiente.
- **Investigación de fuentes:** 19 de octubre de 2026.

## Qué vas a conseguir

Podrás entregar una función sin ejecutarla, seguir quién la llama y explicar qué variables utiliza cuando finalmente
se ejecuta. También podrás registrar un listener y retirarlo conservando la función que entregaste.

Esta unidad desarrolla todos los conceptos de la unidad 2 del plan: **función**, **referencia**, **ejecución**,
**callback**, **listener**, **función anónima**, **closure**, **`=>`**, **`void`**, **`VoidCallback`** y **
`void Function()`**. Añadimos el vocabulario mínimo de parámetros, argumentos, retorno y alcance para poder
explicarlos sin saltos.

La pregunta que debe acompañar cada ejemplo es: **¿qué función se conserva, quién la ejecuta y en qué momento?**

## Ruta y progreso

Antes de empezar, comprueba que puedes explicar por qué una lectura guardada de `'claro'` sigue conservando ese texto
después de asignar `'oscuro'` a la variable original. Es la base de la unidad 1.

Seguimos su estructura de nodos pequeños: problema, explicación, predicción, recurso y comprobación. Los ejemplos A–E
son programas independientes para un pad de **Dart** de [DartPad](https://dartpad.dev/); no necesitan Flutter ni
paquetes.
Los fragmentos del proyecto se identifican como tales y se leen en sus archivos.

- [ ] [2.1. Separar una función de su ejecución](#21-separar-una-función-de-su-ejecución).
- [ ] [2.2. Leer la firma: parámetros, retorno y void](#22-leer-la-firma-parámetros-retorno-y-void).
- [ ] [2.3. Reconocer funciones anónimas, callbacks y flechas](#23-reconocer-funciones-anónimas-callbacks-y-flechas).
- [ ] [2.4. Seguir las variables de una closure](#24-seguir-las-variables-de-una-closure).
- [ ] [2.5. Registrar, avisar y retirar listeners](#25-registrar-avisar-y-retirar-listeners).
- [ ] [2.6. Leer los callbacks y listeners de DaisyUI](#26-leer-los-callbacks-y-listeners-de-daisyui).
- [ ] [Completar el proyecto de la unidad](#proyecto-de-la-unidad-un-botón-y-un-observador).
- [ ] [Superar la comprobación final](#comprobación-final).

Puedes repartirlo en varias sesiones: primero 2.1–2.3; después 2.4; finalmente 2.5–2.6 y el proyecto.
Marca una casilla cuando puedas resolver y explicar su comprobación sin copiar.

## 2.1. Separar una función de su ejecución

### El problema

Quieres que un botón avise cuando se pulse. Si ejecutas el aviso mientras preparas el botón, ¿qué le has dejado para
ejecutar después?

### La idea

Una **función** describe una operación que puede ejecutarse al llamarla. Puede recibir datos y producir un resultado.
Además, en Dart podemos guardar una función en una variable o entregarla a otra función.
La referencia oficial
es [Functions as first-class objects](https://dart.dev/language/functions#functions-as-first-class-objects).

Separa estas tres formas:

- `void avisar() { ... }`: declara la función y su cuerpo.
- `avisar`, usado como expresión: obtiene la función como valor, sin ejecutar su cuerpo.
- `avisar()`: llama a la función. Los paréntesis contienen los argumentos; aquí no hay ninguno.

Una referencia a una función permite llamarla más adelante. No es el texto con su nombre ni el resultado de haberla
ejecutado.

### Ejemplo A: entregar y ejecutar

Para leerlo, `void` indica que no utilizaremos un resultado de esa llamada. El parámetro
`void Function() accion` recibe una función que podemos llamar sin argumentos. Descompondremos esta firma en 2.2.

Predice toda la salida antes de ejecutar este programa completo.

```dart
void avisar() {
  print('Aviso');
}

void ejecutar(void Function() accion) {
  print('Dentro de ejecutar');
  accion();
}

void main() {
  print('1. Inicio');
  final pendiente = avisar;
  print('2. Función guardada');
  ejecutar(pendiente);
  print('3. Fin');
}
```

Sigue el recorrido:

1. Dart empieza ejecutando `main`.
2. `pendiente` recibe la función `avisar`. Esa asignación no imprime `Aviso`.
3. `ejecutar(pendiente)` llama a `ejecutar` y le entrega esa función.
4. Dentro de `ejecutar`, el parámetro `accion` permite acceder a la función recibida.
5. `accion()` ejecuta su cuerpo y aparece `Aviso`.
6. La ejecución vuelve a `main` y se imprime la última línea.

En este recorrido, `avisar` actúa como **callback**: una función que entregamos para que el código receptor la llame.
Aquí el receptor la llama inmediatamente dentro de `ejecutar`. La palabra callback no obliga a esperar, usar
asincronía o crear otro hilo.

Puedes pensar en entregar una receta y en cocinar siguiendo esa receta. Entregarla no cocina nada. La analogía ayuda
a separar entrega y ejecución; una función también puede conservar acceso a variables, como veremos en 2.4.

### Comprobación

- Quita `accion();`. ¿Qué línea deja de aparecer? ¿Sigue recibiéndose la función?
- Cambia `ejecutar(pendiente)` por `pendiente()`. ¿Quién realiza ahora la llamada?
- Intenta `ejecutar(avisar())`. Explica por qué se intenta usar el resultado de una llamada `void` donde se necesita
  una función. El analizador lo rechaza; no es una versión que haya dejado el aviso preparado.

**Puedes avanzar cuando:** localizas la entrega y la llamada sin confundir los dos pares de paréntesis de
`ejecutar(pendiente)` y `accion()`.

## 2.2. Leer la firma: parámetros, retorno y void

### El problema

Dos funciones imprimen mensajes. Una necesita el nombre del tema y la otra no necesita datos. ¿Podemos entregarlas
indistintamente a cualquier receptor?

### El vocabulario

- **Parámetro:** variable que aparece en la declaración de una función para recibir un dato.
- **Argumento:** expresión que entregas en una llamada. En `crearEtiqueta('claro')`, el argumento es `'claro'`.
- **Retorno:** resultado que la función entrega a quien la llamó.
- **Firma:** descripción de cómo se llama a la función: sus parámetros y su tipo de retorno.

En `void ejecutar(void Function() accion)`, el primer `void` describe el retorno de `ejecutar`.
`void Function()` es el tipo de su parámetro `accion`: se puede llamar sin argumentos y su resultado no se utiliza.
`accion` es el nombre del parámetro.

Otros ejemplos de tipos son `String Function()`, para obtener un texto sin pasar argumentos, y
`String Function(String)`, para obtener un texto pasando otro texto. Consulta
[Function types](https://dart.dev/language/functions#function-types).

### Qué significa void

`void` indica que el valor de resultado no se usa. Una función `void` puede realizar trabajo: imprimir, modificar
un dato o registrar otra función. Eso no la convierte en una función que debamos utilizar para obtener un texto.
La documentación lo recoge entre los [tipos con un papel especial](https://dart.dev/language/built-in-types).

Separa las dos partes de `void Function()`: `void` habla del resultado; `()` habla de los argumentos.
Una función también puede tener tipo `void Function(String)`: recibe un texto y no ofrece un resultado utilizable.

### VoidCallback

Flutter da un nombre a un tipo que veremos muchas veces:

```dart
typedef VoidCallback = void Function();
```

`typedef` introduce un alias de tipo. `VoidCallback` y `void Function()` nombran el mismo tipo; el alias no crea
una función ni una suscripción. Consulta su
[definición oficial](https://api.flutter.dev/flutter/dart-ui/VoidCallback.html) y la explicación de
[Typedefs](https://dart.dev/language/typedefs).

Los programas de Dart de esta guía usan `void Function()` directamente. En código Flutter podemos importar
`package:flutter/foundation.dart` para utilizar `VoidCallback`, como hace el controlador de DaisyUI.

### Comprobación

Explica qué datos hay que entregar y qué resultado puede utilizarse en cada caso:

1. `void Function()`.
2. `void Function(String)`.
3. `String Function()`.
4. `String Function(String)`.

Si el receptor necesita un `void Function()`, una función que exige un argumento `String` no sirve directamente.
En el siguiente nodo construiremos una función sin argumentos que realiza por dentro la llamada con ese dato.

**Puedes avanzar cuando:** lees la firma sin confundir el retorno del receptor con el retorno del callback.

## 2.3. Reconocer funciones anónimas, callbacks y flechas

### El problema

Quieres preparar una acción pequeña para un uso concreto. ¿Necesitas declarar siempre una función con nombre?

### La idea y la sintaxis

Una función **anónima** se escribe sin un nombre de declaración. Podemos guardarla o pasarla directamente.
`() { ... }` construye una función sin parámetros con un bloque como cuerpo.
`() => expresion` construye una función cuyo cuerpo consiste en una expresión.
La documentación presenta las [funciones anónimas](https://dart.dev/language/functions#anonymous-functions).

La flecha también sirve en funciones con nombre. `=>` no registra listeners ni decide cuándo se ejecutará la función.
Cuando necesitamos varias instrucciones, usamos un bloque. Cuando una función produce un dato, la forma con flecha
devuelve el resultado de su expresión.

### Ejemplo B: un bloque, una flecha y una acción preparada

La instrucción `return` entrega el resultado a quien llamó a la función. En las funciones de este ejemplo, `nombre`
es el parámetro que recibe un texto y `String` es el tipo del texto que se devuelve.

Programa completo. Predice qué ocurre al crear `alPulsar` y qué ocurre al llamarla.

```dart
String crearEtiqueta(String nombre) {
  return 'Tema: $nombre';
}

String crearEtiquetaCorta(String nombre) => 'Tema: $nombre';

void main() {
  final alPulsar = () {
    print(crearEtiqueta('claro'));
  };
  final otraAccion = () => print(crearEtiquetaCorta('oscuro'));

  print('Acciones preparadas');
  alPulsar();
  otraAccion();
}
```

Las dos funciones que crean etiquetas producen el mismo resultado para el mismo argumento.
Los cuerpos de `alPulsar` y `otraAccion` se ejecutan al llegar a sus llamadas, después de la primera impresión.

Ahora compara estas expresiones:

- `crearEtiqueta`: función que todavía necesita un argumento.
- `crearEtiqueta('claro')`: llamada cuyo resultado es un texto.
- `() => crearEtiqueta('claro')`: función nueva sin argumentos que realizará esa llamada cuando se ejecute.

Una función anónima puede utilizarse como callback o como listener. Esos nombres describen su papel.
La sintaxis anónima, por sí sola, no la registra en ningún sitio.

Cuando una función o un método existente tiene la firma que necesitamos, podemos entregarlo sin envolverlo.
Esa obtención de una función existente se llama **tear-off**; por ejemplo, `final pendiente = avisar;`.
Consulta el [glosario oficial de closurización](https://dart.dev/resources/glossary#closurization).

### Comprobación

Reescribe `otraAccion` con un bloque y `crearEtiquetaCorta` con un bloque y `return`. Conserva el comportamiento.
Después explica por qué `final alPulsar = crearEtiqueta('claro');` guardaría un texto y no una acción pendiente.

**Puedes avanzar cuando:** distingues forma de escribir, firma y papel de una función.

## 2.4. Seguir las variables de una closure

### El problema

Preparas una función que utiliza el tema actual y después cambias el tema. ¿Qué verá cuando finalmente la ejecutes?

### La idea

El **alcance léxico** determina a qué variables se puede acceder según dónde está escrito el código.
Una **closure** conserva acceso al entorno que necesita: puede usar variables del lugar donde fue creada incluso
cuando se llama desde otro lugar. La referencia es
[Lexical closures](https://dart.dev/language/functions#lexical-closures).

Capturar una variable mutable permite leer su valor cuando se ejecuta el cuerpo. No convierte una lectura anterior
guardada en otra variable en una consulta nueva a la fuente.

### Ejemplo C: una variable y una lectura guardada

Programa completo. Predice las tres líneas.

```dart
void main() {
  var temaActual = 'claro';
  final lecturaGuardada = temaActual;

  final consultar = () => print('Actual: $temaActual');
  final recordar = () => print('Guardado: $lecturaGuardada');

  temaActual = 'oscuro';
  consultar();
  recordar();

  temaActual = 'cupcake';
  consultar();
}
```

`consultar` utiliza la variable `temaActual`; cada llamada lee lo que contiene entonces.
`recordar` utiliza `lecturaGuardada`, que recibió el texto inicial. Las dos funciones conservan acceso a variables
distintas. No hay una regla que obligue a todas las closures a mostrar siempre el valor inicial o siempre el más nuevo.

### Ejemplo D: la función sigue disponible después de retornar

Programa completo. Lee el tipo de retorno de `crearAviso` como una pieza: `void Function()`.
Esta función devuelve otra función. `cantidad += 1` equivale aquí a `cantidad = cantidad + 1`.

```dart
void Function() crearAviso(String etiqueta) {
  var cantidad = 0;
  return () {
    cantidad += 1;
    print('$etiqueta: $cantidad');
  };
}

void main() {
  final avisarApp = crearAviso('App');
  final avisarPreview = crearAviso('Preview');

  avisarApp();
  avisarApp();
  avisarPreview();
}
```

1. La primera llamada a `crearAviso` crea su variable `cantidad` y devuelve una función con acceso a ella.
2. La segunda llamada crea otra variable `cantidad` para su propia ejecución.
3. Las dos llamadas a `avisarApp` incrementan la primera.
4. `avisarPreview` incrementa la segunda.

La ejecución de `crearAviso` ya terminó cuando se utilizan esos callbacks. El entorno que necesitan sigue accesible.
Conservar un callback también puede conservar acceso a objetos de ese entorno; retirar listeners será parte del
cuidado del ciclo de vida en unidades posteriores.

### Comprobación

- En C, añade otra llamada a `recordar()` al final. Explica su resultado.
- En D, intercala las llamadas a App y Preview. ¿Cambiará un contador por llamar al otro?
- Prepara una función que imprima la variable actual y otra que imprima una etiqueta calculada antes del cambio.
  Señala qué variable usa cada cuerpo.

**Puedes avanzar cuando:** señalas la variable concreta a la que accede cada closure y cuándo se lee.

## 2.5. Registrar, avisar y retirar listeners

### El problema

Quieres que varias funciones se enteren del cambio de tema. También necesitas dejar de avisar a una de ellas.
¿Dónde se conservan y quién las ejecuta?

### Las tres operaciones

Un **listener** es una función registrada para recibir avisos. En el mecanismo que vamos a construir:

1. Registrar conserva la función en una colección.
2. Avisar recorre las funciones registradas y llama a cada una.
3. Retirar elimina un registro para que no reciba los avisos posteriores.

Flutter expresa las operaciones de registro y retirada mediante
[`Listenable.addListener`](https://api.flutter.dev/flutter/foundation/Listenable/addListener.html) y
[`Listenable.removeListener`](https://api.flutter.dev/flutter/foundation/Listenable/removeListener.html).
Su implementación y su política de avisos se estudiarán en las unidades 4–7.

### Ejemplo E: dos listeners y dos retiradas

Este programa completo es un modelo didáctico escrito con funciones locales. Para leer su sintaxis:

- `<void Function()>[]` crea una lista vacía de funciones sin argumentos.
- `add` añade una función y `remove` retira la primera que resulte igual mediante `==`.
- `for (final listener in listeners)` recorre la lista; `listener()` llama a la función de esa vuelta.

Predice toda la salida y dibuja qué funciones contiene la lista antes de cada llamada a `notificar()`.

```dart
void main() {
  var temaActual = 'claro';
  var avisos = 0;
  final listeners = <void Function()>[];

  void registrar(void Function() listener) {
    listeners.add(listener);
  }

  void retirar(void Function() listener) {
    listeners.remove(listener);
  }

  void notificar() {
    for (final listener in listeners) {
      listener();
    }
  }

  void mostrarTema() {
    print('Tema: $temaActual');
  }

  final contarAviso = () {
    avisos += 1;
    print('Avisos: $avisos');
  };

  registrar(mostrarTema);
  registrar(contarAviso);
  print('Registrados');

  temaActual = 'oscuro';
  notificar();

  retirar(mostrarTema);
  temaActual = 'cupcake';
  notificar();

  retirar(contarAviso);
  temaActual = 'claro';
  notificar();
  print('Final: $temaActual');
}
```

Registrar no ejecuta los cuerpos de los listeners en este programa. La asignación del tema tampoco recorre la lista.
El aviso ocurre porque se llama explícitamente a `notificar()`. El listener que muestra el tema consulta la variable
cuando recibe la llamada; no recibe el tema como argumento.

Este modelo limita la práctica al registro y la retirada **fuera** del recorrido. No resuelve cambios de la lista
durante un aviso, excepciones ni liberación de recursos. Esas decisiones pertenecen a implementaciones concretas.

### Conservar el callback que registraste

Dentro del ejemplo E, esta forma conserva la función que queremos retirar:

```dart

final listener = () => print(temaActual);

registrar(listener);

retirar(listener);
```

Reescribir el cuerpo no garantiza obtener un callback igual al registrado. Esta variante no es una forma fiable de
retirarlo:

```dart
registrar
(
() => print(temaActual));
retirar((
)
=>
print
(
temaActual
)
);
```

Dart permite optimizaciones en las evaluaciones de funciones anónimas y no garantiza su igualdad.
Por eso la explicación correcta no es «dos funciones anónimas siempre son distintas», sino «reescribir la expresión no
garantiza recuperar la registrada». Consulta
[`Function.operator ==`](https://api.dart.dev/dart-core/Function/operator_equals.html).

Los tear-offs de un mismo método de instancia sobre el mismo objeto tienen reglas de igualdad específicas.
No necesitan ser idénticos para resultar iguales. Profundizaremos en identidad e igualdad en la unidad 8; conservar
el callback entregado permite resolver ahora el registro sin depender de esas diferencias.

### No trasladar todas las políticas de este modelo a DaisyUI

La lista de E admite registros repetidos. `ChangeNotifier` también documenta que un listener añadido varias veces
necesita las retiradas correspondientes:
[`ChangeNotifier.addListener`](https://api.flutter.dev/flutter/foundation/ChangeNotifier/addListener.html).

La versión **7.1.0** de `signals_flutter` resuelta en este proyecto conserva sus listeners en un mapa y evita añadir
otra suscripción para el mismo callback. Ese comportamiento se comprobó en el mixin `ValueNotifierSignalMixin` del
paquete instalado. No es una promesa universal de la palabra listener ni del contrato `Listenable`.

### Comprobación

- Quita la primera llamada a `notificar()`. ¿Qué dato cambia y qué cuerpos dejan de ejecutarse?
- Retira `mostrarTema` antes del primer aviso. Explica qué conserva el otro listener.
- Registra `mostrarTema` dos veces en E y retíralo una vez. ¿Cuántos registros quedan?
- Explica por qué `retirar(mostrarTema())` intenta ejecutar el cuerpo en vez de entregar la función.

**Puedes avanzar cuando:** sigues la colección y las llamadas por separado y conservas la función que necesitas retirar.

## 2.6. Leer los callbacks y listeners de DaisyUI

Los siguientes fragmentos pertenecen al proyecto. Las clases, interfaces y señales se desarrollarán después;
ahora identificamos funciones entregadas y llamadas.

### El botón recibe una función

En [example/lib/main.dart](../../example/lib/main.dart), `_ThemeExample.build` obtiene un modelo mediante
`final theme = context.daisyTheme;`. El botón contiene:

```dart
onPressed: () => DaisyThemeService.setTheme
(
theme.id == DaisyThemes.light.id
? DaisyThemes.
dark
:
DaisyThemes
.
light
,
)
,
```

Lee el fragmento de fuera hacia dentro:

1. `onPressed:` entrega un argumento con nombre al constructor del botón.
2. `() => ...` crea el callback sin argumentos. Construir el botón no ejecuta su cuerpo.
3. Cuando Flutter atiende la pulsación, llama al callback.
4. Su cuerpo compara el identificador del tema y elige qué modelo pasar a `setTheme`.
   La forma `condicion ? opcionSiEsVerdad : opcionSiEsFalsa` es una expresión condicional.
5. Entonces se ejecuta `DaisyThemeService.setTheme(...)`, que delega en el controlador.

El botón espera un `VoidCallback?`: puede recibir una función sin argumentos o `null`.
`null` desactiva este botón cuando tampoco hay `onLongPress`. La referencia es
[`ButtonStyleButton.onPressed`](https://api.flutter.dev/flutter/material/ButtonStyleButton/onPressed.html).

`DaisyThemeService.setTheme` necesita un argumento `DaisyThemeModel`. Entregar directamente ese método a
`onPressed` no satisface su firma. Aquí la función anónima prepara la llamada con el argumento necesario.

### Qué conserva ese callback

El callback usa el `theme` local de esa ejecución de `build`. Ese `final` conserva el modelo que se obtuvo entonces.
Cambiar la selección no sustituye el valor de esa variable local.

Cuando Flutter vuelve a ejecutar `build`, se hace otra lectura y se crea el callback del nuevo botón con su propio
`theme`. El mecanismo que solicita esa reconstrucción se estudia en las unidades de scopes. El ejemplo enlaza
closures con las lecturas de la unidad 1.

### La vista de lectura recibe y reenvía listeners

En el [controlador](../../lib/themes/application/daisy_theme_controller.dart), el adaptador privado contiene:

```dart
void addListener(VoidCallback listener) => _source.addListener(listener);

void removeListener(VoidCallback listener) =>
    _source.removeListener(listener);
```

`addListener` recibe una función. Su cuerpo llama inmediatamente a `_source.addListener` y le entrega ese mismo
`listener`. No aparece `listener()`: el adaptador no ejecuta su cuerpo ni crea otro callback para envolverlo.
La fuente conserva la suscripción según su implementación. La retirada reenvía la función de la misma manera.

El [scope](../../lib/themes/application/daisy_theme_scope.dart) entrega esa vista como `notifier` a
`InheritedNotifier`, que conecta los avisos con Flutter. Registrar un listener cualquiera no implica por sí solo
reconstruir la pantalla: el cuerpo que recibe el aviso y su integración tienen que realizar el trabajo correspondiente.

### Una prueba existente para seguir el recorrido

Abre [daisy_theme_controller_test.dart](../../test/themes/daisy_theme_controller_test.dart) y localiza la prueba
`Theme views notify on changes and support listener removal`. Identifica:

1. La declaración local `listener`.
2. La entrega mediante `theme.addListener(listener)`.
3. El contador que permite detectar una ejecución.
4. El cambio a un tema distinto.
5. La retirada mediante `theme.removeListener(listener)`.
6. El cambio posterior que ya no incrementa el contador.

En ese archivo también aparece `addTearDown(controller.dispose)`: se entrega un método para que el sistema de pruebas
lo ejecute durante la limpieza. `controller.dispose()` lo llamaría en ese momento.

Puedes ejecutar el archivo desde la raíz del repositorio:

```sh
flutter test test/themes/daisy_theme_controller_test.dart
```

**Puedes avanzar cuando:** localizas quién recibe cada función y distingues la pulsación del botón, el registro del
listener y el aviso que ejecuta su cuerpo.

## Materiales de estudio seleccionados

La guía y las tareas están en español. Las referencias principales son documentación oficial en inglés.
Cada recurso tiene una lectura acotada; no necesitas recorrer todas sus secciones.

- **D1 · Dart: [Functions](https://dart.dev/language/functions)** — nodos 2.1–2.4. Lee las secciones sobre funciones
  como valores, tipos, funciones anónimas, alcance léxico y closures. Localiza un ejemplo de entrega y otro de llamada.
  Los generadores y los detalles de parámetros opcionales quedan fuera de esta unidad.
- **D2 · Dart: [Built-in types](https://dart.dev/language/built-in-types)** — nodo 2.2. Busca la explicación de `void`
  y diferencia el retorno de los argumentos.
- **D3 · Flutter: [VoidCallback](https://api.flutter.dev/flutter/dart-ui/VoidCallback.html)** y
  **Dart: [Typedefs](https://dart.dev/language/typedefs)** — nodo 2.2. Explica por qué el alias y el tipo completo
  permiten describir el mismo callback.
- **D4 · Dart: [Closurization](https://dart.dev/resources/glossary#closurization)** — nodo 2.3. Reconoce la obtención
  de una función sin ejecutarla. Las clases del ejemplo oficial se estudian en la unidad 3.
- **D5 · Dart: [Function.operator ==](https://api.dart.dev/dart-core/Function/operator_equals.html)** — nodo 2.5.
  Lee el párrafo sobre evaluaciones de funciones anónimas. Explica por qué conservar el callback resuelve la retirada.
- **D6 · Flutter: [addListener](https://api.flutter.dev/flutter/foundation/Listenable/addListener.html) y
  [removeListener](https://api.flutter.dev/flutter/foundation/Listenable/removeListener.html)** — nodo 2.5.
  Identifica qué función se entrega. El contrato completo de `Listenable` corresponde a la unidad 4.
- **D7 ·
  Flutter: [ChangeNotifier.addListener](https://api.flutter.dev/flutter/foundation/ChangeNotifier/addListener.html)**
  — ampliación del nodo 2.5. Localiza la política de registros repetidos y compárala con el modelo didáctico.
- **D8 · Flutter: [onPressed](https://api.flutter.dev/flutter/material/ButtonStyleButton/onPressed.html)** — nodo 2.6.
  Comprueba la firma del callback y cuándo se llama.
- **P1 · [DartPad](https://dartpad.dev/) y su [guía oficial](https://dart.dev/tools/dartpad)** — práctica A–E.
  Crea un pad de Dart para cada programa. Los fragmentos que importan DaisyUI necesitan el repositorio y sus
  dependencias.

### Apoyo audiovisual opcional

La documentación de Dart enlaza [Dart Tear-offs | Decoding Flutter](https://www.youtube.com/watch?v=OmCaloD7sis).
Úsalo después del nodo 2.3 para reforzar la diferencia entre entregar una función y llamarla.
El [enlace desde la documentación](https://dart.dev/language/constructors#constructor-tear-offs) también desarrolla
constructores, que se estudiarán más adelante.

Se comprobó ese enlace en la documentación oficial; no se pudo reproducir el vídeo ni revisar su transcripción.
Su contenido completo no forma parte de la verificación técnica de esta guía.

## Proyecto de la unidad: un botón y un observador

Escribe un programa de Dart desde cero, sin Flutter, utilizando las piezas de E.

### Requisitos

1. Conserva un tema actual con valor inicial `'claro'` y guarda una lectura inicial.
2. Permite registrar y retirar funciones `void Function()`.
3. Define `seleccionarTema(String nuevoTema)`: asigna el tema y llama a los listeners registrados.
   Para este ejercicio, notifica en cada llamada, aunque el texto sea igual. Es una política explícita de la práctica.
4. Guarda y registra un callback que imprima `Tema observado: ...` consultando la variable actual.
5. Prepara un callback `alPulsar`, sin argumentos, que seleccione `'oscuro'`.
6. Imprime el tema antes de llamar a `alPulsar()`. Crear y registrar funciones no debe haber cambiado el tema.
7. Ejecuta `alPulsar()`, retira el observador y selecciona `'cupcake'`.
8. Muestra la lectura inicial y el tema final. La segunda selección ya no debe imprimir un aviso del observador
   retirado.

Antes de ejecutar, escribe la salida esperada y señala la primera llamada que puede ejecutar cada cuerpo.
Después compara tu solución con la incluida al final.

### Variaciones

- Guarda una etiqueta inicial y haz que otro callback la imprima. Explica por qué muestra una lectura anterior.
- Entrega `alPulsar` a una función `ejecutar` como la de A. Predice si se ejecuta durante esa llamada o después.
- Añade un segundo observador y retira solamente el primero.
- Explica qué cambia al conectar el callback con un botón Flutter real y qué parte seguiría siendo una llamada Dart.

**Entrega de estudio:** código, predicción y explicación de la entrega, captura, registro, ejecución y retirada.

## Errores de comprensión que vamos a comprobar

- Entregar `avisar()` cuando el receptor necesita `avisar`.
- Creer que guardar una función ejecuta su cuerpo.
- Pensar que todo callback se ejecuta después, de forma asíncrona o en otro hilo.
- Interpretar `void` como ausencia de argumentos o ausencia de trabajo.
- Confundir una función que devuelve un texto con el texto que devuelve al llamarla.
- Atribuir a `=>` el registro de dependencias o la programación de una ejecución futura.
- Pensar que una closure copia siempre el valor inicial de todas sus variables.
- Esperar que una closure que utiliza una lectura guardada consulte otra variable distinta por sí sola.
- Reescribir una función anónima y suponer que con ello recuperaste el listener registrado.
- Aplicar la política de listeners duplicados de una implementación a todas las demás.
- Confundir recibir un aviso con solicitar una reconstrucción de Flutter.

## Comprobación final

Responde sin mirar las soluciones:

1. ¿Qué diferencia hay entre declarar `avisar`, obtener `avisar` como valor y llamar a `avisar()`?
2. En A, ¿quién entrega el callback, quién lo recibe y quién llama a su cuerpo?
3. ¿Por qué un callback puede ejecutarse antes de que retorne la función que lo recibió?
4. ¿Qué describe cada parte de `void Function()` y qué relación tiene con `VoidCallback`?
5. ¿Cómo conviertes una operación que necesita un argumento en una acción preparada sin argumentos?
6. ¿Qué cambia al escribir una función con `=>`?
7. En C, ¿qué variable utiliza cada closure y qué valor consulta en cada llamada?
8. En D, ¿por qué una llamada a App no incrementa el contador de Preview?
9. En E, ¿qué operación conserva las funciones y cuál ejecuta sus cuerpos?
10. ¿Qué debe conservarse para retirar con fiabilidad una función anónima registrada?
11. ¿Por qué no puedes afirmar que toda implementación trata igual los listeners duplicados?
12. En DaisyUI, ¿qué ejecuta el callback del botón y qué reenvía `_ThemeListenable.addListener`?
13. ¿Qué modelo utiliza el callback de una ejecución concreta de `build` y qué cambia al reconstruir?
14. ¿Qué demuestra que un listener imprimió un mensaje? ¿Demuestra por sí solo una reconstrucción de pantalla?

Marca la unidad como dominada cuando puedas resolver el proyecto sin copiar, explicar estas respuestas y seguir las
funciones del ejemplo real. Si falla la diferencia entre entregar y llamar, vuelve a 2.1 antes de avanzar a los
contratos
de la unidad 3.

## Soluciones para contrastar después de practicar

<details>
<summary>Ver salidas, solución del proyecto y claves de las comprobaciones</summary>

### Ejemplo A

```text
1. Inicio
2. Función guardada
Dentro de ejecutar
Aviso
3. Fin
```

Sin `accion();` no aparece `Aviso`. Con `pendiente()` se ejecuta el aviso directamente desde `main` y no aparece
`Dentro de ejecutar`. Usar `ejecutar(avisar())` intenta entregar una expresión `void` como argumento y el analizador
lo rechaza.

### Ejemplo B

```text
Acciones preparadas
Tema: claro
Tema: oscuro
```

Preparar las dos acciones no imprime sus mensajes. La función con bloque que devuelve un texto necesita
`return`; la función con flecha devuelve el resultado de su expresión.

### Ejemplo C

```text
Actual: oscuro
Guardado: claro
Actual: cupcake
```

Una llamada final a `recordar()` imprime otra vez `Guardado: claro`.
`consultar` utiliza `temaActual`; `recordar` utiliza la lectura inicial.

### Ejemplo D

```text
App: 1
App: 2
Preview: 1
```

Cada ejecución de `crearAviso` aporta sus propias variables a la función que devuelve.
Intercalar llamadas conserva esa independencia.

### Ejemplo E

```text
Registrados
Tema: oscuro
Avisos: 1
Avisos: 2
Final: claro
```

Al primer aviso llegan las dos funciones. Al segundo solamente llega `contarAviso`.
En el tercero la lista está vacía. Si omites el primer aviso, el contador solo se incrementa en el segundo:
imprime `Avisos: 1`.

Registrar dos veces `mostrarTema` añade dos entradas en esta lista. Una retirada elimina una; queda otra.
La fuente de Signals instalada en DaisyUI evita duplicar la suscripción del mismo callback.

### Una solución del proyecto

Programa completo para un pad de Dart:

```dart
void main() {
  var temaActual = 'claro';
  final lecturaInicial = temaActual;
  final listeners = <void Function()>[];

  void registrar(void Function() listener) {
    listeners.add(listener);
  }

  void retirar(void Function() listener) {
    listeners.remove(listener);
  }

  void seleccionarTema(String nuevoTema) {
    temaActual = nuevoTema;
    for (final listener in listeners) {
      listener();
    }
  }

  final observador = () => print('Tema observado: $temaActual');
  registrar(observador);

  final alPulsar = () => seleccionarTema('oscuro');
  print('Antes: $temaActual');
  alPulsar();

  retirar(observador);
  seleccionarTema('cupcake');

  print('Lectura guardada: $lecturaInicial');
  print('Tema final: $temaActual');
}
```

```text
Antes: claro
Tema observado: oscuro
Lectura guardada: claro
Tema final: cupcake
```

`alPulsar` captura la función local que realizará la selección. Al llamarlo se cambia la variable y se recorre la lista.
`observador` lee el tema durante ese aviso. Retirarlo evita su siguiente llamada; el tema puede seguir cambiando.

### Claves de la comprobación final

Las preguntas 1–3 exigen separar declaración, entrega y llamada, e identificar el receptor que decide ejecutar.
Las 4–6 exigen leer una firma y preparar una llamada sin atribuir a la flecha un mecanismo de observación.
Las 7–8 exigen seguir variables concretas de entornos concretos.
Las 9–11 exigen distinguir conservación, ejecución, retirada y política de la implementación.

En 12, el botón ejecuta una llamada a `setTheme`; el adaptador entrega el listener a su fuente.
En 13, cada callback utiliza el `theme` local de su construcción; una nueva construcción obtiene otro valor y prepara
otro callback. En 14, una impresión demuestra la ejecución del cuerpo; para demostrar una reconstrucción necesitamos
observar o probar también el consumidor Flutter.

</details>

## Qué se ha revisado y cómo se ha comprobado

- Se contrastaron las definiciones con las páginas oficiales enlazadas y se leyeron el controlador, el servicio,
  el scope, la extensión de contexto, el ejemplo y las pruebas actuales de controladores.
- El índice MCP no pudo crearse porque el servidor no permite esta raíz. La comprobación de cobertura tampoco encontró
  un proyecto indexado; las referencias al repositorio se verificaron mediante lectura directa de esos archivos.
- Se revisó la implementación de listeners de `signals_flutter 7.1.0` resuelta localmente para distinguir su política
  de registros repetidos de la de `ChangeNotifier`.
- Se ejecutaron los programas completos A–E y la solución del proyecto con Dart 3.13.5. Las seis salidas coinciden con
  las soluciones y el análisis estático terminó sin incidencias. También se confirmó el diagnóstico
  `use_of_void_result` de la variante inválida `ejecutar(avisar())`.
- Pasaron las tres pruebas existentes de `daisy_theme_controller_test.dart`, ejecutadas con `flutter test --no-pub`.
  Entre ellas se comprueba que el registro no llama inmediatamente al listener, que un cambio a un tema distinto lo
  llama y que la retirada evita su llamada en el cambio posterior.
- Se comprobaron los enlaces locales, las anclas de navegación, los bloques de código y los espacios del documento.
- El vídeo es apoyo opcional. Ejecutar programas Dart y pruebas de controladores no equivale a validar pulsaciones
  ni reconstrucciones de la interfaz real.
