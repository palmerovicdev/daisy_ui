# 15. Construcción del controlador y sintaxis de Dart

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 14](14-el-concepto-de-controller.md) · **Estado:** pendiente

## Qué vas a aprender

En la unidad 14 vimos qué responsabilidad tiene `DaisyThemeController`. Ahora vamos a leer la línea que lo crea:

```dart
DaisyThemeController({
  DaisyThemeModel initialTheme = DaisyThemes.light,
}) : _palette = FlutterSignal<DaisyThemeModel>(initialTheme);
```

Es un fragmento del [controlador real](../../../lib/themes/application/daisy_theme_controller.dart), no un programa
completo. En pocas líneas aparecen llaves, un valor predeterminado, dos puntos y un campo que recibe un objeto nuevo.
¿Qué ocurre exactamente al escribir `DaisyThemeController()`? ¿Cuántos objetos existen después? ¿Por qué aparece
`_palette` después de `:` y no dentro de unas llaves?

Al terminar podrás explicar cada parte de ese constructor y de los otros dos que usa el proyecto: reconocerás parámetros
nombrados, `required`, valores predeterminados, listas de inicialización, `this.campo`, reenvío con `super`, nombres
privados con `_` y la diferencia entre un campo `final` y una `final class`. También podrás contar qué objetos y qué
referencias existen tras crear uno o varios controladores.

