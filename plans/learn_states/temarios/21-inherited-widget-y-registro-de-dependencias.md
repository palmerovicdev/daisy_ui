# 21. `InheritedWidget` y registro de dependencias

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 20](20-build-context-y-el-arbol-de-widgets.md) · **Estado:** pendiente

## Qué vas a aprender

La unidad 20 mostró que un contexto puede **encontrar** datos en sus ancestros. Pero encontrar algo una vez no sirve de
mucho si ese dato cambia después. `Text(context.daisyTheme.name)` se actualiza cuando cambia el tema: ¿cómo sabe Flutter
que **ese** widget, y no otro, necesita volver a construirse?

Al terminar podrás escribir un `InheritedWidget` propio y explicar qué relación se establece entre el consumidor y el
proveedor. Distinguirás consultar un valor de consultarlo registrando una dependencia, y sabrás identificar qué
consumidores dependen de un valor heredado. También sabrás por qué un widget puede actualizarse «por casualidad» sin
haber registrado ninguna dependencia, y qué papel tiene `updateShouldNotify`.

Los ejemplos completos son pruebas de widgets independientes. Copia **una cada vez** a `test/estudio_heredado_test.dart`
y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_heredado_test.dart
```

Necesitas las dependencias ya resueltas. Predice cada resultado antes de mirarlo. Los fragmentos identificados como
tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar con 7–8 y el
ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0;
consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas. Los nombres internos de Flutter que
citemos, como `_dependents`, sirven para seguir el mecanismo y pueden cambiar entre versiones; lo que no cambia es el
contrato de los métodos públicos.

## 1. El problema: pasar un dato por todos los niveles

Imagina una pantalla con un grosor de borde. Solo la caja del fondo lo utiliza, pero entre la raíz y la caja hay varios
widgets. Con lo que conocemos hasta ahora, cada nivel debe recibirlo y entregarlo. Este **fragmento** lo muestra:

```dart
class Pantalla extends StatelessWidget {
  const Pantalla({super.key, required this.grosor});
  final int grosor;

  @override
  Widget build(BuildContext context) => Seccion(grosor: grosor);
}

class Seccion extends StatelessWidget {
  const Seccion({super.key, required this.grosor});
  final int grosor; // No lo usa: solo lo reenvía.

  @override
  Widget build(BuildContext context) => Caja(grosor: grosor);
}
```

Esto funciona, pero tiene tres inconvenientes. `Seccion` declara un dato que no usa, y añadir otro dato obliga a
modificar todos los niveles. Además, cuando cambia el grosor, cada nivel recibe una descripción distinta y se
reconstruye sin necesidad (unidad 18).

Nos gustaría que la raíz **publicara** el dato para todo lo que tiene debajo, y que quien lo necesite lo recogiera. Ya
sabemos la mitad de la solución: buscar hacia arriba desde el contexto. Falta el widget que publica y la manera de
avisar.

### Practica 1

En la cadena `Pantalla → Seccion → Caja`, ¿qué widgets deberían conocer `grosor` si solo `Caja` lo muestra? ¿Qué widgets
lo conocen con el código del fragmento?

<details>
<summary>Ver respuesta</summary>

Debería conocerlo `Caja` y quien lo proporciona. Con el fragmento, lo conocen los tres, y `Seccion` solo por tener que
reenviarlo. Esa es la dependencia innecesaria que queremos eliminar.

</details>

## 2. Un primer `InheritedWidget`

Un `InheritedWidget` es un widget que **publica datos para sus descendientes**. No dibuja nada: tiene un `child` y unos
campos. A pesar del nombre, no tiene relación con heredar de una clase mediante `extends`. Aquí «heredado» significa que
el dato se recibe por la **posición en el árbol**.

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class BordeHeredado extends InheritedWidget {
  const BordeHeredado({super.key, required this.grosor, required super.child});

  final int grosor;

  static int of(BuildContext context) {
    final encontrado =
        context.dependOnInheritedWidgetOfExactType<BordeHeredado>();
    if (encontrado == null) {
      throw FlutterError('Coloca BordeHeredado por encima de este widget.');
    }
    return encontrado.grosor;
  }

  @override
  bool updateShouldNotify(BordeHeredado oldWidget) {
    return grosor != oldWidget.grosor;
  }
}

class Seccion extends StatelessWidget {
  const Seccion({super.key});

  @override
  Widget build(BuildContext context) => const Caja();
}

class Caja extends StatelessWidget {
  const Caja({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Grosor: ${BordeHeredado.of(context)}');
  }
}

void main() {
  testWidgets('un dato heredado llega a la caja', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: BordeHeredado(grosor: 2, child: Seccion()),
      ),
    );

    expect(find.text('Grosor: 2'), findsOneWidget);
  });
}
```

Las líneas nuevas:

