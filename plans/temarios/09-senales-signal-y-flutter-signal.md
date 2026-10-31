# 09. Señales: `signal<T>` y `FlutterSignal<T>`

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 8](08-identidad-igualdad-e-inmutabilidad.md)

- **Bloque:** Signals: almacenar y relacionar estado.
- **Estado de estudio:** pendiente.
- **Investigación de fuentes:** 31 de octubre de 2026.

## Qué vas a conseguir

Podrás seguir la creación de una señal, su valor inicial, una lectura, el registro de un listener y una escritura.
Identificarás qué objeto almacena el valor, qué compara la implementación instalada, cuándo el listener puede leer el
nuevo valor y por qué un aviso no equivale por sí solo a una reconstrucción de Flutter.

Aplicaremos ese recorrido a `_palette.value = theme` en `DaisyThemeController`. También distinguirás el objeto señal de
su valor, el tipo `ValueListenable` de las capacidades reales de un objeto, y el adaptador público de DaisyUI de la
señal privada. Las dependencias rastreadas y `SignalBuilder` se estudian a fondo en la unidad 10; `computed`, `effect`
y propiedad de recursos tienen unidades posteriores.

## Versiones y forma de practicar

Esta guía se contrastó con el `pubspec.lock` y la implementación instalada: **`signals_flutter` 7.1.0**,
**`signals_core` 7.0.0** y **`preact_signals` 7.0.0**. `pubspec.yaml` declara un rango para `signals_flutter`; la
versión resuelta y sus dependencias son las que determinan el comportamiento de estos ejemplos. La documentación con
`latest` puede cambiar. Los comportamientos internos descritos aquí corresponden a esa combinación de versiones, no a
cualquier biblioteca llamada «signals».

Los ejemplos A–D y la solución del proyecto son archivos de prueba Flutter completos e independientes. Copia uno a la
vez en `test/estudio_senales_test.dart` dentro del repositorio y ejecuta:

```shell
flutter test --no-pub test/estudio_senales_test.dart
```

La opción `--no-pub` usa las dependencias ya resueltas; si no están instaladas, primero habrá que resolverlas. Los
programas importan `signals_flutter` y `flutter_test`: **no son programas Dart independientes listos para DartPad**.
Elimina el archivo de práctica cuando termines o guárdalo con otro nombre si quieres conservarlo. Los fragmentos sin
`main` son para leer. A cada ejemplo le siguen predicciones y soluciones más abajo.

## Ruta y progreso

