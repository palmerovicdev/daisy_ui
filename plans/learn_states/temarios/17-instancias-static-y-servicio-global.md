# 17. Instancias, `static` y servicio global

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 16](16-vistas-de-lectura-getters-y-delegacion.md) · **Estado:** pendiente

## Qué vas a aprender

Hasta ahora, para usar un tema creábamos un `DaisyThemeController` y guardábamos la referencia. Sin embargo, cualquier botón puede llamar a `DaisyThemeService.setTheme(...)` sin haber creado ningún objeto. ¿Dónde está entonces el tema que cambia? ¿Quién lo creó y quién más lo ve?

Al terminar podrás distinguir lo que pertenece a una instancia de lo que pertenece a una clase, y sabrás cuándo se inicializa un campo `static`. También podrás leer `abstract final class` y seguir una llamada al servicio hasta su señal. Con eso predecirás qué comparten dos consumidores del servicio, qué conservan dos controladores propios y por qué las pruebas del proyecto reinician el servicio. Por último, podrás justificar cuándo compartir estado y cuándo crear una instancia independiente.

Los programas sin dependencias de los apartados 1–4 se pueden ejecutar en [DartPad](https://dartpad.dev/) en modo **Dart**. Las pruebas son archivos completos: copia **una cada vez** a `test/estudio_servicio_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_servicio_test.dart
```

Necesitas las dependencias ya resueltas. Predice cada resultado antes de mirarlo. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–4 en una sesión, 5–7 en otra y terminar después con el apartado 8 y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas.

## 1. El estado de una instancia

Imagina dos marcadores en un partido: el del equipo local y el del visitante. Ambos se comportan igual, pero cada uno debe recordar sus propios puntos. Una clase describe cómo son; cada objeto creado conserva sus datos.

```dart
class Marcador {
  int puntos = 0;

  void sumar() {
    puntos = puntos + 1;
  }
}

void main() {
  final local = Marcador();
  final visitante = Marcador();

  local.sumar();
  local.sumar();
  visitante.sumar();

  print('Local: ${local.puntos}');
  print('Visitante: ${visitante.puntos}');
}
```

La salida es:

```text
Local: 2
Visitante: 1
```

Paso a paso:

1. Cada `Marcador()` crea un objeto distinto, una **instancia**, con su propio campo `puntos`.
2. `local.sumar()` ejecuta el mismo código de la clase, pero sobre el objeto al que apunta `local`.
3. `visitante.sumar()` modifica el otro objeto. Compartir el código de un método no significa compartir los datos.

`puntos` y `sumar` son **miembros de instancia**: para usarlos hace falta un objeto, y por eso se escriben después de una referencia como `local`. Así funciona también `DaisyThemeController`: cada controlador tiene su `_palette`.

### Practica 1

Añadimos `final tercero = Marcador();` al final de `main`, sin llamar a `sumar`. ¿Cuánto vale `tercero.puntos`? ¿Cambian los valores de `local` y `visitante`?

<details>
<summary>Ver respuesta</summary>

`tercero.puntos` vale `0`, porque el nuevo objeto recibe su propio campo con el valor inicial. `local` y `visitante` conservan `2` y `1`: crear otra instancia no modifica los datos de las anteriores.

</details>

## 2. Un miembro que pertenece a la clase

Ahora queremos saber cuántos marcadores se han creado en total. Ese dato no pertenece al local ni al visitante, sino al conjunto. La palabra `static` declara un **miembro estático**: pertenece a la clase y no a cada objeto.

```dart
class Marcador {
  Marcador() {
    creados = creados + 1;
  }

  static int creados = 0;

  int puntos = 0;

  void sumar() {
    puntos = puntos + 1;
  }

  static String resumen() => 'Marcadores creados: $creados';
}

void main() {
  print(Marcador.resumen());

  final local = Marcador();
  final visitante = Marcador();
  local.sumar();

  print(Marcador.resumen());
  print('Local: ${local.puntos}');
  print('Visitante: ${visitante.puntos}');
}
```

La salida es:

```text
Marcadores creados: 0
Marcadores creados: 2
Local: 1
Visitante: 0
```

Paso a paso:

1. `Marcador.resumen()` se llama con el **nombre de la clase**, antes de que exista ningún marcador. Lee `creados`, que vale `0`.
2. Cada constructor suma uno al mismo campo `creados`. Existe un solo `creados` para toda la clase, por eso llega a 2.
3. `puntos` sigue siendo de instancia: `local` tiene `1` y `visitante` tiene `0`.

Como un método estático se ejecuta sin un objeto concreto, no hay ningún `this` al que referirse. Este **fragmento** reúne cuatro errores que indica el analizador; no compila:

```dart
// Dentro de la clase Marcador:
static int leerPuntos() => puntos; // Instance members can't be accessed from a static method.
static Marcador yo() => this; // Invalid reference to 'this' expression.

// En main:
print(Marcador.puntos); // Instance member 'puntos' can't be accessed using static access.
print(local.creados); // The static getter 'creados' can't be accessed through an instance.
```

`Marcador.puntos` no tiene sentido porque habría que elegir de qué marcador. Y Dart tampoco deja escribir `local.creados`, aunque en otros lenguajes se permita, de modo que la escritura muestra de quién es cada dato. El camino contrario sí funciona: el constructor, que es código de instancia, puede usar `creados`.

### Practica 2

Después del programa anterior creamos un tercer marcador y sumamos en él una vez. Sin ejecutarlo, ¿qué devuelve `Marcador.resumen()`? ¿Cuánto vale `local.puntos`?

<details>
<summary>Ver respuesta</summary>

`Marcadores creados: 3`, porque el constructor incrementa el único campo `creados` de la clase. `local.puntos` sigue en `1`: sumar en el tercer marcador modifica el campo de ese objeto.

</details>

## 3. Una fachada estática que delega

Un miembro estático también puede guardar un **objeto**. En este ejemplo, la clase `Preferencias` es corriente y `ServicioPreferencias` conserva una instancia para que cualquier parte del programa pueda usarla:

```dart
class Preferencias {
  String tema = 'claro';

  void cambiar(String nuevo) {
    tema = nuevo;
  }
}

class ServicioPreferencias {
  static final _actuales = Preferencias();

  static String get tema => _actuales.tema;

  static void cambiar(String nuevo) {
    _actuales.cambiar(nuevo);
  }
}

void mostrarPanel() => print('Panel: ${ServicioPreferencias.tema}');

void mostrarMenu() => print('Menú: ${ServicioPreferencias.tema}');

void main() {
  final vistaPrevia = Preferencias();

  ServicioPreferencias.cambiar('oscuro');
  vistaPrevia.cambiar('cupcake');

  mostrarPanel();
  mostrarMenu();
  print('Vista previa: ${vistaPrevia.tema}');
}
```

La salida es:

```text
Panel: oscuro
Menú: oscuro
Vista previa: cupcake
```

Paso a paso:

1. `vistaPrevia` es una instancia propia de `main`.
2. `ServicioPreferencias.cambiar('oscuro')` no cambia nada por sí mismo: **delega** en el objeto `_actuales`, como vimos con `_ThemeListenable` en la unidad 16. La diferencia es que aquí quien delega es un miembro estático.
3. `mostrarPanel` y `mostrarMenu` no reciben ningún parámetro. Ambos leen el mismo objeto a través del nombre de la clase, por eso muestran `oscuro`.
4. `vistaPrevia.cambiar('cupcake')` afecta solo a su instancia, que no tiene relación con `_actuales`.

Esta forma de presentar operaciones sencillas delante de otro objeto se suele llamar **fachada**. Como `_actuales` está en un campo estático, cualquier código de la biblioteca o del programa que vea la clase llega al mismo dato: es una **fuente global de estado**. Es cómodo, pero observa lo que deja de verse: leyendo la firma de `mostrarPanel()` no se sabe que depende del servicio. Volveremos a ello en el apartado 8.

### Practica 3

Si `mostrarMenu` llama a `ServicioPreferencias.cambiar('bosque')` antes de imprimir, ¿qué mostrará después `mostrarPanel()`? ¿Cambia `vistaPrevia.tema`?

<details>
<summary>Ver respuesta</summary>

`mostrarPanel()` mostrará `Panel: bosque`, porque ambas funciones usan el único objeto `_actuales`. `vistaPrevia.tema` sigue en `cupcake`: es otra instancia. Fíjate en que `mostrarMenu` ha cambiado lo que ve `mostrarPanel` sin que ninguna de las dos reciba al otro: esa conexión queda oculta en el estado global.

</details>

## 4. ¿Cuándo se inicializa un campo estático?

¿En qué momento se crea el objeto de `_actuales`? Un campo estático con inicializador se calcula **la primera vez que se accede a él**, y solo una vez. Vamos a imprimir un mensaje en el constructor para verlo.

**Antes de mirar la salida**, predice en qué orden aparecen las líneas:

```dart
class Preferencias {
  Preferencias(this.nombre) {
    print('Se crea $nombre');
  }

  final String nombre;
}

class ServicioPreferencias {
  static final _actuales = Preferencias('global');

  static String get nombre => _actuales.nombre;
}

void main() {
  print('Empieza main');
  final local = Preferencias('local');
  print('Usamos ${local.nombre}');
  print('Antes del primer acceso');
  print(ServicioPreferencias.nombre);
  print(ServicioPreferencias.nombre);
}
```

La salida es:

```text
Empieza main
Se crea local
Usamos local
Antes del primer acceso
Se crea global
global
global
```

Paso a paso:

1. Al empezar `main` todavía no se ha creado `global`: definir la clase con un campo estático no ejecuta su inicializador.
2. Crear `Preferencias('local')` y usar esa misma clase tampoco lo ejecuta. El campo pertenece a `ServicioPreferencias`, a la que todavía nadie ha accedido.
3. La primera lectura de `ServicioPreferencias.nombre` necesita `_actuales`. En ese momento se crea `global`.
4. La segunda lectura reutiliza el objeto ya guardado: el mensaje `Se crea global` no se repite.

Ya conoces otros momentos de inicialización. Conviene compararlos:

| Declaración                            | Cuándo se inicializa              | Cuántos valores hay |
|----------------------------------------|-----------------------------------|---------------------|
| Campo `final` de instancia (unidad 15) | Al construir cada instancia       | Uno por instancia   |
| `late final` de instancia (unidad 16)  | Al primer acceso en esa instancia | Uno por instancia   |
| `static final`                         | Al primer acceso a ese campo      | Uno para la clase   |

Observa también que `static final _actuales = ...` no escribe un tipo. Dart lo **infiere** del inicializador: su tipo es `Preferencias`. Y `final` impide reasignar el campo, no modificar el objeto: `_actuales.tema = 'oscuro'` sería válido en la versión del apartado 3, como estudiamos en la unidad 8.

«Uno para la clase» vale para todo el programa mientras se ejecuta en un mismo *isolate*, la unidad de ejecución de Dart que conserva su propia memoria. Los ejemplos de esta guía solo usan uno.

### Practica 4

Si borramos las dos últimas líneas de `main`, ¿aparece `Se crea global` en algún momento? ¿Y si las sustituimos por una sola lectura colocada al principio de `main`?

<details>
<summary>Ver respuesta</summary>

Sin esas líneas, nadie accede a `_actuales` y `Se crea global` no aparece nunca. Con la lectura como primera instrucción, ese mensaje se imprime antes de `Empieza main`: lo decide el primer acceso, no la posición de la clase en el archivo.

</details>

## 5. `abstract final class`: una clase sin instancias

`ServicioPreferencias` solo tiene miembros estáticos, pero nada impide escribir `ServicioPreferencias()` y crear un objeto sin utilidad. DaisyUI lo evita con dos palabras:

```dart
abstract final class DaisyThemeService {
  // ...
}
```

Es un fragmento de la declaración real. Cada palabra impone una restricción distinta:

- `abstract` impide crear instancias directamente: `DaisyThemeService()` no compila.
- `final`, que viste en `final class DaisyThemeController` en la unidad 15, impide que otra biblioteca herede de la clase o la implemente.

Juntas expresan el propósito: esta clase existe solo como **espacio de nombres** para sus miembros estáticos. Este **fragmento** usa el paquete desde otro archivo, por ejemplo una prueba, y no compila; los comentarios recogen lo que indica el analizador:

```dart
class Mio extends DaisyThemeService {}
// The class 'DaisyThemeService' can't be extended outside of its library because it's a final class.

class Otro implements DaisyThemeService {}
// The class 'DaisyThemeService' can't be implemented outside of its library because it's a final class.

// Dentro de cualquier función:
DaisyThemeService(); // Abstract classes can't be instantiated.
```

La restricción de `final` se refiere a otras **bibliotecas**. Si pruebas con un único archivo en DartPad, todo pertenece a la misma biblioteca y el `extends` compila; necesitas dos archivos para ver el error.

En Dart no es obligatorio usar una clase para esto. Unas funciones y variables de nivel superior podrían hacer el mismo trabajo, y la guía [Effective Dart](https://dart.dev/effective-dart/design#avoid-defining-a-class-that-contains-only-static-members) recomienda evitar por norma general las clases con solo miembros estáticos. Aquí la clase agrupa las operaciones bajo un nombre que se lee bien en cada llamada: `DaisyThemeService.setTheme`. Es una decisión de diseño de este paquete, no una obligación del lenguaje.

### Practica 5

¿Qué palabra impide `DaisyThemeService()` y cuál impide `class Mio extends DaisyThemeService {}` en una aplicación que usa el paquete? ¿Impiden esas palabras llamar a `DaisyThemeService.setTheme`?

<details>
<summary>Ver respuesta</summary>

`abstract` impide crear la instancia y `final` impide heredar desde otra biblioteca. Ninguna impide usar los miembros estáticos públicos: se llaman con el nombre de la clase y no necesitan un objeto.

</details>

## 6. El servicio real de DaisyUI

Este es el [servicio de temas](../../../lib/themes/application/daisy_theme_service.dart), sin los imports:

```dart
abstract final class DaisyThemeService {
  static final _controller = DaisyThemeController();

  static ValueListenable<DaisyThemeModel> get theme => _controller.theme;

  static void setTheme(DaisyThemeModel theme) {
    _controller.setTheme(theme);
  }
}
```

Tiene la misma forma que nuestra fachada. Sigamos qué ocurre al llamar a `DaisyThemeService.setTheme(DaisyThemes.dark)` por primera vez en un programa:

1. El método accede a `_controller`. Como es el primer acceso, se ejecuta `DaisyThemeController()`, sin argumentos: su tema inicial es `DaisyThemes.light` y crea su `FlutterSignal` privada `_palette`.
2. El servicio delega: `_controller.setTheme(theme)`.
3. El controlador escribe `_palette.value = theme`. La señal compara con `==`, como vimos en la unidad 9, y si el valor es distinto lo guarda y avisa a sus observadores.

Y al leer `DaisyThemeService.theme` el recorrido es:

1. El getter estático devuelve `_controller.theme`.
2. El controlador devuelve su adaptador `_ThemeListenable`, creado una sola vez gracias a `late final` (unidad 16).
3. Como solo hay un `_controller` y solo un adaptador por controlador, todas las lecturas obtienen **el mismo objeto**.

El servicio no guarda ningún tema: es la señal de su controlador oculto quien lo conserva. `_controller` empieza por `_`, de modo que otra biblioteca no puede obtener ese controlador; solo llega a `theme` y a `setTheme`.

**Antes de mirar los `expect`**, predice si las dos referencias son el mismo objeto y qué guarda el listener:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dos lecturas del servicio llegan al mismo objeto', () {
    addTearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));
    final primera = DaisyThemeService.theme;
    final segunda = DaisyThemeService.theme;
    final avisos = <String>[];
    void escuchar() => avisos.add(segunda.value.name);

    primera.addListener(escuchar);
    DaisyThemeService.setTheme(DaisyThemes.dark);
    primera.removeListener(escuchar);

    expect(identical(primera, segunda), isTrue);
    expect(primera.value.name, 'Dark');
    expect(avisos, ['Dark']);
  });
}
```

El listener se registra mediante una referencia y lee mediante la otra, pero ambas son el mismo adaptador sobre la misma señal. Por eso recibe el aviso y lee `Dark`. `addTearDown` restablece el tema al terminar por un motivo que veremos en el siguiente apartado. La prueba comprueba objetos y avisos, no una reconstrucción de widgets.

### Quién libera el controlador del servicio

Fíjate en lo que **no** aparece: el servicio no tiene `dispose`. Nadie fuera de la clase puede liberar su controlador. Según la [unidad 13](13-propiedad-de-los-recursos-y-dispose.md), el propietario es quien decide cuándo termina la vida de un recurso. Aquí el propietario es el propio servicio, y no decide terminarla: el controlador dura mientras se ejecuta el programa.

Es una decisión coherente con una fuente global. Cualquier consumidor puede depender de ella en cualquier momento, y un controlador liberado rechaza escrituras (`setTheme` lanza `SignalsWriteAfterDisposeError`). Si un consumidor pudiera liberarlo, rompería a todos los demás. El consumidor del servicio solo responde de **sus listeners**: retirar los que registró sigue siendo tarea suya. La consecuencia es que el servicio conserva su valor hasta el final del programa, y eso incluye cualquier prueba que siga en el mismo archivo.

### Practica 6

Una pantalla registra un listener en `DaisyThemeService.theme` y luego se cierra. ¿Qué debe hacer ella y qué no puede ni debe hacer? ¿Qué ocurre con el tema seleccionado?

<details>
<summary>Ver respuesta</summary>

Debe retirar su listener con `removeListener` y la misma función que registró. No puede liberar el controlador: el servicio no expone esa operación ni el controlador. El tema seleccionado se conserva, porque vive en la señal del controlador estático y no en la pantalla.

</details>

## 7. Los tres valores y el estado que sobrevive

Ya podemos resolver la pregunta central. Tenemos el servicio y dos controladores propios: `primero`, sin argumentos, y `segundo`, que empieza en `cupcake`. Cambiaremos **solo** el servicio y después **solo** `primero`.

**Antes de mirar los `expect`**, escribe los tres nombres tras cada cambio:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('servicio y dos controladores propios', () {
    addTearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));
    final primero = DaisyThemeController();
    final segundo = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    addTearDown(primero.dispose);
    addTearDown(segundo.dispose);
    final consumidorA = DaisyThemeService.theme;
    final consumidorB = DaisyThemeService.theme;

    DaisyThemeService.setTheme(DaisyThemes.dark);
    expect(consumidorA.value.name, 'Dark');
    expect(consumidorB.value.name, 'Dark');
    expect(primero.theme.value.name, 'Light');
    expect(segundo.theme.value.name, 'Cupcake');

    primero.setTheme(DaisyThemes.cupcake);
    expect(consumidorA.value.name, 'Dark');
    expect(primero.theme.value.name, 'Cupcake');
    expect(segundo.theme.value.name, 'Cupcake');
  });
}
```

Después del primer cambio, los dos consumidores del servicio ven `Dark`: comparten una señal. `primero` conserva `Light` porque tiene otra, aunque se haya creado con el mismo constructor que el controlador oculto del servicio. Y al cambiar `primero` a `cupcake`, coincide con `segundo` en el **valor**, pero siguen siendo dos fuentes: cambiar una no toca la otra. Igual valor no significa misma fuente.

El test libera sus dos controladores, de los que es propietario. El del servicio no se libera, por lo explicado en el apartado 6. Pero sí restablece su tema, y ahora veremos por qué.

### El estado global sobrevive entre pruebas

Cada `test` debería poder ejecutarse sin depender de los demás. Un controlador creado dentro de una prueba cumple esto por sí solo, porque desaparece con ella. El servicio no: `flutter test` ejecuta cada archivo por separado, pero las pruebas de un mismo archivo comparten su estado estático. Esta prueba muestra el problema:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la primera prueba cambia el servicio', () {
    expect(DaisyThemeService.theme.value.name, 'Light');
    DaisyThemeService.setTheme(DaisyThemes.dark);
  });

  test('la segunda hereda el cambio', () {
    expect(DaisyThemeService.theme.value.name, 'Dark');
  });
}
```

