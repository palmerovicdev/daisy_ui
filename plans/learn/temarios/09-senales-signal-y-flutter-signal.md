# 09. Señales: `signal<T>` y `FlutterSignal<T>`

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 8](08-identidad-igualdad-e-inmutabilidad.md)

- **Bloque:** Signals: almacenar y relacionar estado.
- **Estado de estudio:** pendiente.

## Qué vas a conseguir

Podrás seguir la creación de una señal, su valor inicial, una lectura, el registro de un listener y una escritura.
Identificarás qué objeto almacena el valor, qué compara la implementación instalada, cuándo el listener puede leer el
nuevo valor y por qué un aviso no equivale por sí solo a una reconstrucción de Flutter.

Estudiaremos Signals con ejemplos independientes y los compararemos con el controlador actual, que usa
`ValueNotifier` para sus temas. Las dependencias rastreadas y `SignalBuilder` se estudian en la unidad 10;
`computed`, `effect` y propiedad de recursos tienen unidades posteriores.

## Cómo practicar

Las pruebas completas de A y C están en las soluciones; las de B y D aparecen en sus secciones. La solución del
proyecto también es una prueba completa. Copia una de ellas a la vez en `test/estudio_senales_test.dart` dentro del
repositorio y ejecuta:

```shell
flutter test --no-pub test/estudio_senales_test.dart
```

La opción `--no-pub` presupone que las dependencias ya están resueltas e instaladas; si aún no lo están, ejecuta antes
`flutter pub get` en la raíz del proyecto. Las pruebas importan `signals_flutter` y `flutter_test`, por lo que
necesitan el entorno Flutter del proyecto; no funcionan en DartPad. Los fragmentos de 9.1, los enunciados de A y C y
el fragmento del controlador en 9.7 sirven para leer y predecir: no son programas completos ejecutables por sí solos.

Esta guía se contrastó con `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0 (resueltas en
`pubspec.lock`); si tu proyecto usa otra versión, algunos detalles internos pueden diferir.

## Índice

- [9.1. Qué problema resuelve una señal](#91-qué-problema-resuelve-una-señal)
- [9.2. Crear, leer y escribir](#92-crear-leer-y-escribir)
- [9.3. Observar una señal desde Flutter](#93-observar-una-señal-desde-flutter)
- [9.4. Orden de ejecución y valor actual](#94-orden-de-ejecución-y-valor-actual)
- [9.5. Igualdad y conservación del valor](#95-igualdad-y-conservación-del-valor)
- [9.6. Mutación interna y sustitución](#96-mutación-interna-y-sustitución)
- [9.7. Comparar con DaisyUI](#97-comparar-con-daisyui)
- [9.8. Avisos, widgets y ciclo de vida](#98-avisos-widgets-y-ciclo-de-vida)
- [Proyecto de la unidad](#proyecto-de-la-unidad-un-selector-de-tema)
- [Comprobación final](#comprobación-final)

Escribe tus predicciones antes de mirar las soluciones y anota qué secciones puedes explicar con tus palabras.

## 9.1. Qué problema resuelve una señal

Una variable guarda una referencia que podemos consultar y, si es reasignable, cambiar. Pero un consumidor que leyó
esa variable en otro momento no recibe por ello un aviso de cambios. Una señal añade una fuente observable: conserva
un valor actual y ofrece formas de relacionar observadores con cambios aceptados de ese valor.

Piensa en una pizarra con el tema actual y un sistema para avisar a quienes se apuntaron. Leer la pizarra una vez no
es lo mismo que apuntarse para escuchar. Esta analogía no explica por sí sola cómo se registran observadores, cómo se
compara un valor ni cuándo Flutter decide reconstruir: esas decisiones pertenecen a implementaciones concretas.

En este proyecto, [`signal<T>` de
`signals_flutter`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/signal.html)
crea un [
`FlutterSignal<T>`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterSignal-class.html)
mutable con un valor inicial. `T` describe el tipo del **valor que contiene**, no el tipo de la variable que contiene
la referencia a la señal.

```dart

