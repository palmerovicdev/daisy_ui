# 28. Mapas, JSON y serialización anidada

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 27](27-modelos-inmutables-y-freezed.md) · **Estado:** pendiente

## Qué vas a aprender

Una persona personaliza su tema y quiere conservarlo al cerrar la aplicación, o bien lo recibe de un servidor. Un objeto `DaisyThemeModel` solo existe en la memoria del programa: para guardarlo o enviarlo hay que convertirlo en algo que viaje, normalmente **texto JSON**, y después reconstruirlo. Parece sencillo, pero un tema es un árbol de objetos: tema, colores, pares de color y componentes numéricos.

Al terminar podrás distinguir un mapa de Dart del texto JSON y recorrer un tema hasta sus números. También sabrás probar los dos ciclos de ida y vuelta, localizar el nivel donde se quedó un objeto sin convertir y explicar qué ocurre con los valores opcionales y con los números.

Los programas sin dependencias se pueden ejecutar en [DartPad](https://dartpad.dev/) en modo **Dart**. Las pruebas son archivos completos: copia **una cada vez** a `test/estudio_json_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_json_test.dart
```

Necesitas las dependencias ya resueltas. Predice cada resultado antes de mirarlo. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–5 en otra y terminar con 6–7 y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `json_serializable` 6.15.2 y `prism` 2.1.0; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas. Cómo se genera el código de esta unidad se estudia en la siguiente.

## 1. Un mapa no es JSON

Un **mapa** es un objeto de Dart que asocia claves con valores. **JSON** es un formato de **texto** con reglas fijas. Se parecen tanto al escribirlos que es fácil confundirlos, así que vamos a separarlos:

```dart
import 'dart:convert';

void main() {
  final Map<String, Object?> mapa = {'nombre': 'claro', 'borde': 1.5};

  final String texto = jsonEncode(mapa);
  final dynamic leido = jsonDecode(texto);

  print(mapa['nombre']);
  print(texto);
  print(texto.length);
  print(texto[0]);
  print(leido is Map<String, dynamic>);
  print(leido['borde']);
}
```

La salida es:

```text
claro
{"nombre":"claro","borde":1.5}
30
{
true
1.5
```

- `mapa` es un objeto: `mapa['nombre']` busca una clave.
- `texto` es un `String` de 30 caracteres: `texto[0]` es solo la llave de apertura. No se le puede preguntar por `nombre` sin analizarlo.
- `jsonEncode` **codifica**, de objeto a texto, y `jsonDecode` **decodifica**, de texto a objeto. Ambas funciones están en `dart:convert`.

Hay dos tipos que se parecen y conviene distinguir: `Object?` y `dynamic`. Ambos admiten cualquier valor, también `null`. Con `Object?`, el compilador solo te deja hacer lo que puede hacer cualquier objeto: tienes que comprobar el tipo primero. Con `dynamic`, el compilador **deja de comprobar** y cualquier error aparece al ejecutar. Por eso `leido['borde']` compila, mientras que esto no:

```dart
// Fragmento que NO compila: el valor es Object?.
print(mapa['nombre'].length);
// Con una comprobación del tipo sí compila:
final nombre = mapa['nombre'];
if (nombre is String) print(nombre.length);
```

`jsonDecode` devuelve `dynamic` porque su resultado depende del contenido del texto: podría ser un mapa, una lista, un número…

### Practica 1

¿Qué imprime `jsonEncode({'a': null, 'b': true, 'c': [1, 2]})`? ¿Y `print(jsonDecode('[1, 2]') is Map);`? ¿Compila `dynamic x = 3; x.noExiste();`? Si compila, ¿qué ocurre?

<details>
<summary>Ver respuesta</summary>

Imprime `{"a":null,"b":true,"c":[1,2]}`: JSON admite también nulos, booleanos y listas. El segundo imprime `false`: ese texto representa una lista. El tercero **compila**, porque con `dynamic` no hay comprobación, y falla al ejecutar con un `NoSuchMethodError`. Es el precio de `dynamic`.

</details>

## 2. Serializar y deserializar un objeto

**Serializar** es convertir un objeto en un dato que pueda viajar, y **deserializar** es reconstruirlo. Por convención, en Dart lo hacen un método `toJson`, que devuelve un mapa, y una fábrica `fromJson`, que recibe un mapa. Mira el modelo de radios de la unidad 27, ahora con esos dos miembros:

```dart
import 'dart:convert';

class Radios {
  const Radios({required this.cajas, required this.campos});

  factory Radios.fromJson(Map<String, dynamic> json) => Radios(
    cajas: json['cajas'] as int,
    campos: json['campos'] as int,
  );

  final int cajas;
  final int campos;

  Map<String, dynamic> toJson() => {'cajas': cajas, 'campos': campos};
}

void main() {
  const original = Radios(cajas: 8, campos: 4);

  final mapa = original.toJson();
  final texto = jsonEncode(mapa);
  final decodificado = jsonDecode(texto) as Map<String, dynamic>;
  final recuperado = Radios.fromJson(decodificado);

  print(mapa);
  print(texto);
  print(recuperado.cajas);
  print(identical(original, recuperado));
}
```

La salida es:

```text
{cajas: 8, campos: 4}
{"cajas":8,"campos":4}
8
false
```

Observa el orden: objeto → mapa → texto → mapa → objeto. Fíjate en que `print(mapa)` y `print(texto)` muestran cosas distintas: el primero es la forma en que Dart imprime un mapa, sin comillas, y **no es JSON válido**.

`as Map<String, dynamic>` y `as int` son **conversiones de tipo**, ya que `jsonDecode` y los valores del mapa no aportan un tipo concreto. `as` no transforma nada: comprueba al ejecutar que el valor ya sea de ese tipo y, si no, lanza un `TypeError`. Lo recuperado es otro objeto, nuevo.

### Practica 2

En `main`, sustituye `final texto = jsonEncode(mapa);` por `final texto = mapa.toString();`. ¿Qué ocurre al decodificar? Si alguien envía `{"cajas":"8","campos":4}`, ¿qué falla?

<details>
<summary>Ver respuesta</summary>

`jsonDecode` lanza un `FormatException`: `{cajas: 8, campos: 4}` no es JSON, porque las claves no llevan comillas. Por eso `toString` no sirve para serializar. En el segundo caso, el texto sí es JSON válido y `jsonDecode` funciona, pero `json['cajas'] as int` lanza un `TypeError`: `'8'` es un `String`.

</details>

## 3. Serialización anidada: el fallo que no se ve

Ahora el tema contiene otro objeto. La pregunta es qué debe hacer `toJson` con él. Prueba las dos versiones:

```dart
import 'dart:convert';

class Radios {
  const Radios(this.cajas);

  factory Radios.fromJson(Map<String, dynamic> json) =>
      Radios(json['cajas'] as int);

  final int cajas;

  Map<String, dynamic> toJson() => {'cajas': cajas};
}

class Tema {
  const Tema(this.nombre, this.radios);

  factory Tema.fromJson(Map<String, dynamic> json) => Tema(
    json['nombre'] as String,
    Radios.fromJson(json['radios'] as Map<String, dynamic>),
  );

  final String nombre;
  final Radios radios;

  Map<String, dynamic> toJson() => {'nombre': nombre, 'radios': radios.toJson()};

  Map<String, dynamic> toJsonSinConvertir() => {
    'nombre': nombre,
    'radios': radios,
  };
}

void main() {
  const tema = Tema('claro', Radios(8));

  final bien = tema.toJson();
  final mal = tema.toJsonSinConvertir();

  print(bien['radios'].runtimeType);
  print(mal['radios'].runtimeType);

  print(jsonEncode(bien));
  print(jsonEncode(mal));

  print(Tema.fromJson(bien).radios.cajas);

  try {
    Tema.fromJson(mal);
  } on TypeError catch (error) {
    print('Fallo: $error');
  }
}
```

La salida es, en una máquina virtual de Dart:

```text
_Map<String, int>
Radios
{"nombre":"claro","radios":{"cajas":8}}
{"nombre":"claro","radios":{"cajas":8}}
8
Fallo: type 'Radios' is not a subtype of type 'Map<String, dynamic>' in type cast
```

Esto es lo más importante de la unidad. Las dos versiones producen **el mismo texto**, de modo que un `jsonEncode` no permite distinguirlas. ¿Por qué? Porque `jsonEncode`, cuando encuentra un objeto que no sabe codificar, como `Radios`, llama a su método `toJson()`. Y lo hace en todos los niveles.

Pero el mapa intermedio es distinto: `mal['radios']` todavía es un objeto `Radios`, de modo que `Tema.fromJson(mal)` falla al intentar convertirlo en mapa. En resumen:

| | `jsonEncode(...)` | `fromJson(...)` directo |
|---|---|---|
| Todos los niveles convertidos | Funciona | Funciona |
| Un nivel sin convertir | Funciona | `TypeError` |

Si necesitas un mapa formado únicamente por valores JSON, cada nivel debe convertirse. Es lo que indica la opción `explicit_to_json: true` de [build.yaml](../../../build.yaml), que estudiaremos en la unidad 29.

### Practica 3

Añade a `Tema` un campo `final List<Radios> variantes` y a `toJson`, la entrada `'variantes': variantes`. ¿Qué devuelve `jsonEncode`? ¿Es un mapa de valores JSON? Escribe la entrada correcta.

<details>
<summary>Ver respuesta</summary>

`jsonEncode` funciona: recorre la lista y llama a `toJson()` en cada elemento. Pero el mapa no está formado solo por valores JSON, porque la lista contiene objetos `Radios`. La entrada correcta es `'variantes': variantes.map((radios) => radios.toJson()).toList()`.

</details>

## 4. Recorrer un tema hasta los números

Un `DaisyThemeModel` funciona igual, con más niveles. El código está generado, pero se lee sin dificultad. Este es un fragmento de [theme.g.dart](../../../lib/themes/domain/generated/theme.g.dart):

```dart
// Fragmento del archivo generado. No se edita a mano.
Map<String, dynamic> _$DaisyThemeModelToJson(_DaisyThemeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'colors': instance.colors.toJson(),
      'radius': instance.radius.toJson(),
      'size': instance.size.toJson(),
      'border': instance.border,
    };
```

Las cadenas y los números pasan tal cual, y cada modelo anidado llama a su `toJson()`. Vamos a bajar nivel a nivel:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recorrer el tema hasta los números', () {
    final json = DaisyThemes.light.toJson();

    print(json.keys.toList());
    print(json['border']);
    print(json['radius']);
    print(json['size']);

    final colors = json['colors'] as Map<String, dynamic>;
    print(colors.keys.first);

    final primary = colors['primary'] as Map<String, dynamic>;
    print(primary.keys.toList());
    print(primary['base200']);

    final base = primary['base'] as Map<String, dynamic>;
    print(base.keys.toList());
    print(base['l']);
  });
}
```

La salida incluye:

```text
[id, name, description, colors, radius, size, border]
1.0
{boxes: 8, fields: 4, selectors: 8}
{fields: {base: 4}, selectors: {base: 4}}
base
[base, content, base200, base300]
null
[l, c, h]
0.45
```

El árbol completo tiene esta forma:

```text
tema                 DaisyThemeModel
├── id, name, ...    texto
├── border           número
├── radius           DaisyThemeRadius → { boxes, fields, selectors }
├── size             DaisyThemeSize
│   └── fields       DaisyThemeSizePresets → { base }
└── colors           DaisyThemeColor
    └── primary      DaisyThemeColorPair
        ├── base     RayOklch → { l, c, h }
        ├── content  RayOklch → { l, c, h }
        ├── base200  null o RayOklch
        └── base300  null o RayOklch
```

Tres detalles que se ven en la salida:

1. **Solo se serializa lo guardado.** `size.fields` es `{base: 4}`, sin `md`. Y un par guarda `RayOklch`, sin el `Color` de sus getters. Los valores derivados se vuelven a calcular al leerlos (unidad 26). No serializarlos evita que un JSON contenga `base: 4` con `md: 50`.
2. **Una clave no tiene por qué llamarse como su campo.** El campo se llama `baseOklch`, y la clave, `base`. Lo define la anotación `@JsonKey(name: 'base')` que vimos en la unidad 26. La usaremos en la unidad 29.
3. **`RayOklch` no lo genera este proyecto:** su `toJson` y su `fromJson` están escritos a mano en el paquete `prism`. Con opacidad 1 omite la clave `o`.

### Practica 4

Escribe la expresión para obtener el número `h` de `content` del rol `success`, a partir de `final json = DaisyThemes.light.toJson();`. ¿Cuántas conversiones `as Map<String, dynamic>` necesitas? ¿Y sin ellas? ¿Aparecerá `lg` en algún lugar de `jsonEncode(DaisyThemes.light)`?

<details>
<summary>Ver respuesta</summary>

```dart
// Fragmento.
final colors = json['colors'] as Map<String, dynamic>;
final success = colors['success'] as Map<String, dynamic>;
final content = success['content'] as Map<String, dynamic>;
final h = content['h'];
```

Son tres conversiones. Sin ellas también compilaría: como `Map<String, dynamic>` devuelve `dynamic`, se puede escribir `json['colors']['success']['content']['h']`. Pero no hay ninguna comprobación, y un error de escritura en una clave aparecería al ejecutar. `lg` no aparecerá: es un getter calculado, no un dato guardado.

</details>

## 5. Los dos ciclos de ida y vuelta

Un **ciclo de ida y vuelta** (*round trip*) serializa, deserializa y comprueba que el resultado sea igual al original. Para los temas hay dos. Antes de ver los `expect`, predice cuáles serían ciertos aunque un nivel estuviera sin convertir:

```dart
import 'dart:convert';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ciclo directo: objeto, mapa, objeto', () {
    final original = DaisyThemes.cupcake;

    final recuperado = DaisyThemeModel.fromJson(original.toJson());

    expect(recuperado, original);
    expect(identical(recuperado, original), isFalse);
  });

  test('ciclo de texto: objeto, mapa, texto, mapa, objeto', () {
    final original = DaisyThemes.cupcake;

    final texto = jsonEncode(original);
    expect(texto, startsWith('{"id":"cupcake","name":"Cupcake"'));
    expect(texto, jsonEncode(original.toJson()));

    final mapa = jsonDecode(texto) as Map<String, dynamic>;
    expect(DaisyThemeModel.fromJson(mapa), original);
  });
}
```

Los dos pasan, y cada uno demuestra algo distinto:

- `expect(recuperado, original)` usa `==`. Como la igualdad compara todos los `props` de forma recursiva (unidad 27), ninguno de los tokens se ha perdido por el camino. `recuperado` es otro objeto: desde luego, `identical` es `false`.
- `jsonEncode(original)` funciona porque el tema tiene un método `toJson`. Da el mismo texto que `jsonEncode(original.toJson())`.
- El **ciclo de texto** no detecta un nivel sin convertir, como vimos en el apartado 3, porque `jsonEncode` lo oculta. El **ciclo directo** sí, y por eso hacen falta los dos.

El proyecto tiene una prueba más estricta en [daisy_theme_json_test.dart](../../../test/themes/daisy_theme_json_test.dart). Comprueba, para los 35 temas, que todos los valores del árbol son JSON. Es recursiva:

```dart
// Fragmento de test/themes/daisy_theme_json_test.dart.
void _expectJsonValue(Object? value) {
  if (value is Map) {
    for (final entry in value.entries) {
      expect(entry.key, isA<String>());
      _expectJsonValue(entry.value);
    }
  } else if (value is List) {
    for (final item in value) {
      _expectJsonValue(item);
    }
  } else {
    expect(value, anyOf(isNull, isA<String>(), isA<num>(), isA<bool>()));
  }
}
```

Si `value` es un mapa o una lista, entra en sus elementos. Cualquier otro valor debe ser nulo, texto, número o booleano. Un `DaisyThemeColor` olvidado llegaría a la última línea y haría fallar la prueba.

### Practica 5

Si a un tema le quitaras `.toJson()` de `'radius'` en el código generado, ¿qué pasaría con cada una de estas pruebas: el ciclo directo, el ciclo de texto y `_expectJsonValue`? ¿Por qué `expect(recuperado, original)` depende de que los `props` estén completos?

<details>
<summary>Ver respuesta</summary>

El ciclo directo falla, con un `TypeError`, al convertir un `DaisyThemeRadius` en mapa. El ciclo de texto sigue pasando, porque `jsonEncode` llama a `toJson()` por su cuenta. `_expectJsonValue` falla, ya que el valor no es un mapa ni un valor JSON. Y sobre los `props`: si faltara un campo en ellos, `==` no lo compararía, de modo que el ciclo podría perder ese dato sin que la prueba lo notara.

</details>

## 6. Valores opcionales y números

Los dos últimos detalles son los que más sorprenden al leer JSON de otro sistema. Predice cada línea:

```dart
import 'dart:convert';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opcionales', () {
    const par = DaisyThemeColorPair(
      baseOklch: RayOklch.fromComponents(0.5, 0.1, 120, 0.6),
      contentOklch: RayOklch.fromComponents(0.9, 0.01, 120),
    );

    print(par.toJson());

    final conNulo = {
      'base': {'l': 0.5, 'c': 0.1, 'h': 120.0, 'o': 0.6},
      'content': {'l': 0.9, 'c': 0.01, 'h': 120.0},
      'base200': null,
    };
    print(DaisyThemeColorPair.fromJson(conNulo) == par);

    try {
      DaisyThemeColorPair.fromJson({'content': conNulo['content']});
    } on TypeError catch (error) {
      print('Falta base: $error');
    }
  });

  test('números', () {
    print(jsonEncode({'borde': 1.0, 'radio': 8}));
    print(jsonDecode('1.0').runtimeType);
    print(jsonDecode('1').runtimeType);

    final tema = DaisyThemes.light.toJson()..['border'] = 2;
    print(DaisyThemeModel.fromJson(tema).border);

    print(DaisyThemeRadius.fromJson({
      'boxes': 8.9,
      'fields': 4,
      'selectors': 8,
    }).boxes);

    print(RayOklch.fromJson({'l': 5, 'c': -1, 'h': 720}).lightness);
  });
}
```

La salida incluye:

```text
{base: {l: 0.5, c: 0.1, h: 120.0, o: 0.6}, content: {l: 0.9, c: 0.01, h: 120.0}, base200: null, base300: null}
true
Falta base: type 'Null' is not a subtype of type 'Map<String, dynamic>' in type cast
{"borde":1.0,"radio":8}
double
int
2.0
8
5.0
```

**Opcionales.** Un par sin `base200` lo escribe igualmente, como `base200: null`. Al leer, la clave ausente y el valor `null` dan el mismo resultado, porque el código generado solo pregunta `json['base200'] == null`. En cambio, `base` es obligatoria: su ausencia lanza un `TypeError`. La clave `o` sigue otra regla, la del paquete `prism`: se omite si la opacidad es 1 y, al leer, el valor predeterminado es 1. Esas decisiones tan distintas en un mismo objeto son el motivo por el que conviene probar el formato. Lo hace `Previously serialized OKLCH color pairs retain their JSON format`, de [daisy_theme_color_test.dart](../../../test/themes/daisy_theme_color_test.dart).

**Números.** JSON solo tiene un tipo de número. Al decodificar, `1.0` da `double`, y `1` da `int`. Si el generador escribiera `json['border'] as double`, un JSON con `"border": 2` fallaría. Por eso genera esto:

```dart
// Fragmentos de theme.g.dart y theme_radius.g.dart.
border: (json['border'] as num).toDouble(),
boxes: (json['boxes'] as num).toInt(),
```

`num` es el supertipo de `int` y `double`: la conversión acepta los dos, y `toDouble()` o `toInt()` dan el tipo del campo. Tiene un coste: `toInt()` **trunca**, de modo que `8.9` se convierte en `8` sin ningún error.

La última línea muestra otro límite: `fromJson` comprueba **tipos**, no **sentido**. Una claridad de `5` no tiene sentido en un color OKLCH, cuyo rango es de 0 a 1, y aun así se acepta. Si un tema llega de una fuente que no controlas, esa validación es trabajo adicional que el modelo no hace por ti.

### Practica 6

¿Qué da cada una? (a) `DaisyThemeSizePresets.fromJson({'base': 4.0}).md`; (b) `DaisyThemeSizePresets.fromJson({'base': '4'})`; (c) `DaisyThemeSizePresets.fromJson({})`; (d) `RayOklch.fromJson({'l': 0.5, 'c': 0.1, 'h': 120}).opacity`.

<details>
<summary>Ver respuesta</summary>

(a) `40`: `4.0` es un `num`, y `toInt()` da 4. (b) `TypeError`: un `String` no es un `num`. (c) `TypeError`: `null` tampoco es un `num`, porque el campo es obligatorio. (d) `1.0`: sin la clave `o`, se usa el valor predeterminado.

</details>

## 7. Del texto a la interfaz

Vamos a unir esto con todo el recorrido anterior: una aplicación recibe un tema como texto y lo selecciona.

```dart
import 'dart:convert';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('un tema recibido como texto llega al widget', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: controller,
          child: Builder(
            builder: (context) => Text(context.daisyTheme.name),
          ),
        ),
      ),
    );

    final recibido = jsonEncode(DaisyThemes.nord);
    final tema = DaisyThemeModel.fromJson(
      jsonDecode(recibido) as Map<String, dynamic>,
    );
    controller.setTheme(tema);
    await tester.pump();

    expect(find.text('Nord'), findsOneWidget);
    expect(identical(controller.theme.value, DaisyThemes.nord), isFalse);
    expect(controller.theme.value, DaisyThemes.nord);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Cada paso es de una unidad distinta. `fromJson` crea un modelo nuevo, que no es la constante `DaisyThemes.nord`, pero sí es igual a ella. `setTheme` lo ofrece a la señal, que lo compara con `==` y, como es distinto de `light`, lo guarda y avisa. El scope se entera y el `Text` se reconstruye con el nuevo nombre (unidades 21 y 22). Si el texto hubiera contenido `light`, no habría habido ningún aviso.

La prueba no demuestra nada sobre el almacenamiento. El paquete no lee ni guarda archivos: serializa y deserializa, y decidir dónde se guarda ese texto corresponde a la aplicación.

### Practica 7

En esta prueba, ¿cuántos avisos produciría una segunda llamada a `controller.setTheme` con el mismo texto recién decodificado de nuevo? ¿Qué lanza `jsonDecode('no es json')`, y en qué paso de los anteriores? ¿Debería ese error cambiar el tema actual?

<details>
<summary>Ver respuesta</summary>

Ninguno: es otro objeto, pero compara igual, de modo que la señal lo descarta. `jsonDecode` lanza `FormatException` en la decodificación, antes de llegar a `fromJson` o a `setTheme`. El tema actual no cambia, porque el código no llega a ofrecer ningún valor. Si el texto puede venir de fuera, conviene capturar `FormatException` y `TypeError`, y mantener el tema anterior.

</details>

## Ejercicio final: el detector de niveles sin convertir

Vas a escribir una herramienta para el diagnóstico que pide el objetivo de esta unidad: localizar en qué nivel se quedó un objeto sin convertir.

1. Escribe `String? rutaNoJson(Object? valor, [String ruta = 'raíz'])`. Debe recorrer un valor y devolver la ruta del **primer** valor que no sea JSON, como `raíz.radios`, o `null` si todos lo son. Tiene que entrar en mapas y listas.
2. Comprueba que devuelve `null` para `DaisyThemes.light.toJson()`.
3. Comprueba el resultado con estos dos casos, ambos en un mapa construido a mano a partir del de `light`: sustituir `radius` por el objeto `DaisyThemes.light.radius`, y sustituir el `base` de `colors.primary` por un `RayOklch`.
4. En ese segundo caso, predice qué pasa con `jsonEncode` y con `DaisyThemeModel.fromJson` antes de ejecutar.
5. Prueba `DaisyThemeModel.fromJson` con el JSON de `light`, cambiando un `border` entero y quitando una clave `base300`. Predice si el resultado es igual a `light`.

<details>
<summary>Ver una posible solución</summary>

```dart
import 'dart:convert';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

String? rutaNoJson(Object? valor, [String ruta = 'raíz']) {
  if (valor is Map) {
    for (final entrada in valor.entries) {
      final encontrada = rutaNoJson(entrada.value, '$ruta.${entrada.key}');
      if (encontrada != null) return encontrada;
    }
    return null;
  }
  if (valor is List) {
    for (var i = 0; i < valor.length; i++) {
      final encontrada = rutaNoJson(valor[i], '$ruta[$i]');
      if (encontrada != null) return encontrada;
    }
    return null;
  }
  final esJson = valor == null || valor is String || valor is num || valor is bool;
  return esJson ? null : ruta;
}

Map<String, dynamic> copiaProfunda() =>
    jsonDecode(jsonEncode(DaisyThemes.light)) as Map<String, dynamic>;

void main() {
  test('un tema generado no tiene objetos sin convertir', () {
    expect(rutaNoJson(DaisyThemes.light.toJson()), isNull);
  });

  test('localiza un objeto en el primer nivel', () {
    final json = copiaProfunda()..['radius'] = DaisyThemes.light.radius;

    expect(rutaNoJson(json), 'raíz.radius');
  });

  test('localiza un objeto profundo', () {
    final json = copiaProfunda();
    final colors = json['colors'] as Map<String, dynamic>;
    final primary = colors['primary'] as Map<String, dynamic>;
    primary['base'] = DaisyThemes.light.colors.primary.baseOklch;

    expect(rutaNoJson(json), 'raíz.colors.primary.base');
    expect(jsonDecode(jsonEncode(json)), copiaProfunda());
    expect(() => DaisyThemeModel.fromJson(json), throwsA(isA<TypeError>()));
  });

  test('tolera un número entero y un opcional ausente', () {
    final json = copiaProfunda()..['border'] = 1;
    final colors = json['colors'] as Map<String, dynamic>;
    final primary = colors['primary'] as Map<String, dynamic>;
    primary.remove('base300');

    final recuperado = DaisyThemeModel.fromJson(json);

    expect(recuperado.border, 1.0);
    expect(recuperado, DaisyThemes.light);
  });
}
```

La función repite la forma de `_expectJsonValue`, pero construye la ruta a medida que baja. Un `RayOklch` no es un mapa, una lista ni un valor simple, así que termina en la última línea y devuelve su ruta.

En el caso profundo, `jsonEncode` funciona y produce el mismo texto que el tema sin alterar, porque llama a `RayOklch.toJson()`. `fromJson`, en cambio, lanza un `TypeError`: encuentra un `RayOklch` donde exige un mapa. Es el mismo fallo del apartado 3, en otro nivel, y la razón por la que `jsonEncode` no es una buena comprobación.

`copiaProfunda` no se puede sustituir por `DaisyThemes.light.toJson()` y modificar el mapa sin más. Cada llamada a `toJson` crea mapas nuevos, de modo que sería posible, pero pasar por texto garantiza que el resultado no comparte nada y es exactamente lo que habría decodificado un programa externo.

El último caso da un tema igual a `light`. El `1` se convierte en `1.0` mediante `(json['border'] as num).toDouble()`, y `primary.base300` ya era `null` en `light`, de modo que quitar la clave no cambia el resultado.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué diferencia hay entre un mapa de Dart y el texto JSON? ¿Sirve `toString` para serializar? **Apartados 1 y 2.**
2. ¿En qué se diferencian `Object?` y `dynamic`? **Apartado 1.**
3. ¿Qué hace `as`, y qué no hace? **Apartado 2.**
4. Si un nivel queda sin convertir, ¿qué sigue funcionando y qué falla? ¿Por qué? **Apartado 3.**
5. Recorre un tema desde la raíz hasta una componente `l`. **Apartado 4.**
6. ¿Por qué `md` y `Color` no aparecen en el JSON? **Apartado 4.**
7. ¿Qué demuestra cada ciclo de ida y vuelta, y por qué hacen falta los dos? **Apartado 5.**
8. ¿Qué diferencia hay entre `base200` y `o` al escribirse y al leerse? **Apartado 6.**
9. ¿Por qué el código generado usa `as num`? ¿Qué le ocurre a `8.9` en un campo `int`? **Apartado 6.**
10. ¿Qué valida `fromJson` y qué no? **Apartado 6.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y localices un objeto sin convertir sin ejecutar el programa. La siguiente unidad explica de dónde salen `_$DaisyThemeModelToJson` y los demás archivos generados, y qué archivo debes cambiar para modificar el resultado.

## Para consultar si necesitas reforzar

- [JSON en Dart](https://dart.dev/libraries/serialization/json) y [JSON en Flutter](https://docs.flutter.dev/data-and-backend/serialization/json): serialización a mano y con generación de código.
- [`jsonEncode`](https://api.dart.dev/dart-convert/jsonEncode.html) y [`jsonDecode`](https://api.dart.dev/dart-convert/jsonDecode.html): las dos funciones de `dart:convert`.
- [`json_serializable`](https://pub.dev/packages/json_serializable): el generador que produce estos mapas.
- [Pruebas de JSON](../../../test/themes/daisy_theme_json_test.dart), [de colores](../../../test/themes/daisy_theme_color_test.dart) y [theme.g.dart](../../../lib/themes/domain/generated/theme.g.dart): comportamiento actual de DaisyUI.
