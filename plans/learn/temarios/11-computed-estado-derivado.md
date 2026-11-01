# 11. `computed`: estado derivado

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 10](10-dependencias-reactivas-y-contextos-de-observacion.md)

- **Bloque:** Signals: almacenar y relacionar estado.
- **Estado de estudio:** pendiente.
- **Investigación de fuentes:** 31 de octubre de 2026.

## Qué vas a conseguir

Podrás decidir si un dato debe almacenarse, calcularse a partir de otros o exponerse mediante una vista de lectura.
Seguirás la creación de un `computed`, su primer cálculo, las lecturas posteriores, un cambio en sus dependencias y la
siguiente evaluación. Distinguirás la invalidación del cálculo, la comparación del resultado, un aviso al listener y
una reconstrucción de Flutter.

Al final compararemos Signals con el controlador real de DaisyUI y comprobaremos qué ocurre al leer su vista pública
desde un `computed`. El controlador usa `ValueNotifier`, no una señal de Signals. `effect` y la propiedad de recursos
se estudian en las unidades 12 y 13; aquí se presentan solo las piezas necesarias para entender las prácticas. Preparar esta guía no marca la unidad como dominada.

## Versiones y forma de practicar

Se contrastaron las dependencias resueltas del proyecto: **`signals_flutter` 7.1.0**, **`signals_core` 7.0.0** y **
`preact_signals` 7.0.0**. La explicación de caché, seguimiento y comparación se refiere a esas versiones. Los
resultados de ejemplos con otras opciones, lotes, callbacks reentrantes u otras versiones pueden variar. Los enlaces
a documentación `latest` pueden cambiar; consulta también `../../../pubspec.lock` y el código instalado.

Los ejemplos A–E y la solución del proyecto son archivos de **pruebas Flutter completos e independientes**. Antes de
abrir cada bloque, responde a la predicción que lo precede; después usa sus `expect` para contrastar tus respuestas.
Copia uno cada vez a `test/estudio_computed_test.dart` dentro del repositorio y ejecuta:

```shell
flutter test --no-pub test/estudio_computed_test.dart
```

Necesitan las dependencias ya resueltas del proyecto; no son programas independientes listos para DartPad. Los bloques
que se presentan como fragmentos no son programas completos. Predice los resultados antes de ejecutar y consulta las
soluciones después. Elimina tu archivo de práctica al terminar o consérvalo con otro nombre si lo deseas.

Los contadores `calculos` instrumentan los ejemplos para observar las evaluaciones. **No representan una
recomendación de añadir efectos secundarios a cálculos de producción.** En aplicaciones reales, diseña el callback como
una derivación sin efectos externos; si necesita persistir, enviar solicitudes o registrar acciones, estudia una
solución explícita de efectos y ciclo de vida en la unidad 12.

## 11.1. Dato almacenado, derivado y vista de lectura

Imagina una pantalla que debe mostrar `Tema: Light`. Tenemos varias piezas diferentes:

- **Dato almacenado:** el modelo de tema actual, que puede seleccionarse o reemplazarse. En DaisyUI lo conserva la
  instancia privada `ValueNotifier` llamada `_palette` del controlador.
- **Dato derivado:** el texto construido a partir del nombre de ese modelo, por ejemplo `Tema: ${tema.name}`. Su
  contenido depende del tema; no necesita convertirse en una segunda fuente de verdad modificable por separado.
- **Vista de lectura:** una interfaz que deja consultar y escuchar el valor existente sin dar las mismas operaciones
  de modificación. Puede delegar en la fuente sin guardar otro tema ni calcular uno nuevo.

Si se guardan tema y etiqueta como dos valores modificables, cada actualización debe mantenerlos coherentes. Si una
ruta cambia el tema y olvida actualizar la etiqueta, pueden discrepar. Una derivación expresa de dónde sale el dato;
una función o getter puntual puede bastar si solo hace falta calcularlo en el momento de usarlo. `computed` es útil
cuando además se quiere una **fuente reactiva derivada**, con seguimiento de dependencias y caché compartida entre
lecturas u observadores. No es obligatorio envolver cada interpolación sencilla en uno.

Piensa en una receta que usa ingredientes guardados. El resultado depende de esos ingredientes, mientras la receta
indica cómo obtenerlo. Guardar el último plato como caché evita repetir la receta cuando nada pertinente cambió. La
analogía no explica cómo se detecta un ingrediente utilizado ni cuándo se revisa la caché: eso lo hace la
implementación con lecturas rastreadas y versiones.

### Comprobación

- ¿Qué sería la fuente de verdad si una etiqueta se obtiene siempre del tema?
- ¿Qué problema aparece si se modifican tema y etiqueta de forma independiente?
- ¿Por qué una vista de lectura que devuelve el mismo tema no tiene que calcular una transformación?

### Practica 1

El usuario elige un tema y la interfaz muestra `Tema: claro`. ¿Qué dato es almacenado y cuál puede obtenerse a partir de él?