final FlutterSignal<int> contador = signal<int>(0);
```

Aquí `contador` referencia el objeto señal; `contador.value` lee el entero que la señal contiene. `final` impide
reasignar la variable `contador`, pero no impide cambiar `contador.value`. La señal es la celda; el entero es el dato
actual. No son el mismo objeto ni tienen el mismo papel.

### Comprobación

- ¿Qué se conserva en `contador` y qué devuelve `contador.value`?
- ¿Por qué se puede escribir `contador.value = 1` si `contador` es `final`?
- ¿Leer una vez `contador.value` equivale a registrar un listener?

## 9.2. Crear, leer y escribir

### Ejemplo A: una lectura antigua y otra nueva

Sin ejecutar el fragmento, anota qué contiene `lecturaAnterior` al leerla y qué contienen `tema.value` y
`lecturaAnterior` después de la asignación. Después contrasta tus tres respuestas con la prueba completa de las
[soluciones](#ejemplo-a).

```dart
final FlutterSignal<String> tema = signal<String>('claro');
final lecturaAnterior = tema.value;
tema.value = 'oscuro';
```

La escritura `tema.value = 'oscuro'` llama al setter de la señal; no sustituye la variable `tema`. En esta combinación
de versiones el setter delega en `set`, que comprueba si acepta la propuesta y actualiza el valor en caso afirmativo.
Crear una segunda señal con el mismo valor inicial crea otra celda independiente; no crea otra referencia a la primera.

### Comprobación

- ¿Qué vale `lecturaAnterior` después de la asignación y por qué?
- ¿Qué se sustituye: la señal o su valor?
- Si hay dos señales creadas por separado, ¿escribir en una cambia la otra?

## 9.3. Observar una señal desde Flutter

Una `FlutterSignal<T>` también puede usarse como [`ValueListenable<T>`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html).
Desde ese tipo puedes leer `value`, registrar un callback con `addListener` y retirarlo con `removeListener`, usando
la misma referencia a la función. El tipo `ValueListenable` no expone un setter ni `dispose`, aunque el objeto real
pueda ofrecerlos.

En el siguiente ejemplo, registrar el callback no lo ejecuta. Cuando la señal acepta un cambio, lo avisa y el callback
lee el valor actual; tras retirarlo, la señal puede seguir cambiando sin llamarlo. Ese comportamiento al registrar
corresponde a la configuración predeterminada usada aquí, no a todos los `Listenable`.

### Ejemplo B: registrar, cambiar y retirar

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('un listener observa los cambios aceptados', () {
    final FlutterSignal<String> tema = signal<String>('claro');
    final ValueListenable<String> lectura = tema;
    addTearDown(tema.dispose);
    final eventos = <String>[];
    void escuchar() => eventos.add('aviso: ${lectura.value}');

    lectura.addListener(escuchar);
    eventos.add('antes');
    tema.value = 'oscuro';
    eventos.add('después');
    lectura.removeListener(escuchar);
    tema.value = 'bosque';

    expect(eventos, ['antes', 'aviso: oscuro', 'después']);
    expect(lectura.value, 'bosque');
  });
}
```

La variable `lectura` y `tema` apuntan a la **misma señal**; cambiar el tipo declarado no crea un adaptador ni elimina
las capacidades del objeto real. El tipo `ValueListenable` restringe qué operaciones se pueden escribir a través de
esa variable, pero un consumidor podría reconocer el tipo real mediante un cast. El controlador actual de DaisyUI
expone de forma similar su `ValueNotifier` mediante el tipo `ValueListenable`; no usa un adaptador separado.

### Un detalle de la implementación

`FlutterSignal<T>` extiende la señal del núcleo y, en la versión instalada, implementa la interfaz
`ValueNotifier<T>` mediante `ValueNotifierSignalMixin<T>`. Esto también la hace compatible con `ChangeNotifier`, por lo
que `senal is ChangeNotifier` resulta verdadero. **Implementar esa interfaz no significa heredar su implementación:**
`FlutterSignal` no extiende `ChangeNotifier`; su almacenamiento, comparación y escucha proceden de Signals.

En `signals_flutter` 7.1.0, `addListener(callback)` crea una suscripción interna y guarda en un mapa cómo cancelarla.
Con `runCallbackOnListen: false`, la opción predeterminada, el puente suprime la primera llamada al callback del
consumidor; con `runCallbackOnListen: true`, lo llama al registrar. Volver a registrar el mismo callback no crea otra
entrada en el mapa y una retirada cancela la suscripción. Otras implementaciones de `Listenable`, como
`ChangeNotifier`, pueden tratar los registros duplicados de otra forma.

