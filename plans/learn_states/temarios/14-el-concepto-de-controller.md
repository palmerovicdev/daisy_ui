# 14. El concepto de controller

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 13](13-propiedad-de-los-recursos-y-dispose.md) · **Estado:** pendiente

## Qué vas a aprender

Imagina una aplicación con una pantalla de ajustes, un botón en la barra superior y una vista previa. Las tres necesitan el tema seleccionado y dos de ellas pueden cambiarlo. Con lo aprendido hasta ahora bastaría una señal que todas pudieran leer y escribir. Funciona, pero ¿quién decide qué cambios son válidos? ¿Y quién la libera?

Al terminar podrás separar tres responsabilidades: los datos, la administración del valor actual y la interfaz. Crearás un controlador pequeño, le añadirás una regla y lo probarás sin montar widgets. También comprobarás que la palabra `controller` no aporta comportamiento y sabrás explicar por qué dos controladores pueden administrar temas diferentes. Por último repartiremos las piezas reales de DaisyUI entre esas tres responsabilidades.

Los ejemplos completos son pruebas Flutter independientes. Copia **una cada vez** a `test/estudio_controller_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_controller_test.dart
```

Necesitas las dependencias ya resueltas. Antes de mirar cada `expect`, intenta predecir el resultado; después lee la explicación paso a paso. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar después con los widgets, DaisyUI y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas.

## 1. Una señal que todos pueden escribir

Supongamos que el tema vive en una señal y que cada pantalla recibe una referencia a ella. Solo admitimos tres nombres: `claro`, `oscuro` y `bosque`. En esta prueba, las funciones hacen de pantallas:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('una señal suelta admite cualquier escritura', () {
    final tema = signal('claro');
    addTearDown(tema.dispose);
    final registro = <String>[];
    void escuchar() => registro.add(tema.value);
    tema.addListener(escuchar);
    addTearDown(() => tema.removeListener(escuchar));

    void pantallaAjustes() {
      tema.value = 'oscuro';
    }

    void pantallaAyuda() {
      tema.value = 'azul';
    }

    pantallaAjustes();
    pantallaAyuda();

    expect(tema.value, 'azul');
    expect(registro, ['oscuro', 'azul']);
  });
}
```

Paso a paso:

1. `pantallaAjustes` escribe `oscuro`, un nombre admitido. La señal lo guarda y avisa al listener.
2. `pantallaAyuda` escribe `azul`. Para la señal es solo un `String` distinto del actual: lo guarda y avisa igual.
3. El valor actual termina siendo `azul`, un tema que la aplicación no admite.

La señal cumplió su trabajo: conservar un valor y avisar de sus cambios. Lo que falta es otra cosa: **un lugar responsable de la selección del tema**. Si la regla de los tres nombres se escribe en cada pantalla, hay que repetirla en todas y acordarse de actualizarlas. Además, ninguna pantalla sabe si le corresponde liberar la señal.

### Practica 1

Una cuarta pantalla necesita cambiar el tema. Con este diseño, ¿qué tendría que saber quien la programe para no romper la regla? ¿Qué le impide escribir `'azul'`?

<details>
<summary>Ver respuesta</summary>

Tendría que conocer los tres nombres admitidos y comprobarlos antes de escribir. Nada se lo impide: tiene una referencia a la señal y puede asignar cualquier `String`. La regla existe solo como acuerdo entre personas, no en el código que realiza el cambio.

</details>

## 2. Tres preguntas que separan responsabilidades

Antes de escribir una clase nueva conviene hacerse tres preguntas sobre el tema:

- **¿Qué datos hay?** Los colores, radios, tamaños y borde de un tema. Corresponde al **modelo**.
- **¿Cuál es el valor actual y cómo cambia?** Qué tema está seleccionado ahora y qué operaciones pueden sustituirlo. Corresponde al **controlador**.
- **¿Qué se ve y qué pulsa el usuario?** El texto que se muestra y el botón que recibe la pulsación. Corresponde al **widget**.

Un **controlador** es un objeto cuya responsabilidad es administrar un estado: lo conserva, ofrece operaciones para cambiarlo y permite observarlo. Una analogía: el modelo es una ficha con los datos de un tema, y el controlador es quien recuerda qué ficha está elegida. El widget es el panel que enseña esa ficha y el botón para pedir otra. La analogía no explica cómo se propagan los avisos; ese recorrido lo estudiaste en las unidades 9 y 10.

Veámoslo con piezas reales. [`DaisyThemeModel`](../../../lib/themes/domain/theme.dart) contiene datos y no recuerda cuál es «el tema actual»; [`DaisyThemeController`](../../../lib/themes/application/daisy_theme_controller.dart) sí:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el modelo contiene datos y el controlador elige', () {
    final original = DaisyThemes.light;
    final grueso = original.copyWith(border: 2.0);
    final controller = DaisyThemeController(initialTheme: original);
    addTearDown(controller.dispose);

    expect(original.border, 1.0);
    expect(grueso.border, 2.0);
    expect(identical(controller.theme.value, original), isTrue);

    controller.setTheme(grueso);

    expect(identical(controller.theme.value, grueso), isTrue);
    expect(original.border, 1.0);
  });
}
```