- `extends InheritedWidget` declara un proveedor. `required super.child` reenvía el hijo a la clase padre (unidad 15).
- `grosor` es el dato publicado. Como en cualquier widget, es `final`.
- `updateShouldNotify` decide si hay que avisar a los dependientes cuando llega otra descripción. Lo veremos en el
  apartado 6.
- `of` es un método estático: se llama con el nombre de la clase, antes de tener una instancia (unidad 17). Agrupa la
  búsqueda y el tratamiento del error.
- `dependOnInheritedWidgetOfExactType<BordeHeredado>()` es la operación central. Devuelve el `BordeHeredado` más cercano
  o `null`, y hace algo más que veremos enseguida.

`Seccion` ya no sabe nada del grosor, y por eso puede ser `const`. Así, la conexión entre `Caja` y `BordeHeredado` se
resuelve mediante el árbol. La búsqueda sigue la regla de la unidad 20: hacia arriba, el más cercano y por tipo.

### Practica 2

Colocamos dos proveedores anidados: `BordeHeredado(grosor: 1, child: BordeHeredado(grosor: 5, child: Caja()))`. ¿Qué
muestra la caja? ¿Qué ocurre si no hay ninguno? ¿Y si `Caja` usa su contexto dentro del `build` de un widget situado por
encima del proveedor?

<details>
<summary>Ver respuesta</summary>

Muestra `Grosor: 5`, el más cercano. Sin ninguno, `encontrado` es `null` y se lanza el error. Si el contexto está por
encima del proveedor, no lo encuentra: se aplica lo mismo que en la unidad 20, porque un `InheritedWidget` solo es
visible para sus descendientes.

</details>

## 3. Cuando cambia el dato: solo se reconstruye el consumidor

Pongamos ahora el dato en un `State` y comprobemos quién se reconstruye. `Raiz` recibe su `child` por parámetro. `Ajeno`
es otro descendiente que no lee el grosor.

**Antes de mirar los `expect`**, predice los tres contadores después de `cambiar(2)`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final builds = <String, int>{'seccion': 0, 'caja': 0, 'ajeno': 0};

class BordeHeredado extends InheritedWidget {
  const BordeHeredado({super.key, required this.grosor, required super.child});

  final int grosor;

  static int of(BuildContext context) {
    final encontrado =
        context.dependOnInheritedWidgetOfExactType<BordeHeredado>();
    if (encontrado == null) {
      throw FlutterError('Coloca BordeHeredado por encima de este widget.');
    }
    return encontrado.grosor;
  }

  @override
  bool updateShouldNotify(BordeHeredado oldWidget) {
    return grosor != oldWidget.grosor;
  }
}

class Raiz extends StatefulWidget {
  const Raiz({super.key, required this.child});

  final Widget child;

  @override
  State<Raiz> createState() => RaizState();
}

class RaizState extends State<Raiz> {
  int grosor = 1;

  void cambiar(int nuevo) => setState(() => grosor = nuevo);

  @override
  Widget build(BuildContext context) {
    return BordeHeredado(grosor: grosor, child: widget.child);
  }
}

class Seccion extends StatelessWidget {
  const Seccion({super.key});

  @override
  Widget build(BuildContext context) {
    builds['seccion'] = builds['seccion']! + 1;
    return const Column(children: [Caja(), Ajeno()]);
  }
}

class Caja extends StatelessWidget {
  const Caja({super.key});

  @override
  Widget build(BuildContext context) {
    builds['caja'] = builds['caja']! + 1;
    return Text('Grosor: ${BordeHeredado.of(context)}');
  }
}

class Ajeno extends StatelessWidget {
  const Ajeno({super.key});

  @override
  Widget build(BuildContext context) {
    builds['ajeno'] = builds['ajeno']! + 1;
    return const Text('Ajeno');
  }
}