### Comprobación

- ¿Por qué el callback puede leer `oscuro` sin recibir argumentos?
- ¿Por qué `lectura.value` termina siendo `bosque` aunque el listener ya no reciba el aviso?
- ¿Qué pasa si eliminas `removeListener`? ¿Qué ocurre con el tipo real al declarar `lectura` como `ValueListenable`?

## 9.4. Orden de ejecución y valor actual

En B, sin un `batch` externo ni escrituras reentrantes, el cambio aceptado se guarda y el callback se ejecuta durante
la asignación, antes de añadir `después`. El listener lee el valor actual a través de la fuente. La suscripción del
puente de Flutter se implementa con el mecanismo reactivo del paquete, no con una llamada directa a
`ChangeNotifier.notifyListeners()`.

El código de `preact_signals` inicia y termina internamente un lote de actualizaciones al propagar una escritura. Si
el código llama explícitamente a `batch` alrededor de varios cambios, las notificaciones pueden agruparse y el orden
que acabamos de observar no debe generalizarse a ese escenario. Tampoco garantizamos aquí un orden entre varios
listeners ni analizamos callbacks que escriben de nuevo en la misma señal. Esos casos necesitan sus propias pruebas.

La cadena de B, para **esta ejecución concreta**, es:

1. El test registra `escuchar` mediante `lectura`; el objeto real es la señal.
2. El puente crea una suscripción interna y omite el primer callback externo por la opción predeterminada.
3. El test añade `antes` y asigna `oscuro` al setter.
4. La señal compara, guarda el valor aceptado y propaga la actualización a la suscripción.
5. El puente llama `escuchar`; el callback lee `lectura.value`, que ya es `oscuro`.
6. Termina la asignación; el test añade `después`, retira el callback y asigna `bosque`.
7. El valor cambia de nuevo, pero esa suscripción ya se canceló. Al final el propietario libera la señal.

### Comprobación

- ¿El listener obtiene el dato como argumento o lo consulta?
- ¿Qué evento ocurre primero en B: el aviso o la línea `eventos.add('después')`?
- ¿Por qué esa predicción no basta para afirmar el orden de cualquier `batch` o de cualquier `Listenable`?

## 9.5. Igualdad y conservación del valor

En las versiones instaladas, el setter normal usa `set(valorPropuesto)` y, con la configuración predeterminada,
compara con `==`. Si la comparación considera iguales el nuevo valor y el actual, no se guarda la propuesta ni se
propaga ese cambio. Si son distintos, se guarda primero y después se propaga. `SignalOptions` permite elegir otra
política; esta guía no supone que todas las señales usen siempre la predeterminada.

Un detalle de implementación: el núcleo compara **propuesta `==` valor actual**; el setter de `ValueNotifier` de
Flutter compara **valor actual `==` propuesta**. Una igualdad bien implementada debe ser simétrica, así que normalmente
el resultado coincide. No uses una igualdad asimétrica para explotar esta diferencia: violaría el contrato de `==`.
Tampoco son el mismo setter: la señal admite opciones y `set(..., force: true)` para omitir la comparación, que no se
aplica al `ValueNotifier` utilizado por `DaisyThemeController`.

### Ejemplo C: igual, distinto y mismo objeto conservado