1. `copyWith` crea otro modelo con un borde diferente y deja intacto el original, como vimos en la unidad 8. Crear `grueso` no selecciona nada: es solo otro dato. Freezed, que genera `copyWith`, se estudia en la unidad 27.
2. El controlador empieza conservando una referencia a `original`.
3. `setTheme(grueso)` no modifica ningún modelo: sustituye cuál es el actual. Por eso `original.border` sigue en `1.0`.

El modelo no sabe si está seleccionado, ni avisa a nadie. El controlador no define qué colores tiene un tema. Cada uno puede cambiar por sus propios motivos.

### Practica 2

Clasifica estas tres frases como modelo, controlador o widget: «el borde del tema oscuro mide 1», «ahora mismo está seleccionado el tema oscuro» y «al pulsar este botón se pide otro tema».

<details>
<summary>Ver respuesta</summary>

La primera es un dato del modelo. La segunda es el estado que administra el controlador. La tercera pertenece al widget: recibe la pulsación y llama a una operación. El widget pide el cambio, pero no conserva por eso la selección.

</details>

## 3. Un controlador pequeño

Vamos a envolver la señal del apartado 1 en una clase propia, parecida al selector del ejercicio final de la unidad 9.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

class SelectorTema {
  final _tema = signal('claro');

  ValueListenable<String> get tema => _tema;

  void seleccionar(String nombre) => _tema.value = nombre;

  void dispose() => _tema.dispose();
}