<details>
<summary>Ver respuesta</summary>

El tema elegido es el dato almacenado; la etiqueta se calcula a partir de su nombre. Si guardamos ambos como estados modificables independientes, tendríamos que mantenerlos coherentes.

</details>

## 11.2. Crear y leer un `computed`

En `signals_flutter`, [
`computed<T>`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/computed.html)
recibe una función `T Function()` y crea un `FlutterComputed<T>`. El objeto resultante representa un valor derivado;
`.value` lo consulta. La API normal no ofrece un setter `value` para asignar ese resultado directamente: se cambian las
fuentes utilizadas por la función. `FlutterComputed<T>` implementa `ValueListenable<T>`, por lo que puede escucharse
con las interfaces de Flutter, y también dispone de capacidades propias de Signals.

```dart

final tema = signal<String>('claro');
final FlutterComputed<String> titulo = computed<String>(
      () => 'Tema: ${tema.value}',
);
```

`tema` referencia una señal mutable; `titulo` referencia **otro objeto**, un cálculo derivado. El `String` que se lee
mediante `titulo.value` es el resultado, no el objeto `titulo`. La función `() => ...` se entrega para que el
`computed` la ejecute cuando corresponda; escribirla no equivale a ejecutarla en ese momento.

En la implementación instalada, durante la evaluación el núcleo coloca el `computed` como contexto reactivo de
cálculo. Las lecturas de `.value` de las fuentes registran la relación con ese contexto; al terminar se restauran el
contexto anterior y las dependencias utilizadas. Una lectura hecha antes de entrar en la función no se vuelve
reactiva por usar después su resultado dentro del cálculo.

### Comprobación

- ¿Cuál es el objeto fuente y cuál el objeto calculado en el fragmento?
- ¿Por qué se entrega una función en lugar de pasar directamente un `String`?
- ¿Qué objeto debe modificarse para cambiar el resultado ordinario del cálculo?

### Practica 2

Si `titulo = computed(() => tema.value)` y escribimos `titulo.value = ...`, ¿qué fuente se pretende cambiar?

<details>
<summary>Ver respuesta</summary>

Un `computed` representa un resultado de lectura, no un setter ordinario para cambiarlo. Debemos cambiar `tema`, que es la fuente mutable; además, si solo se necesita una vista del mismo valor quizá no haga falta ese derivado.

</details>

## 11.3. Caché y evaluación bajo demanda

### Ejemplo A: primer cálculo, reutilización y cambio