- [ ] [9.1. Qué problema resuelve una señal](#91-qué-problema-resuelve-una-señal).
- [ ] [9.2. Crear, leer y escribir](#92-crear-leer-y-escribir).
- [ ] [9.3. Observar una señal desde Flutter](#93-observar-una-señal-desde-flutter).
- [ ] [9.4. Orden de ejecución y valor actual](#94-orden-de-ejecución-y-valor-actual).
- [ ] [9.5. Igualdad y conservación del valor](#95-igualdad-y-conservación-del-valor).
- [ ] [9.6. Mutación interna y sustitución](#96-mutación-interna-y-sustitución).
- [ ] [9.7. El recorrido en DaisyUI](#97-el-recorrido-en-daisyui).
- [ ] [9.8. Avisos, widgets y ciclo de vida](#98-avisos-widgets-y-ciclo-de-vida).
- [ ] [Resolver el proyecto de la unidad](#proyecto-de-la-unidad-un-selector-de-tema).
- [ ] [Superar la comprobación final](#comprobación-final).

Una sesión puede cubrir 9.1–9.3; otra, 9.4–9.6; una tercera, 9.7–9.8 y el proyecto. Escribe tus predicciones
antes de mirar las soluciones y marca las casillas cuando puedas explicarlas con tus palabras.

## 9.1. Qué problema resuelve una señal

Una variable guarda una referencia que podemos consultar y, si es reasignable, cambiar. Pero un consumidor que leyó
esa variable en otro momento no recibe por ello un aviso de cambios. Una señal añade una fuente observable: conserva
un valor actual y ofrece formas de relacionar observadores con cambios aceptados de ese valor.

Piensa en una pizarra con el tema actual y un sistema para avisar a quienes se apuntaron. Leer la pizarra una vez no
es lo mismo que apuntarse para escuchar. Esta analogía no explica por sí sola cómo se registran observadores, cómo se
compara un valor ni cuándo Flutter decide reconstruir: esas decisiones pertenecen a implementaciones concretas.

En este proyecto, [`signal<T>` de `signals_flutter`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/signal.html)
crea un [`FlutterSignal<T>`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterSignal-class.html)
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

Predice los tres `expect` antes de ejecutar. La lectura anterior guarda la referencia al `String` leído, no una
conexión que cambie con la señal. Como `String` es inmutable, sigue representando `claro`. En la unidad 8 vimos por qué
una lectura de una lista mutable compartida necesita un razonamiento diferente.

La escritura `tema.value = 'oscuro'` llama al setter de la señal; no sustituye la variable `tema`. En esta combinación
de versiones el setter delega en `set`, que comprueba si acepta la propuesta y actualiza el valor en caso afirmativo.
Crear una segunda señal con el mismo valor inicial crea otra celda independiente; no crea otra referencia a la primera.

### Comprobación

- ¿Qué vale `lecturaAnterior` después de la asignación y por qué?
- ¿Qué se sustituye: la señal o su valor?
- Si hay dos señales creadas por separado, ¿escribir en una cambia la otra?

## 9.3. Observar una señal desde Flutter

`FlutterSignal<T>` extiende la señal del núcleo y, en la versión instalada, implementa la interfaz
`ValueNotifier<T>` mediante `ValueNotifierSignalMixin<T>`. Por esa vía también satisface
[`ValueListenable<T>`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html): un consumidor Flutter
puede leer `value` y registrar o retirar callbacks sin conocer toda la API de Signals.

**Implementar la interfaz de `ValueNotifier` no significa heredar su implementación concreta.** La señal no es un
`ChangeNotifier` solo porque admita ese contrato. Su almacenamiento, comparación y mecanismo de escucha proceden de
Signals. `ValueListenable<T>` promete el getter y la escucha, no un setter ni `dispose`; el objeto real puede tener
más capacidades que las expuestas por el tipo de una variable.

En `signals_flutter` 7.1.0, `addListener(callback)` utiliza una suscripción interna de Signals para ejecutar ese
callback. El puente registra el callback en un mapa y guarda cómo cancelar la suscripción. La suscripción interna se
establece inicialmente; con la opción predeterminada `runCallbackOnListen: false`, el puente **suprime la primera
llamada al callback del consumidor**. Por eso registrar un listener no lo ejecuta en los ejemplos de esta guía. Si se
crea la señal con `runCallbackOnListen: true`, sí se llama al callback al registrar. Esto es política de esta
implementación, no garantía general de `Listenable`.

En esa misma implementación, volver a registrar **el mismo callback** no crea otra entrada en el mapa, y una retirada
lo cancela. No extrapoles esa política a `ChangeNotifier` ni a todos los `Listenable`: otras implementaciones pueden
tratar los registros duplicados de otra forma. Usa la misma referencia a la función para retirarla.

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
esa variable, pero un consumidor podría reconocer el tipo real mediante un cast. DaisyUI utiliza un objeto adaptador
separado para exponer su API pública.

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
usa en `DaisyThemeController`.

### Ejemplo C: igual, distinto y mismo objeto conservado

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

Predice los cuatro `expect`. Aquí dos instancias separadas de `Tema` pueden ser iguales por sus campos. La primera
propuesta no reemplaza el objeto; la segunda sí. El callback no recibe el dato como argumento, aunque en este ejemplo
solo contamos sus ejecuciones.

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

## 9.7. El recorrido en DaisyUI

El [controlador](../../lib/themes/application/daisy_theme_controller.dart) contiene estas piezas:

```dart
DaisyThemeController({DaisyThemeModel initialTheme = DaisyThemes.light})
  : _palette = signal<DaisyThemeModel>(initialTheme);

final FlutterSignal<DaisyThemeModel> _palette;
late final ValueListenable<DaisyThemeModel> _theme = _ThemeListenable(_palette);
ValueListenable<DaisyThemeModel> get theme => _theme;

void setTheme(DaisyThemeModel theme) {
  _palette.value = theme;
}
```

1. Al construir el controlador se llama a `signal<DaisyThemeModel>(initialTheme)`: se crea una señal con el modelo
   inicial, por defecto `DaisyThemes.light`. Cada controlador construido crea su propia señal.
2. `_palette` es una referencia privada y `final` a esa señal. La señal conserva el modelo actual y puede sustituirlo.
3. Al acceder por primera vez a `controller.theme`, el campo `late final` crea `_ThemeListenable` con la señal como
   fuente. Después se reutiliza ese adaptador; no es una copia del tema ni una segunda señal.
4. El getter `value` del adaptador lee `_source.value`; `addListener` y `removeListener` reenvían a esa misma fuente.
   El adaptador no emite un segundo aviso. Su API pública no ofrece escritura ni liberación de la señal.
5. `controller.setTheme(nuevo)` ejecuta `_palette.value = nuevo`. Con las opciones predeterminadas actuales, la señal
   compara propuesta y valor almacenado; si son iguales, conserva el valor anterior sin propagar; si son diferentes,
   guarda el nuevo y propaga el cambio a sus suscriptores.
6. Si un listener se registró mediante la vista, el puente de la señal lo invoca. Si consulta `controller.theme.value`,
   el adaptador delega la lectura y devuelve el valor actual. El orden concreto depende también de lotes y reentradas.
7. El dueño del controlador llama a `dispose()` cuando termina su uso. Un consumidor que solo pidió escuchar debe
   retirar su listener cuando deje de necesitarlo; poseer y escuchar son responsabilidades distintas.

El [modelo de tema](../../lib/themes/domain/theme.dart) usa Freezed; su [igualdad generada](../../lib/themes/domain/generated/theme.freezed.dart)
compara los campos actuales según las igualdades de sus valores. La prueba existente del
[controlador](../../test/themes/daisy_theme_controller_test.dart) observa que `light.copyWith()` no avisa y que cambiar
a `dark` sí. Un cambio de tema y una reconstrucción de interfaz son eventos distintos.

### Comprobación

- ¿Cuántas señales se crean al construir dos controladores? ¿Qué comparten si se usa una sola instancia?
- ¿Quién guarda el modelo, quién reenvía la escucha y quién puede escribir?
- ¿Por qué `_ThemeListenable` no almacena una segunda copia del tema?
- ¿Qué pasaría al asignar un `DaisyThemeModel` equivalente con la configuración actual?

## 9.8. Avisos, widgets y ciclo de vida

El [scope](../../lib/themes/application/daisy_theme_scope.dart) es un
`InheritedNotifier<ValueListenable<DaisyThemeModel>>`. Recibe la vista del controlador, escucha su notifier y permite a
los consumidores registrar una dependencia heredada al consultar `DaisyThemeScope.of(context)`. Cuando llega un aviso,
Flutter puede marcar dependientes para su actualización y reconstruirlos en un frame posterior. El adaptador no dibuja
ni reconstruye; la señal no reconstruye por sí sola toda la aplicación. Una reconstrucción tampoco equivale a afirmar
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

- **S1 · Signals:** [`signal<T>` de Flutter](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/signal.html)
  y [`FlutterSignal<T>`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterSignal-class.html)
  — 9.1–9.3. Compara creación, clase e interfaces con la implementación instalada.
- **S2 · Signals:** [`SignalOptions`](https://pub.dev/documentation/signals_core/latest/signals_core/SignalOptions-class.html)
  y [`Signal` del núcleo](https://pub.dev/documentation/signals_core/latest/signals_core/Signal-class.html) — 9.4–9.6.
  Revisa opciones y `set`; el código exacto usado por este proyecto está en la caché de paquetes resueltos.
- **F1 · Flutter:** [`ValueListenable`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html),
  [`ValueNotifier.value`](https://api.flutter.dev/flutter/foundation/ValueNotifier/value.html) e
  [`InheritedNotifier`](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html) — contratos, comparación
  del setter de Flutter y puente con los dependientes.
- **D1 · Dart:** [igualdad y diseño](https://dart.dev/effective-dart/design#equality) — simetría y contrato de `==`.
- **P1 · DaisyUI:** [controlador](../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../lib/themes/application/daisy_theme_scope.dart), [modelo](../../lib/themes/domain/theme.dart) y
  [pruebas](../../test/themes/daisy_theme_controller_test.dart).
- **P2 · Versiones:** [dependencias declaradas](../../pubspec.yaml) y [versiones resueltas](../../pubspec.lock).
  La documentación `latest` puede describir una versión posterior: comprueba siempre los paquetes resueltos.

## Proyecto de la unidad: un selector de tema

Crea una clase `SelectorTema` que posea una señal de `String` inicializada con `claro`. Expón una referencia de tipo
`ValueListenable<String>` para leer y escuchar; conserva el método `seleccionar` y la liberación en el propietario.
El objetivo es comprender el flujo. Como en B, exponer directamente la señal bajo otro tipo restringe las operaciones
visibles al compilar, pero no es una barrera frente a casts; DaisyUI usa un adaptador separado.

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

## Errores de comprensión que vamos a comprobar

- Confundir la señal con el valor que contiene o pensar que `final` impide cambiar `.value`.
- Creer que una lectura puntual por sí sola registra una reconstrucción de Flutter.
- Atribuir a todas las señales la implementación concreta de `ValueNotifier` o de `ChangeNotifier`.
- Creer que toda asignación aceptará la propuesta y ejecutará un callback, incluso si la igualdad la descarta.
- Omitir que un valor equivalente puede dejar almacenado el objeto anterior.
- Suponer que mutar un objeto dentro de la señal invoca el setter.
- Dar por universal el orden de B o la política de registros duplicados de esta implementación.
- Confundir la vista de lectura del controlador con otra señal o con una copia del valor.
- Confundir aviso, dependencia, reconstrucción y repintado, o liberar un recurso prestado.

## Comprobación final

1. ¿Qué crea `signal<DaisyThemeModel>(initialTheme)` y dónde está el valor actual?
2. ¿Qué significa que la referencia a la señal sea `final`?
3. ¿Qué ofrece `ValueListenable<T>` y qué capacidades puede tener el objeto real además de ese tipo?
4. ¿Cómo conecta el mixin de Flutter `addListener` con la suscripción de Signals en la versión estudiada?
5. En B, ¿por qué no se ejecuta el callback al registrarlo y cuándo lee `oscuro`?
6. ¿Cómo cambia la predicción si hay un `batch` externo o un callback reentrante?
7. En C, ¿por qué permanece `original` al proponer `equivalente`? ¿Qué cambia con el valor distinto?
8. ¿En qué orden compara los operandos la señal y en qué orden los compara `ValueNotifier`? ¿Por qué una igualdad
   válida no debería depender de eso?
9. En D, ¿qué operación invoca el setter y cuál modifica solo el interior de la lista?
10. ¿Qué hacen `_palette`, `_ThemeListenable` y `setTheme` en DaisyUI?
11. ¿Qué conecta un aviso con los dependientes en el flujo actual del scope? ¿Qué no prueba un test de listeners?
12. ¿Quién retira la escucha y quién libera la señal? ¿Qué significa que un recurso sea prestado?

**Unidad dominada cuando:** puedes resolver el proyecto y seguir creación, comparación, almacenamiento, aviso y
limpieza sin copiar las respuestas ni saltarte quién realiza cada paso.

## Soluciones para contrastar después de practicar

### Ejemplo A

La lectura anterior es `claro`; el valor actual, después de la asignación, es `oscuro`. `lecturaAnterior` no es una
suscripción. Cada nueva llamada a `signal` crea otra celda y actualizar una no cambia la otra.

### Ejemplo B

Los eventos son `antes`, `aviso: oscuro`, `después`. `bosque` se almacena después de retirar el listener, por eso la
lectura final lo encuentra pero no aparece un tercer aviso. Sin retirar el callback, se añadiría `aviso: bosque`.
`lectura` es una referencia a la misma señal, no un objeto adaptador.

### Ejemplo C

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
}
```

Las propuestas aceptadas antes de retirar el callback son `oscuro` y `bosque`; repetir `oscuro` se descarta. Después,
`claro` se almacena sin ejecutar ese callback. Si no se retira, agrega `claro`. Si solo la primera propuesta cambia a
`claro`, se descarta la primera, se aceptan la segunda (`oscuro`) y la tercera (`bosque`): siguen siendo dos avisos.
Un adaptador separado como `_ThemeListenable` oculta la señal real tras otro objeto con la API de lectura.

### Claves de la comprobación final

1. Una `FlutterSignal<DaisyThemeModel>` inicializada con el modelo; la señal almacena la referencia al valor actual.
2. Impide reasignar la variable `_palette`, no cambiar el valor de la señal.
3. Lectura y escucha; el objeto concreto puede ofrecer escritura y `dispose`.
4. El mixin guarda el callback y usa una suscripción interna que puede cancelar al retirarlo.
5. La opción predeterminada suprime el callback inicial; en B lo lee durante la asignación aceptada.
6. La secuencia de B no se puede extrapolar: hay que analizar y probar ese escenario.
7. La igualdad predeterminada devuelve verdadero y no se reemplaza; el valor distinto se guarda y propaga.
8. Señal: propuesta frente a actual; `ValueNotifier`: actual frente a propuesta. `==` debe ser simétrico.
9. `estado.value = ...` ejecuta el setter; `estado.value.add(...)` modifica la lista devuelta.
10. La señal conserva el tema, el adaptador reenvía lectura y escucha, y el controlador asigna a la señal.
11. `InheritedNotifier` escucha y conecta el aviso con las dependencias heredadas; el test de listeners no prueba
    reconstrucción ni repintado.
12. El consumidor retira lo que registró; el propietario libera la señal. Prestado significa que su vida útil la
    administra otro dueño.

## Qué se ha revisado y cómo se ha comprobado

- Se revisaron las referencias oficiales enlazadas, el controlador, el scope, el modelo generado y las pruebas del
  proyecto. También se leyeron las implementaciones instaladas de `signals_flutter` 7.1.0, `signals_core` 7.0.0 y
  `preact_signals` 7.0.0; las afirmaciones internas quedan limitadas a esas versiones y casos indicados.
- El grafo rechazó indexar esta carpeta por su configuración de acceso; los archivos citados se contrastaron mediante
  lectura directa.
- Pasaron los cuatro ejemplos, la solución del proyecto, dos comprobaciones adicionales de registro y de señales
  independientes, y las tres pruebas existentes del controlador: **10 pruebas**. El analizador de Dart no encontró
  problemas en los seis archivos temporales; después se retiraron. Estas pruebas no demuestran reconstrucciones,
  repintados ni comportamiento en un dispositivo.
- Se comprobaron los enlaces locales, los bloques de código y `git diff --check`. El estudio permanece pendiente hasta
  resolver y explicar las prácticas.
