# 13. Propiedad de los recursos y `dispose`

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 12](12-efectos-y-suscripciones.md)

- **Bloque:** Signals: almacenar y relacionar estado.
- **Estado de estudio:** pendiente.
- **Fuentes contrastadas:** 1 de noviembre de 2026.

## Qué vas a conseguir

Imagina una vista previa que utiliza un controlador de tema. La vista desaparece de la pantalla, pero otra parte de la
aplicación todavía quiere utilizar ese mismo controlador. Si la vista lo libera simplemente porque lo estaba usando,
la otra parte se queda con un recurso que ya no debe utilizar. En cambio, si la vista deja registrado un listener que
ya no necesita, seguirá recibiendo avisos.

Al terminar podrás identificar quién crea o recibe un recurso, quién decide el final de su vida y quién debe retirar
una escucha concreta. Practicarás cómo desmontar un consumidor, reutilizar un controlador y liberarlo cuando su
propietario termine. También distinguirás la parada de un efecto de la liberación de una señal, y verás cómo afecta
`autoDispose` al caso concreto de Signals. La unidad no queda marcada como dominada por haber preparado esta guía.

## Cómo practicar

Los ejemplos se contrastaron con Flutter **3.47.8**, `signals_flutter` **7.1.0**, `signals_core` **7.0.0** y
`preact_signals` **7.0.0**; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas del paquete.
Los bloques A–F son **pruebas Flutter completas e independientes**. Antes de mirar cada bloque, predice el resultado;
después copia uno a un archivo nuevo, por ejemplo `test/estudio_propiedad_test.dart`, y ejecuta:

```shell
flutter test --no-pub test/estudio_propiedad_test.dart
```

`test` comprueba objetos y callbacks; `testWidgets` monta un árbol de widgets controlado. `expect` compara el resultado
con el esperado. Necesitas las dependencias resueltas del proyecto; no son ejemplos listos para DartPad. Los fragmentos
que se presentan fuera de esos bloques no son programas completos. En los ejemplos se ve explícitamente la limpieza
al final; en pruebas reales, registra limpiezas con `addTearDown` para ejecutarlas incluso si falla una comprobación,
cuidando desmontar y retirar escuchas antes de liberar la fuente y evitando liberar dos veces el mismo recurso.

## 13.1. Una referencia no decide quién es propietario

Un **recurso** es un objeto cuya vida o relaciones requieren gestión: por ejemplo, un controlador que conserva un
notificador o una suscripción que mantiene un callback registrado. Una **referencia** permite acceder al objeto, pero
tener una referencia no indica por sí solo quién debe liberarlo. Dos variables pueden apuntar al mismo controlador.

Llamaremos **propietario** a la parte que, según el diseño acordado, es responsable de terminar la vida útil del
recurso. Normalmente quien crea un recurso para su propio uso es su propietario; también se puede transferir esa
responsabilidad mediante un contrato claro. Un **consumidor** puede recibirlo prestado para leerlo, utilizarlo o
escucharlo sin asumir su liberación. Crear un objeto no es una regla mágica: lo importante es conocer el contrato de
propiedad y qué usos deben haber terminado antes de liberarlo.

Piensa en una biblioteca que presta un libro a dos lectores. Que uno devuelva su ejemplar prestado no autoriza a ese
lector a destruir el libro que el otro todavía utiliza. La analogía termina ahí: en memoria se pueden compartir
referencias simultáneamente y cada recurso tiene una API y condiciones propias para terminar su vida.

### Cuatro acciones distintas

1. **Crear:** `DaisyThemeController()` construye un controlador con su notificador.
2. **Escuchar:** `controller.theme.addListener(escuchar)` registra un callback en la vista de lectura.
3. **Dejar de escuchar:** `controller.theme.removeListener(escuchar)` retira ese registro; el controlador sigue vivo.
4. **Liberar:** el propietario llama a `controller.dispose()` cuando el controlador ya no se necesita.