Lee la clase y las operaciones sin ejecutarlas. Después de cada asignación, anota cuántos avisos se han acumulado y
cuál de los tres objetos conserva `estado.value`. Contrasta tus respuestas con la prueba completa de las
[soluciones](#ejemplo-c).

```dart
class Tema {
  const Tema(this.nombre, this.borde);

  final String nombre;
  final int borde;

  @override
  bool operator ==(Object other) =>
      other is Tema && nombre == other.nombre && borde == other.borde;

  @override
  int get hashCode => Object.hash(nombre, borde);
}
```

```dart
final original = Tema('claro', 1);
final equivalente = Tema('claro', 1);
final distinto = Tema('claro', 2);
final estado = signal<Tema>(original);
var avisos = 0;
void escuchar() => avisos++;
estado.addListener(escuchar);

estado.value = equivalente;
estado.value = distinto;
```

### Comprobación

- ¿Por qué la primera propuesta no reemplaza el objeto almacenado?
- ¿Qué cambiaría si `Tema` usara la igualdad por identidad de `Object`?
- ¿Por qué es importante comprobar las opciones de la señal antes de predecir la política de comparación?

## 9.6. Mutación interna y sustitución

Una señal ordinaria que contiene una lista guarda una referencia a esa lista. `estado.value.add(...)` llama a `add` en
la lista obtenida; no invoca el setter de la señal. Una referencia anterior a la misma lista ve la mutación. Reasignar
esa misma lista al setter normal no produce un cambio aceptado con la igualdad predeterminada de listas ordinarias,
porque es idéntica a sí misma. Una lista nueva ordinaria tiene otra identidad: con el `==` habitual de esas listas, una
sustitución se acepta incluso si contiene los mismos elementos.

### Ejemplo D: una lista compartida

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('mutar por dentro no ejecuta el setter', () {
    final estado = signal<List<String>>(<String>['claro']);
    addTearDown(estado.dispose);
    final anterior = estado.value;
    var avisos = 0;
    void escuchar() => avisos++;
    estado.addListener(escuchar);

    estado.value.add('oscuro');
    expect(anterior, ['claro', 'oscuro']);
    expect(avisos, 0);
    estado.value = estado.value;
    expect(avisos, 0);
    estado.value = <String>[...estado.value];
    expect(avisos, 1);
    expect(identical(anterior, estado.value), isFalse);
    estado.removeListener(escuchar);
  });
}
```

La prueba de contenido de `expect` es un comparador de pruebas; no convierte el `==` de `List` en comparación profunda.
Una alternativa de diseño es crear una nueva colección no modificable al actualizar y decidir explícitamente si una
propuesta equivalente debe descartarse. La API permite forzar una actualización, pero eso no deshace la mutación ni
crea una fotografía anterior. No confundas `signal<List<T>>` con las APIs especializadas de colecciones del paquete:
estas últimas pueden definir operaciones y políticas adicionales.

### Comprobación

- ¿Por qué la primera modificación no avisa y la copia exterior sí?
- ¿Qué ve `anterior` después de `add` y después de sustituir la lista?
- ¿Por qué forzar un aviso no recupera el contenido anterior?

## 9.7. Comparar con DaisyUI

El [controlador actual](../../../lib/themes/application/daisy_theme_controller.dart) no usa una señal para el tema:

```dart
final ValueNotifier<DaisyThemeModel> _palette;
ValueListenable<DaisyThemeModel> get theme => _palette;
void setTheme(DaisyThemeModel theme) => _palette.value = theme;
```

El constructor crea un `ValueNotifier` por controlador. `theme` devuelve ese mismo objeto con el tipo de lectura y
escucha `ValueListenable`; no crea una señal ni un adaptador. `setTheme` usa el setter del notificador, cuya comparación
estudiamos en la unidad 7. El propietario libera el controlador y cada consumidor retira sus propios listeners.

Las señales de esta unidad son ejercicios separados. Comparten con el notificador la capacidad de leer y escuchar,
pero sus detalles de comparación, integración y ciclo de vida deben comprobarse en su propia implementación.

### Comprobación

- ¿Qué objeto guarda el tema de cada controlador y qué tipo ofrece `theme`?
- ¿Qué ocurre al proponer un tema equivalente según la igualdad del modelo?
- ¿Por qué no puedes aplicar automáticamente al controlador las políticas de la señal estudiada?

## 9.8. Avisos, widgets y ciclo de vida

El [scope](../../../lib/themes/application/daisy_theme_scope.dart) es un
`InheritedNotifier<ValueListenable<DaisyThemeModel>>`. Recibe la vista del controlador, escucha su notifier y permite a
los consumidores registrar una dependencia heredada al consultar `DaisyThemeScope.of(context)`. Cuando llega un aviso,
Flutter puede marcar dependientes para su actualización y reconstruirlos en un frame posterior. El notificador no
dibuja ni reconstruye por sí solo toda la aplicación. Una reconstrucción tampoco equivale a afirmar
que todos los píxeles se repintaron.

Una lectura corriente de `.value` fuera de un contexto reactivo es una consulta puntual. Dentro de un contexto reactivo
del paquete, una lectura puede registrar una dependencia; identificar qué contexto realiza ese registro es materia de
la unidad 10. `SignalBuilder` es una integración diferente que también estudiaremos allí. No es necesario afirmar que
DaisyUI usa `SignalBuilder` para explicar su flujo actual de temas.

Al final de cada práctica, quien creó la señal la libera. El ejemplo B retira primero el callback que registró. En
esta versión las opciones predeterminadas no activan `autoDispose`; su uso opcional y las consecuencias de liberar
recursos se estudiarán en la unidad 13. No escribas ni sigas usando una señal después de liberarla.

### Comprobación

- ¿Qué papel desempeña `InheritedNotifier` entre el aviso y los dependientes?
- ¿Por qué un test de listeners no demuestra que un widget se haya reconstruido?
- Si un widget recibe un controlador prestado, ¿por qué no debe liberarlo solo por dejar de escucharlo?

## Materiales de estudio seleccionados

- **S1 · Signals:** [
  `signal<T>` de Flutter](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/signal.html)
  y [`FlutterSignal<T>`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterSignal-class.html)
  — 9.1–9.3. Compara creación, clase e interfaces con la implementación instalada.
- **S2 · Signals:** [
  `SignalOptions`](https://pub.dev/documentation/signals_core/latest/signals_core/SignalOptions-class.html)
  y [`Signal` del núcleo](https://pub.dev/documentation/signals_core/latest/signals_core/Signal-class.html) — 9.4–9.6.
  Revisa opciones y `set`; el código exacto usado por este proyecto está en la caché de paquetes resueltos.
- **F1 · Flutter:** [`ValueListenable`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html),
  [`ValueNotifier.value`](https://api.flutter.dev/flutter/foundation/ValueNotifier/value.html) e
  [`InheritedNotifier`](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html) — contratos, comparación
  del setter de Flutter y puente con los dependientes.
- **D1 · Dart:** [igualdad y diseño](https://dart.dev/effective-dart/design#equality) — simetría y contrato de `==`.
- **P1 · DaisyUI:** [controlador](../../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../../lib/themes/application/daisy_theme_scope.dart), [modelo](../../../lib/themes/domain/theme.dart) y
  [pruebas](../../../test/themes/daisy_theme_controller_test.dart).
- **P2 · Versiones:** [dependencias declaradas](../../../pubspec.yaml) y [versiones resueltas](../../../pubspec.lock).
  La documentación `latest` puede describir una versión posterior: comprueba siempre los paquetes resueltos.

## Proyecto de la unidad: un selector de tema

Crea una clase `SelectorTema` que posea una señal de `String` inicializada con `claro`. Expón una referencia de tipo
`ValueListenable<String>` para leer y escuchar; conserva el método `seleccionar` y la liberación en el propietario.
El objetivo es comprender el flujo. Como en B, exponer directamente la señal bajo otro tipo restringe las operaciones
visibles al compilar, pero no es una barrera frente a casts. DaisyUI devuelve su `ValueNotifier` directamente bajo el tipo `ValueListenable`.

### Requisitos

1. Crea el selector y conserva la lectura inicial. Registra un callback que agregue el valor actual a una lista.
2. Selecciona `oscuro`, vuelve a seleccionar `oscuro` y después selecciona `bosque`.
3. Retira el callback, selecciona `claro` y comprueba los avisos, el valor actual y la lectura inicial.
4. Libera el selector desde su propietario. Antes de ejecutar, anota qué asignaciones se aceptan y cuándo corre el
   listener. Hazlo sin `batch` externo ni escrituras reentrantes.

### Variaciones

- Si no retiras el callback antes de seleccionar `claro`, ¿qué valor adicional aparece?
- Si cambias el primer valor a `claro`, ¿cuántos avisos recibes antes de retirar el callback?
- Si dos selectores empiezan en `claro`, ¿cómo demuestras que cambiar uno no cambia el otro?
- ¿Qué necesitarías cambiar si un consumidor no debiera poder recuperar por cast la señal mutable?

## Qué tener cuidado

Algunos puntos suelen generar confusión. Revisemos los más frecuentes con ejemplos concretos:

**La señal no es el valor.** `contador` apunta al objeto señal; `contador.value` lee el entero que contiene. `final`
impide reasignar la variable `contador`, pero no impide cambiar `contador.value`. Piensa en la señal como una caja:
`final` significa que no puedes cambiar la caja, pero sí lo que hay dentro.

**No toda asignación produce un aviso.** Si la igualdad considera iguales el valor nuevo y el actual, la señal descarta
la propuesta y no avisa. En el ejemplo C, proponer `equivalente` no cambia nada porque compara igual.

**Mutar por dentro no invoca el setter.** `estado.value.add('oscuro')` modifica la lista que la señal contiene, pero
nunca llama al setter de la señal. Por eso el listener no recibe aviso. Solo `estado.value = ...` ejecuta el setter.

**El aviso no es la reconstrucción.** Un listener que se ejecuta demuestra que la señal avisó; no demuestra que un
widget se haya reconstruido. La reconstrucción depende de cómo Flutter conecta el aviso con los dependientes, algo que
estudiamos en la sección 9.8.

## Comprobación final

1. ¿Qué crea `signal<DaisyThemeModel>(initialTheme)` y dónde está el valor actual?
2. ¿Qué significa que la referencia a la señal sea `final`?
3. ¿Qué ofrece `ValueListenable<T>` y qué capacidades puede tener el objeto real además de ese tipo?
4. ¿Cómo conecta el mixin de Flutter `addListener` con la suscripción de Signals en la versión estudiada?
5. En B, ¿por qué no se ejecuta el callback al registrarlo y cuándo lee `oscuro`?
6. ¿Por qué el orden de ejecución del ejemplo B no se puede extrapolar a otros escenarios?
7. En C, ¿por qué permanece `original` al proponer `equivalente`? ¿Qué cambia con el valor distinto?
8. ¿En qué orden compara los operandos la señal y en qué orden los compara `ValueNotifier`? ¿Por qué una igualdad
   válida no debería depender de eso?
9. En D, ¿qué operación invoca el setter y cuál modifica solo el interior de la lista?
10. ¿Qué hacen `_palette`, `theme` y `setTheme` en DaisyUI?
11. ¿Qué conecta un aviso con los dependientes en el flujo actual del scope? ¿Qué no prueba un test de listeners?
12. ¿Quién retira la escucha y quién libera la señal? ¿Qué significa que un recurso sea prestado?

**Unidad dominada cuando:** puedes resolver el proyecto y seguir creación, comparación, almacenamiento, aviso y
limpieza sin copiar las respuestas ni saltarte quién realiza cada paso.

## Soluciones para contrastar después de practicar

### Ejemplo A

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('la señal conserva el valor actual', () {
    final FlutterSignal<String> tema = signal<String>('claro');
    addTearDown(tema.dispose);

    final lecturaAnterior = tema.value;
    expect(lecturaAnterior, 'claro');
    tema.value = 'oscuro';
    expect(tema.value, 'oscuro');
    expect(lecturaAnterior, 'claro');
  });
}
```