**Antes de mirar el test:** crea mentalmente `tema = 'claro'` y un `computed` que devuelve
`'Tema: ${tema.value}'` y aumenta `calculos` cada vez que se ejecuta. Sin listeners, sigue esta secuencia:
créalo, lee su valor dos veces, cambia `tema` a `'oscuro'` y vuelve a leer dos veces. ¿Qué valor obtienes en cada
lectura y cuánto vale `calculos` después de cada paso?

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('evaluación bajo demanda y caché sin observadores', () {
    final tema = signal('claro');
    var calculos = 0;
    final titulo = computed(() {
      calculos++;
      return 'Tema: ${tema.value}';
    });
    addTearDown(tema.dispose);
    addTearDown(titulo.dispose);

    expect(calculos, 0);
    expect(titulo.value, 'Tema: claro');
    expect(calculos, 1);
    expect(titulo.value, 'Tema: claro');
    expect(calculos, 1);
    tema.value = 'oscuro';
    expect(calculos, 1);
    expect(titulo.value, 'Tema: oscuro');
    expect(calculos, 2);
    expect(titulo.value, 'Tema: oscuro');
    expect(calculos, 2);
  });
}
```

### Recorrido paso a paso

1. Crear `titulo` guarda la función; en este test, todavía no la ejecuta: `calculos` vale cero.
2. La primera lectura exige un resultado. Se ejecuta la función, se lee `tema.value`, se registra esa dependencia y se
   guarda `Tema: claro` como resultado. El contador pasa a uno.
3. Otra lectura sin cambio pertinente reutiliza el resultado: el contador sigue en uno.
4. El test asigna `oscuro` a la fuente. **En este ejemplo no hay un observador activo del derivado**, así que la
   asignación no ejecuta la función del `computed` en ese momento.
5. La siguiente lectura comprueba las versiones de las fuentes conocidas, detecta el cambio y vuelve a calcular. El
   nuevo resultado es `Tema: oscuro`; una lectura adicional lo reutiliza.

La caché no es una variable que el programador deba actualizar a mano. La implementación compara versiones y, cuando
corresponde, ejecuta la función y actualiza la información de dependencias. Si cambia una señal ajena, el núcleo puede
revisar si las fuentes del cálculo cambiaron sin tener que ejecutar la función de nuevo: eso se observa en el ejemplo C.
No debes leer «bajo demanda» como «solo se calcula si mi código escribe `.value`»: suscribirse también puede necesitar
una lectura inicial, y un observador activo puede exigir una actualización cuando cambia una fuente.

### Comprobación

- ¿Cuántas ejecuciones de la función hay antes de la primera lectura? ¿Y tras leer dos veces?
- ¿Por qué en A no se ejecuta la función inmediatamente al asignar `oscuro`?
- ¿Qué provoca la segunda evaluación y qué se conserva entre lecturas?

### Practica 3

En A, sin observador activo, si leemos `titulo` dos veces sin cambiar `tema`, ¿cuántas veces se ejecuta el cálculo?

<details>
<summary>Ver respuesta</summary>

Una en esa secuencia: la primera lectura obtiene y guarda el resultado y la segunda reutiliza la caché. Cambiar la fuente y volver a leerlo provoca una nueva evaluación en el caso mostrado.

</details>

## 11.4. Observar el resultado y comparar valores

Un consumidor puede registrar un listener sobre el `FlutterComputed`, que satisface `ValueListenable`. En la versión
instalada, el puente de Flutter usa una suscripción de Signals. Una fuente puede cambiar y hacer que se revise el
cálculo; eso no significa necesariamente que el **resultado derivado** cambie.

### Ejemplo B: una comparación que permanece igual

**Antes de mirar el test:** parte de `borde = 1` y un derivado `borde.value >= 2`, con un contador de cálculos.
Registra un listener que guarde los valores recibidos; después asigna al borde 2, 3 y 1, en ese orden. Retira el
listener, asigna 2 y lee el derivado. ¿Cuándo se calcula, qué valores guarda el listener y qué devuelve la última
lectura? Apunta tu predicción, incluso si aún no sabes qué ocurre al registrar la escucha.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('observar un resultado que a veces no cambia', () {
    final borde = signal(1);
    var calculos = 0;
    final grueso = computed(() {
      calculos++;
      return borde.value >= 2;
    });
    addTearDown(borde.dispose);
    addTearDown(grueso.dispose);
    final valores = <bool>[];
    void escuchar() => valores.add(grueso.value);

    grueso.addListener(escuchar);
    expect(calculos, 1);
    expect(valores, isEmpty);
    borde.value = 2;
    expect(calculos, 2);
    expect(valores, [true]);
    borde.value = 3;
    expect(calculos, 3);
    expect(valores, [true]);
    borde.value = 1;
    expect(calculos, 4);
    expect(valores, [true, false]);
    grueso.removeListener(escuchar);
    borde.value = 2;
    expect(calculos, 4);
    expect(grueso.value, isTrue);
    expect(calculos, 5);
  });
}
```

### Recorrido paso a paso

- Al registrar el listener se evalúa `grueso` por primera vez: `1 >= 2` es `false`. Hay un cálculo y ningún aviso
  externo inicial: con `runCallbackOnListen` en su valor predeterminado, la suscripción obtiene el valor inicial sin
  llamar al callback externo.
- `borde = 2` cambia la fuente: el derivado vuelve a evaluar, pasa de `false` a `true` y el listener lee `true`.
- `borde = 3` vuelve a cambiar la fuente y ejecuta de nuevo el cálculo, pero `3 >= 2` sigue dando `true`. En esta
  implementación el resultado anterior se compara con el nuevo mediante `==`; al ser iguales, la suscripción del
  ejemplo no ejecuta otro callback externo.
- `borde = 1` produce `false` y el segundo aviso. Tras retirar el listener, cambiar el borde no ejecuta inmediatamente
  el cálculo en este caso; la siguiente lectura lo actualiza.

Aquí hay **cinco evaluaciones** al terminar el test y dos avisos antes de retirar el listener. El resultado se
recalculó una vez aunque siguió siendo igual. No se puede contar automáticamente un aviso por cada escritura de la
fuente ni un build por cada evaluación. Esta conclusión se refiere al listener y configuración probados; otros
consumidores pueden tener otras dependencias u otras causas de reconstrucción.

El código del núcleo `preact_signals` 7.0.0 conserva una versión del resultado y usa `_internalValue != val` al
refrescar un `computed` ya inicializado, con ramas adicionales para inicialización y errores. La comparación de la
**fuente** y la comparación del **resultado derivado** son decisiones distintas. Por ejemplo, una señal fuente puede
aceptar 2 → 3 y el resultado booleano seguir siendo `true`.

### Comprobación

- ¿Por qué registrar el listener lleva el contador a uno sin agregar un aviso a `valores`?
- En el cambio 2 → 3, ¿se calcula otra vez? ¿Se agrega un aviso? ¿Por qué?
- ¿Por qué la lectura posterior a retirar el listener vuelve a calcular el resultado en este ejemplo?

### Practica 4

En B, el borde cambia de 2 a 3. ¿Se recalcula el booleano? ¿El listener recibe otro aviso?

<details>
<summary>Ver respuesta</summary>