void main() {
  testWidgets('solo se reconstruye quien depende', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Raiz(child: Seccion()),
      ),
    );
    expect(builds, {'seccion': 1, 'caja': 1, 'ajeno': 1});

    tester.state<RaizState>(find.byType(Raiz)).cambiar(2);
    await tester.pump();
    expect(find.text('Grosor: 2'), findsOneWidget);
    expect(builds, {'seccion': 1, 'caja': 2, 'ajeno': 1});
  });
}
```

`Seccion` no se ha reconstruido y `Caja`, que está debajo de ella, sí. Es la diferencia con el apartado 1. Sigamos qué
ocurre, sin dar nada por «automático»:

1. `cambiar` llama a `setState`, que marca el elemento de `Raiz`. `pump` lo procesa y ejecuta su `build`.
2. Ese `build` crea un **nuevo** `BordeHeredado` con `grosor: 2`. Mismo tipo y misma `key`: su elemento permanece y
   recibe la descripción nueva (unidad 18).
3. Ese elemento, un `InheritedElement`, llama a `updateShouldNotify(anterior)`. El grosor ha cambiado, y devuelve
   `true`.
4. Recorre **la lista de elementos que registraron una dependencia** y, para cada uno, llama a `didChangeDependencies`.
   Su efecto es marcarlo para reconstruir con `markNeedsBuild`. En nuestro árbol, esa lista contiene solo el elemento de
   `Caja`.
5. El `InheritedElement` continúa con su hijo: `widget.child` es **el mismo objeto** `Seccion` de antes, así que Flutter
   no trabaja en él (unidad 18). Se detiene ahí.
6. El elemento marcado de `Caja` se procesa en este mismo frame. Su `build` lee el grosor nuevo.

Por eso `Raiz` recibe el `child` por parámetro: es lo que hace que `widget.child` sea siempre el mismo objeto.

### Practica 3

¿Qué contadores obtenemos si `Caja` se escribe `const Caja()` dentro de un `Column` sin `const` en `Seccion`, y llamamos
a `cambiar(2)`? ¿Cambia algo?

<details>
<summary>Ver respuesta</summary>

Los mismos: `seccion` 1, `caja` 2 y `ajeno` 1. `Seccion` no llega a ejecutar `build`, de modo que nadie crea esa
`Column`. El paso 5 se detiene antes. El `const` importa dentro de un `build` que sí se ejecuta, como veremos en el
apartado 5.

</details>

## 4. Consultar con dependencia y sin ella

Hasta ahora dependíamos del dato cada vez que lo consultábamos. `BuildContext` ofrece otra operación con un resultado
parecido: `getInheritedWidgetOfExactType`. Busca lo mismo, pero **no registra nada**.

**Antes de mirar los `expect`**, predice qué muestra cada consumidor después de cambiar el grosor:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class BordeHeredado extends InheritedWidget {
  const BordeHeredado({super.key, required this.grosor, required super.child});

  final int grosor;

  @override
  bool updateShouldNotify(BordeHeredado oldWidget) {
    return grosor != oldWidget.grosor;
  }
}

class ConDependencia extends StatelessWidget {
  const ConDependencia({super.key});

  @override
  Widget build(BuildContext context) {
    final borde = context.dependOnInheritedWidgetOfExactType<BordeHeredado>();
    return Text('Con: ${borde!.grosor}');
  }
}

class SinDependencia extends StatefulWidget {
  const SinDependencia({super.key});

  @override
  State<SinDependencia> createState() => SinDependenciaState();
}

class SinDependenciaState extends State<SinDependencia> {
  void refrescar() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final borde = context.getInheritedWidgetOfExactType<BordeHeredado>();
    return Text('Sin: ${borde!.grosor}');
  }
}

Widget arbol(int grosor) => Directionality(
  textDirection: TextDirection.ltr,
  child: BordeHeredado(
    grosor: grosor,
    child: const Column(children: [ConDependencia(), SinDependencia()]),
  ),
);

void main() {
  testWidgets('leer con dependencia y sin ella', (tester) async {
    await tester.pumpWidget(arbol(1));
    expect(find.text('Con: 1'), findsOneWidget);
    expect(find.text('Sin: 1'), findsOneWidget);

    await tester.pumpWidget(arbol(2));
    expect(find.text('Con: 2'), findsOneWidget);
    expect(find.text('Sin: 1'), findsOneWidget);

    tester.state<SinDependenciaState>(find.byType(SinDependencia)).refrescar();
    await tester.pump();
    expect(find.text('Sin: 2'), findsOneWidget);
  });
}
```

`!` afirma que el resultado no es `null`, porque sabemos que el proveedor existe en este árbol; se estudia en la unidad
23.

1. Al cambiar el grosor, el proveedor avisa solo a sus dependientes. `ConDependencia` se reconstruye; `SinDependencia`
   no figura en la lista y sigue mostrando la lectura anterior.
2. Cuando otra causa reconstruye a `SinDependencia`, su consulta encuentra el proveedor actual y lee `2`. El valor no
   estaba guardado en ningún sitio: se consulta cada vez.

Las dos consultas responden a preguntas diferentes:

| Operación                          | Pregunta                                                 | ¿Se reconstruirá? |
|------------------------------------|----------------------------------------------------------|-------------------|
| `dependOnInheritedWidgetOfExactType` | ¿Qué vale ahora, y me avisas cuando cambie?            | Sí                |
| `getInheritedWidgetOfExactType`    | ¿Qué vale ahora?                                         | No                |

Es la misma distinción que venimos haciendo desde la unidad 1, entre consultar un dato y enterarse de sus cambios. En
`build`, lo habitual es querer la primera, ya que queremos mostrar el valor actual. La segunda encaja con usos
puntuales, como leer un dato al pulsar un botón.

### Practica 4

Un botón lee el grosor **solo** dentro de `onPressed`, para enviarlo a un servidor, y no lo muestra en pantalla. ¿Qué
operación elegirías? ¿Qué ocurriría con cada una?

<details>
<summary>Ver respuesta</summary>