Son responsabilidades relacionadas, pero no idénticas. Un consumidor puede ser dueño de **su suscripción** y a la vez
usar prestado el controlador. Si el controlador tiene varios consumidores, cada uno retira su propio registro; el
propietario coordina el final del controlador con todos sus usuarios.

**Predice:** si dos consumidores escuchan el mismo controlador y el primero deja de escucharlo, ¿puede el segundo
seguir recibiendo avisos? ¿Debe el primero liberar el controlador? Escribe tu respuesta antes del ejemplo A.

### Practica 1

Una vista recibe un controlador creado por otra parte y registra un listener. ¿De qué es responsable al terminar?

<details>
<summary>Ver respuesta</summary>

De retirar la escucha que registró. El controlador es prestado: su propietario decide cuándo liberarlo, teniendo en cuenta los demás consumidores y el contrato de propiedad.

</details>

## 13.2. Dos consumidores de una misma fuente

### Ejemplo A: retirar solo una escucha

El test crea un controlador y registra dos funciones. Cambia el tema a `dark`, retira la primera función y cambia el
tema a `cupcake`. ¿Qué nombres guarda cada lista? ¿Cuál es el valor actual antes de liberar el controlador?

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('A: dos consumidores y una fuente compartida', () {
    final controller = DaisyThemeController();
    final primero = <String>[];
    final segundo = <String>[];
    void escucharPrimero() => primero.add(controller.theme.value.name);
    void escucharSegundo() => segundo.add(controller.theme.value.name);
    controller.theme.addListener(escucharPrimero);
    controller.theme.addListener(escucharSegundo);
    controller.setTheme(DaisyThemes.dark);
    controller.theme.removeListener(escucharPrimero);
    controller.setTheme(DaisyThemes.cupcake);
    expect(primero, ['Dark']);
    expect(segundo, ['Dark', 'Cupcake']);
    expect(controller.theme.value.name, 'Cupcake');
    controller.theme.removeListener(escucharSegundo);
    controller.dispose();
  });
}
```

Al principio ambos callbacks están registrados. El cambio a `dark` hace que ambos lean `Dark`. Retirar
`escucharPrimero` no retira `escucharSegundo` ni termina la vida del controlador: el cambio a `cupcake` añade `Cupcake`
solo a la segunda lista. El valor actual sigue siendo `Cupcake`. El test retira el segundo registro y, como responsable
del controlador que creó, llama a `dispose()`.

La escucha no recibe automáticamente un valor como argumento: las funciones leen `controller.theme.value` cuando son
llamadas. La lista registra avisos, no el historial completo de asignaciones de la aplicación. Este ejemplo usa cambios
a temas distintos; `ValueNotifier` compara mediante `==` antes de notificar, como vimos en la unidad 7.

**Comprueba:** si el primer consumidor se marcha, ¿qué dos cosas siguen existiendo? ¿Quién decide cuándo liberar el
controlador compartido?

### Practica 2

En A, ¿qué pasa con el segundo listener cuando se retira el primero?

<details>
<summary>Ver respuesta</summary>

Sigue registrado y recibe `Cupcake` en el siguiente cambio. Retirar una escucha concreta no termina la vida del controlador ni elimina los registros de los demás.

</details>

## 13.3. La identidad y el número de registros importan

`removeListener` necesita la misma función que se entregó a `addListener`. Crear otra función anónima con un cuerpo
parecido no garantiza que sea la misma referencia. Puedes guardar el callback en una variable o declarar una función
con nombre, como `escucharPrimero` en A, y usar esa referencia tanto al registrar como al retirar.

Además, en el `ChangeNotifier` utilizado por este controlador es posible registrar el mismo callback más de una vez.
Cada registro cuenta. Para el caso sencillo sin retiradas durante una notificación, retirar una vez no elimina ambos.
No dependas de detalles de retirada reentrante sin consultar el contrato de Flutter.

### Ejemplo B: dos registros de la misma función

**Predice:** registramos `escuchar` dos veces y lo retiramos una sola vez. Al cambiar el tema, ¿cuántos avisos recibe?
Tras retirarlo otra vez y cambiar el tema de nuevo, ¿cuánto vale el contador?

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('B: registrar dos veces requiere retirar dos veces', () {
    final controller = DaisyThemeController();
    var avisos = 0;
    void escuchar() => avisos++;
    controller.theme.addListener(escuchar);
    controller.theme.addListener(escuchar);
    controller.theme.removeListener(escuchar);
    controller.setTheme(DaisyThemes.dark);
    expect(avisos, 1);
    controller.theme.removeListener(escuchar);
    controller.setTheme(DaisyThemes.light);
    expect(avisos, 1);
    controller.dispose();
  });
}
```