Ambas pasan, pero fíjate en lo que afirma la segunda: el tema es `Dark` aunque ella no lo haya cambiado. Si la ejecutas sola, falla, porque la primera no ha llegado a ejecutarse y el servicio aún está en `Light`:

```shell
flutter test --no-pub test/estudio_servicio_test.dart --plain-name "la segunda hereda el cambio"
```

Esa prueba depende del orden. Para evitarlo se usan dos funciones de `flutter_test`, que registran código que se ejecuta alrededor de **cada** `test`:

- `setUp` antes de cada prueba;
- `tearDown` después de cada prueba, aunque falle una comprobación.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  test('una prueba cambia el servicio', () {
    DaisyThemeService.setTheme(DaisyThemes.dark);
    expect(DaisyThemeService.theme.value.name, 'Dark');
  });

  test('otra prueba empieza con el tema claro', () {
    expect(DaisyThemeService.theme.value.name, 'Light');
  });
}
```

Ahora cada prueba parte de `Light`, sea cual sea el orden. Estas dos líneas son las mismas que aparecen al principio de [las pruebas del controlador](../../../test/themes/daisy_theme_controller_test.dart) y de [las del scope](../../../test/themes/daisy_theme_scope_test.dart). No liberan el controlador del servicio; solo devuelven su señal a un valor conocido. Una instancia propia no necesitaría este cuidado, y esa es una de las diferencias reales entre ambas opciones. `addTearDown`, usado en otros ejemplos, registra la limpieza desde dentro de una prueba concreta.

### Practica 7

En la prueba de los tres valores, añadimos `DaisyThemeService.setTheme(DaisyThemes.light)` al final. ¿Qué valores leen `consumidorA`, `primero` y `segundo`? ¿Y si en lugar de eso quitamos el `addTearDown` del servicio y añadimos a continuación otra prueba que espera `Light` en el servicio sin `setUp`?

<details>
<summary>Ver respuesta</summary>

Leen `Light`, `Cupcake` y `Cupcake`: el cambio solo afecta a la señal del servicio. En el segundo caso, la nueva prueba encontraría `Dark` y fallaría, porque el campo estático conserva el cambio de la prueba anterior. Ese fallo no señalaría un error en la nueva prueba, sino una limpieza omitida en otra.

</details>

## 8. ¿Compartir o crear una instancia?

La versión del ejemplo anterior al commit `41fe41f` usaba las dos opciones a la vez. Puedes consultarla con `git show 41fe41f~1:example/lib/main.dart`, y está reproducida en el [apartado 8 de la unidad 25](25-scopes-anidados-e-independencia.md#8-el-ejemplo-anterior-completo). Estos son **fragmentos** de ese archivo:

```dart
// MyApp: un scope sin controlador usa el servicio.
return DaisyThemeScope(child: const MaterialApp(home: _ThemeExample()));