void main() {
  test('un controlador pequeño', () {
    final selector = SelectorTema();
    addTearDown(selector.dispose);
    final registro = <String>[];
    void escuchar() => registro.add(selector.tema.value);
    selector.tema.addListener(escuchar);
    addTearDown(() => selector.tema.removeListener(escuchar));

    expect(selector.tema.value, 'claro');
    selector.seleccionar('oscuro');

    expect(selector.tema.value, 'oscuro');
    expect(registro, ['oscuro']);
  });
}
```

Cada línea de la clase cumple un papel distinto:

1. `final _tema = signal('claro')` crea la señal cuando se construye un `SelectorTema`. Es el **estado administrado**. El guion bajo indica un nombre privado; su alcance exacto y el constructor se estudian en la [unidad 15](15-construccion-del-controlador-y-sintaxis-de-dart.md).
2. `get tema` ofrece una lectura. El tipo `ValueListenable<String>` permite consultar y escuchar, pero no declara un setter, como vimos en las unidades 6 y 9. Las formas de exponer esa lectura se comparan en la [unidad 16](16-vistas-de-lectura-getters-y-delegacion.md).
3. `seleccionar` es una **operación de cambio**: un método con un nombre que explica qué pide quien lo llama.
4. `dispose` ofrece a su propietario una forma de terminar la vida del controlador. Delega en la señal que el controlador creó, como estudiaste en la unidad 13.

En la prueba, el test crea el selector y es su propietario. El listener lee el valor a través de la vista y obtiene `oscuro`. Es la misma señal de siempre; hemos cambiado **qué puede hacer cada parte con ella**. Quien recibe `selector.tema` puede leer y escuchar, y para cambiar el valor debe pasar por `seleccionar`.

Todavía no hemos añadido ninguna regla: `selector.seleccionar('azul')` se aceptaría. Y como en esta prueba la clase y `main` están en el mismo archivo, Dart tampoco impediría escribir `selector._tema` desde `main`. Ese límite y sus consecuencias se estudian en la unidad 15.

### Practica 3

Si otra parte de la aplicación recibe un `ValueListenable<String>` obtenido de `selector.tema`, ¿qué puede hacer con él y qué no puede hacer mediante ese tipo? ¿Quién debe llamar a `selector.dispose()`?

<details>
<summary>Ver respuesta</summary>

Puede leer `.value` y registrar o retirar listeners. Mediante ese tipo no puede asignar a `.value` ni llamar a `dispose`. El propietario del selector, el test en este ejemplo, es quien lo libera; el consumidor solo retira los listeners que registró.

</details>

## 4. La regla vive en la operación

Ahora que todos los cambios pasan por `seleccionar`, tenemos **un solo lugar** donde escribir la regla de los nombres. Antes de mirar los `expect`, predice qué ocurre con `azul` y con la segunda selección de `oscuro`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

class SelectorTema {
  final _permitidos = const ['claro', 'oscuro', 'bosque'];
  final _tema = signal('claro');

  ValueListenable<String> get tema => _tema;

  bool seleccionar(String nombre) {
    if (!_permitidos.contains(nombre)) {
      return false;
    }
    _tema.value = nombre;
    return true;
  }

  void dispose() => _tema.dispose();
}

void main() {
  test('la regla se comprueba sin widgets', () {
    final selector = SelectorTema();
    addTearDown(selector.dispose);
    final registro = <String>[];
    void escuchar() => registro.add(selector.tema.value);
    selector.tema.addListener(escuchar);
    addTearDown(() => selector.tema.removeListener(escuchar));

    expect(selector.seleccionar('azul'), isFalse);
    expect(selector.tema.value, 'claro');
    expect(registro, isEmpty);

    expect(selector.seleccionar('oscuro'), isTrue);
    expect(selector.seleccionar('oscuro'), isTrue);
    expect(selector.tema.value, 'oscuro');
    expect(registro, ['oscuro']);
  });
}
```

1. `azul` no está en la lista: la operación devuelve `false` antes de tocar la señal. El valor sigue en `claro` y no hay aviso. Devolver un `bool` es una decisión de este ejemplo; otro diseño podría lanzar un error.
2. La primera selección de `oscuro` pasa la regla, escribe en la señal y produce un aviso.
3. La segunda también pasa la regla y devuelve `true`, pero la señal compara el valor con `==`, descarta el cambio y no avisa. Hay **dos decisiones en dos sitios**: el controlador decide si la petición es admisible y la señal decide si el valor cambió.

Esta prueba no monta ningún widget y aun así comprueba la regla completa. Esa es una ventaja concreta de la separación: no hace falta dibujar un botón para saber qué pasa con un nombre no admitido. Una regla escrita en el callback de un botón solo se ejecuta si alguien pulsa ese botón, y habría que repetirla en cada botón que cambie el tema.

No toda regla pertenece al controlador. «Este tema se muestra con letra grande» describe la interfaz, y «el tema claro tiene borde 1» es un dato. Pregúntate si la regla decide **qué cambios del estado son válidos**.

### Practica 4

Añade a `SelectorTema` una operación `alternar()` que pase de `claro` a `oscuro` y de cualquier otro nombre a `claro`. Partiendo de `claro`, ¿qué contiene `registro` después de llamarla dos veces? ¿Hace falta montar un widget para comprobarlo?

<details>
<summary>Ver respuesta</summary>

```dart
void alternar() {
  _tema.value = _tema.value == 'claro' ? 'oscuro' : 'claro';
}
```

Es un fragmento para añadir a la clase. `registro` contiene `['oscuro', 'claro']`: cada llamada produce un valor distinto del actual y un aviso. No hace falta un widget, porque la operación y su resultado se pueden comprobar con un `test` normal.

</details>

## 5. El nombre no hace nada