`getInheritedWidgetOfExactType`. Lee el valor actual en el momento de la pulsación y no añade reconstrucciones. Con
`dependOnInheritedWidgetOfExactType`, también obtendrías el valor correcto, pero a partir de esa pulsación el botón
quedaría registrado y se reconstruiría en cada cambio, sin mostrar nada nuevo. Lo comprobaremos en la unidad 23.

</details>

## 5. Dos causas de reconstrucción: la trampa del árbol en línea

En el apartado 3 tuvimos cuidado de entregar `child` por parámetro. ¿Y si lo creamos dentro del `build` del `State`,
como suele hacerse al empezar? **Antes de mirar los `expect`**, predice si `SinLeer` se actualiza:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

var buildsSinLeer = 0;

class BordeHeredado extends InheritedWidget {
  const BordeHeredado({super.key, required this.grosor, required super.child});

  final int grosor;

  @override
  bool updateShouldNotify(BordeHeredado oldWidget) {
    return grosor != oldWidget.grosor;
  }
}

class SinLeer extends StatelessWidget {
  const SinLeer({super.key, required this.etiqueta});

  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    buildsSinLeer++;
    final borde = context.getInheritedWidgetOfExactType<BordeHeredado>();
    return Text('$etiqueta: ${borde!.grosor}');
  }
}

class RaizEnLinea extends StatefulWidget {
  const RaizEnLinea({super.key});

  @override
  State<RaizEnLinea> createState() => RaizEnLineaState();
}

class RaizEnLineaState extends State<RaizEnLinea> {
  int grosor = 1;

  void cambiar(int nuevo) => setState(() => grosor = nuevo);

  @override
  Widget build(BuildContext context) {
    return BordeHeredado(
      grosor: grosor,
      // ignore: prefer_const_constructors
      child: SinLeer(etiqueta: 'En línea'),
    );
  }
}

void main() {
  testWidgets('una causa distinta oculta la falta de dependencia', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: RaizEnLinea(),
      ),
    );
    expect(buildsSinLeer, 1);

    tester.state<RaizEnLineaState>(find.byType(RaizEnLinea)).cambiar(2);
    await tester.pump();
    expect(find.text('En línea: 2'), findsOneWidget);
    expect(buildsSinLeer, 2);
  });
}
```

¡El texto se actualiza, aunque `SinLeer` no registró ninguna dependencia! La causa es otra: el `build` de
`RaizEnLineaState` crea un `SinLeer` **nuevo** cada vez, de modo que este se reconstruye como cualquier hijo con una
descripción distinta. Parece que funciona, pero solo porque quien lo actualiza es el padre.

Esto importa cuando pruebas tu código. Si un consumidor mal escrito está debajo de un `build` que se repite, no verás el
error. En cuanto alguien haga `const` ese widget, o lo mueva, dejará de actualizarse. Por eso las pruebas de esta unidad
y de las siguientes separan bien las causas, con `const` o con `child` por parámetro.

Un consumidor bien escrito puede reconstruirse por las dos causas en el mismo frame, y Flutter solo ejecutará su `build`
una vez: marcar un elemento ya marcado no añade otra construcción.

### Practica 5

En `RaizEnLinea` escribimos `const SinLeer(etiqueta: 'En línea')`. Después de `cambiar(2)`, ¿qué texto muestra y cuánto
vale `buildsSinLeer`? ¿Cómo se arregla?

<details>
<summary>Ver respuesta</summary>

Muestra `En línea: 1` y `buildsSinLeer` queda en `1`. Ahora el hijo es el mismo objeto constante, y no hay dependencia
que lo marque. Se arregla registrando la dependencia con `dependOnInheritedWidgetOfExactType`. Quitar el `const` también
lo «arregla», pero solo oculta el problema.

</details>

## 6. `updateShouldNotify`: el proveedor decide si avisa

Cada vez que llega una descripción nueva del proveedor, Flutter se lo pregunta a `updateShouldNotify`, con la
descripción anterior como argumento. Ese método es una **política**, como la de `ValueNotifier` con `==` (unidad 7),
pero la escribes tú.

**Antes de mirar los `expect`**, predice qué pasa con cada proveedor:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class BordeComparado extends InheritedWidget {
  const BordeComparado({super.key, required this.grosor, required super.child});

  final int grosor;

  @override
  bool updateShouldNotify(BordeComparado oldWidget) {
    return grosor != oldWidget.grosor;
  }
}

class BordeMudo extends InheritedWidget {
  const BordeMudo({super.key, required this.grosor, required super.child});

  final int grosor;

  @override
  bool updateShouldNotify(BordeMudo oldWidget) => false;
}

var buildsComparado = 0;
var buildsMudo = 0;

class LectorComparado extends StatelessWidget {
  const LectorComparado({super.key});

  @override
  Widget build(BuildContext context) {
    buildsComparado++;
    final borde = context.dependOnInheritedWidgetOfExactType<BordeComparado>();
    return Text('Comparado: ${borde!.grosor}');
  }
}

class LectorMudo extends StatefulWidget {
  const LectorMudo({super.key});

  @override
  State<LectorMudo> createState() => LectorMudoState();
}

class LectorMudoState extends State<LectorMudo> {
  void refrescar() => setState(() {});

  @override
  Widget build(BuildContext context) {
    buildsMudo++;
    final borde = context.dependOnInheritedWidgetOfExactType<BordeMudo>();
    return Text('Mudo: ${borde!.grosor}');
  }
}

Widget arbol(int grosor) => Directionality(
  textDirection: TextDirection.ltr,
  child: BordeComparado(
    grosor: grosor,
    child: BordeMudo(
      grosor: grosor,
      child: const Column(children: [LectorComparado(), LectorMudo()]),
    ),
  ),
);

void main() {
  testWidgets('la política del proveedor', (tester) async {
    await tester.pumpWidget(arbol(1));
    expect((buildsComparado, buildsMudo), (1, 1));

    await tester.pumpWidget(arbol(1));
    expect((buildsComparado, buildsMudo), (1, 1));

    await tester.pumpWidget(arbol(2));
    expect((buildsComparado, buildsMudo), (2, 1));
    expect(find.text('Comparado: 2'), findsOneWidget);
    expect(find.text('Mudo: 1'), findsOneWidget);

    tester.state<LectorMudoState>(find.byType(LectorMudo)).refrescar();
    await tester.pump();
    expect((buildsComparado, buildsMudo), (2, 2));
    expect(find.text('Mudo: 2'), findsOneWidget);
  });
}
```