En esta prueba sí se recalcula, pero `borde >= 2` sigue siendo `true`. Como el resultado derivado no cambia según la comparación del paquete, no se añade otro aviso externo.

</details>

## 11.5. Dependencias dinámicas y capturas

### Ejemplo C: elegir una fuente

**Antes de mirar el test:** `usarLocal` empieza en `true`, `local` en `'claro'` y `global` en `'oscuro'`.
Un derivado lee `usarLocal` y, según su valor, lee `local` o `global`. Sin listener, léelo y luego repite la lectura
después de cada cambio: `global = 'bosque'`, `usarLocal = false`, `local = 'noche'` y `global = 'nieve'`.
¿Qué devuelve cada lectura, cuántas veces se ejecuta el cálculo y qué fuentes utiliza en cada rama?

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('las dependencias siguen la rama calculada', () {
    final usarLocal = signal(true);
    final local = signal('claro');
    final global = signal('oscuro');
    var calculos = 0;
    final etiqueta = computed(() {
      calculos++;
      return usarLocal.value ? local.value : global.value;
    });
    addTearDown(usarLocal.dispose);
    addTearDown(local.dispose);
    addTearDown(global.dispose);
    addTearDown(etiqueta.dispose);

    expect(etiqueta.value, 'claro');
    expect(calculos, 1);
    global.value = 'bosque';
    expect(etiqueta.value, 'claro');
    expect(calculos, 1);
    usarLocal.value = false;
    expect(etiqueta.value, 'bosque');
    expect(calculos, 2);
    local.value = 'noche';
    expect(etiqueta.value, 'bosque');
    expect(calculos, 2);
    global.value = 'nieve';
    expect(etiqueta.value, 'nieve');
    expect(calculos, 3);
  });
}
```

La primera evaluación lee `usarLocal` y `local`. El cambio de `global` no obliga a ejecutar la función porque no se
leyó en esa rama. Al leer después de cambiar `usarLocal`, se ejecuta la otra rama y se usan `usarLocal` y `global`.
A partir de esa evaluación, cambiar solo `local` ya no exige otro cálculo de este derivado; cambiar `global` sí. En
este test el `computed` se consulta sin listener activo: la detección al leer y la activación de suscripciones cuando
hay observadores no son el mismo paso.

En términos de implementación, durante el cálculo se establece un contexto de evaluación y se registran las fuentes
realmente leídas. Después se limpian las fuentes que ya no participan en la rama nueva. Cuando un derivado obtiene su
primer suscriptor activo, el núcleo puede suscribirse a sus dependencias; al perder el último puede dejar de hacerlo.
Aun sin suscriptor, una lectura posterior debe verificar si el resultado sigue vigente. No confundas registrar qué
fuentes se usaron con afirmar que el `computed` permanece siempre suscrito activamente a todas ellas.

**Fragmento con una captura incorrecta para actualizaciones:**

```dart