¿Debería llamarse `SelectorTemaController`? Puede ser una buena idea si ayuda a quien lee el código, pero el cambio de nombre no añade nada. `controller` no es una palabra clave de Dart ni una clase base que debamos extender. Comprobemos qué ofrecen tres objetos con ese nombre:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class TemaController {
  var tema = 'claro';
}

void main() {
  test('la palabra controller no aporta comportamiento', () {
    final sinAvisos = TemaController();
    final daisy = DaisyThemeController();
    final texto = TextEditingController(text: 'hola');
    addTearDown(daisy.dispose);
    addTearDown(texto.dispose);

    expect(sinAvisos, isNot(isA<Listenable>()));

    expect(daisy, isNot(isA<Listenable>()));
    expect(daisy.theme, isA<Listenable>());

    expect(texto, isA<ValueNotifier<TextEditingValue>>());
    expect(texto.text, 'hola');
  });
}
```

1. `TemaController` se llama así, pero solo tiene un campo mutable: no se puede escuchar y cualquiera puede asignarlo. Es un mal controlador, porque el nombre promete una responsabilidad que la clase no cumple.
2. `DaisyThemeController` es una clase propia del proyecto. El propio objeto no es un `Listenable`; lo que se escucha es la vista que ofrece su getter `theme`.
3. `TextEditingController` es una clase de Flutter que extiende `ValueNotifier<TextEditingValue>`: administra el texto y la selección de un campo editable. Comparte la palabra con los otros dos, no su implementación ni su contrato.

Por tanto, lo que define a un controlador es lo que hace. Para saber qué ofrece uno concreto hay que leer sus tipos y sus métodos, igual que distinguías en la unidad 3 un contrato de una implementación.

### Practica 5

Renombramos `SelectorTema` a `TemaController` sin tocar su cuerpo, y `DaisyThemeController` pasa a llamarse `DaisyThemeHolder`. ¿Cambia el comportamiento de alguno? ¿Qué tendríamos que cambiar para que dejara de ser un controlador en el sentido de esta unidad?

<details>
<summary>Ver respuesta</summary>

El comportamiento no cambia: solo tendríamos que actualizar los lugares que usan esos nombres. Dejaría de ser un controlador si perdiera esa responsabilidad, por ejemplo si no conservara el estado o si no ofreciera operaciones para cambiarlo. El nombre informa a las personas, pero Dart no le asigna ningún comportamiento.

</details>

## 6. Dos controladores, dos estados

Cada vez que se construye un controlador se crea un objeto nuevo con su propia señal. Por eso una aplicación puede tener el tema principal y, a la vez, una vista previa con otro tema. Predice qué nombre tiene cada uno al final:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cada controlador administra su propio estado', () {
    final principal = DaisyThemeController();
    final vistaPrevia = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    addTearDown(principal.dispose);
    addTearDown(vistaPrevia.dispose);
    final otraReferencia = principal;

    principal.setTheme(DaisyThemes.dark);
    expect(principal.theme.value.name, 'Dark');
    expect(vistaPrevia.theme.value.name, 'Cupcake');
    expect(otraReferencia.theme.value.name, 'Dark');

    vistaPrevia.setTheme(DaisyThemes.dark);
    expect(identical(principal.theme.value, vistaPrevia.theme.value), isTrue);

    principal.setTheme(DaisyThemes.light);
    expect(principal.theme.value.name, 'Light');
    expect(vistaPrevia.theme.value.name, 'Dark');
  });
}
```

1. `principal` y `vistaPrevia` son dos objetos creados por separado, y cada constructor crea su propia señal. Cambiar uno no toca el valor del otro.
2. `otraReferencia` no es un tercer controlador: apunta al mismo objeto que `principal`, así que ve el mismo cambio. Contar referencias no equivale a contar objetos, como en la unidad 3.
3. Cuando ambos seleccionan `DaisyThemes.dark`, `identical` da `true`: los dos apuntan al mismo modelo. Compartir un dato inmutable no comparte la selección. Lo comprueba el paso siguiente: `principal` vuelve a `Light` y `vistaPrevia` sigue en `Dark`.