Paso a paso:

1. **Mismo valor en una descripción nueva.** `arbol(1)` crea otro `BordeComparado` con `grosor: 1`. Su política devuelve
   `false`, de modo que el consumidor no se reconstruye. El `Column` es constante y no hay nada más que hacer.
2. **Valor distinto.** `BordeComparado` avisa y `BordeMudo` no, aunque su campo también ha cambiado. El `LectorMudo` sí
   tiene una dependencia registrada, pero no recibe el aviso. Sigue mostrando `1`.
3. **Otra causa de construcción.** Al refrescar, `LectorMudo` lee el valor actual. **`updateShouldNotify` no impide que
   el dato cambie**: solo decide si se avisa. El elemento ya ha adoptado la descripción nueva.

La política habitual es comparar los campos que publica. Una trampa frecuente es olvidar alguno: si añades un campo y no
lo incluyes en la comparación, los cambios de ese campo no se notifican.

### Practica 6

`BordeHeredado` tiene dos campos, `grosor` y `color`, y su `updateShouldNotify` solo compara `grosor`. Un consumidor
muestra el color. ¿Qué ocurre si cambia solo `color`? ¿Y si cambian los dos a la vez?

<details>
<summary>Ver respuesta</summary>

Si cambia solo `color`, no se avisa y el consumidor sigue mostrando el color anterior. Si cambian los dos, la
comparación de `grosor` devuelve `true`, el consumidor se reconstruye y lee ambos valores nuevos. Por eso el error es
intermitente y difícil de localizar: depende de qué otra cosa cambie a la vez.

</details>

## 7. Qué relación queda establecida

Ya podemos ser precisos. ¿Quién registra qué? Este **fragmento** resume el código de `Element` en Flutter 3.47.8:

```dart
// Simplificado de la clase Element.
T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>() {
  final InheritedElement? ancestor = _inheritedElements?[T];
  if (ancestor != null) {
    _dependencies.add(ancestor); // El consumidor anota a su proveedor.
    ancestor.updateDependencies(this, null); // El proveedor anota a su consumidor.
    return ancestor.widget as T;
  }
  return null;
}
```

De aquí salen varias conclusiones:

1. **La relación es entre elementos, no entre widgets.** Los widgets se sustituyen en cada descripción; los elementos
   permanecen. El consumidor no se suscribe a un valor, ni a un objeto `BordeHeredado` concreto, sino al **sitio** del
   proveedor.
2. **La relación se registra en los dos sentidos.** El proveedor conserva sus `_dependents`, para saber a quién avisar.
   El consumidor conserva sus `_dependencies`, para darse de baja al desmontarse.
3. **`_inheritedElements` es un mapa.** Cada elemento tiene disponible un mapa que asocia cada tipo de `InheritedWidget`
   con el proveedor más cercano de ese tipo. Por eso la búsqueda no recorre todo el árbol y es rápida, y por eso busca
   por tipo exacto.
4. **Nadie ha creado un listener.** No hay `addListener` en esta relación. Es otro mecanismo que `Listenable`, aunque
   resuelve un problema parecido.