final capturado = tema.value;
final titulo = computed(() => 'Tema: $capturado');
```

La función utiliza el valor ya obtenido y no ejecuta `tema.value`; cambiar la señal no la convierte en dependencia.
La corrección es leer `tema.value` dentro de la función. Lo mismo ocurre con cualquier dato externo mutable no reactivo:
cambiarlo no avisa por sí solo al cálculo. `peek()` evita rastrear deliberadamente una lectura; úsalo solo si esa
exclusión es parte del diseño y comprendes cómo se actualizará el resultado.

### Comprobación

- En C, ¿por qué el primer cambio de `global` no incrementa `calculos` al leer `etiqueta`?
- Tras cambiar de rama y leer, ¿cuáles son las dependencias pertinentes?
- ¿Por qué una variable capturada antes del callback no equivale a leer la señal dentro de él?

### Practica 5

Si capturamos `tema.value` antes de crear un `computed` y el callback usa solo ese texto, ¿el cambio posterior de `tema` queda rastreado?

<details>
<summary>Ver respuesta</summary>

No. El callback utiliza una lectura anterior; no lee la señal al calcular. Para que sea una dependencia del cálculo, hay que realizar la lectura rastreada dentro de su callback.

</details>

## 11.6. El resultado derivado en Flutter

`FlutterComputed<T>` implementa [
`ValueListenable<T>`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html).
[`ValueListenableBuilder`](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html) registra una
escucha
en ese objeto y recibe su valor para construir la interfaz. Otra integración posible es leer el derivado en un
`SignalBuilder`, estudiado en la unidad 10. El cálculo no dibuja por sí mismo: hace falta un consumidor que conecte el
aviso con Flutter.

### Ejemplo D: escuchar el valor derivado

**Antes de mirar el test:** un `ValueListenableBuilder` escucha un derivado que devuelve `'grueso'` si
`borde >= 2` y `'fino'` en otro caso. El borde empieza en 1. Tras montar el widget, cambia el borde a 2 y
procesa un frame; después cámbialo a 3 y procesa otro. ¿Qué texto se muestra en cada momento? ¿Cuántos cálculos y
construcciones esperas en este árbol aislado?

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('ValueListenableBuilder escucha el resultado derivado', (tester) async {
    final borde = signal(1);
    var calculos = 0;
    final etiqueta = computed(() {
      calculos++;
      return borde.value >= 2 ? 'grueso' : 'fino';
    });
    addTearDown(borde.dispose);
    addTearDown(etiqueta.dispose);
    var builds = 0;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ValueListenableBuilder<String>(
        valueListenable: etiqueta,
        builder: (context, valor, child) {
          builds++;
          return Text(valor);
        },
      ),
    ));
    expect(find.text('fino'), findsOneWidget);
    expect([calculos, builds], [1, 1]);
    borde.value = 2;
    await tester.pump();
    expect(find.text('grueso'), findsOneWidget);
    expect([calculos, builds], [2, 2]);
    borde.value = 3;
    await tester.pump();
    expect(find.text('grueso'), findsOneWidget);
    expect([calculos, builds], [3, 2]);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

### Recorrido y límites

Al montar, Flutter obtiene `fino` y el cálculo se ejecuta una vez. Cambiar el borde a 2 produce `grueso`: la escucha
solicita una reconstrucción y tras `pump` el texto y contador de builds cambian. Cambiar 2 a 3 hace que se ejecute de
nuevo el cálculo, pero el resultado permanece `grueso`; en este montaje el listener del derivado no vuelve a construir
el widget y el contador permanece en dos. Se desmonta el árbol antes de que el test libere los objetos que creó.

Esta prueba aísla una relación. Un `ValueListenableBuilder` puede reconstruirse por cambios de su padre u otras causas,
y otro consumidor puede escuchar además la fuente original. Un `SignalBuilder` que lea solo el derivado en un caso de
prueba equivalente también se comprobó con las versiones instaladas; no es una garantía universal de que ningún otro
widget o dependencia vaya a reconstruirse. Un `pump` demuestra el comportamiento del árbol y frames de prueba, no un
repintado observado en un dispositivo físico.

### Comprobación

- ¿Qué objeto escucha el `ValueListenableBuilder`?
- ¿Por qué el tercer cálculo no implica un tercer build en esta secuencia?
- ¿Qué diferencia hay entre un cambio de dependencia, un cambio de resultado y un frame de Flutter?

### Practica 6

En D, ¿por qué el tercer cálculo no implica necesariamente un tercer build?

<details>
<summary>Ver respuesta</summary>

En la secuencia mostrada el resultado sigue siendo `grueso`; el listener del derivado no solicita otra construcción. Un widget también puede reconstruirse por otras causas, de modo que el resultado se limita al árbol probado.

</details>

## 11.7. El controlador real de DaisyUI

El [controlador](../../../lib/themes/application/daisy_theme_controller.dart) conserva el tema en un `ValueNotifier`.
`theme` devuelve el mismo objeto con tipo `ValueListenable`; `setTheme` asigna a su setter. El
[scope](../../../lib/themes/application/daisy_theme_scope.dart) escucha esa fuente con `InheritedNotifier`.

Una lectura de un `ValueNotifier` no registra por sí sola una dependencia de Signals. El siguiente ejemplo permite
observar cómo afecta esa diferencia a un cálculo.

### Ejemplo E: una lectura que no registra una señal

**Antes de mirar el test:** el controlador comienza con el tema `Light`. Un `computed` lee su nombre para formar
una etiqueta y un listener guarda los cambios del derivado. Después de registrar la escucha, se cambia el controlador
a `dark` y se lee la etiqueta. ¿Qué valor tiene el controlador, qué etiqueta se obtiene y cuántos cálculos y avisos
esperas? Usa la distinción entre `ValueNotifier` y señal de Signals para justificarlo.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('computed no observa automáticamente un ValueNotifier', () {
    final controller = DaisyThemeController();
    var calculos = 0;
    final titulo = computed(() {
      calculos++;
      return 'Tema: ${controller.theme.value.name}';
    });
    addTearDown(controller.dispose);
    addTearDown(titulo.dispose);
    final avisos = <String>[];
    void escuchar() => avisos.add(titulo.value);
    titulo.addListener(escuchar);
    expect(titulo.value, 'Tema: Light');
    expect(calculos, 1);
    controller.setTheme(DaisyThemes.dark);
    expect(controller.theme.value, DaisyThemes.dark);
    expect(titulo.value, 'Tema: Light');
    expect(avisos, isEmpty);
    expect(calculos, 1);
    titulo.removeListener(escuchar);
  });
}
```

En esta prueba, el primer cálculo lee `Light`. Al cambiar el controlador a `dark`, su `ValueNotifier` sí cambia, pero
el `computed` no detecta ninguna señal de Signals y conserva su resultado en caché. Para actualizar una derivación
reactiva se necesita conectar explícitamente una fuente que ese mecanismo pueda observar; limitar el tipo a
`ValueListenable` no crea esa conexión.

