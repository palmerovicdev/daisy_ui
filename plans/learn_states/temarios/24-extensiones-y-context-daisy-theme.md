# 24. Extensiones y `context.daisyTheme`

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 23](23-daisy-theme-scope-of-nullabilidad-y-errores.md) · **Estado:** pendiente

## Qué vas a aprender

Desde la unidad 10 escribimos `context.daisyTheme`, y parece que cada `BuildContext` tuviera un tema guardado. Pero
`BuildContext` pertenece a Flutter, que no sabe nada de DaisyUI. ¿De dónde sale entonces esa propiedad? ¿Guarda algo?
¿Hace que un widget sea más reactivo?

Al terminar podrás escribir una extensión con getters y métodos, y explicar qué puede hacer y qué no. Podrás sustituir
`context.daisyTheme` por su llamada explícita, seguir la misma dependencia y comprobar que el comportamiento se
conserva. Y sabrás distinguir la comodidad de escritura del almacenamiento o de la reactividad adicional.

Los programas sin dependencias de los apartados 1–3 se pueden ejecutar en [DartPad](https://dartpad.dev/) en modo
**Dart**. Las pruebas son archivos completos: copia **una cada vez** a `test/estudio_extension_test.dart` y ejecuta
desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_extension_test.dart
```

Necesitas las dependencias ya resueltas. Predice cada resultado antes de mirarlo. Los fragmentos identificados como
tales no son archivos completos. Es una unidad más corta que las anteriores: puedes estudiar los apartados 1–3 en una
sesión y terminar con los apartados 4–6 y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0;
consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas.

## 1. Añadir operaciones a una clase que no es tuya

Imagina que quieres presentar textos entre comillas. Podrías escribir una función `entreComillas('claro')`, pero se
leería mejor como `'claro'.entreComillas`. Sin embargo, `String` pertenece a Dart: no puedes modificar su código. Una
**extensión** declara miembros adicionales para un tipo existente, sin tocar la clase.

```dart
extension Presentacion on String {
  String get entreComillas => '«$this»';

  String repetir(int veces) => this * veces;
}

void main() {
  print('claro'.entreComillas);
  print('ab'.repetir(2));
}
```

La salida es:

```text
«claro»
abab
```

La sintaxis nueva:

- `extension Presentacion on String` declara una extensión llamada `Presentacion` para el tipo `String`. El nombre es
  opcional, pero conviene ponerlo, como veremos.
- Dentro puede haber getters (unidad 16), métodos y operadores.
- `this` es el objeto sobre el que se llama. En `'claro'.entreComillas`, `this` vale `'claro'`. Se puede omitir en las
  mismas condiciones que dentro de una clase.

La extensión es comodidad de escritura. Dart traduce esa llamada a una función corriente que recibe el texto. Se puede
escribir incluso de forma explícita, algo que nos será útil enseguida:

```dart
// Fragmento: dentro de main.
print(Presentacion('oscuro').entreComillas);
```

Esta sintaxis no crea ningún objeto `Presentacion`: solo indica qué extensión aplicar a ese valor. `'oscuro'` sigue
siendo un `String` normal, sin ninguna capacidad nueva. Si hay otra biblioteca que no importa la extensión, para ella el
`String` no tiene esos miembros.

### Practica 1

Añade a `Presentacion` un getter `esCorto` que devuelva `true` si el texto tiene menos de 4 caracteres. ¿Qué devuelven
`'sol'.esCorto` y `'luna'.esCorto`?

<details>
<summary>Ver respuesta</summary>

```dart
// Fragmento: dentro de la extensión.
bool get esCorto => length < 4;
```

Devuelven `true` y `false`. `length` se refiere a `this.length`, igual que en un método de una clase. Dentro de la
extensión, puedes usar los miembros públicos de `String`.

</details>

## 2. Lo que una extensión no puede hacer: guardar datos

Aquí está la respuesta a la pregunta principal de la unidad. Una extensión **no añade nada al objeto**: no tiene dónde
guardar. Este **fragmento** no compila:

```dart
extension Mala on Caja {
  int copia = 0;
  // Extensions can't declare instance fields.
}
```

Por eso, en una extensión solo se pueden declarar operaciones. Un getter de una extensión es exactamente lo mismo que un
getter de una clase: **se ejecuta en cada lectura**. **Antes de mirar la salida**, predice cuántas veces se ejecuta
este:

```dart
class Caja {
  Caja(this.valor);

  int valor;
}

var lecturas = 0;

extension Lectura on Caja {
  int get doble {
    lecturas++;
    return valor * 2;
  }
}

void main() {
  final caja = Caja(2);

  print(caja.doble);
  print(caja.doble);
  caja.valor = 5;
  print(caja.doble);
  print('Lecturas: $lecturas');
}
```

La salida es:

```text
4
4
10
Lecturas: 3
```

Cada `caja.doble` ejecuta el cuerpo otra vez y consulta el valor que hay en ese momento. El tercer resultado es `10`
porque no se guardó ningún resultado anterior.

`lecturas` es una variable de nivel superior: pertenece al programa, no a la extensión ni a la caja. Una extensión sí
puede tener miembros `static` o leer una variable global, igual que cualquier otro código, pero entonces no se almacena
por objeto. Lo veremos en el ejercicio final.

### Practica 2

Queremos que un `Marcador` tenga un `apodo`. El marcador es una clase nuestra, y escribimos
`extension on Marcador { String apodo = ''; }`. ¿Qué ocurre? ¿Cuál sería la solución correcta?

<details>
<summary>Ver respuesta</summary>

No compila: una extensión no puede declarar campos de instancia. Como la clase es nuestra, lo correcto es añadir el
campo a `Marcador`. Una extensión solo sirve para operaciones que se pueden calcular a partir de lo que el objeto ya
ofrece.

</details>

## 3. El tipo declarado decide

Recuerda la diferencia entre el tipo declarado y el objeto real (unidad 3). Los métodos de una clase se eligen según el
objeto real. Los de una extensión se eligen **al compilar, según el tipo declarado**. **Antes de mirar la salida**,
predice las líneas:

```dart
class Animal {
  String get sonido => 'genérico';
}

class Perro extends Animal {
  @override
  String get sonido => 'guau';
}

extension AnimalExtra on Animal {
  String get familia => 'animal';
}

extension PerroExtra on Perro {
  String get familia => 'perro';
}

void main() {
  Animal mascota = Perro();
  print(mascota.sonido);
  print(mascota.familia);

  final perro = Perro();
  print(perro.familia);
}
```

La salida es:

```text
guau
animal
perro
```

Paso a paso:

1. `mascota.sonido` es un miembro de la clase: se elige según el objeto real, un `Perro`. Es el `@override` de siempre.
2. `mascota.familia` es de una extensión: la variable se declaró como `Animal`, así que se usa `AnimalExtra`, aunque el
   objeto sea un `Perro`.
3. `perro.familia` tiene el tipo `Perro`. Se aplican las dos extensiones y Dart elige la más específica: `PerroExtra`.

Tres consecuencias prácticas de que se resuelvan al compilar:

- **Un miembro de la clase siempre gana.** Si `Caja` tuviera su propio `doble`, la extensión se ignoraría.
- **Con `dynamic` no funcionan.** Si una variable se declara `dynamic`, el compilador no sabe a qué tipo aplicarla. Lo
  veremos en la unidad 28.
- **Hay que importarlas.** Una extensión solo está disponible si su biblioteca es visible. Sin importarla, este
  **fragmento** falla:

```dart
String nombre(BuildContext context) => context.daisyTheme.name;
// The getter 'daisyTheme' isn't defined for the type 'BuildContext'.
```

Por eso funciona en el ejemplo: `import 'package:daisy_ui/daisy_ui.dart'` lleva a un `export` de la extensión, en
[la API pública](../../../lib/daisy_ui.dart). La unidad 32 estudia los `export`.

### Practica 3

Con las clases del ejemplo: (a) `Animal otro = Animal(); print(otro.familia);` (b)
`Perro p = Perro(); Animal a = p; print(a.familia);` (c) Añadimos a `Perro` un getter `String get familia => 'cánido';`.
¿Qué imprime `Perro().familia`?

<details>
<summary>Ver respuesta</summary>

(a) `animal`. (b) `animal`: el objeto es el mismo perro, pero la variable `a` se declara como `Animal`. (c) `cánido`: un
miembro de la clase tiene prioridad sobre cualquier extensión.

</details>

## 4. `context.daisyTheme` por dentro

Este es **todo** el código de la [extensión real](../../../lib/themes/core/extension/build_context.dart), sin los
imports:

```dart
extension DaisyThemeContext on BuildContext {
  DaisyThemeModel get daisyTheme => DaisyThemeScope.of(this);
}
```

Una línea, y ya tienes todo lo necesario para leerla:

1. Declara un getter para el tipo `BuildContext`. Flutter no se entera.
2. `this` es el contexto sobre el que se escribe `.daisyTheme`. No hay otro contexto: la búsqueda parte exactamente del
   que escribiste (unidad 20).
3. El cuerpo llama a `DaisyThemeScope.of`. No añade nada más.

`BuildContext` es un tipo declarado, y todos los elementos lo implementan (unidad 20). Por eso `tester.element(...)`,
que devuelve un `Element`, también puede usarlo.

El recorrido de `context.daisyTheme` es **el mismo que el de la unidad 23, con un paso más al principio**:

```text
context.daisyTheme
└── DaisyThemeScope.of(context)
    └── context.dependOnInheritedWidgetOfExactType<DaisyThemeScope>()
        ├── Registra la dependencia del elemento en el scope más cercano
        └── scope.notifier!.value → adaptador → _palette.value
```

**Antes de mirar los `expect`**, predice si las tres formas devuelven el mismo objeto y si se reconstruyen las tres:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final builds = <String, int>{'extension': 0, 'explicita': 0, 'of': 0};
final leidos = <String, DaisyThemeModel>{};

class ConExtension extends StatelessWidget {
  const ConExtension({super.key});

  @override
  Widget build(BuildContext context) {
    builds['extension'] = builds['extension']! + 1;
    leidos['extension'] = context.daisyTheme;
    return const SizedBox.shrink();
  }
}

class ConExplicita extends StatelessWidget {
  const ConExplicita({super.key});

  @override
  Widget build(BuildContext context) {
    builds['explicita'] = builds['explicita']! + 1;
    leidos['explicita'] = DaisyThemeContext(context).daisyTheme;
    return const SizedBox.shrink();
  }
}

class ConOf extends StatelessWidget {
  const ConOf({super.key});

  @override
  Widget build(BuildContext context) {
    builds['of'] = builds['of']! + 1;
    leidos['of'] = DaisyThemeScope.of(context);
    return const SizedBox.shrink();
  }
}

void main() {
  testWidgets('tres escrituras, un mismo comportamiento', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: controller,
          child: const Column(
            children: [ConExtension(), ConExplicita(), ConOf()],
          ),
        ),
      ),
    );
    expect(builds, {'extension': 1, 'explicita': 1, 'of': 1});
    expect(identical(leidos['extension'], leidos['explicita']), isTrue);
    expect(identical(leidos['extension'], leidos['of']), isTrue);

    controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(builds, {'extension': 2, 'explicita': 2, 'of': 2});
    expect(leidos['extension']!.name, 'Dark');
    expect(identical(leidos['extension'], leidos['of']), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Las tres formas devuelven el **mismo objeto**: el que hay en la señal. Y las tres registran la misma dependencia, porque
las tres acaban en la misma llamada a `dependOnInheritedWidgetOfExactType`. El comportamiento también coincide cuando
falla: la prueba `Reading outside a scope reports the missing ancestor`, en
[las pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart), lanza el mismo `FlutterError` de `of`.

La extensión no añade ninguna reactividad. Quien hace que un consumidor se actualice es la dependencia, y esta ya la
registraba `of`.

### Practica 4

Una persona dice: «`context.daisyTheme` es más eficiente que `DaisyThemeScope.of(context)`, porque el contexto ya tiene
guardado el tema». Corrige la frase. ¿Cuál de las dos usarías en tu código?

<details>
<summary>Ver respuesta</summary>

El contexto no guarda nada, y una extensión no podría guardarlo. `context.daisyTheme` ejecuta
`DaisyThemeScope.of(context)`: hacen exactamente lo mismo. La elección es de estilo. La primera es más corta y es la que
usa el proyecto; la segunda hace visible qué scope se usa, y por eso la escribimos en la unidad 23.

</details>

## 5. Volver a leer es lo que actualiza

Como el contexto no guarda nada, la diferencia entre un dato actual y uno obsoleto está en **cuándo se lee**. Aquí
tienes un error que esta forma de escribir puede ocultar: guardar el primer resultado en un campo del `State`. `??=`
asigna solo si la variable es `null` (es como `??`, pero asignando).

**Antes de mirar los `expect`**, predice el texto y las construcciones de cada consumidor:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Actual extends StatelessWidget {
  const Actual({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = context.daisyTheme;
    return Text('Actual: ${tema.name}, ${tema.id}');
  }
}

class Guardado extends StatefulWidget {
  const Guardado({super.key});

  @override
  State<Guardado> createState() => GuardadoState();
}

class GuardadoState extends State<Guardado> {
  DaisyThemeModel? _tema;
  int builds = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    _tema ??= context.daisyTheme;
    return Text('Guardado: ${_tema!.name}');
  }
}

void main() {
  testWidgets('reconstruirse no basta: hay que volver a leer', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: controller,
          child: const Column(children: [Actual(), Guardado()]),
        ),
      ),
    );
    final guardado = tester.state<GuardadoState>(find.byType(Guardado));
    expect(guardado.builds, 1);

    controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('Actual: Dark, dark'), findsOneWidget);
    expect(find.text('Guardado: Light'), findsOneWidget);
    expect(guardado.builds, 2);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Paso a paso:

1. `Actual` guarda el tema en una variable **local**. Es una lectura puntual, de una sola construcción, y se puede usar
   varias veces sin repetir la consulta. La siguiente construcción lee de nuevo. Es lo que hace el botón real, con
   `final th = context.daisyTheme;`.
2. `Guardado` también lee en la primera construcción: la dependencia queda registrada para siempre (unidad 21). Cuando
   cambia el tema, **se reconstruye**, como muestra `builds`.
3. Pero `??=` no vuelve a leer, porque `_tema` ya tiene un valor. El `build` usa el dato antiguo. El aviso llegó, y aun
   así la pantalla es incorrecta.

Este es el último eslabón de la cadena que empezamos en la unidad 1: **una reconstrucción solo sirve si `build` lee los
datos actuales**. Si necesitas guardar un dato derivado en el `State`, recuerda que el lugar adecuado es
`didChangeDependencies` (unidad 19), que se vuelve a ejecutar.

### Practica 5

Un `_tema` guardado en `didChangeDependencies` con `_tema = context.daisyTheme;`, sin `??=`, ¿se quedaría obsoleto? ¿Y
un `final tema = context.daisyTheme;` en `build`, usado en el `onPressed` de un botón?

<details>
<summary>Ver respuesta</summary>

El primero no: `didChangeDependencies` se ejecuta en cada cambio del tema, antes de `build`, y lo actualiza. El segundo
tampoco en la práctica: al cambiar el tema, se reconstruye y se crea un nuevo callback con el valor nuevo. Solo se
quedaría obsoleto en una pulsación entre el cambio y el siguiente frame.

</details>

## 6. Cuándo escribir una extensión propia

Vistas sus limitaciones, ¿cuándo merece la pena una extensión? Cuando una operación **se escribe a menudo** y se puede
calcular con lo que el tipo ya ofrece. El [ejemplo](../../../example/lib/main.dart) y el
[botón](../../../lib/themes/presentation/action/button.dart) repiten la misma expresión:

```dart
// Fragmento repetido en el proyecto.
context.daisyTheme.radius.fields.toDouble()
```

Podríamos añadir una extensión, y hay dos sitios posibles. Este **fragmento** las compara:

```dart
// Opción 1: sobre el contexto.
extension AtajoContexto on BuildContext {
  double get radioCampos => daisyTheme.radius.fields.toDouble();
}
// Uso: context.radioCampos

// Opción 2: sobre el modelo.
extension AtajoTema on DaisyThemeModel {
  double get radioCampos => radius.fields.toDouble();
}
// Uso: context.daisyTheme.radioCampos
```

La opción 2 suele ser mejor: la operación pertenece al tema y no necesita un contexto. Se puede usar sobre cualquier
modelo y probar sin widgets, como `expect(DaisyThemes.light.radioCampos, ...)`. Y el código que la usa deja claro de
dónde viene el dato. La opción 1 es cómoda, pero oculta la búsqueda y la dependencia.

El proyecto ya depende de una extensión ajena: `RayToFlutterColor`, del paquete `prism_flutter`, añade el método
`toColor()` a los colores OKLCH. Este es un **fragmento** de
[theme_color.dart](../../../lib/themes/domain/theme/theme_color.dart):

```dart
Color get base => baseOklch.toColor();
```

La [API pública](../../../lib/daisy_ui.dart) la vuelve a exportar con `show RayOklch, RayToFlutterColor`, para que quien
use DaisyUI también pueda llamar a `toColor()`. Estudiaremos los colores en la unidad 26.

### Practica 6

Decide si escribirías una extensión y sobre qué tipo: (a) un texto en mayúsculas con el nombre del tema; (b) un contador
de cuántas veces se ha leído el tema de cada contexto; (c) un atajo para `context.daisyTheme.colors`.

<details>
<summary>Ver respuesta</summary>

(a) Sí, sobre `DaisyThemeModel`: se calcula a partir del nombre. (b) No: necesita guardar datos por contexto, y una
extensión no tiene dónde hacerlo; escribirlo con una variable global sería una trampa. Si fuera necesario, habría que
escribir una clase. (c) Es posible, sobre `BuildContext`, si se repite mucho, aunque aporta poco y oculta la
dependencia. Es una decisión de estilo; no hay una única respuesta.

</details>

## Ejercicio final: el atajo que guarda y el que no

Escribe una prueba con dos atajos sobre `BuildContext`:

1. `nombreTema` devuelve `daisyTheme.name`.
2. `nombreCacheado` guarda el primer nombre en una variable global `String? _cache` y lo devuelve siempre. Es una
   versión deliberadamente incorrecta.

Crea un consumidor que muestre los dos. Monta **dos** consumidores: uno en un scope `exterior` y otro en un scope
`interior`, anidado. Después cambia `interior` a `dark` y procesa un frame.

Predice los cuatro textos en cada momento. Responde además: ¿se registra la dependencia en cada atajo? ¿Se reconstruye
cada consumidor? ¿Qué pasa con `nombreCacheado` entre dos pruebas del mismo archivo? ¿Qué cambiarías para que
`nombreTema` fuera un atajo sobre el modelo?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

String? _cache;

extension AtajosTema on BuildContext {
  String get nombreTema => daisyTheme.name;

  String get nombreCacheado {
    final actual = daisyTheme.name;
    return _cache ??= actual;
  }
}

class Consumidor extends StatelessWidget {
  const Consumidor(this.etiqueta, {super.key});

  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$etiqueta bien: ${context.nombreTema}'),
        Text('$etiqueta mal: ${context.nombreCacheado}'),
      ],
    );
  }
}

void main() {
  testWidgets('el atajo que guarda y el que no', (tester) async {
    final exterior = DaisyThemeController();
    final interior = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    addTearDown(exterior.dispose);
    addTearDown(interior.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: exterior,
          child: Column(
            children: [
              const Consumidor('Exterior'),
              DaisyThemeScope(
                controller: interior,
                child: const Consumidor('Interior'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Exterior bien: Light'), findsOneWidget);
    expect(find.text('Exterior mal: Light'), findsOneWidget);
    expect(find.text('Interior bien: Cupcake'), findsOneWidget);
    expect(find.text('Interior mal: Light'), findsOneWidget);

    interior.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('Exterior bien: Light'), findsOneWidget);
    expect(find.text('Interior bien: Dark'), findsOneWidget);
    expect(find.text('Interior mal: Light'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

`nombreTema` no guarda nada: lee el scope de ese contexto, en cada construcción, y funciona.

`nombreCacheado` falla ya al montar: el consumidor interior muestra `Light`, el tema del scope exterior, porque se
construye después y reutiliza lo que este guardó. Tras el cambio, sigue mostrando `Light`, aunque se haya reconstruido.

La dependencia sí se registra en los dos, porque ambos llaman a `daisyTheme`: por eso **escribimos primero
`final actual`**. Si escribiéramos `_cache ??= daisyTheme.name`, a partir de la segunda llamada `??=` ni siquiera
evaluaría el lado derecho, de modo que el consumidor interior no llegaría a registrar la dependencia y no se
reconstruiría. En cualquier caso, el resultado es incorrecto.

`_cache` es global (unidad 17): una segunda prueba del mismo archivo lo encontraría ya relleno, con la misma dependencia
del orden de la unidad 17.

Para que fuera un atajo sobre el modelo:
`extension AtajosModelo on DaisyThemeModel { String get nombreEnMayusculas => name.toUpperCase(); }`, y se usaría con
`context.daisyTheme.nombreEnMayusculas`.

Esta es la distinción de toda la unidad: la comodidad de escritura no cuesta nada. Almacenar sí cambia el
comportamiento, y requiere un dueño para el dato.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué es una extensión? ¿Qué significa `this` dentro de ella? **Apartado 1.**
2. ¿Por qué una extensión no puede guardar datos por objeto? ¿Cuántas veces se ejecuta su getter? **Apartado 2.**
3. ¿Cómo se elige qué extensión aplicar? ¿Qué le ocurre a una variable declarada con el tipo padre? **Apartado 3.**
4. ¿Qué hace falta para que `context.daisyTheme` compile en otro archivo? **Apartado 3.**
5. Escribe el cuerpo de `daisyTheme`. ¿Qué es `this`? **Apartado 4.**
6. ¿Qué se conserva al sustituir `context.daisyTheme` por `DaisyThemeScope.of(context)`? **Apartado 4.**
7. ¿Por qué un consumidor puede reconstruirse y seguir mostrando un tema antiguo? **Apartado 5.**
8. ¿Cuándo escribirías una extensión sobre el modelo en lugar de sobre el contexto? **Apartado 6.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y distingas la comodidad de escritura del
almacenamiento o de la reactividad adicional. La unidad 25 cierra el Bloque 5 con los scopes anidados: qué se actualiza
cuando conviven varios controladores.

## Para consultar si necesitas reforzar

- [Métodos de extensión](https://dart.dev/language/extension-methods): sintaxis, resolución estática y conflictos.
- [`Extension types`](https://dart.dev/language/extension-types): algo distinto de las extensiones, por si lo encuentras
  en otro código.
- [Extensión de contexto](../../../lib/themes/core/extension/build_context.dart),
  [scope](../../../lib/themes/application/daisy_theme_scope.dart), [API pública](../../../lib/daisy_ui.dart) y
  [pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart): comportamiento actual de DaisyUI.