// _ThemeExample: el botón cambia el tema de toda la aplicación.
onPressed: () => DaisyThemeService.setTheme(/* ... */),

// _ThemePreviewState: la vista previa crea, usa y libera el suyo.
_controller = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
```

El [ejemplo actual](../../../example/lib/main.dart) solo conserva la primera: `MyApp` monta un scope sin controlador, con lo que usa el servicio. La vista previa sigue siendo un buen caso para comparar.

La aplicación tiene un solo tema general, que muchas partes consultan y que dura tanto como ella: encaja con el servicio. La vista previa quiere probar un tema sin alterar el resto y solo vive mientras está en pantalla: encaja con una instancia propia, de la que es propietaria. La línea `controller?.theme ?? DaisyThemeService.theme` del constructor del scope hace esta elección; `??` y sus ramas se estudian en la unidad 23.

Cambiar el servicio actualiza a los consumidores de la aplicación y no a los de la vista previa; cambiar la vista previa no altera la aplicación. La prueba `Nested scopes update only their own theme consumers` de [las pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart) lo comprueba con tres niveles y cuenta las reconstrucciones. Cómo encuentra cada consumidor su scope se explica en las unidades 20–25; los scopes anidados, en la 25.

Para decidir entre las dos opciones, hazte estas preguntas:

- **Alcance.** ¿El dato es realmente uno solo para todo el programa? Si dos partes pueden necesitar valores distintos, necesitas instancias.
- **Vida útil.** ¿Debe durar hasta el final del programa, o terminar con una pantalla? Una instancia puede tener un propietario que la libere; el servicio no tiene `dispose`.
- **Pruebas.** Una instancia nace limpia en cada prueba. El estado global obliga a restablecerlo y puede crear dependencias de orden, como en el apartado 7.
- **Dependencias visibles.** Una función que recibe un controlador declara lo que usa. Una que llama a `DaisyThemeService` depende de él sin que su firma lo diga.

Compartir tampoco exige un servicio global. Si dos consumidores reciben **la misma instancia** de un controlador, comparten su estado, y un tercero con otro controlador queda fuera. El servicio es una forma de compartir disponible en todo el programa; pasar una referencia es otra, con un alcance que tú decides.

### Practica 8

Decide en cada caso entre el servicio, una instancia independiente o una instancia compartida entre dos consumidores, y justifícalo: (a) el tema general de una aplicación con un solo tema; (b) un panel de diseño que prueba temas y se cierra; (c) dos pestañas de ese panel que deben mostrar el mismo tema de prueba, sin afectar a la aplicación.

<details>
<summary>Ver respuesta</summary>

(a) El servicio encaja: hay un solo dato, dura todo el programa y lo usan muchas partes. (b) Una instancia independiente: no debe alterar el resto y su propietario la libera al cerrar. (c) Una instancia compartida: el panel crea un controlador y lo entrega a las dos pestañas; comparten estado entre ellas sin tocar el servicio, y el panel sigue siendo el propietario. Son decisiones razonadas para estos casos, no reglas absolutas: una aplicación con requisitos distintos podría no usar el servicio en absoluto.

</details>

## Ejercicio final: un servicio de borde

Escribe una prueba que reúna las ideas de la unidad:

1. Declara `final class ControladorBorde` con una `FlutterSignal<int>` privada, un parámetro nombrado `inicial` que valga `1` por defecto, un getter `borde` de tipo `ValueListenable<int>`, un método `cambiar` y un método `dispose`.
2. Añade un campo `static int creados = 0` que el constructor incremente.
3. Declara `abstract final class ServicioBorde` con un campo estático privado `_controlador`, un getter estático `borde` y un método estático `cambiar`, que deleguen.
4. En la prueba comprueba `creados` en cuatro momentos: al empezar, tras crear un controlador local con `inicial: 3`, tras la primera lectura de `ServicioBorde.borde` y tras una segunda lectura.
5. Registra un listener en una lectura del servicio. Cambia el servicio a `2` usando `ServicioBorde.cambiar` y comprueba el aviso desde otra lectura. Cambia después el local a `5`. Predice los dos valores y los avisos.
6. Retira el listener y libera lo que sea tuyo.

Predice todo antes de abrir la solución. Como variaciones, ¿qué valor de `creados` obtendrías si borras la lectura del paso 4 y cambias primero el servicio? ¿Qué ocurriría con `ServicioBorde.borde.value` si añades después una segunda prueba al archivo?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

final class ControladorBorde {
  ControladorBorde({int inicial = 1}) : _borde = FlutterSignal<int>(inicial) {
    creados = creados + 1;
  }

  static int creados = 0;

  final FlutterSignal<int> _borde;

  ValueListenable<int> get borde => _borde;

  void cambiar(int nuevo) => _borde.value = nuevo;

  void dispose() => _borde.dispose();
}

abstract final class ServicioBorde {
  static final _controlador = ControladorBorde();

  static ValueListenable<int> get borde => _controlador.borde;

  static void cambiar(int nuevo) {
    _controlador.cambiar(nuevo);
  }
}

void main() {
  test('servicio de borde y controlador local', () {
    expect(ControladorBorde.creados, 0);

    final local = ControladorBorde(inicial: 3);
    addTearDown(local.dispose);
    expect(ControladorBorde.creados, 1);

    final lectura = ServicioBorde.borde;
    expect(ControladorBorde.creados, 2);
    expect(identical(ServicioBorde.borde, lectura), isTrue);
    expect(ControladorBorde.creados, 2);

    final avisos = <int>[];
    void escuchar() => avisos.add(lectura.value);
    lectura.addListener(escuchar);

    ServicioBorde.cambiar(2);
    expect(ServicioBorde.borde.value, 2);
    expect(local.borde.value, 3);
    expect(avisos, [2]);

    local.cambiar(5);
    expect(ServicioBorde.borde.value, 2);
    expect(local.borde.value, 5);
    expect(avisos, [2]);

    lectura.removeListener(escuchar);
  });
}
```