Los programas de consola de los apartados 1–6 solo usan Dart: puedes copiarlos en [DartPad](https://dartpad.dev/),
elegir **Dart** y pulsar **Run**. Predice la salida antes de ejecutar. Los errores de compilación aparecen en fragmentos
identificados como tales; sus mensajes se contrastaron con Dart 3.13.7 y el texto puede variar en otras versiones. La
prueba del apartado 8 usa el paquete real: cópiala a `test/estudio_constructor_test.dart` y ejecuta desde la raíz:

```shell
flutter test --no-pub test/estudio_constructor_test.dart
```

Necesitas las dependencias ya resueltas del proyecto. Puedes estudiar los apartados 1–3 en una sesión, 4–5 en otra,
6–7 en una tercera y terminar con DaisyUI y el ejercicio final.

## 1. Un constructor crea un objeto en cada llamada

En la unidad 3 escribimos clases como `SeleccionTema` con un constructor breve. Un **constructor** es el código que se
ejecuta para preparar un objeto nuevo. Vamos a añadirle un `print` para ver cuándo ocurre:

```dart
class Selector {
  Selector(this.tema) {
    print('Se crea un selector con $tema');
  }

  String tema;
}

void main() {
  final primero = Selector('claro');
  final segundo = Selector('claro');
  final otraReferencia = primero;

  primero.tema = 'oscuro';

  print(primero.tema);
  print(segundo.tema);
  print(otraReferencia.tema);
  print(identical(primero, segundo));
  print(identical(primero, otraReferencia));
}
```

La salida es:

```text
Se crea un selector con claro
Se crea un selector con claro
oscuro
claro
oscuro
false
true
```

Paso a paso:

1. `Selector('claro')` llama al constructor. Se reserva un objeto, se guarda `'claro'` en su campo `tema` y se ejecuta
   el cuerpo, que es lo que va entre `{` y `}`. Por eso aparece la primera línea.
2. La segunda llamada repite todo el proceso y produce **otro** objeto, aunque reciba el mismo texto.
3. `final otraReferencia = primero` no llama a ningún constructor: no se imprime nada. Solo hay otra variable que apunta
   al primer objeto.
4. Al cambiar `primero.tema`, `otraReferencia.tema` también devuelve `oscuro`, porque es el mismo objeto. `segundo`
   conserva `claro`, y los dos `identical` lo confirman.

Hay **dos objetos** `Selector` y **tres referencias**. Esta forma de contar es la que aplicaremos al controlador real.

### Practica 1

Si añadimos `final tercero = segundo;` al final de `main`, ¿cuántas veces más aparece `Se crea un selector`? ¿Cuántos
objetos y cuántas referencias hay ahora?

<details>
<summary>Ver respuesta</summary>

No aparece más veces, porque esa línea no llama al constructor. Siguen existiendo dos objetos y ahora hay cuatro
referencias. Cada objeto nuevo necesita una llamada a un constructor; copiar una referencia no crea otro objeto.

</details>

## 2. Parámetros nombrados, `required` y valores predeterminados

Cuando una llamada recibe varios datos, `Selector('claro', 'app', true)` obliga a recordar qué significa cada posición.
Los **parámetros nombrados** se declaran entre llaves y se entregan indicando su nombre. La sintaxis es la misma en
funciones y en constructores, así que la probaremos primero con una función:

```dart
String describir({
  required String nombre,
  String tema = 'claro',
  String? nota,
}) {
  final extra = nota == null ? '' : ' ($nota)';
  return '$nombre usa $tema$extra';
}

void main() {
  print(describir(nombre: 'Ana'));
  print(describir(tema: 'oscuro', nombre: 'Eva'));
  print(describir(nombre: 'Luz', nota: 'vista previa'));
}
```

La salida es:

```text
Ana usa claro
Eva usa oscuro
Luz usa claro (vista previa)
```

Las llaves declaran tres parámetros nombrados, cada uno con una regla distinta:

- `required String nombre` es obligatorio. Omitirlo es un error de compilación.
- `String tema = 'claro'` tiene un **valor predeterminado**: si la llamada no lo entrega, vale `'claro'`.
- `String? nota` es opcional y su tipo admite `null`. El `?` indica que la variable puede no contener un texto; si no se
  entrega, vale `null`. La unidad 23 estudia la nulabilidad con detalle; aquí la expresión `nota == null ? '' : ...`
  comprueba ese caso con la condición que ya conocemos.

La segunda llamada muestra que los argumentos nombrados pueden escribirse en cualquier orden. Un parámetro nombrado sin
`required`, sin valor predeterminado y con un tipo que no admite `null` no compila, porque no tendría ningún valor
válido. Estos dos **fragmentos** son incorrectos a propósito:

```dart
String sinValor({String tema}) => tema;
// Error: The parameter 'tema' can't have a value of 'null' because of its type 'String',
// but the implicit default value is 'null'.

final resultado = describir(tema: 'oscuro');
// Error: Required named parameter 'nombre' must be provided.
```

El valor predeterminado debe ser una **constante**, algo que se conoce al compilar. Una variable `final` corriente no
sirve, aunque nunca cambie:

```dart
final preferido = 'claro' + obtenerSufijo();

String conVariable({String tema = preferido}) => tema;
// Error: Not a constant expression.
```

Volvamos al constructor real: `{DaisyThemeModel initialTheme = DaisyThemes.light}` declara un parámetro nombrado
opcional. Es válido porque en [daisy_themes.dart](../../../lib/themes/domain/daisy_themes.dart) el tema se declara como
`static const DaisyThemeModel light`, es decir, como una constante. Por eso se admiten estas dos formas:

```dart
DaisyThemeController();
DaisyThemeController(initialTheme: DaisyThemes.dark);
```

Es un fragmento. En la primera llamada `initialTheme` referencia `DaisyThemes.light`; en la segunda, `DaisyThemes.dark`.

### Practica 2

¿Qué imprime `print(describir(nota: 'prueba', nombre: 'Noa', tema: 'bosque'));`? ¿Qué ocurre con
`describir(nota: 'prueba')`?

<details>
<summary>Ver respuesta</summary>

Imprime `Noa usa bosque (prueba)`: el orden de los argumentos nombrados no importa. La segunda llamada no compila,
porque falta `nombre`, que es `required`. El compilador detecta el problema antes de que el programa empiece a
ejecutarse.

</details>

## 3. Campos `final` y lista de inicialización

Un campo `final` recibe un valor una sola vez. Parece natural asignarlo dentro del cuerpo, pero este **fragmento** no
compila:

```dart
class Selector {
  Selector(String inicial) {
    _tema = inicial;
  }

  final String _tema;
}
// Error: Final field '_tema' is not initialized.
// Error: The setter '_tema' isn't defined for the type 'Selector'.
```

Cuando empieza el cuerpo, Dart exige que los campos `final` ya tengan valor; dentro del cuerpo solo se podría estar
reasignando. La **lista de inicialización** es el lugar previsto para darles ese primer valor. Se escribe después de `:`
y se ejecuta antes del cuerpo. Vamos a comprobar el orden:

```dart
String registrar(String valor) {
  print('Lista de inicialización: $valor');
  return valor;
}

class Selector {
  Selector({String inicial = 'claro'}) : _tema = registrar(inicial) {
    print('Cuerpo: el campo ya vale $_tema');
  }

  final String _tema;

  String get tema => _tema;
}

void main() {
  final selector = Selector();
  print('Objeto creado: ${selector.tema}');
}
```

La salida es:

```text
Lista de inicialización: claro
Cuerpo: el campo ya vale claro
Objeto creado: claro
```

1. `Selector()` no entrega argumentos, así que `inicial` vale `'claro'`.
2. Se ejecuta la parte posterior a `:`. Se llama a `registrar` y el resultado se guarda en `_tema`.
3. Con el campo ya preparado, se ejecuta el cuerpo, que puede leer `_tema`.
4. El constructor termina y `selector` recibe la referencia al objeto.

La lista de inicialización tiene un límite: **no puede leer el objeto que se está construyendo**, porque todavía está a
medias. Puede usar los parámetros, pero no otros campos. Este **fragmento** no compila, y un inicializador escrito junto
a la declaración del campo tiene la misma restricción:

```dart
class Selector {
  Selector(String inicial) : _tema = inicial, _copia = _tema;

  final String _tema;
  final String _copia;
}
// Error: Can't access 'this' in a field initializer to read '_tema'.
```

Ya podemos leer el constructor del controlador:

```dart
DaisyThemeController({
  DaisyThemeModel initialTheme = DaisyThemes.light,
}) : _palette = FlutterSignal<DaisyThemeModel>(initialTheme);

final FlutterSignal<DaisyThemeModel> _palette;
```

Es un fragmento de la clase real. Después de `:` se crea una señal con el parámetro `initialTheme` y se guarda en
`_palette`. Solo usa un parámetro, de modo que no necesita leer el objeto en construcción. El constructor termina en
`;`: no tiene cuerpo porque no hay nada más que hacer.

En la unidad 9 creábamos señales con la función `signal<T>(valor)`. Aquí se llama directamente al constructor de la
clase, `FlutterSignal<T>(valor)`. En `signals_flutter` 7.1.0 esa función devuelve `FlutterSignal<T>(value, ...)`, así
que ambos caminos producen una `FlutterSignal`.

`final` impide cambiar **a qué objeto apunta** `_palette`, no el valor que contiene la señal: como vimos en la unidad 8,
una referencia `final` no vuelve inmutable al objeto. Por eso `setTheme` puede asignar `_palette.value`.

### Un campo que sí necesita a otro

La clase real contiene también esta declaración:

```dart
late final ValueListenable<DaisyThemeModel> _theme = _ThemeListenable(
  _palette,
);
```

Este fragmento lee `_palette` para crear otro objeto, algo que acabamos de ver que no se permite sin más. `late` cambia
el momento: el inicializador no se ejecuta durante la construcción, sino la primera vez que alguien lee `_theme`. Para
entonces el objeto está completo y `_palette` ya tiene valor, así que el acceso es válido. La unidad 16 estudia esta
inicialización diferida y el objeto que crea; aquí basta con reconocer por qué esa línea compila.

### Practica 3

Si en el último programa cambiamos la creación por `final selector = Selector(inicial: 'oscuro');`, ¿qué tres líneas se
imprimen? ¿Podría `_tema` asignarse dentro del cuerpo si quitamos la lista de inicialización?

<details>
<summary>Ver respuesta</summary>

Se imprimen `Lista de inicialización: oscuro`, `Cuerpo: el campo ya vale oscuro` y `Objeto creado: oscuro`. No se podría
asignar en el cuerpo: un campo `final` sin `late` debe tener valor antes de que el cuerpo empiece.

</details>

## 4. `this.campo`: guardar un parámetro directamente

Muchas veces un constructor solo guarda lo que recibe. Con lo aprendido, podríamos escribirlo con una lista de
inicialización. `this.campo` es la forma abreviada que ya usamos en la unidad 3. Comparemos ambas en una vista que
consulta otra fuente:

```dart
class Fuente {
  Fuente(this.tema);

  String tema;
}

class VistaCorta {
  VistaCorta(this._fuente);

  final Fuente _fuente;

  String get tema => _fuente.tema;
}

class VistaLarga {
  VistaLarga(Fuente fuente) : _fuente = fuente;

  final Fuente _fuente;

  String get tema => _fuente.tema;
}

void main() {
  final fuente = Fuente('claro');
  final corta = VistaCorta(fuente);
  final larga = VistaLarga(fuente);

  fuente.tema = 'oscuro';

  print(corta.tema);
  print(larga.tema);
}
```

La salida es:

```text
oscuro
oscuro
```

`VistaCorta(this._fuente)` declara un parámetro y lo guarda en el campo del mismo nombre, antes del cuerpo. El tipo sale
de la declaración del campo. `VistaLarga` escribe lo mismo por extenso. Ninguna copia el objeto `Fuente`: ambas guardan
una referencia. Por eso, al cambiar la fuente, las dos vistas leen `oscuro`.

En el controlador real aparece exactamente esta forma:

```dart
final class _ThemeListenable implements ValueListenable<DaisyThemeModel> {
  _ThemeListenable(this._source);

  final FlutterSignal<DaisyThemeModel> _source;
```

Es un fragmento. El parámetro recibe la señal y la guarda en `_source`; `_ThemeListenable` no crea otra señal. La unidad
16 estudia para qué sirve esta clase.

También se puede usar `this.campo` en un parámetro nombrado. Con un campo privado hay un matiz, porque quien llama desde
otro archivo no debería depender de un nombre privado. En la versión de Dart de este proyecto, el parámetro se declara
con `_` y se entrega sin él:

```dart
class Vista {
  Vista({required this._fuente});

  final Fuente _fuente;
}

final vista = Vista(fuente: Fuente('claro'));
```

Es un fragmento. `Vista(_fuente: ...)` no compila: `No named parameter with the name '_fuente'`. Esta posibilidad
depende de la versión del lenguaje: en un archivo fijado a Dart 3.10, la declaración se rechaza porque esa
característica no está activada. `_ThemeListenable` no la necesita, porque su único parámetro es posicional.

### Practica 4

Reescribe el constructor de `_ThemeListenable` sin usar `this._source`, conservando su comportamiento.

<details>
<summary>Ver respuesta</summary>

```dart
_ThemeListenable(FlutterSignal<DaisyThemeModel> source) : _source = source;
```

Es un fragmento. El parámetro se llama `source` y la lista de inicialización guarda esa referencia en `_source`. Hace lo
mismo que la forma abreviada: el campo apunta a la señal recibida y no se crea ninguna señal nueva.

</details>

## 5. `super`: entregar datos a la clase padre

Cuando una clase extiende otra, parte de sus campos pertenece a la clase padre, y es el constructor de esa clase quien
los prepara. El constructor hijo debe entregarle lo que necesita. `super.campo` reenvía un parámetro tal cual;
`super(...)` permite llamar al constructor padre calculando antes lo que se entrega. Este ejemplo usa ambos:

```dart
class Base {
  Base({this.clave, required this.hijo, required this.fuente}) {
    print('Cuerpo de Base: $fuente');
  }

  final String? clave;
  final String hijo;
  final String fuente;
}

class Panel extends Base {
  Panel({super.clave, required super.hijo, String? fuentePropia})
    : super(fuente: fuentePropia == null ? 'global' : fuentePropia) {
    print('Cuerpo de Panel: $hijo');
  }
}

void main() {
  final uno = Panel(hijo: 'texto');
  final dos = Panel(clave: 'vista', hijo: 'botón', fuentePropia: 'local');

  print('${uno.clave} ${uno.fuente}');
  print('${dos.clave} ${dos.fuente}');
}
```

La salida es:

```text
Cuerpo de Base: global
Cuerpo de Panel: texto
Cuerpo de Base: local
Cuerpo de Panel: botón
null global
vista local
```

Sigamos `Panel(hijo: 'texto')`:

1. `super.clave` declara un parámetro que `Panel` no guarda, sino que entrega a `Base`. Aquí no se indicó y queda en
   `null`, porque en `Base` el tipo es `String?`.
2. `required super.hijo` también reenvía, y además obliga a entregarlo. Dentro de `Panel` no hace falta otro campo:
   `hijo` se hereda.
3. `fuentePropia` es un parámetro propio de `Panel`. La lista de inicialización llama a `super(fuente: ...)` y entrega
   `'global'` porque no se recibió ninguno.
4. Se ejecuta primero el cuerpo de `Base` y después el de `Panel`. El objeto padre debe estar preparado antes de que el
   cuerpo del hijo lo utilice.

Hay un solo objeto por cada llamada: `Panel` y `Base` no son dos objetos, sino dos clases que preparan partes del mismo.

Ahora podemos leer el [scope](../../../lib/themes/application/daisy_theme_scope.dart):

```dart
DaisyThemeScope({
  super.key,
  required super.child,
  DaisyThemeController? controller,
}) : super(notifier: controller?.theme ?? DaisyThemeService.theme);
```

Es un fragmento con la misma forma que `Panel`. `super.key` y `required super.child` se reenvían sin cambios a la clase
padre, `InheritedNotifier`. `controller` es un parámetro propio y opcional. Después de `:`, `super(notifier: ...)`
entrega la fuente que debe observar: si hay controlador, su vista `theme`; si no, la del servicio global. Los operadores
`?.` y `??` se estudian en la unidad 23, `InheritedNotifier` en la 22 y el servicio en la 17. Por ahora basta con ver
que el scope no guarda `controller`: lo usa para calcular lo que entrega a su padre.

### Practica 5

En `Panel(clave: 'x', hijo: 'y')`, ¿qué valor recibe cada campo de `Base`? ¿Qué se imprime primero?

<details>
<summary>Ver respuesta</summary>

`clave` recibe `'x'`, `hijo` recibe `'y'` y `fuente` recibe `'global'`, porque no se entregó `fuentePropia`. Primero se
imprime `Cuerpo de Base: global` y después `Cuerpo de Panel: y`: el cuerpo del padre se ejecuta antes que el del hijo.

</details>

## 6. `_`: privado para la biblioteca, no para la clase

Desde la unidad 3 escribimos campos como `_valor`. En otros lenguajes, «privado» significa accesible solo desde la misma
clase. En Dart, un nombre que empieza por `_` es privado para su **biblioteca**, y en general cada archivo es una
biblioteca. Esto tiene una consecuencia que quizá no esperes:

```dart
class Caja {
  Caja(this._secreto);

  final String _secreto;
}

class Inspector {
  String leer(Caja caja) => caja._secreto;
}

void main() {
  final caja = Caja('claro');

  print(Inspector().leer(caja));
  print(caja._secreto);
}
```

La salida es:

```text
claro
claro
```

`Inspector` y `main` no son `Caja`, pero están en el mismo archivo y pueden leer `_secreto`. La frontera es el archivo.
También una clase puede ser privada: `_ThemeListenable` solo puede nombrarse dentro de
[daisy_theme_controller.dart](../../../lib/themes/application/daisy_theme_controller.dart). El controlador la utiliza
porque comparte ese archivo.

Desde otro archivo, en cambio, el nombre no existe. Este **fragmento**, dentro de una prueba, no compila:

```dart
final controller = DaisyThemeController();
print(controller._palette);
// Error: The getter '_palette' isn't defined for the type 'DaisyThemeController'.
```

El mensaje no dice «es privado», sino que no está definido: desde ese archivo no se puede ver. Así, quien usa el paquete
solo puede cambiar el tema mediante `setTheme`.

Hay dos matices. Los archivos unidos con `part`, como los generados de los modelos, forman una sola biblioteca; lo
veremos en la unidad 29. Además, `_` restringe los **nombres**, no la información: desde una prueba,
`controller.theme.runtimeType` imprime `_ThemeListenable`, aunque ese archivo no pueda escribir ese tipo.

### Practica 6

Si movieras la clase `_ThemeListenable` a otro archivo, sin cambiar su nombre, y lo importases desde el controlador,
¿qué línea del controlador dejaría de compilar? ¿Y si `_palette` se usara desde otra clase del mismo archivo?

<details>
<summary>Ver respuesta</summary>

Dejaría de compilar la que crea `_ThemeListenable(_palette)`, porque el nombre es privado de la biblioteca donde se
declara y un `import` no lo hace visible. En cambio, otra clase del mismo archivo sí puede usar `_palette` en un objeto
`DaisyThemeController`, porque comparten biblioteca.

</details>

## 7. `final class` no es lo mismo que un campo `final`

`final` aparece con dos significados según dónde se escriba. En un campo, significa que esa referencia no se reasigna.
En una clase, limita **quién puede construir un subtipo**. `DaisyThemeController` se declara como `final class`, y estos
dos **fragmentos** escritos en otro archivo no compilan:

```dart
class ControladorMio extends DaisyThemeController {}
// Error: The class 'DaisyThemeController' can't be extended outside of its library
// because it's a final class.

class ControladorFalso implements DaisyThemeController {}
// Error: The class 'DaisyThemeController' can't be implemented outside of its library
// because it's a final class.
```

El modificador no impide crear objetos: `DaisyThemeController()` funciona desde cualquier archivo. Tampoco impide que su
estado cambie: `setTheme` sigue cambiando el tema. Lo que garantiza es que un `DaisyThemeController` recibido por una
función es realmente esta implementación, y no una variante escrita fuera que se comporte de otra forma. La
contrapartida es que una prueba no puede sustituirlo por una implementación falsa: utiliza el controlador real, como
haremos en el apartado siguiente.

Dentro de la misma biblioteca sí se puede extender, pero la subclase debe declararse también de forma restringida:

```dart
final class Base {}

class Libre extends Base {}
// Error: The type 'Libre' must be 'base', 'final' or 'sealed' because the supertype 'Base' is 'final'.

final class Permitida extends Base {}
```

Es un fragmento: las dos primeras declaraciones producen ese error y la última es válida. Una `final class` también
puede implementar contratos: `_ThemeListenable` es una `final class` que implementa `ValueListenable`. La forma
`abstract final class` de `DaisyThemeService` combina otro modificador y se estudia en la unidad 17.

### Practica 7

Clasifica estas afirmaciones: a) `final class` impide llamar a `setTheme`; b) un campo `final` impide reasignar
`_palette`; c) un campo `final` impide cambiar `_palette.value`; d) `final class` impide implementar el controlador
desde otro archivo.