La lectura anterior es `claro`; el valor actual, después de la asignación, es `oscuro`. `lecturaAnterior` guarda la
referencia al `String` leído, no una suscripción que cambie con la señal. Como `String` es inmutable, sigue
representando `claro`; con una lista mutable compartida habría que razonar como en la unidad 8. Cada nueva llamada a
`signal` crea otra celda y actualizar una no cambia la otra.

### Ejemplo B

Los eventos son `antes`, `aviso: oscuro`, `después`. `bosque` se almacena después de retirar el listener, por eso la
lectura final lo encuentra pero no aparece otro aviso. Sin retirar el callback, se añadiría `aviso: bosque`.
`lectura` es una referencia a la misma señal, no un objeto adaptador.

### Ejemplo C

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

class Tema {
  const Tema(this.nombre, this.borde);

  final String nombre;
  final int borde;

  @override
  bool operator ==(Object other) =>
      other is Tema && nombre == other.nombre && borde == other.borde;

  @override
  int get hashCode => Object.hash(nombre, borde);
}

void main() {
  test('la igualdad predeterminada decide si se acepta la propuesta', () {
    final original = Tema('claro', 1);
    final equivalente = Tema('claro', 1);
    final distinto = Tema('claro', 2);
    final estado = signal<Tema>(original);
    addTearDown(estado.dispose);
    var avisos = 0;
    void escuchar() => avisos++;
    estado.addListener(escuchar);

    estado.value = equivalente;
    expect(avisos, 0);
    expect(identical(estado.value, original), isTrue);
    estado.value = distinto;
    expect(avisos, 1);
    expect(identical(estado.value, distinto), isTrue);
    estado.removeListener(escuchar);
  });
}
```

La propuesta equivalente compara igual: cero avisos y la señal conserva `original`. La propuesta con borde 2 compara
distinto: se almacena `distinto` y se recibe un aviso. Con igualdad por identidad, la primera propuesta distinta se
aceptaría y también avisaría. Una opción de comparación distinta puede producir otro resultado.

### Ejemplo D

`anterior` y el valor inicial apuntan a la misma lista; tras `add` ambos muestran `claro, oscuro`, sin aviso. Reasignar
la misma lista se descarta. La expansión crea otra lista exterior que se acepta y produce un aviso, aunque su contenido
sea igual. `anterior` sigue apuntando a la lista anterior.

### Una solución del proyecto

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

class SelectorTema {
  final FlutterSignal<String> _tema = signal<String>('claro');

  ValueListenable<String> get tema => _tema;

  void seleccionar(String nuevo) => _tema.value = nuevo;

  void dispose() => _tema.dispose();
}

void main() {
  test('seleccionar, escuchar y retirar', () {
    final selector = SelectorTema();
    addTearDown(selector.dispose);
    final lectura = selector.tema;
    final inicial = lectura.value;
    final avisos = <String>[];
    void escuchar() => avisos.add(lectura.value);

    lectura.addListener(escuchar);
    selector.seleccionar('oscuro');
    selector.seleccionar('oscuro');
    selector.seleccionar('bosque');
    lectura.removeListener(escuchar);
    selector.seleccionar('claro');

    expect(avisos, ['oscuro', 'bosque']);
    expect(lectura.value, 'claro');
    expect(inicial, 'claro');
  });

  test('cada selector conserva su propio tema', () {
    final primero = SelectorTema();
    final segundo = SelectorTema();
    addTearDown(primero.dispose);
    addTearDown(segundo.dispose);

    primero.seleccionar('oscuro');
    expect(primero.tema.value, 'oscuro');
    expect(segundo.tema.value, 'claro');

    segundo.seleccionar('bosque');
    expect(segundo.tema.value, 'bosque');
    expect(primero.tema.value, 'oscuro');
  });
}
```