Al empezar no hay ningún controlador: `creados` es `0`, y existe porque es un campo estático, sin necesidad de un objeto. Crear el local lo pone en `1`. Definir `ServicioBorde` no había creado nada; su primera lectura inicializa `_controlador` y `creados` pasa a `2`. La segunda lectura reutiliza ese objeto.

Cambiar el servicio a `2` avisa al listener y no afecta al local, que conserva `3`. Cambiar el local a `5` no avisa al listener, porque está registrado en la señal del servicio. El test retira su listener y libera `local`, que creó; no puede liberar el controlador del servicio, porque `ServicioBorde` no ofrece esa operación.

En este ejemplo, `borde` devuelve la propia señal con tipo `ValueListenable<int>`, por lo que un cast podría recuperar el setter. DaisyUI usa además el adaptador de la unidad 16.

En la primera variación, `creados` también pasa a `2`, porque cambiar es otro acceso a `_controlador`: lo que importa es el primer acceso, sea una lectura o una escritura. En la segunda, una prueba posterior encontraría `2` en el servicio: el estado estático sobrevive dentro del archivo, y `creados` tampoco volvería a `0`. Haría falta `setUp` para restablecer el borde.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Por qué `local` y `visitante` pueden tener puntos distintos con el mismo método `sumar`? **Apartado 1.**
2. ¿A quién pertenece un miembro `static`, cómo se accede a él y por qué no dispone de `this`? **Apartado 2.**
3. ¿Qué hace una fachada estática y qué dependencia queda oculta en la firma de quien la usa? **Apartado 3.**
4. ¿Cuándo se ejecuta el inicializador de `static final _actuales` y cuántas veces? **Apartado 4.**
5. ¿Qué diferencia hay entre un campo `final`, uno `late final` y uno `static final`? **Apartado 4.**
6. ¿Qué restricción aporta cada palabra de `abstract final class`? **Apartado 5.**
7. ¿Qué ocurre, en orden, desde `DaisyThemeService.setTheme(...)` hasta la señal? **Apartado 6.**
8. ¿Dónde se guarda el tema del servicio y por qué dos lecturas de `theme` son el mismo objeto? **Apartado 6.**
9. ¿Por qué el servicio no tiene `dispose` y qué sigue siendo responsabilidad de un consumidor? **Apartado 6.**
10. Tras cambiar solo el servicio, ¿qué leen sus dos consumidores y dos controladores propios? **Apartado 7.**
11. ¿Por qué las pruebas del proyecto usan `setUp` y `tearDown` para el servicio? **Apartado 7.**
12. ¿Qué criterios usarías para elegir entre el servicio, una instancia propia o una instancia compartida? **Apartado 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y justifiques, para un caso nuevo, si compartes estado o creas una instancia independiente. Con esto termina el Bloque 4. El Bloque 5 empieza en la unidad 18, que estudia widgets, elementos, estado y reconstrucción: cómo llega por fin el estado a la interfaz.

## Para consultar si necesitas reforzar

- [Modificadores de clase](https://dart.dev/language/class-modifiers): `abstract`, `final` y sus restricciones.
- [Miembros estáticos](https://dart.dev/language/classes#class-variables-and-methods): variables y métodos de clase.
- [Variables en Dart](https://dart.dev/language/variables#late-variables): inicialización diferida y `late`.
- [Effective Dart: clases con solo miembros estáticos](https://dart.dev/effective-dart/design#avoid-defining-a-class-that-contains-only-static-members): la recomendación general y sus alternativas.
- [`setUp`](https://api.flutter.dev/flutter/flutter_test/setUp.html), [`tearDown`](https://api.flutter.dev/flutter/flutter_test/tearDown.html) y [`addTearDown`](https://api.flutter.dev/flutter/flutter_test/addTearDown.html): preparación y limpieza de pruebas.
- [Servicio](../../../lib/themes/application/daisy_theme_service.dart), [controlador](../../../lib/themes/application/daisy_theme_controller.dart), [ejemplo](../../../example/lib/main.dart) y [pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart): comportamiento actual de DaisyUI; el ejemplo ya no incluye la vista previa.