Tras la primera retirada queda un registro, por eso el primer cambio suma un aviso. La segunda retirada quita el
registro restante y el contador permanece en uno. La solución no es liberar el controlador desde un consumidor, sino
emparejar cada registro que se realizó con su retirada. Esto importa incluso si ambos registros usan el mismo callback.

**Comprueba:** ¿qué cambia si se registra una vez y se retira una vez? ¿Por qué no basta con escribir otra closure
que haga lo mismo?

### Practica 3

En B registramos la misma función dos veces y la retiramos una vez. ¿Qué queda?

<details>
<summary>Ver respuesta</summary>

En ese `ChangeNotifier` y fuera de una notificación queda un registro. Hay que emparejar ambas altas con sus retiradas; otros tipos pueden tener otra política de duplicados.

</details>

## 13.4. Qué significa `dispose`

`dispose` es una operación definida por cada tipo para terminar su uso y liberar o desconectar los recursos que ese
tipo administra. No es una instrucción general de Dart que borre inmediatamente el objeto de la memoria. Si todavía
hay referencias, el objeto puede seguir siendo alcanzable; la recogida de memoria y la limpieza explícita son asuntos
distintos. Consulta el contrato concreto: no todos los tipos comparten el mismo comportamiento ni garantizan que
llamar dos veces sea válido.