Cada controlador tiene también su propia vida. Según la unidad 13, cada propietario libera el suyo; aquí el test creó los dos y registra las dos limpiezas. Si dos partes deben ver **la misma** selección, se les presta la misma instancia. La [unidad 17](17-instancias-static-y-servicio-global.md) estudia una forma de compartirla mediante un servicio global.

### Practica 6

Dos widgets muestran el tema y deben cambiar siempre a la vez. Otro debe poder probar temas sin afectar a los demás. ¿Cuántos controladores necesitas y quién usa cada uno?

<details>
<summary>Ver respuesta</summary>

Dos controladores. Los dos primeros widgets comparten una instancia, porque deben ver la misma selección; el tercero usa otra, porque su selección es independiente. Quien crea cada controlador conserva la responsabilidad de liberarlo.

</details>

## 7. El widget muestra y pide

Falta la tercera responsabilidad. Un widget lee el estado para mostrarlo y traduce una pulsación en una llamada a una operación. Usaremos `GestureDetector`, un widget de Flutter que ejecuta su callback `onTap` al detectar una pulsación. `tester.tap` simula esa pulsación en la prueba. Antes de mirar los `expect`, predice el texto y el contador tras pulsar:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

class SelectorTema {
  final _tema = signal('claro');

  ValueListenable<String> get tema => _tema;

  void alternar() {
    _tema.value = _tema.value == 'claro' ? 'oscuro' : 'claro';
  }

  void dispose() => _tema.dispose();
}

void main() {
  testWidgets('el botón llama a una operación', (tester) async {
    final selector = SelectorTema();
    addTearDown(selector.dispose);
    var builds = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            SignalBuilder(
              builder: (_) {
                builds++;
                return Text('Tema: ${selector.tema.value}');
              },
            ),
            GestureDetector(
              onTap: selector.alternar,
              child: const Text('Cambiar'),
            ),
          ],
        ),
      ),
    );
    expect(find.text('Tema: claro'), findsOneWidget);
    expect(builds, 1);

    await tester.tap(find.text('Cambiar'));
    expect(selector.tema.value, 'oscuro');
    expect(find.text('Tema: claro'), findsOneWidget);

    await tester.pump();
    expect(find.text('Tema: oscuro'), findsOneWidget);
    expect(builds, 2);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Paso a paso:

1. `SignalBuilder` lee `selector.tema.value` durante su callback. El tipo declarado es `ValueListenable`, pero el objeto real es la señal: la lectura ejecuta su getter y queda rastreada, como en la unidad 10.
2. `onTap: selector.alternar` **entrega** el método sin ejecutarlo, como en la unidad 2. Escribir `selector.alternar()` lo ejecutaría durante la construcción y entregaría su resultado.
3. `tester.tap` simula la pulsación. El `GestureDetector` llama a `alternar` y el valor cambia a `oscuro`. El texto del árbol sigue diciendo `claro`, porque todavía no se ha procesado ningún frame.
4. `pump` procesa el frame: el `SignalBuilder` vuelve a construirse y muestra `oscuro`. El contador pasa a 2.

El widget no conoce el nombre siguiente ni escribe en la señal: muestra lo que lee y pide `alternar`. Si la regla cambia, el widget no tiene que cambiar.

La prueba demuestra el recorrido en este árbol: pulsación simulada, operación, valor y nueva construcción. No demuestra cómo se ve en una pantalla física ni cuántas construcciones habría en un árbol mayor. Aquí el test crea el selector porque es breve. En una aplicación real hay que elegir un lugar que lo conserve entre reconstrucciones; `State` y su ciclo de vida se estudian en las unidades 18 y 19.

### Practica 7

Sustituimos el callback por `onTap: () => selector.alternar()`. ¿Cambia el resultado de la prueba? Y si un segundo `SignalBuilder` muestra el mismo tema, ¿hay que tocar `SelectorTema`?

<details>
<summary>Ver respuesta</summary>

El resultado no cambia: es otra función que, al ejecutarse, llama a `alternar`. Tampoco hay que tocar `SelectorTema`. El nuevo consumidor lee la misma fuente y registra su propia dependencia. Añadir una forma de mostrar el dato es trabajo de la interfaz, no del controlador.