### Comprobación

- ¿Qué objeto devuelve `controller.theme` y qué operaciones permite su tipo público?
- ¿Por qué el `computed` de E no se invalida cuando cambia el controlador?
- ¿Qué conexión de Flutter usa el scope para escuchar el notificador?

### Practica 7

Si un `computed` solo lee `controller.theme.value`, ¿detecta automáticamente un cambio del controlador actual?

<details>
<summary>Ver respuesta</summary>

No: el controlador usa `ValueNotifier` y esa lectura no registra una fuente de Signals. En el test el derivado conserva su resultado anterior; hace falta una conexión explícita compatible para observar ese dato.

</details>

## 11.8. Elección, límites y propiedad

**Usa un estado almacenado** cuando el usuario o el programa selecciona y modifica el dato de manera independiente.
Por ejemplo, el controlador conserva el tema elegido. **Usa un cálculo puntual** si solo necesitas una expresión en un
lugar y momento concretos. **Considera un `computed`** si un resultado derivado debe poder leerse u observarse como
fuente reactiva o si varias lecturas pueden beneficiarse de la caché. **Usa una vista de lectura** si necesitas limitar
las operaciones disponibles mediante un tipo; un adaptador separado puede además ofrecer otro objeto con una API propia.

Una derivación basada en la hora, archivos, red o una variable mutable no reactiva no se actualizará simplemente
porque esos datos externos cambien. El paquete ofrece operaciones avanzadas como `recompute`, pero forzar cálculos no
sustituye un diseño explícito de fuentes y ciclo de vida. La unidad 12 estudiará acciones laterales y suscripciones.
Si el cálculo depende de colecciones mutadas por dentro sin que la fuente emita un cambio, tampoco basta con esperar que
la caché descubra la mutación.