<details>
<summary>Ver respuesta</summary>

Son verdaderas b y d. La a es falsa: el modificador de clase no limita sus métodos. La c también: `final` protege la
referencia `_palette`, no el valor que conserva la señal; por eso `setTheme` puede asignarlo.

</details>

## 8. Recorrido real: qué existe después de cada línea

Ya podemos seguir la creación completa. Antes de mirar los `expect`, predice cuántos controladores, señales y modelos
hay tras crear `a`, `b` y `c`, y qué devuelve cada uno después de cambiar solo `a`:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cada controlador crea su propia señal', () {
    final a = DaisyThemeController();
    final b = DaisyThemeController();
    final c = DaisyThemeController(initialTheme: DaisyThemes.dark);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    addTearDown(c.dispose);

    expect(identical(a, b), isFalse);
    expect(identical(a.theme.value, b.theme.value), isTrue);
    expect(identical(a.theme.value, DaisyThemes.light), isTrue);
    expect(c.theme.value.name, 'Dark');

    a.setTheme(DaisyThemes.cupcake);

    expect(a.theme.value.name, 'Cupcake');
    expect(b.theme.value.name, 'Light');
    expect(c.theme.value.name, 'Dark');
    expect(DaisyThemes.light.name, 'Light');
  });
}
```

La prueba pasa. Recorramos `final a = DaisyThemeController();`:

1. La llamada no entrega argumentos, así que `initialTheme` referencia la constante `DaisyThemes.light`.
2. Se ejecuta la lista de inicialización: `FlutterSignal<DaisyThemeModel>(initialTheme)` crea una señal nueva que guarda
   una referencia a ese modelo. El modelo **no se copia**.
3. La referencia a la señal se guarda en `_palette`, que es privado y `final`.
4. `_theme` no se crea todavía, porque es `late`: se creará al leer `a.theme` por primera vez.
5. No hay cuerpo, así que el constructor termina y `a` recibe la referencia al controlador.

Al crear los tres, antes de leer ninguna vista, tenemos:

| Variable | Controlador | Señal `_palette` | Modelo al que apunta la señal |
|----------|-------------|------------------|-------------------------------|
| `a`      | propio      | propia           | `DaisyThemes.light`           |
| `b`      | propio      | propia           | `DaisyThemes.light`           |
| `c`      | propio      | propia           | `DaisyThemes.dark`            |

Son tres controladores, tres señales y solo dos modelos, que ya existían como constantes. Por eso
`identical(a.theme.value, b.theme.value)` es verdadero: dos señales distintas apuntan al mismo modelo.

`a.setTheme(DaisyThemes.cupcake)` hace que la señal de `a` apunte a otro modelo. La señal de `b` no se entera, porque es
otro objeto y `b` sigue en `Light`. Tampoco se modifica `DaisyThemes.light`: cambia a qué modelo apunta una señal, no el
contenido de ningún modelo. Compartir un modelo inmutable no comparte el estado; lo que cada controlador conserva por
separado es **su señal**.

El test creó los tres controladores y registra su liberación, como estudiamos en la unidad 13. Comprueba identidades y
valores; no monta ningún widget ni demuestra una reconstrucción.

### Practica 8

Añadimos `final d = a;` y `final e = DaisyThemeController(initialTheme: a.theme.value);` después de `a.setTheme(...)`.
¿Cuántos controladores y señales nuevos se crean? ¿Qué devuelve `e.theme.value.name`? Si después hacemos
`a.setTheme(DaisyThemes.dark)`, ¿cambia `d`? ¿Cambia `e`?

<details>
<summary>Ver respuesta</summary>

`d` no crea nada: es otra referencia a `a`. `e` crea un controlador y una señal nuevos, y parte del modelo que `a` tenía
en ese momento, así que devuelve `Cupcake`. Tras el último cambio, `d.theme.value` devuelve `Dark` porque es el mismo
controlador que `a`. `e` sigue en `Cupcake`: recibió una lectura puntual para empezar, pero su señal es independiente.

</details>

## Ejercicio final: un controlador de práctica

Escribe un programa Dart completo que reúna todo lo anterior, sin usar Flutter:

1. Declara `Fuente` con un parámetro posicional que se guarda en un campo privado `_valor`, un getter `valor` y un
   método `cambiar(String nuevo)`.
2. Declara `Vista` con `this._fuente` y un getter `valor` que consulte esa fuente.
3. Declara `class ControladorTema` como `final class`, con `nombre` obligatorio e `inicial` opcional con valor
   predeterminado `'claro'`. La lista de inicialización debe crear `_fuente` con `inicial`, y `nombre` debe guardarse
   con `this.nombre`. El cuerpo imprime `Creado <nombre> con <valor>`.
4. Añade un campo `late final Vista vista = Vista(_fuente);` y un método `cambiar`.
5. Declara `ControladorVistaPrevia`, subclase de `ControladorTema`, que reenvíe `nombre` con `super.nombre` y entregue
   siempre `inicial: 'cupcake'` mediante `super(...)`.
6. En `main`, crea `a` sin indicar el tema, `b` con `'oscuro'` y `c` como vista previa. Cambia `a` a `'bosque'`, imprime
   el nombre y el valor de cada uno, y comprueba con `identical` si `a.vista` es siempre el mismo objeto y si coincide
   con `b.vista`.

Predice la salida antes de ejecutar y cuenta cuántos objetos `Fuente` existen. Como variaciones: ¿qué error produce
mover `Vista(_fuente)` a un campo sin `late`? ¿Qué cambia si `ControladorVistaPrevia` se declara sin `final`?

<details>
<summary>Ver una posible solución</summary>

```dart
class Fuente {
  Fuente(this._valor);