</details>

## 8. El reparto en DaisyUI

Apliquemos las tres preguntas al proyecto. Este fragmento procede del [controlador real](../../../lib/themes/application/daisy_theme_controller.dart); no es un archivo completo:

```dart
final class DaisyThemeController {
  DaisyThemeController({
    DaisyThemeModel initialTheme = DaisyThemes.light,
  }) : _palette = FlutterSignal<DaisyThemeModel>(initialTheme);

  final FlutterSignal<DaisyThemeModel> _palette;

  ValueListenable<DaisyThemeModel> get theme => _theme;

  void setTheme(DaisyThemeModel theme) => _palette.value = theme;

  void dispose() => _palette.dispose();
}
```

Reconoces las mismas piezas que en `SelectorTema`: el estado es `_palette`, la lectura es `theme`, la operación de cambio es `setTheme` y la limpieza es `dispose`. El fragmento omite el campo `_theme` y la clase `_ThemeListenable`, que se estudian en la unidad 16; la sintaxis del constructor corresponde a la unidad 15.

Para la interfaz usaremos la versión del ejemplo anterior al commit `41fe41f`, que tenía dos botones para cambiar de tema. El ejemplo actual ya no los tiene, pero puedes consultar esa versión con `git show 41fe41f~1:example/lib/main.dart`, y está reproducida en el [apartado 8 de la unidad 25](25-scopes-anidados-e-independencia.md#8-el-ejemplo-anterior-completo). Este fragmento pertenece al botón de `_ThemeExample`:

```dart
onPressed: () => DaisyThemeService.setTheme(
  theme.id == DaisyThemes.light.id
      ? DaisyThemes.dark
      : DaisyThemes.light,
),
```

Y este al botón de la vista previa, en `_ThemePreviewState`:

```dart
onPressed: () => _controller.setTheme(
  theme.id == DaisyThemes.dark.id
      ? DaisyThemes.cupcake
      : DaisyThemes.dark,
),
```

Aquí hay una diferencia con nuestro `alternar`: **la decisión de cuál es el siguiente tema vive en el widget**. El controlador real no tiene reglas propias: almacena el valor, lo deja observar, acepta el modelo que recibe y se libera. Esta prueba lo comprueba:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el controlador real no filtra qué tema recibe', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    var avisos = 0;
    void escuchar() => avisos++;
    controller.theme.addListener(escuchar);
    addTearDown(() => controller.theme.removeListener(escuchar));
    final propio = DaisyThemes.light.copyWith(id: 'propio', name: 'Propio');

    controller.setTheme(propio);
    expect(controller.theme.value.name, 'Propio');
    expect(avisos, 1);

    controller.setTheme(propio.copyWith());
    expect(identical(controller.theme.value, propio), isTrue);
    expect(avisos, 1);
  });
}
```

Un tema creado en la prueba, que no aparece en `DaisyThemes`, se acepta sin más: `setTheme` no tiene ninguna lista de permitidos. La copia equivalente no produce aviso, pero esa decisión es de la señal, que compara con `==` como en las unidades 8 y 9. El método `setTheme` no contiene esa comparación.

¿Es esto un defecto? Es una decisión de diseño con consecuencias en ambos sentidos. Los dos botones alternan entre parejas de temas distintas, y la misma clase sirve para ambos porque no impone ninguna política. A cambio, esa lógica solo se ejecuta al pulsar, se comprueba con pruebas de widget y habría que repetirla si otro botón necesitara la misma alternancia. En nuestro `SelectorTema` elegimos lo contrario. La pregunta útil es **qué reglas debe garantizar el estado sea quien sea el que lo cambie**, y cuáles dependen de una pantalla concreta.

Dos piezas de esa versión siguen esta separación de otra manera. `_ThemePreviewState` crea su propio controlador en `initState` y lo libera en `dispose`: es su propietario, como en la unidad 13. Y `_ThemeExample` no crea ninguno: llama a `DaisyThemeService`, que conserva un controlador compartido. Lo estudiaremos en la unidad 17.

### Practica 8

Clasifica estas piezas como modelo, controlador o widget, e indica qué hace cada una: `DaisyThemes.dark`, `setTheme`, `_palette`, el `onPressed` de la vista previa y el `Text` que muestra `theme.name`. ¿Por qué podían `MyApp` y la vista previa de esa versión mostrar temas diferentes en la misma pantalla?

<details>
<summary>Ver respuesta</summary>

`DaisyThemes.dark` es un modelo: datos de un tema. `setTheme` y `_palette` pertenecen al controlador: la operación de cambio y la señal que conserva el estado. El `onPressed` y el `Text` pertenecen al widget: el primero decide qué tema pedir y llama a la operación, y el segundo muestra un dato leído.

Mostraban temas diferentes porque usaban controladores diferentes: la aplicación usaba el del servicio y la vista previa creaba el suyo. Cada controlador conserva su propia señal, así que cambiar uno no altera el valor del otro.

</details>

## Ejercicio final: un carrusel de temas

Escribe una prueba de widgets con un controlador propio `CarruselTemas` que:

1. Tenga una señal privada de `DaisyThemeModel` que empiece en `DaisyThemes.light`, y una lista privada con `light`, `dark` y `cupcake`.
2. Exponga un getter `tema` de tipo `ValueListenable<DaisyThemeModel>` y un método `dispose`.
3. Ofrezca `siguiente()`, que pase al tema posterior de la lista y vuelva al primero después del último. Puedes usar `(indice + 1) % lista.length`: `%` devuelve el resto de la división, así que el índice 3 de esa lista vuelve a 0.
4. Ofrezca `seleccionar(DaisyThemeModel tema)`, que devuelva `false` sin cambiar nada si el tema no está en la lista.

Después, en la prueba:

5. Compruebe sin montar widgets que un tema con otro `id` se rechaza y que `DaisyThemes.dark` se acepta.
6. Monte dos carruseles, cada uno con un `SignalBuilder` que cuente sus construcciones y un `GestureDetector` con el texto del botón, y pulse tres veces el del primero con un `pump` tras cada pulsación.
7. Compruebe los textos y los contadores, desmonte el árbol y libere los carruseles.

Predice el resultado antes de abrir la solución. Clasifica además cada pieza como modelo, controlador o widget. Como variación, razona qué tendrías que cambiar si los dos paneles debieran mostrar siempre el mismo tema.

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CarruselTemas {
  final _temas = const [
    DaisyThemes.light,
    DaisyThemes.dark,
    DaisyThemes.cupcake,
  ];
  final _actual = signal<DaisyThemeModel>(DaisyThemes.light);

  ValueListenable<DaisyThemeModel> get tema => _actual;

  void siguiente() {
    final indice = _temas.indexOf(_actual.value);
    _actual.value = _temas[(indice + 1) % _temas.length];
  }

  bool seleccionar(DaisyThemeModel tema) {
    if (!_temas.contains(tema)) {
      return false;
    }
    _actual.value = tema;
    return true;
  }

  void dispose() => _actual.dispose();
}

void main() {
  test('la regla del carrusel no necesita widgets', () {
    final carrusel = CarruselTemas();
    addTearDown(carrusel.dispose);
    final propio = DaisyThemes.light.copyWith(id: 'propio');

    expect(carrusel.seleccionar(propio), isFalse);
    expect(carrusel.tema.value, DaisyThemes.light);
    expect(carrusel.seleccionar(DaisyThemes.dark), isTrue);
    expect(carrusel.tema.value, DaisyThemes.dark);
  });

  testWidgets('dos carruseles independientes', (tester) async {
    final primero = CarruselTemas();
    final segundo = CarruselTemas();
    addTearDown(primero.dispose);
    addTearDown(segundo.dispose);
    final builds = <String, int>{'primero': 0, 'segundo': 0};

    Widget panel(String nombre, CarruselTemas carrusel) => Column(
      children: [
        SignalBuilder(
          builder: (_) {
            builds[nombre] = builds[nombre]! + 1;
            return Text('$nombre: ${carrusel.tema.value.name}');
          },
        ),
        GestureDetector(
          onTap: carrusel.siguiente,
          child: Text('Avanzar $nombre'),
        ),
      ],
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [panel('primero', primero), panel('segundo', segundo)],
        ),
      ),
    );
    expect(builds, {'primero': 1, 'segundo': 1});

    await tester.tap(find.text('Avanzar primero'));
    await tester.pump();
    expect(find.text('primero: Dark'), findsOneWidget);

    await tester.tap(find.text('Avanzar primero'));
    await tester.pump();
    expect(find.text('primero: Cupcake'), findsOneWidget);

    await tester.tap(find.text('Avanzar primero'));
    await tester.pump();
    expect(find.text('primero: Light'), findsOneWidget);
    expect(find.text('segundo: Light'), findsOneWidget);
    expect(builds, {'primero': 4, 'segundo': 1});

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

El tema con otro `id` no es igual a ninguno de la lista, así que `contains` da `false` y no se escribe en la señal. `DaisyThemes.dark` sí está y se acepta. En la prueba de widgets, cada pulsación avanza solo el primer carrusel: pasa por `Dark`, `Cupcake` y vuelve a `Light`. Su `SignalBuilder` se construye una vez al montar y una por cada cambio, lo que da 4. El segundo no recibe cambios y se queda en 1 en este árbol. Las reglas se han comprobado sin widgets y los textos con widgets: son dos pruebas de cosas distintas.

`DaisyThemes.light`, `dark` y `cupcake` son modelos. `CarruselTemas` es el controlador: conserva la señal, contiene la regla y se libera. `panel` crea los widgets que muestran y piden. El test es el propietario de ambos carruseles.

Para que los dos paneles mostraran siempre el mismo tema bastaría con entregar el mismo carrusel a ambos en lugar de crear dos. `CarruselTemas` no cambiaría: compartir o no es una decisión de quien lo crea y lo entrega.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué problema aparece cuando todas las pantallas pueden escribir en la misma señal? **Apartado 1.**
2. ¿Qué pregunta responde el modelo, cuál el controlador y cuál el widget? **Apartado 2.**
3. ¿Por qué `setTheme(grueso)` no modifica el modelo `original`? **Apartado 2.**
4. ¿Qué papel cumple cada miembro de `SelectorTema`: señal, getter, operación y `dispose`? **Apartado 3.**
5. ¿Qué decide el controlador y qué decide la señal cuando se selecciona otra vez `oscuro`? **Apartado 4.**
6. ¿Qué ventaja da probar una regla sin montar widgets? **Apartado 4.**
7. ¿Qué aporta la palabra `controller` al comportamiento? ¿Qué tienen en común `DaisyThemeController` y `TextEditingController`? **Apartado 5.**
8. ¿Por qué dos controladores pueden administrar temas diferentes, aunque apunten al mismo modelo? **Apartado 6.**
9. En la prueba del botón, ¿quién llama a `alternar`, cuándo cambia el valor y cuándo el texto? **Apartado 7.**
10. ¿Dónde se decide hoy el siguiente tema en el ejemplo de DaisyUI? ¿Qué ganas y qué pierdes con ese reparto? **Apartado 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y clasifiques sus piezas sin dudar, explicando por qué dos controladores pueden administrar temas diferentes. La unidad 15 estudia cómo se construye el controlador: constructores, parámetros nombrados, lista de inicialización y campos privados.

## Para consultar si necesitas reforzar

- [Conceptos de arquitectura de Flutter](https://docs.flutter.dev/app-architecture/concepts): separación de responsabilidades y fuente única de verdad. Usa otros nombres, como *view model*; aquí importa la idea de separar.
- [`TextEditingController`](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html): un controlador de Flutter, con su propio contrato, para comparar con el del proyecto.
- [`GestureDetector`](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html) y [`WidgetTester.tap`](https://api.flutter.dev/flutter/flutter_test/WidgetController/tap.html): pulsación real y simulada.
- [`SignalBuilder`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/SignalBuilder-class.html): conexión entre lecturas de señales y construcciones. Compara `latest` con la versión instalada.
- [Controlador](../../../lib/themes/application/daisy_theme_controller.dart), [modelo](../../../lib/themes/domain/theme.dart) y [catálogo de temas](../../../lib/themes/application/daisy_themes.dart): las piezas reales repartidas en esta unidad.