`DaisyThemeController.dispose()` delega en el `dispose()` de su `ValueNotifier`. Según el contrato de
[`ChangeNotifier.dispose`](https://api.flutter.dev/flutter/foundation/ChangeNotifier/dispose.html), que hereda
`ValueNotifier`, solo el propietario debe llamarlo; el objeto deja de estar en un estado utilizable, se vacía la lista
de listeners y **no se emite un último aviso**. No uses después el controlador como fuente activa, aunque alguna
operación concreta parezca funcionar en una configuración determinada. Las comprobaciones de error pueden variar entre
modo debug y release; no construyas una regla de propiedad basándote en que siempre se lance una excepción.

Cuando un objeto presta otro recurso, es útil dejar explícito qué debe ocurrir primero: los consumidores terminan sus
escuchas, luego el propietario libera la fuente cuando ningún usuario la necesita. Liberar el notificador no sustituye
el diseño de una salida coordinada para consumidores activos. Un objeto que requiere limpieza no necesariamente filtra
memoria en todos los casos si no se llama a `dispose`: la consecuencia depende de sus referencias y recursos externos.

**Piensa:** ¿es lo mismo retirar tu listener que vaciar todas las escuchas al liberar el notificador? ¿`dispose`
notifica a los listeners que el tema ha cambiado?

### Practica 4

¿Llamar a `dispose()` en un `ChangeNotifier` envía un último aviso de cambio o borra inmediatamente el objeto de la memoria?

<details>
<summary>Ver respuesta</summary>

No envía un último aviso: vacía sus listeners y deja de ser utilizable según su contrato. La recogida de memoria es un mecanismo distinto y no se deduce de esa llamada.

</details>

## 13.5. Señales, efectos y suscripciones

En la unidad 12, `effect` devolvía una función para detener **esa observación**. La señal que el efecto lee puede
compartirse con otros consumidores y tener una vida más larga. Su propietario decide cuándo llamar a `signal.dispose()`.
Del mismo modo, la función devuelta por `subscribe` cancela esa suscripción; no debe confundirse con una autorización
general para liberar cualquier fuente prestada. La sección siguiente muestra una configuración que modifica el final
de la vida de una señal al perder su último observador.

### Ejemplo C: detener el efecto y conservar la señal

**Predice:** el efecto registra el tema inicial y un cambio; después lo detenemos y cambiamos la señal otra vez. ¿Qué
contiene el registro? ¿Qué valen `tema.disposed` y `tema.value` antes de que el propietario libere la señal?

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('C: detener efecto no libera su señal', () {
    final tema = signal('claro');
    final registro = <String>[];
    final detener = effect(() { registro.add(tema.value); });
    tema.value = 'oscuro';
    detener();
    tema.value = 'bosque';
    expect(registro, ['claro', 'oscuro']);
    expect(tema.disposed, isFalse);
    expect(tema.value, 'bosque');
    tema.dispose();
    expect(tema.disposed, isTrue);
  });
}
```

La lista queda en `['claro', 'oscuro']`. El cambio a `bosque` no ejecuta el efecto detenido, pero la señal permanece
activa: `disposed` es `false` y `.value` devuelve `bosque`. Solo después de `tema.dispose()` es `true`. Esta prueba usa
la configuración predeterminada y una sola secuencia; no trata la cancelación de peticiones o trabajo asíncrono ya
iniciado.

**Comprueba:** ¿qué objeto queda detenido y cuál sigue utilizable antes de `tema.dispose()`? Si otro efecto observa la
señal, ¿por qué no sería apropiado que este consumidor la liberase por su cuenta?

### `autoDispose`: una regla diferente y explícita

Signals permite configurar `SignalOptions(autoDispose: true)`. En las versiones indicadas, la señal del ejemplo se
libera cuando se retira su **última** suscripción activa: retirar una de dos no la libera. Esta configuración modifica
el acuerdo de vida útil; no significa que todos los recursos de Flutter se liberen solos, ni que una señal sin ningún
observador inicial se libere inmediatamente. En el caso predeterminado de C, parar el efecto no libera la señal.

### Ejemplo D: dos observadores y `autoDispose`

**Predice:** una señal con `autoDispose: true` recibe dos suscripciones. Cancelamos la primera y luego la segunda.
¿Cuándo pasa `disposed` a `true`? ¿Debe otro usuario asumir que la señal seguirá disponible tras la última cancelación?

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('D: autoDispose y último observador', () {
    final tema = signal('claro', options: const SignalOptions(autoDispose: true));
    final uno = tema.subscribe((_) {});
    final dos = tema.subscribe((_) {});
    expect(tema.disposed, isFalse);
    uno();
    expect(tema.disposed, isFalse);
    dos();
    expect(tema.disposed, isTrue);
  });
}
```

Después de cancelar `uno` queda otro observador y `disposed` es `false`. Al cancelar `dos`, se retira el último y en
esta prueba la señal pasa a `disposed == true`. No la reutilizamos después. La sintaxis `options: const SignalOptions(...)`
crea un objeto de opciones y se lo entrega a `signal`; `autoDispose: true` activa esta política. `subscribe` ejecuta
su callback inicial y devuelve una función de cancelación, como practicamos en la unidad 12.

No supongas que todos los tipos de Signals tengan exactamente el mismo comportamiento tras liberarse. Las versiones,
las opciones y el tipo concreto importan; consulta su API e implementación antes de basarte en una lectura posterior.
Si un consumidor todavía necesita una fuente de larga vida, acuerda esa vida útil en vez de activar esta opción sin
considerar las consecuencias. `autoDispose` no cancela por sí mismo trabajos externos que se hayan iniciado por otro
mecanismo.