  String _valor;

  String get valor => _valor;

  void cambiar(String nuevo) {
    _valor = nuevo;
  }
}

class Vista {
  Vista(this._fuente);

  final Fuente _fuente;

  String get valor => _fuente.valor;
}

final class ControladorTema {
  ControladorTema({required this.nombre, String inicial = 'claro'})
    : _fuente = Fuente(inicial) {
    print('Creado $nombre con ${_fuente.valor}');
  }

  final String nombre;
  final Fuente _fuente;
  late final Vista vista = Vista(_fuente);

  void cambiar(String nuevo) => _fuente.cambiar(nuevo);
}

final class ControladorVistaPrevia extends ControladorTema {
  ControladorVistaPrevia({required super.nombre}) : super(inicial: 'cupcake');
}

void main() {
  final a = ControladorTema(nombre: 'app');
  final b = ControladorTema(nombre: 'otro', inicial: 'oscuro');
  final c = ControladorVistaPrevia(nombre: 'previa');

  a.cambiar('bosque');

  print('${a.nombre}: ${a.vista.valor}');
  print('${b.nombre}: ${b.vista.valor}');
  print('${c.nombre}: ${c.vista.valor}');
  print(identical(a.vista, a.vista));
  print(identical(a.vista, b.vista));
}
```

```text
Creado app con claro
Creado otro con oscuro
Creado previa con cupcake
app: bosque
otro: oscuro
previa: cupcake
true
false
```

Cada llamada a un constructor crea una `Fuente` en su lista de inicialización: hay tres. La línea `Creado previa con
cupcake` aparece aunque `ControladorVistaPrevia` no tenga cuerpo, porque se ejecuta el cuerpo de su clase padre. `a` no
entrega `inicial` y parte de `claro`; solo su fuente pasa a `bosque`. `identical(a.vista, a.vista)` es verdadero porque
`late final` crea la vista en la primera lectura y la conserva; cada controlador tiene la suya.

Sin `late`, el inicializador intenta leer `_fuente` durante la construcción y aparece `Can't access 'this' in a field
initializer`. Sin `final` en la subclase, aparece el error del apartado 7, porque su clase padre es `final`.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué ocurre al llamar a un constructor y qué no ocurre al copiar una referencia? **Apartado 1.**
2. ¿Qué diferencia hay entre `required`, un valor predeterminado y un tipo con `?`? **Apartado 2.**
3. ¿Por qué `DaisyThemes.light` puede ser un valor predeterminado y una variable `final` corriente no? **Apartado 2.**
4. ¿En qué orden se ejecutan la lista de inicialización y el cuerpo? ¿Por qué `_palette` no se asigna en el cuerpo?
   **Apartado 3.**
5. ¿Por qué `late` permite que `_theme` lea `_palette`? **Apartado 3.**
6. ¿Qué hace `_ThemeListenable(this._source)`? ¿Copia la señal? **Apartado 4.**
7. ¿Qué diferencia hay entre `super.key` y `super(notifier: ...)`? ¿Cuántos objetos crea una llamada? **Apartado 5.**
8. ¿Dónde termina la privacidad de `_` y por qué no es privada «de la clase»? **Apartado 6.**
9. ¿Qué limita `final class` y qué limita un campo `final`? **Apartado 7.**
10. Tras crear dos controladores sin argumentos, ¿cuántas señales y cuántos modelos hay? ¿Por qué cambiar uno no afecta
    al otro? **Apartado 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques, sin mirar, cada parte del
constructor de `DaisyThemeController` y qué objetos existen después de llamarlo. La unidad 16 estudia el otro lado de
esta clase: el getter `theme`, la inicialización diferida y el adaptador `_ThemeListenable`.

## Para consultar si necesitas reforzar

- [Constructores en Dart](https://dart.dev/language/constructors): parámetros de inicialización, listas de
  inicialización y parámetros `super`.
- [Parámetros de funciones](https://dart.dev/language/functions#parameters): parámetros nombrados, `required` y valores
  predeterminados.
- [Variables `late`](https://dart.dev/language/variables#late-variables): inicialización diferida, que se amplía en la
  unidad 16.
- [Bibliotecas y privacidad](https://dart.dev/language/libraries): por qué `_` pertenece a la biblioteca.
- [Modificadores de clase](https://dart.dev/language/class-modifiers): `final`, `base`, `sealed` y sus combinaciones.
- [Controlador](../../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../../lib/themes/application/daisy_theme_scope.dart) y
  [catálogo de temas](../../../lib/themes/domain/daisy_themes.dart): los constructores y constantes de esta unidad.