Cuando el proveedor avisa, llama a `didChangeDependencies` en cada elemento de la lista. Para un `StatelessWidget`, esto
solo lo marca para reconstruir. Para un `StatefulWidget`, además hace que se ejecute el `didChangeDependencies` de su
`State` (unidad 19).

### Una dependencia dura lo que dura el elemento

Hay una diferencia importante con `SignalBuilder`. En la unidad 10 viste que este recalcula sus dependencias en cada
construcción, y que deja de observar una señal si ya no la lee. ¿Ocurre lo mismo aquí?

Para que su `build` solo pueda deberse al aviso, el hijo es siempre el mismo objeto `const`. **Antes de mirar los
`expect`**, predice si este consumidor se reconstruye después de dejar de leer:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class BordeHeredado extends InheritedWidget {
  const BordeHeredado({super.key, required this.grosor, required super.child});

  final int grosor;

  @override
  bool updateShouldNotify(BordeHeredado oldWidget) {
    return grosor != oldWidget.grosor;
  }
}

class Condicional extends StatefulWidget {
  const Condicional({super.key});

  @override
  State<Condicional> createState() => CondicionalState();
}

class CondicionalState extends State<Condicional> {
  bool leer = true;
  int builds = 0;

  void elegir(bool valor) => setState(() => leer = valor);

  @override
  Widget build(BuildContext context) {
    builds++;
    if (!leer) {
      return const Text('Sin leer');
    }
    final borde = context.dependOnInheritedWidgetOfExactType<BordeHeredado>();
    return Text('Grosor: ${borde!.grosor}');
  }
}

Widget arbol(int grosor, Widget hijo) => Directionality(
  textDirection: TextDirection.ltr,
  child: BordeHeredado(grosor: grosor, child: hijo),
);