**Comprueba:** ¿qué diferencia de configuración hay entre C y D? ¿Qué evento concreto causó la liberación en D?

### Practica 5

En D cancelamos una de dos suscripciones de una señal con `autoDispose: true`. ¿Se libera ya?

<details>
<summary>Ver respuesta</summary>

No en esta secuencia: sigue existiendo otra suscripción. Al cancelar la última, la señal pasa a `disposed`; con las opciones predeterminadas de C, detener el efecto no liberaba la fuente.

</details>

## 13.6. El controlador real de DaisyUI

En [daisy_theme_controller.dart](../../../lib/themes/application/daisy_theme_controller.dart) encontramos:

```dart
DaisyThemeController({
  DaisyThemeModel initialTheme = DaisyThemes.light,
}) : _palette = ValueNotifier<DaisyThemeModel>(initialTheme);

final ValueNotifier<DaisyThemeModel> _palette;

ValueListenable<DaisyThemeModel> get theme => _palette;

void dispose() => _palette.dispose();
```

Es un **fragmento** de la clase real, no un archivo completo. Al crear el controlador, este crea y conserva `_palette`.
`theme` devuelve ese mismo objeto con el tipo público de lectura y escucha `ValueListenable`; no crea otro notificador.
El controlador administra la vida de `_palette` y le delega su propia limpieza. El propietario del controlador decide
cuándo llamar a `controller.dispose()`.

En [daisy_theme_scope.dart](../../../lib/themes/application/daisy_theme_scope.dart), el constructor recibe un
controlador opcional y pasa `controller?.theme ?? DaisyThemeService.theme` a `InheritedNotifier`. Cuando recibe un
controlador explícito, usa su vista **prestada**. El scope no crea ese controlador ni llama a su `dispose`. Flutter
administra la escucha del `InheritedNotifier` mientras el scope está montado y la retira al sustituir su fuente o
desmontarlo. El hecho de escuchar no transfiere la propiedad del controlador.

Si no se pasa controlador, se utiliza la vista de [DaisyThemeService](../../../lib/themes/application/daisy_theme_service.dart),
que conserva su propio controlador estático. No debes liberar desde un consumidor una fuente compartida del servicio.
El servicio actual no expone un método público para liberar ese controlador; su organización y alcance se estudian en
la unidad 17.

En [example/lib/main.dart](../../../example/lib/main.dart), `_ThemePreviewState` crea su controlador en `initState`, se
lo entrega al scope y llama a `_controller.dispose()` en su propio `dispose`. Esa vista previa es propietaria del
controlador que creó. `initState`, `State`, `build` y el resto del ciclo de vida se estudiarán con detalle en las
unidades 18 y 19; aquí basta con reconocer creación, préstamo y limpieza.

### Ejemplo E: desmontar y reutilizar un controlador prestado