Las propuestas aceptadas antes de retirar el callback son `oscuro` y `bosque`; repetir `oscuro` se descarta. Después,
`claro` se almacena sin ejecutar ese callback. Si no se retira, agrega `claro`. Si solo la primera propuesta cambia a
`claro`, se descarta la primera, se aceptan la segunda (`oscuro`) y la tercera (`bosque`): siguen siendo dos avisos.
En la segunda prueba, cada selector crea su propia señal: al cambiar el primero, el segundo sigue en `claro`; al
cambiar después el segundo, el primero permanece en `oscuro`. Un adaptador separado podría exponer otro objeto con API
de lectura; el controlador actual no utiliza uno.

### Claves de la comprobación final

1. Una `FlutterSignal<DaisyThemeModel>` inicializada con el modelo; la señal almacena la referencia al valor actual.
2. Impide reasignar la variable que contiene la señal, no cambiar su valor.
3. Lectura y escucha; el objeto concreto puede ofrecer escritura y `dispose`.
4. El mixin guarda el callback y usa una suscripción interna que puede cancelar al retirarlo.
5. La opción predeterminada suprime el callback inicial; en B lo lee durante la asignación aceptada.
6. La secuencia de B no se puede extrapolar: hay que analizar y probar ese escenario.
7. La igualdad predeterminada devuelve verdadero y no se reemplaza; el valor distinto se guarda y propaga.
8. Señal: propuesta frente a actual; `ValueNotifier`: actual frente a propuesta. `==` debe ser simétrico.
9. `estado.value = ...` ejecuta el setter; `estado.value.add(...)` modifica la lista devuelta.
10. El `ValueNotifier` conserva el tema; `theme` devuelve ese objeto como `ValueListenable` y `setTheme` le asigna un valor.
11. `InheritedNotifier` escucha y conecta el aviso con las dependencias heredadas; el test de listeners no prueba
    reconstrucción ni repintado.
12. El consumidor retira lo que registró; el propietario libera la señal. Prestado significa que su vida útil la
    administra otro dueño.