En las prácticas, el test posee la señal y el derivado. Elimina listeners y desmonta widgets antes de liberar recursos;
libera el derivado antes que sus fuentes. En estos tests, los callbacks de [
`addTearDown`](https://pub.dev/documentation/test/latest/test/addTearDown.html)
se ejecutan en orden inverso al registro: por eso se registra la limpieza del derivado después de la de sus fuentes.
Las opciones de `autoDispose` pueden cambiar el ciclo de vida y se analizan en la unidad 13. No se deben crear nuevos
`computed` repetidamente dentro de un `build` sin pensar quién los conserva y
libera: un build puede ejecutarse muchas veces.

### Practica 8

Necesitamos mostrar un texto una sola vez durante un build que ya observa el tema. ¿Es obligatorio crear un `computed`?

<details>
<summary>Ver respuesta</summary>

No. Una interpolación o función puntual puede bastar. Un `computed` resulta útil cuando necesitamos una fuente reactiva derivada o compartir su caché y sus observadores; no reemplaza el análisis de propiedad.

</details>

## Proyecto de la unidad: una etiqueta derivada

Construye una etiqueta reactiva que combine dos fuentes: un nombre de tema y un grosor de borde. La etiqueta tendrá la
forma `claro: fino` si el borde es menor que 2 y `claro: grueso` en caso contrario. El nombre y el borde son estado
almacenado; la etiqueta es un resultado derivado que no se modifica directamente.

### Requisitos

1. Crea las señales `tema = claro` y `borde = 1`, y un `computed` que lea ambas. Cuenta las evaluaciones solo para
   estudiar el comportamiento.
2. Registra un listener que guarde cada nuevo resultado; explica qué ocurre al registrar y cuál es el valor inicial.
3. Asigna borde 2, borde 3 y tema `oscuro` mediante escrituras separadas. Predice evaluaciones y avisos después de cada paso.
4. Retira el listener, cambia el tema a `bosque` y compara los contadores antes y después de leer la etiqueta.
5. Libera derivado y fuentes desde el test propietario. Intenta resolverlo antes de mirar la solución.

### Variaciones

- Captura `tema.value` antes de crear la función. ¿Qué relación deja de registrarse?
- Si dos temas distintos pueden tener el mismo texto visible, ¿por qué cambiar el tema podría recalcular sin emitir
  un cambio de etiqueta?
- Si solo necesitas mostrar el nombre en un único `build`, ¿qué alternativas más sencillas tienes?

#### Una primera prueba con `batch`

`batch` agrupa escrituras para que los observadores procesen juntos sus cambios al terminar la función. Para comparar,
parte de nuevo de `tema = 'claro'`, `borde = 1` y el listener del proyecto ya registrado. En vez de hacer las
escrituras por separado, usa este **fragmento** en el test, sin leer la etiqueta dentro del bloque:

```dart
batch(() {
  borde.value = 2;
  tema.value = 'oscuro';
});
```

La función que se pasa a `batch` contiene las dos asignaciones. Antes de ejecutarlo, predice qué valores guardará
el listener y cuántas veces se evaluará el derivado, contando también la evaluación inicial al registrarlo. Después
añade comprobaciones al test y compara con la solución. Esta prueba cubre una secuencia concreta; no establece el
comportamiento de todos los casos posibles de lotes.

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('etiqueta derivada de tema y grosor', () {
    final tema = signal('claro');
    final borde = signal(1);
    var calculos = 0;
    final etiqueta = computed(() {
      calculos++;
      final tipo = borde.value >= 2 ? 'grueso' : 'fino';
      return '${tema.value}: $tipo';
    });
    addTearDown(tema.dispose);
    addTearDown(borde.dispose);
    addTearDown(etiqueta.dispose);
    final avisos = <String>[];
    void escuchar() => avisos.add(etiqueta.value);
    etiqueta.addListener(escuchar);

    expect(etiqueta.value, 'claro: fino');
    expect(calculos, 1);
    borde.value = 2;
    borde.value = 3;
    tema.value = 'oscuro';
    expect(calculos, 4);
    expect(avisos, ['claro: grueso', 'oscuro: grueso']);
    etiqueta.removeListener(escuchar);
    tema.value = 'bosque';
    expect(calculos, 4);
    expect(etiqueta.value, 'bosque: grueso');
    expect(calculos, 5);
  });
}
```

Al registrar hay un cálculo inicial y ningún aviso externo. Borde 2 produce `claro: grueso` y un segundo cálculo;
borde 3 produce un tercer cálculo con el mismo texto, sin aviso adicional. Tema `oscuro` produce el cuarto cálculo y
el aviso `oscuro: grueso`. Después de retirar el listener, cambiar a `bosque` no calcula inmediatamente; la lectura
posterior realiza el quinto cálculo. En la variación con `batch`, partiendo del estado inicial indicado, hay dos
cálculos en total: el inicial y otro al terminar el lote. El listener guarda solo `oscuro: grueso`, construido con
los dos valores finales. Capturar el nombre antes del callback elimina su lectura rastreada. Si solo se muestra una vez
por construcción, una
interpolación dentro de un consumidor que ya observe el tema puede ser suficiente.

</details>

## Errores de comprensión que vamos a comprobar

- Tratar el resultado derivado como una segunda fuente de verdad mutable independiente.
- Creer que crear el objeto ejecuta siempre la función inmediatamente.
- Pensar que la función solo puede ejecutarse al escribir explícitamente `.value` en el código del consumidor.
- Confundir una fuente invalidada, una evaluación, un cambio de resultado, un aviso y un build.
- Creer que mencionar una señal fuera de la función la convierte en dependencia rastreada.
- Pensar que todas las ramas se observan aunque no se hayan ejecutado.
- Suponer que cualquier implementación de `ValueListenable` se rastrea automáticamente como señal de Signals.
- Suponer que el tipo de lectura elimina todas las capacidades del objeto real o que un derivado idéntico es lo mismo
  que un adaptador separado.
- Añadir efectos de red o persistencia al cálculo o crear y perder derivaciones en cada build sin dueño.

## Comprueba si puedes avanzar

1. ¿Qué diferencia hay entre dato almacenado, dato derivado y vista de lectura?
2. ¿Qué devuelve `computed<T>` de `signals_flutter` y qué contiene su `.value`?
3. En A, ¿cuándo se ejecuta la función y por qué una segunda lectura no la repite?
4. ¿Por qué una suscripción puede provocar el primer cálculo sin ejecutar el listener externo inicial de B?
5. En B, ¿qué pasa al cambiar borde 2 → 3 con el cálculo, el resultado y los avisos?
6. ¿Qué cambia después de retirar el listener y volver a leer el derivado?
7. En C, ¿qué señales usa el cálculo antes y después del cambio de rama?
8. ¿Por qué una lectura capturada antes del callback no crea una dependencia de la señal original?
9. En D, ¿quién escucha el derivado y por qué `pump` es un paso separado del cambio de señal?
10. ¿Qué objeto devuelve `controller.theme` y qué limita su tipo público?
11. ¿Por qué el `computed` de la práctica E no se invalida al cambiar el `ValueNotifier`?
12. ¿Quién retira escuchas, desmonta widgets y libera las fuentes y derivaciones creadas en las prácticas?

**Unidad dominada cuando:** puedes resolver el proyecto y explicar cuándo se consulta, recalcula y notifica un valor
sin confundir los objetos o copiar las soluciones.

<details>
<summary>Consultar claves de los ejemplos y la comprobación final</summary>


### Ejemplo A

Los contadores son 0 al crear, 1 tras la primera lectura, 1 tras la segunda y tras cambiar la fuente sin observador,
2 tras volver a leer y 2 en la lectura final. Los valores son `Tema: claro` y después `Tema: oscuro`.

### Ejemplo B

Registrar el listener calcula `false` pero suprime la llamada externa inicial. Al cambiar el borde a 2 hay segundo
cálculo y aviso `true`; al cambiarlo a 3, tercer cálculo y ningún aviso nuevo porque el resultado sigue siendo `true`.
Con borde 1 hay cuarto cálculo y aviso `false`. Tras retirar el listener, borde 2 no ejecuta inmediatamente; leer
`grueso.value` causa el quinto cálculo y devuelve `true`.

### Ejemplo C

Las evaluaciones son 1, 1, 2, 2 y 3 en los puntos comprobados. Inicialmente se leen `usarLocal` y `local`; tras activar
y evaluar la otra rama se leen `usarLocal` y `global`. Cambiar una fuente que no pertenece a la rama vigente no exige
volver a ejecutar esa función cuando se consulta el resultado.

### Ejemplo D

Al montar se muestra `fino`, con un cálculo y un build. Borde 2 muestra `grueso`, con dos cálculos y dos builds.
Borde 3 ejecuta el tercer cálculo pero conserva el resultado igual y el contador del builder permanece en dos tras
`pump`. Estos números describen el árbol aislado del test.

### Ejemplo E

Registrar el listener evalúa `Tema: Light` una vez. Cambiar el controlador a `dark` actualiza el `ValueNotifier`,
pero no invalida el `computed`: sigue mostrando `Tema: Light`, sin nuevo cálculo ni aviso en esta prueba.

### Claves de la comprobación final

1. El primero conserva un valor elegido; el segundo se obtiene a partir de fuentes; la vista delega la lectura y
   escucha.
2. Un `FlutterComputed<T>`; `.value` devuelve el resultado calculado de tipo `T`.
3. En el primer acceso y después del cambio pertinente cuando se vuelve a leer; entre ambos reutiliza el resultado.
4. La suscripción necesita evaluar la fuente, pero el puente suprime la primera llamada externa por defecto.
5. Se ejecuta el cálculo; el booleano permanece `true`; en la prueba no se agrega un aviso.
6. En el caso probado, la fuente cambia sin ejecución inmediata; leer luego verifica y calcula el valor actual.
7. `usarLocal` y `local`; después del cambio de rama y la evaluación, `usarLocal` y `global`.
8. El callback utiliza el valor guardado y no hace una lectura rastreada de la señal.
9. `ValueListenableBuilder` escucha el derivado; Flutter procesa la reconstrucción solicitada al avanzar el frame.
10. El mismo `ValueNotifier`, expuesto mediante `ValueListenable`; el tipo permite leer y escuchar.
11. La lectura del `ValueNotifier` no registra una dependencia de Signals.
12. El consumidor retira lo que registró y desmonta el árbol; el propietario libera el derivado y luego las fuentes.

</details>

## Para consultar si necesitas reforzar

- **S1 · Signals:** [`computed<T>`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/computed.html)
  y [
  `FlutterComputed<T>`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterComputed-class.html)
  — creación, valor de lectura y contrato Flutter. Verifica las versiones: las páginas `latest` pueden cambiar.
- **S2 · Signals:** [documentación de `signals`](https://pub.dev/packages/signals) — derivaciones, lecturas
  rastreadas, efectos y lotes; úsala como contexto y contrasta las afirmaciones de versión con las fuentes instaladas.
- **S3 · Implementación instalada:** `signals_flutter-7.1.0/lib/src/core/computed.dart` y
  `src/mixins/value_listenable.dart`; `signals_core-7.0.0/lib/src/core/computed.dart`; y
  `preact_signals-7.0.0/lib/src/computed.dart` y `readonly.dart`. Lee primero la API pública y después sigue el
  contexto de evaluación, la caché y la comparación del resultado.
- **F1 · Flutter:** [`ValueListenable`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html) y
  [`ValueListenableBuilder`](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html) — contrato de
  escucha y consumidor del resultado.
- **P1 · DaisyUI:** [controlador](../../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../../lib/themes/application/daisy_theme_scope.dart),
  [pruebas del controlador](../../../test/themes/daisy_theme_controller_test.dart),
  [dependencias declaradas](../../../pubspec.yaml) y [versiones resueltas](../../../pubspec.lock).

## Qué se ha revisado y cómo se ha comprobado

- Se contrastaron las referencias oficiales enlazadas, los archivos actuales de DaisyUI y las implementaciones de
  `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0. Los detalles internos y las secuencias de
  notificación están delimitados a esas versiones y ejemplos.
- El servidor del grafo rechazó indexar esta carpeta por su configuración de acceso; se leyeron directamente los
  archivos pertinentes.
- En la revisión original pasaron los ejemplos, el proyecto, variaciones y pruebas del controlador. Tras cambiar el
  controlador a `ValueNotifier`, se actualizó y ejecutó de nuevo el ejemplo E junto a las pruebas del controlador y
  del scope; el analizador no encontró problemas en esos archivos.
- Se revisaron enlaces locales, anclas, bloques de código y `git diff --check`. Las pruebas de widgets comprueban
  árboles
  y frames controlados, no una pantalla física ni sus repintados. El estudio sigue pendiente hasta resolver y explicar
  las prácticas.