**Predice:** un test crea un controlador y monta un scope que muestra el nombre. Después desmonta el árbol, cambia el
tema a `dark`, vuelve a montar un scope con el mismo controlador y finalmente lo desmonta. ¿Qué nombre se muestra al
volver? ¿Quién libera el controlador?

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('E: desmontar, reutilizar y volver a montar', (tester) async {
    final controller = DaisyThemeController();
    Widget pantalla() => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(
        controller: controller,
        child: Builder(builder: (context) => Text(context.daisyTheme.name)),
      ),
    );
    await tester.pumpWidget(pantalla());
    expect(find.text('Light'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.setTheme(DaisyThemes.dark);
    await tester.pumpWidget(pantalla());
    expect(find.text('Dark'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
```

Al principio se muestra `Light`. `pumpWidget` monta un árbol para la prueba; sustituirlo por `SizedBox.shrink()`
desmonta el scope y su consumidor. El test sigue conservando el controlador, cambia su tema a `dark` y monta otro scope
que muestra `Dark`. Solo después de desmontar también este segundo árbol llama a `controller.dispose()`.

La prueba muestra que este recorrido permite reutilizar el controlador tras desmontar el scope. No demuestra por sí
sola cada llamada interna de Flutter, ni repintados en un dispositivo. El código y el contrato de `InheritedNotifier`
permiten entender por qué la escucha del scope se gestiona por separado de la vida del controlador.

**Comprueba:** ¿quién creó el controlador en E? ¿Qué relación terminó al desmontar el scope? ¿Por qué se puede volver
a montar con el mismo controlador antes de liberarlo?

### Practica 6

En E desmontamos el scope y volvemos a montarlo con el mismo controlador. ¿Quién lo libera y cuándo?

<details>
<summary>Ver respuesta</summary>

El test creó y conserva el controlador, así que lo libera después de desmontar el último scope. Desmontar el consumidor termina su observación, pero no transfiere ni termina la propiedad de la fuente prestada.

</details>

## 13.7. Sustituir una fuente prestada

Un consumidor puede pasar de observar una fuente a observar otra. La regla conceptual es retirar su relación con la
fuente anterior y establecerla con la nueva; eso no significa que deba liberar ninguna de ellas si son prestadas. Un
widget que registre listeners manualmente debe contemplar la actualización de su configuración: Flutter documenta
`initState`, `didUpdateWidget` y `dispose` como los lugares habituales para registrar, sustituir y retirar esas
escuchas. No hace falta dominar todavía esos métodos para seguir la siguiente prueba: usaremos el scope real, cuya
integración con `InheritedNotifier` gestiona su propia escucha.

### Ejemplo F: cambiar de controlador

**Predice:** montamos el scope con `primero` (`Light`) y luego lo actualizamos con `segundo` (`Dark`). Cambiamos
`primero` a `Cupcake` y `segundo` a `Light`, procesando un frame tras cada cambio. ¿Qué cambios reconstruyen el
consumidor en este árbol aislado? ¿Quién libera ambos controladores?

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('F: sustituir un controlador prestado', (tester) async {
    final primero = DaisyThemeController();
    final segundo = DaisyThemeController(initialTheme: DaisyThemes.dark);
    var builds = 0;
    final consumidor = Builder(builder: (context) {
      builds++;
      return Text(context.daisyTheme.name);
    });
    Widget pantalla(DaisyThemeController controller) => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(controller: controller, child: consumidor),
    );
    await tester.pumpWidget(pantalla(primero));
    await tester.pumpWidget(pantalla(segundo));
    expect(find.text('Dark'), findsOneWidget);
    expect(builds, 2);
    primero.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(builds, 2);
    segundo.setTheme(DaisyThemes.light);
    await tester.pump();
    expect(find.text('Light'), findsOneWidget);
    expect(builds, 3);
    await tester.pumpWidget(const SizedBox.shrink());
    primero.dispose();
    segundo.dispose();
  });
}
```

El primer montaje y el cambio de fuente producen dos construcciones en este árbol controlado y se muestra `Dark`.
Cambiar `primero` después de sustituirlo no incrementa el contador: ya no es la fuente escuchada por este scope. Al
cambiar `segundo`, el siguiente `pump` procesa la actualización y aparece `Light`, con tres construcciones. El test
conserva ambos controladores, desmonta el árbol y después los libera. La cifra de construcciones describe esta prueba,
no una garantía sobre cualquier árbol o cualquier causa de reconstrucción.

**Comprueba:** ¿qué observación cambia al sustituir el controlador? ¿Por qué el primer controlador sigue pudiendo
cambiar aunque el scope ya no lo utilice?

### Practica 7

En F, ¿por qué cambiar el controlador primero deja de reconstruir ese consumidor tras sustituirlo?

<details>
<summary>Ver respuesta</summary>

El scope ha pasado a escuchar la vista del segundo controlador. El primero sigue vivo y puede cambiar, pero ya no es la fuente observada por ese scope; el test libera ambos después de desmontar.

</details>

## Proyecto de la unidad: un controlador que sobrevive a una vista

Resuelve primero sin mirar la solución:

1. El test es propietario de un controlador cuyo tema inicial es `Light`. Registra un callback manual que guarde los
   nombres cuando haya avisos. Monta además un scope que muestra el mismo controlador.
2. Cambia el tema a `Dark` y procesa un frame. Predice la lista y el texto visible.
3. Retira el callback manual y desmonta el scope. Cambia el tema a `Cupcake`. ¿Puede seguir usándose el controlador?
   ¿Qué contiene ahora la lista?
4. Monta de nuevo un scope con el mismo controlador y comprueba el texto actual. Desmonta el árbol y libera el
   controlador una sola vez.
5. Explica quién poseía el controlador, quién poseía el registro manual y quién gestionaba la escucha del scope.

Variación: imagina que también hay un segundo consumidor manual que no se retira. ¿Seguiría recibiendo el cambio a
`Cupcake`? ¿Qué coordinación habría que hacer antes de liberar el controlador?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el controlador sobrevive a un consumidor', (tester) async {
    final controller = DaisyThemeController();
    final avisos = <String>[];
    void escuchar() => avisos.add(controller.theme.value.name);
    Widget pantalla() => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(
        controller: controller,
        child: Builder(builder: (context) => Text(context.daisyTheme.name)),
      ),
    );

    controller.theme.addListener(escuchar);
    await tester.pumpWidget(pantalla());
    controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(avisos, ['Dark']);
    expect(find.text('Dark'), findsOneWidget);

    controller.theme.removeListener(escuchar);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.setTheme(DaisyThemes.cupcake);
    expect(avisos, ['Dark']);
    await tester.pumpWidget(pantalla());
    expect(find.text('Cupcake'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
```

El test crea el controlador y es responsable de liberarlo. También registra y retira su callback manual. El scope
recibe el controlador prestado y gestiona su propia escucha mientras está montado. Si otro consumidor manual siguiera
registrado, recibiría `Cupcake`; tendría que retirar su registro y dejar de necesitar la fuente antes de que el
propietario la liberase.

</details>

## Comprueba si puedes avanzar

1. ¿Qué diferencia existe entre tener una referencia y ser propietario del recurso?
2. ¿Puede un consumidor poseer su suscripción y usar prestada la fuente? Pon un ejemplo.
3. En A, ¿por qué el segundo listener sigue recibiendo avisos tras retirar el primero?
4. En B, ¿por qué una retirada deja una escucha activa?
5. ¿Qué hace y qué no hace `ChangeNotifier.dispose()` respecto a sus listeners y a la memoria?
6. ¿Por qué no debes utilizar el controlador después de que su propietario lo haya liberado?
7. En C, ¿qué detiene `detener()` y cuándo se libera la señal?
8. En D, ¿qué diferencia introduce `autoDispose` y qué ocurre al retirar el último observador?
9. ¿Quién posee el controlador de `_ThemePreviewState` y qué papel desempeña `DaisyThemeScope`?
10. En E, ¿qué demuestra volver a montar el scope? ¿Qué no demuestra?
11. En F, ¿por qué cambiar la primera fuente deja de reconstruir ese consumidor?
12. ¿Por qué no deberías crear un controlador nuevo en cada `build` sin gestionar quién conserva y libera cada uno?

<details>
<summary>Consultar claves de los ejemplos y la comprobación final</summary>


### Preguntas breves

- **A:** ambas listas reciben `Dark`; solo la segunda recibe `Cupcake`. El controlador sigue vivo hasta que el test,
  su propietario, lo libera. El primer consumidor retira su registro, no el de los demás.
- **B:** el contador queda en uno: una retirada deja un registro y la segunda retira el restante. Una función anónima
  nueva con cuerpo similar puede ser otra función y no retirar la registrada.
- **`dispose`:** retirar una escucha concreta conserva la fuente y las demás escuchas. `ChangeNotifier.dispose` vacía
  sus escuchas sin un aviso final y deja el objeto inutilizable; no implica que la memoria se borre inmediatamente.
- **C:** detener el efecto deja la señal viva: contiene `bosque` y `disposed` es falso. Su propietario la libera
  después. Otro consumidor podría seguir utilizándola hasta entonces.
- **D:** con `autoDispose: true`, cancelar el último de los dos observadores libera la señal en esta secuencia. Tras
  cancelar solo uno sigue activa. La configuración predeterminada de C no aplica esa misma política.
- **E:** el test creó y posee el controlador. Al desmontar termina la escucha del scope; volver a montarlo muestra
  `Dark` porque el controlador seguía vivo. La prueba no demuestra repintados en un dispositivo.
- **F:** el scope deja de observar la primera fuente y pasa a la segunda. El test posee ambas y las libera después de
  desmontar. La primera sigue viva aunque ya no sea la fuente del scope.

### Claves de la comprobación final

1. Una referencia da acceso; la propiedad asigna la responsabilidad de terminar la vida del recurso.
2. Sí: un consumidor registra y retira su callback sobre un controlador creado y conservado por otro.
3. Son registros separados; retirar uno no retira el otro ni libera la fuente.
4. La misma función se registró dos veces y una retirada quitó solo uno de esos registros en este caso.
5. Deja el notifier inutilizable y vacía los listeners sin avisar; no promete borrar inmediatamente la memoria.
6. El contrato de su notificador considera terminado su uso; no es seguro depender de operaciones posteriores.
7. Se detiene el efecto; el test libera la señal más tarde mediante `tema.dispose()`.
8. En D la señal se libera cuando se cancela la última suscripción activa; la primera cancelación no basta.
9. El estado de la vista previa lo crea y libera; el scope toma prestada su vista y gestiona una escucha.
10. Demuestra que el controlador se pudo reutilizar tras desmontar el scope, no el comportamiento visual de un dispositivo.
11. El scope sustituye su escucha anterior por la de la segunda fuente.
12. Un `build` puede repetirse y dejar varias instancias o relaciones sin una responsabilidad clara de limpieza.

</details>

## Para consultar si necesitas reforzar

- [ChangeNotifier.dispose](https://api.flutter.dev/flutter/foundation/ChangeNotifier/dispose.html): contrato de
  propiedad, estado posterior y listeners; [removeListener](https://api.flutter.dev/flutter/foundation/ChangeNotifier/removeListener.html):
  identidad, registros repetidos y particularidades durante una notificación.
- [State.dispose](https://api.flutter.dev/flutter/widgets/State/dispose.html): limpieza de recursos del estado y
  sustitución de suscripciones. Las situaciones del ciclo de vida se estudian con detalle más adelante.
- [InheritedNotifier](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html): relación entre notifier,
  dependientes y cambios de fuente.
- [API de Signals](https://pub.dev/documentation/signals_core/latest/signals_core/SignalOptions-class.html) y fuentes
  instaladas de `signals_core` 7.0.0: compara `autoDispose` con la versión que tengas; `latest` puede cambiar.
- [Controlador](../../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../../lib/themes/application/daisy_theme_scope.dart), [servicio](../../../lib/themes/application/daisy_theme_service.dart),
  [ejemplo](../../../example/lib/main.dart) y [pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart).

## Qué se ha comprobado

Se revisaron los archivos actuales del controlador, servicio, scope y ejemplo, junto con las implementaciones instaladas
y documentación oficial. Las prácticas A–F y la solución del proyecto se ejecutaron como pruebas Flutter en las
versiones indicadas. Comprueban las secuencias descritas en objetos y árboles de prueba; no demuestran repintados en un
dispositivo ni el comportamiento de todas las versiones y configuraciones. El grafo rechazó indexar esta carpeta por
su configuración de acceso; los archivos pertinentes se revisaron directamente. El estudio sigue pendiente hasta
resolver y explicar las prácticas.