void main() {
  testWidgets('la dependencia permanece y se recibe el aviso', (tester) async {
    const hijo = Condicional();
    await tester.pumpWidget(arbol(1, hijo));
    final estado = tester.state<CondicionalState>(find.byType(Condicional));

    estado.elegir(false);
    await tester.pump();
    expect(estado.builds, 2);

    await tester.pumpWidget(arbol(2, hijo));
    expect(find.text('Sin leer'), findsOneWidget);
    expect(estado.builds, 3);

    await tester.pumpWidget(arbol(3, hijo));
    expect(estado.builds, 4);

    await tester.pumpWidget(arbol(3, hijo));
    expect(estado.builds, 4);
  });
}
```

Aunque el callback ya no lea el grosor, `builds` sigue subiendo cuando este cambia. **La dependencia permanece hasta que
el elemento se retira del árbol.** Se añade al leer y no se elimina al dejar de leer. La última línea demuestra que
tampoco se avisa si el valor no cambia.

No suele ser un problema: como mucho, una reconstrucción de más. Pero es una diferencia real con `SignalBuilder`, y un
ejemplo de que «reactivo» no significa lo mismo en cada mecanismo.

### Practica 7

Un widget lee `BordeHeredado` en su primer `build` y `OtroHeredado` en el segundo, por una condición. Después del
segundo `build`, ¿de cuántos proveedores depende? ¿Y un `SignalBuilder` que hace lo mismo con dos señales?

<details>
<summary>Ver respuesta</summary>

El widget depende de **los dos** proveedores, porque las dependencias heredadas se acumulan mientras el elemento siga
montado. El `SignalBuilder`, según vimos en la unidad 10, observa solo lo que leyó en la última construcción: la señal
de la otra rama deja de provocar construcciones.

</details>

## 8. `DaisyThemeScope` también es un `InheritedWidget`

El [scope real](../../../lib/themes/application/daisy_theme_scope.dart) hereda de `InheritedNotifier`, que a su vez
hereda de `InheritedWidget`. Sin el constructor, este **fragmento** ya te resulta familiar:

```dart
class DaisyThemeScope
    extends InheritedNotifier<ValueListenable<DaisyThemeModel>> {
  // ...
  static DaisyThemeModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DaisyThemeScope>();

    if (scope == null) {
      throw FlutterError('Coloca DaisyThemeScope por encima de este widget.');
    }

    return scope.notifier!.value;
  }
}
```

Las piezas coinciden con `BordeHeredado`: un método estático `of`, una búsqueda con dependencia y un error si no hay
proveedor. La diferencia es que no guarda el dato en un campo propio, sino que lo consulta en `notifier`. Como
consecuencia, cuando cambia el tema **nadie entrega una descripción nueva del scope**. Cómo se avisa entonces a los
dependientes es el tema de la unidad 22.

También puedes comparar los dos tipos de consulta con el scope real:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class ConDependencia extends StatelessWidget {
  const ConDependencia({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Con: ${context.daisyTheme.name}');
  }
}

class SinDependencia extends StatelessWidget {
  const SinDependencia({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<DaisyThemeScope>();
    return Text('Sin: ${scope!.notifier!.value.name}');
  }
}

void main() {
  testWidgets('el scope real con dependencia y sin ella', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: controller,
          child: const Column(
            children: [ConDependencia(), SinDependencia()],
          ),
        ),
      ),
    );

    controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('Con: Dark'), findsOneWidget);
    expect(find.text('Sin: Light'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

El resultado coincide con el apartado 4. Quien registra la dependencia es `dependOnInheritedWidgetOfExactType`, ya sea
directamente o, como aquí, a través de `context.daisyTheme` y `DaisyThemeScope.of`. Ni `Text` ni `StatelessWidget` hacen
nada especial.

DaisyUI no es el único que sigue este patrón. En el [ejemplo](../../../example/lib/main.dart), `_Header` llama a
`MediaQuery.sizeOf(context)`, que busca un `InheritedWidget` llamado `MediaQuery` y registra una dependencia: por eso
`_Header` se reconstruye al cambiar el tamaño de la ventana.

### Practica 8

En el árbol del ejemplo, `_Header` depende de `MediaQuery`, pero no lee el tema. `_ButtonContent` lee el tema. Si cambia
el tema, ¿cuál se reconstruye? ¿Y si cambia el tamaño de la ventana?

<details>
<summary>Ver respuesta</summary>

Si cambia el tema, se reconstruye `_ButtonContent`, junto con el `State` del botón, que también lo lee; `_Header` no
figura como dependiente del scope. Si cambia el tamaño, se reconstruye `_Header`, que depende de `MediaQuery`. También
lo haría `LayoutBuilder`, aunque por otro mecanismo, el de sus restricciones, que no estudiamos aquí. Cada proveedor
avisa solo a sus dependientes.

</details>

## Ejercicio final: el proveedor de densidad

Escribe una prueba que reúna las ideas de la unidad:

1. Declara `DensidadHeredada`, un `InheritedWidget` con dos campos, `espacio` (`int`) y `nombre` (`String`), y un
   `updateShouldNotify` que compare **solo** `espacio`.
2. Declara `Tabla` (`StatefulWidget`), que conserva esos dos valores y construye `DensidadHeredada` con su
   `widget.child`. Debe tener un método `cambiar(espacio, nombre)` con `setState`.
3. Debajo coloca, sin que nadie pase parámetros, tres consumidores constantes que cuenten sus construcciones:
   - `Lector` lee `espacio` con dependencia.
   - `Consulta` lee `espacio` sin dependencia.
   - `Etiqueta` lee `nombre` con dependencia.
4. Monta el árbol con `espacio: 1` y `nombre: 'compacto'`.
5. Cambia a `(2, 'compacto')`. Después a `(2, 'amplio')`. Después a `(3, 'amplio')`. Procesa un frame tras cada cambio.

Predice los textos y los tres contadores tras cada paso. Como variaciones: ¿qué aviso falta si un consumidor solo
necesita `nombre`? ¿Qué ocurriría si `Tabla` creara a sus hijos dentro de su `build`, sin `const`?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final builds = <String, int>{'lector': 0, 'consulta': 0, 'etiqueta': 0};

class DensidadHeredada extends InheritedWidget {
  const DensidadHeredada({
    super.key,
    required this.espacio,
    required this.nombre,
    required super.child,
  });

  final int espacio;
  final String nombre;

  @override
  bool updateShouldNotify(DensidadHeredada oldWidget) {
    return espacio != oldWidget.espacio;
  }
}

class Tabla extends StatefulWidget {
  const Tabla({super.key, required this.child});

  final Widget child;

  @override
  State<Tabla> createState() => TablaState();
}

class TablaState extends State<Tabla> {
  int espacio = 1;
  String nombre = 'compacto';

  void cambiar(int nuevoEspacio, String nuevoNombre) {
    setState(() {
      espacio = nuevoEspacio;
      nombre = nuevoNombre;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DensidadHeredada(
      espacio: espacio,
      nombre: nombre,
      child: widget.child,
    );
  }
}

class Lector extends StatelessWidget {
  const Lector({super.key});

  @override
  Widget build(BuildContext context) {
    builds['lector'] = builds['lector']! + 1;
    final densidad =
        context.dependOnInheritedWidgetOfExactType<DensidadHeredada>();
    return Text('Lector: ${densidad!.espacio}');
  }
}

class Consulta extends StatelessWidget {
  const Consulta({super.key});

  @override
  Widget build(BuildContext context) {
    builds['consulta'] = builds['consulta']! + 1;
    final densidad = context.getInheritedWidgetOfExactType<DensidadHeredada>();
    return Text('Consulta: ${densidad!.espacio}');
  }
}

class Etiqueta extends StatelessWidget {
  const Etiqueta({super.key});

  @override
  Widget build(BuildContext context) {
    builds['etiqueta'] = builds['etiqueta']! + 1;
    final densidad =
        context.dependOnInheritedWidgetOfExactType<DensidadHeredada>();
    return Text('Etiqueta: ${densidad!.nombre}');
  }
}

void main() {
  testWidgets('el proveedor de densidad', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Tabla(
          child: Column(children: [Lector(), Consulta(), Etiqueta()]),
        ),
      ),
    );
    final tabla = tester.state<TablaState>(find.byType(Tabla));
    expect(builds, {'lector': 1, 'consulta': 1, 'etiqueta': 1});

    tabla.cambiar(2, 'compacto');
    await tester.pump();
    expect(find.text('Lector: 2'), findsOneWidget);
    expect(find.text('Consulta: 1'), findsOneWidget);
    expect(builds, {'lector': 2, 'consulta': 1, 'etiqueta': 2});

    tabla.cambiar(2, 'amplio');
    await tester.pump();
    expect(find.text('Etiqueta: compacto'), findsOneWidget);
    expect(builds, {'lector': 2, 'consulta': 1, 'etiqueta': 2});

    tabla.cambiar(3, 'amplio');
    await tester.pump();
    expect(find.text('Lector: 3'), findsOneWidget);
    expect(find.text('Consulta: 1'), findsOneWidget);
    expect(find.text('Etiqueta: amplio'), findsOneWidget);
    expect(builds, {'lector': 3, 'consulta': 1, 'etiqueta': 3});
  });
}
```

Al pasar a `(2, 'compacto')`, cambia `espacio` y se avisa a los dependientes: `Lector` y también `Etiqueta`, aunque su
dato no haya cambiado. **La dependencia es con el proveedor, no con un campo.** `Consulta` no recibe aviso y sigue en
`1`.

Al pasar a `(2, 'amplio')`, la política devuelve `false`: nadie se reconstruye, y `Etiqueta` muestra un nombre obsoleto.
Es el error del apartado 6. Al pasar a `(3, 'amplio')`, vuelve a avisar y `Etiqueta` se pone al día, por una causa ajena
a su dato.

La política correcta comparará también `nombre`. Aun así, `Lector` se reconstruiría cuando cambie solo `nombre`.
Evitarlo exige dividir el proveedor en dos o usar
[`InheritedModel`](https://api.flutter.dev/flutter/widgets/InheritedModel-class.html), que no necesitamos en este plan.

Si `Tabla` creara a los hijos en su `build`, sin `const`, todos se reconstruirían en cada cambio. `Consulta` mostraría
siempre el valor actual y `Etiqueta` también. El árbol parecería correcto, y los errores que hemos encontrado quedarían
ocultos.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué problema resuelve un `InheritedWidget` frente a pasar parámetros? **Apartado 1.**
2. ¿Qué significa «heredado» aquí, y qué partes tiene un proveedor? **Apartado 2.**
3. Sigue los pasos desde `setState` en la raíz hasta el `build` del consumidor. ¿Por qué no se reconstruye el
   intermedio? **Apartado 3.**
4. ¿Qué diferencia hay entre `dependOnInheritedWidgetOfExactType` y `getInheritedWidgetOfExactType`? **Apartado 4.**
5. ¿Por qué un widget sin dependencia puede actualizarse, y por qué no debes fiarte de ello? **Apartado 5.**
6. ¿Qué hace `updateShouldNotify`, y qué no puede impedir? **Apartado 6.**
7. ¿Entre qué objetos se establece la relación, y quién apunta a quién? **Apartado 7.**
8. ¿Qué ocurre con una dependencia cuando se deja de leer? ¿Y con la de `SignalBuilder`? **Apartado 7.**
9. ¿Qué tiene en común `DaisyThemeScope` con un `InheritedWidget` propio, y qué diferencia les separa? **Apartado 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques qué relación se establece entre el
consumidor y el proveedor. La unidad 22 estudia `InheritedNotifier`: cómo avisar a los dependientes cuando el dato vive
en un notifier y nadie entrega una descripción nueva.

## Para consultar si necesitas reforzar

- [`InheritedWidget`](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html): ejemplo oficial con `of` y
  `maybeOf`.
- [`dependOnInheritedWidgetOfExactType`](https://api.flutter.dev/flutter/widgets/BuildContext/dependOnInheritedWidgetOfExactType.html)
  y
  [`getInheritedWidgetOfExactType`](https://api.flutter.dev/flutter/widgets/BuildContext/getInheritedWidgetOfExactType.html):
  cuándo usar cada una y desde qué métodos del ciclo de vida.
- [`updateShouldNotify`](https://api.flutter.dev/flutter/widgets/InheritedWidget/updateShouldNotify.html): el contrato
  de la política.
- [`MediaQuery.sizeOf`](https://api.flutter.dev/flutter/widgets/MediaQuery/sizeOf.html): otro proveedor que usa el
  ejemplo.
- [Scope](../../../lib/themes/application/daisy_theme_scope.dart) y [pruebas del
  scope](../../../test/themes/daisy_theme_scope_test.dart): comportamiento actual de DaisyUI.
