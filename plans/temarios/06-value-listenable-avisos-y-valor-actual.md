# 06. ValueListenable: avisos y valor actual

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 5](05-change-notifier-producir-avisos.md)

- **Bloque:** el sistema de notificaciones de Flutter.
- **Estado de estudio:** pendiente.
- **Investigación de fuentes:** 29 de octubre de 2026.

## Qué vas a conseguir

Podrás leer `ValueListenable<T>` como un contrato que combina escucha y consulta de un valor tipado. Seguirás un
cambio desde el productor hasta el listener, diferenciando el aviso sin argumentos de la lectura de `.value` realizada
en el cuerpo del callback. Sabrás identificar qué puede hacer un consumidor con su referencia y qué decisiones
pertenecen a la implementación concreta.

La unidad desarrolla **valor actual**, **getter**, **tipo genérico**, **lectura puntual**, **vista de lectura** y **
`ValueListenableBuilder`**. Utiliza las funciones de la unidad 2, los contratos de la 3 y las notificaciones de las
unidades 4 y 5. `ValueNotifier` se usa como productor para algunos ejemplos: sus reglas de igualdad y mutabilidad se
estudiarán con detalle en la unidad 7.

## Ruta y progreso

Antes de empezar, comprueba que distingues una referencia a una fuente de un valor obtenido al leerla, y que puedes
explicar por qué `addListener(observar)` no es `addListener(observar())`. Repasa las unidades 1, 2 y 4 si hace falta.

Los ejemplos **A–C** y la solución del proyecto son programas completos e independientes. Para ejecutarlos, abre
[DartPad](https://dartpad.dev/), selecciona un ejemplo de **Flutter**, copia un programa por vez y observa la consola.
Usan `package:flutter/foundation.dart`; la [documentación de DartPad](https://dart.dev/tools/dartpad) explica el soporte
de Flutter. Los ejemplos **D y E** son pruebas completas para ejecutar en el repositorio con `flutter test`. Los demás
bloques están identificados como fragmentos. No necesitas instalar `provider` ni copiar código al paquete de DaisyUI.

- [ ] [6.1. Del aviso a la lectura actual](#61-del-aviso-a-la-lectura-actual).
- [ ] [6.2. Leer el contrato y el tipo genérico](#62-leer-el-contrato-y-el-tipo-genérico).
- [ ] [6.3. Recibir un aviso y consultar el dato](#63-recibir-un-aviso-y-consultar-el-dato).
- [ ] [6.4. Distinguir referencia, lectura y copia](#64-distinguir-referencia-lectura-y-copia).
- [ ] [6.5. Separar contrato y productor](#65-separar-contrato-y-productor).
- [ ] [6.6. Escuchar y construir un widget](#66-escuchar-y-construir-un-widget).
- [ ] [6.7. Seguir la vista del tema de DaisyUI](#67-seguir-la-vista-del-tema-de-daisyui).
- [ ] [6.8. Responsabilidad, límites y limpieza](#68-responsabilidad-límites-y-limpieza).
- [ ] [Completar el proyecto de la unidad](#proyecto-de-la-unidad-un-marcador-observable).
- [ ] [Superar la comprobación final](#comprobación-final).

Puedes dedicar una sesión a 6.1–6.3, otra a 6.4–6.5 y una tercera a 6.6–6.8 y el proyecto. Marca cada casilla
cuando puedas justificar el recorrido y resolver las variaciones sin copiar la solución.

## 6.1. Del aviso a la lectura actual

### El problema

Un panel escucha que el tema cambió. Con `Listenable` puede registrar su callback, pero el tipo no proporciona un
getter común para consultar el tema. ¿Cómo expresar que una fuente permite **escuchar** y también **leer un valor
actual**, sin exigirle al consumidor conocer toda la implementación?

### La idea

[`ValueListenable<T>`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html) extiende el contrato de
`Listenable` y añade un getter llamado `value` de tipo `T`. Su documentación indica que, cuando cambia el valor, se
invocan los callbacks registrados. Los listeners siguen teniendo la forma `void Function()`: el aviso no entrega un
argumento con el valor. El cuerpo puede consultar `.value` cuando se ejecuta.

Imagina un indicador con una pantalla y una campanilla: puedes mirar el dato actual y apuntarte para escuchar la
campanilla. La campanilla no pronuncia el número; si quieres conocerlo, miras la pantalla. La analogía no determina
si el aviso es síncrono, cómo se compara el dato ni si se conserva un historial: hay que consultar la implementación.

Leer `.value` una vez y registrar una función para avisos posteriores son dos acciones diferentes. Leer no equivale a
suscribirse, y suscribirse no equivale a conservar una copia que se actualice sola.

### Comprobación

- ¿Qué posibilidad añade `ValueListenable` al contrato de escucha?
- ¿Recibe el callback el valor como parámetro? ¿Dónde lo obtiene si lo necesita?
- Si solo leo `.value`, ¿he registrado un listener para más adelante?

**Puedes avanzar cuando:** distingues señal de aviso y consulta del dato sin confundirlas con una reconstrucción.

## 6.2. Leer el contrato y el tipo genérico

### Las firmas

Fragmento para leer las operaciones relevantes del contrato:

```dart
T get value;
void addListener(VoidCallback listener);
void removeListener(VoidCallback listener);
```

El [getter `value`](https://api.flutter.dev/flutter/foundation/ValueListenable/value.html) devuelve el valor actual;
se lee como `fuente.value`, sin paréntesis. `T` representa un tipo que se concreta al usar el contrato:

- `ValueListenable<int>`: `.value` tiene tipo `int`.
- `ValueListenable<String>`: `.value` tiene tipo `String`.
- `ValueListenable<DaisyThemeModel>`: `.value` tiene tipo `DaisyThemeModel`.

Esto es la misma idea de tipos genéricos de la unidad 3. La [guía oficial de Dart](https://dart.dev/language/generics)
explica el parámetro de tipo y los argumentos entre `< >`. Si el tipo es `String?`, la lectura puede devolver `null`;
no significa que todas las fuentes permitan `null`.

`ValueListenable` es abstracto: declara el getter y hereda operaciones de escucha, pero no ofrece por sí mismo un
objeto listo para almacenar, cambiar y notificar. Hay implementaciones distintas, como
[`ValueNotifier<T>`](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) y
[`Animation<T>`](https://api.flutter.dev/flutter/animation/Animation-class.html).

### Lo que permite el tipo declarado

Para un parámetro `ValueListenable<int> fuente`, estos son fragmentos para leer, no un programa independiente:

```dart
final int actual = fuente.value;
fuente.addListener(observar);
fuente.removeListener(observar);
```

El contrato no declara un setter `value`, `dispose` ni `notifyListeners`. Por eso `fuente.value = 3`,
`fuente.dispose()` y `fuente.notifyListeners()` no son operaciones disponibles mediante ese tipo. Una clase concreta
puede ofrecerlas por otra referencia: el tipo de la referencia limita qué se puede solicitar sin recurrir a otras
operaciones, pero no cambia la clase real del objeto.

La ausencia de setter en el contrato tampoco hace inmutable el objeto devuelto por el getter: si `T` es una lista
mutable, las operaciones permitidas sobre esa lista son otro asunto. La unidad 8 estudiará identidad e inmutabilidad.

### Comprobación

- Si la fuente es `ValueListenable<String>`, ¿qué tipo tiene `fuente.value`?
- ¿Por qué puedes pasarla a una función que recibe `Listenable`? ¿Qué lectura deja de estar disponible a través del
  parámetro declarado solo como `Listenable`?
- ¿Demuestra un getter sin setter que nadie puede modificar el dato ni que el objeto devuelto sea inmutable?

**Puedes avanzar cuando:** lees las firmas y separas el tipo de una referencia de las capacidades del objeto real.

## 6.3. Recibir un aviso y consultar el dato

### Ejemplo A: una fuente, una vista y dos lecturas

Programa completo. Predice la salida y marca cuándo se lee el valor y cuándo se ejecuta el listener.

```dart
import 'package:flutter/foundation.dart';

void main() {
  final productor = ValueNotifier<int>(10);
  final ValueListenable<int> lectura = productor;
  final inicial = lectura.value;
  var avisos = 0;

  void observar() {
    avisos += 1;
    print('Aviso $avisos: ${lectura.value}');
  }

  print('Al inicio: $inicial');
  lectura.addListener(observar);
  productor.value = 20;
  print('Lectura guardada: $inicial');
  productor.value = 30;
  lectura.removeListener(observar);
  productor.value = 40;
  print('Actual: ${lectura.value}; avisos: $avisos');
  productor.dispose();
}
```

### Recorrido paso a paso

1. `productor` es un `ValueNotifier<int>` creado con diez. `lectura` es otra referencia al **mismo objeto**, vista
   mediante el tipo `ValueListenable<int>`. Esta asignación no construye un adaptador independiente.
2. `inicial` guarda el entero obtenido en esa lectura: diez. Todavía no hay suscripción.
3. `addListener(observar)` registra la función. Su cuerpo no se ejecuta al registrarse en este ejemplo.
4. `productor.value = 20` utiliza el setter de `ValueNotifier`. Para esta asignación concreta, el productor cambia
   el valor y notifica. `observar` se ejecuta sin argumentos y lee `lectura.value`: encuentra veinte.
5. `inicial` sigue siendo diez. Cambiar la fuente no vuelve a ejecutar la asignación que inicializó esa variable.
6. El cambio a treinta produce otro aviso. Después se retira el callback, y el cambio a cuarenta ya no lo ejecuta.
   Una lectura posterior de la misma fuente encuentra cuarenta. Finalmente el propietario libera el productor.

Para este ejemplo se usan números distintos. La comparación de igualdad y las mutaciones de listas de `ValueNotifier`
corresponden a la unidad 7; no se deducen del contrato `ValueListenable`. Tampoco se necesita crear un widget para
recibir estos avisos.

### Comprobación

- ¿Por qué `inicial` sigue siendo diez y `lectura.value` termina siendo cuarenta?
- Si retiras `observar` antes de escribir treinta, ¿qué avisos se imprimen y qué valor final se puede leer?
- Si eliminas el registro y la retirada, ¿siguen cambiando los valores del productor? ¿Qué salidas desaparecen?
- ¿Quién llama a `observar` y quién decide imprimir el valor?

**Puedes avanzar cuando:** puedes seguir por separado la referencia a la fuente, cada lectura y cada aviso.

## 6.4. Distinguir referencia, lectura y copia

### El problema

Una fuente contiene un `String`. Guardamos una lectura, cambiamos la fuente y luego leemos otra vez. ¿La variable
anterior cambia con la fuente? ¿Qué se necesita para conservar una secuencia de valores observados?

### Ejemplo B: registrar lecturas en el momento del aviso

Programa completo. Predice las cinco líneas y dibuja el contenido de `historial` después de cada cambio.

```dart
import 'package:flutter/foundation.dart';

void main() {
  final productor = ValueNotifier<String>('claro');
  final ValueListenable<String> fuente = productor;
  final primeraLectura = fuente.value;
  final historial = <String>[];

  void guardarActual() {
    historial.add(fuente.value);
  }

  print('Inicial: ${fuente.value}');
  fuente.addListener(guardarActual);
  productor.value = 'oscuro';
  productor.value = 'cupcake';
  fuente.removeListener(guardarActual);
  productor.value = 'forest';
  print('Primera lectura: $primeraLectura');
  print('Actual: ${fuente.value}');
  print('Observados: ${historial.join(', ')}');
  print('Cantidad: ${historial.length}');
  productor.dispose();
}
```

`historial` es una lista que **nuestro callback** mantiene: cada aviso lo lleva a leer el valor que haya en ese
instante y añadirlo. El contrato no crea esa lista ni entrega automáticamente el valor anterior. La primera lectura
se conserva aparte y el cambio posterior a la retirada no añade nada al historial.

Aquí los valores son cadenas. Si el valor fuera un objeto mutable, guardar la referencia no crearía una copia profunda:
ese objeto podría modificarse más tarde. No confundas conservar una lectura con clonar cualquier objeto. Si necesitas
el valor anterior o un historial fiable de objetos mutables, debes diseñar cómo copiar o representar esos datos.

El listener recibe un aviso, no un evento que contenga los valores anterior y nuevo. Si otra acción cambia de nuevo la
fuente antes de una lectura posterior, esa lectura observa el estado disponible **en ese momento**, no necesariamente
una fotografía de cada transición. El ejemplo B lee inmediatamente dentro de cada callback y sus cambios son
secuenciales; no establece una regla sobre el orden temporal de todas las implementaciones.

### Comprobación

- ¿Por qué `forest` es el valor actual pero no aparece en el historial?
- ¿Qué cambia si se añade `historial.add(fuente.value)` antes de registrar el listener?
- Si el callback dejara de leer `.value`, ¿aparecerían valores nuevos en la lista por tener tipo `ValueListenable`?
- ¿Recibir un aviso prueba que el callback recibió también el dato anterior como argumento?

**Puedes avanzar cuando:** puedes explicar quién conserva cada valor y cuándo se obtiene.

## 6.5. Separar contrato y productor

### El problema

Una función necesita imprimir el valor inicial de una fuente y registrar un callback. ¿Debe conocer si el valor viene
de `ValueNotifier` o de una clase que nosotros escribimos?

### Ejemplo C: dos implementaciones, un consumidor

Programa completo. Predice las cuatro líneas. La clase propia cumple el contrato con un getter y hereda de
`ChangeNotifier` la escucha; `sumar` define su política de cambio y aviso.

```dart
import 'package:flutter/foundation.dart';

class Puntuacion extends ChangeNotifier implements ValueListenable<int> {
  int _puntos = 0;

  @override
  int get value => _puntos;

  void sumar() {
    _puntos += 1;
    notifyListeners();
  }
}

void mostrarActual(String nombre, ValueListenable<int> fuente) {
  print('$nombre: ${fuente.value}');
}

void main() {
  final numero = ValueNotifier<int>(10);
  final puntuacion = Puntuacion();
  void observarNumero() => mostrarActual('Número', numero);
  void observarPuntos() => mostrarActual('Puntos', puntuacion);

  mostrarActual('Número inicial', numero);
  mostrarActual('Puntos iniciales', puntuacion);
  numero.addListener(observarNumero);
  puntuacion.addListener(observarPuntos);
  numero.value = 11;
  puntuacion.sumar();
  numero.removeListener(observarNumero);
  puntuacion.removeListener(observarPuntos);
  numero.dispose();
  puntuacion.dispose();
}
```

`mostrarActual` solo necesita un `ValueListenable<int>`. Puede consultar el getter de ambas fuentes sin conocer sus
métodos para cambiarlas. Para producir los cambios, `main` conserva las referencias concretas: usa el setter de
`ValueNotifier` y el método `sumar` de `Puntuacion`.

Ambas cumplen la interfaz, pero su implementación y su política son distintas. En `Puntuacion` escribimos
explícitamente el incremento y `notifyListeners`; `ValueNotifier` tiene su propio setter. No existe una regla general
que exija a todo `ValueListenable` usar `ChangeNotifier`, almacenar el valor en un campo propio, exponer un setter,
comparar con `==` o tener una operación `dispose` en su interfaz.

Las dos fuentes del ejemplo se notifican antes de que regresen sus operaciones concretas porque se apoyan en
`ChangeNotifier`. El contrato de `ValueListenable` no establece por sí solo esa misma temporización para todas las
implementaciones. Para detalles de `ValueNotifier`, consulta
su [API oficial](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html).

### Comprobación

- ¿Puede `mostrarActual` llamar a `sumar()` o escribir `fuente.value = 4`? ¿Por qué?
- Si `Puntuacion.sumar` omite `notifyListeners()`, ¿qué valor muestra una lectura directa posterior? ¿Qué pasa con el
  listener? ¿Cumpliría entonces la expectativa documentada de avisar cuando cambia el valor?
- ¿De dónde obtiene cada implementación su mecanismo de escucha en este ejemplo?

**Puedes avanzar cuando:** puedes cambiar el productor manteniendo el consumidor, sin atribuir a la interfaz detalles
que solo pertenecen a una clase concreta.

## 6.6. Escuchar y construir un widget

### Del callback al builder

[`ValueListenableBuilder<T>`](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html) es un widget
que recibe una fuente `ValueListenable<T>`, escucha sus avisos y entrega un valor de tipo `T` a su callback `builder`.
El `builder` no es el listener `void Function()`: es otra función con parámetros para construir un widget.

En su estado, el builder obtiene el valor inicial de la fuente y se registra como listener. Cuando recibe un aviso,
lee el valor y solicita actualizar su estado; Flutter puede ejecutar la construcción en un frame posterior. Al
actualizarse, si la fuente anterior y la nueva resultan distintas con `!=`, deja de escuchar la anterior y se registra
en la nueva; al retirarse del árbol elimina su listener. El propietario sigue siendo responsable de liberar la fuente
cuando corresponda. Esa secuencia se puede contrastar en el código enlazado por la documentación del widget.

Fragmento para leer: presupone un `ValueListenable<int> fuente` vivo y un contexto de construcción.

```dart
ValueListenableBuilder<int>(
  valueListenable: fuente,
  builder: (context, cantidad, child) {
    return Text('Cantidad: $cantidad');
  },
)
```

`cantidad` es el valor que el widget entrega al builder en esa construcción. Puedes pasar un subárbol independiente
como `child` si tiene sentido; la API explica esa optimización. Una construcción no es lo mismo que un repintado y
no se debe deducir un número universal de construcciones por contar avisos. Un widget también puede construirse por
otras causas.

### Ejemplo D: comprobar lectura inicial y actualización en un widget

Prueba completa para el repositorio. Crea temporalmente `test/value_listenable_practica_test.dart` con este código y
ejecuta `flutter test --no-pub test/value_listenable_practica_test.dart` desde la raíz. Predice el texto antes y después
del `pump` y el número de avisos antes de ejecutarla.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('El builder muestra el valor inicial y el actualizado', (tester) async {
    final productor = ValueNotifier<int>(1);
    var avisos = 0;
    void contarAviso() => avisos += 1;
    productor.addListener(contarAviso);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ValueListenableBuilder<int>(
          valueListenable: productor,
          builder: (context, cantidad, child) => Text('Cantidad: $cantidad'),
        ),
      ),
    );
    expect(find.text('Cantidad: 1'), findsOneWidget);
    expect(avisos, 0);

    productor.value = 2;
    productor.value = 3;
    expect(avisos, 2);
    expect(find.text('Cantidad: 1'), findsOneWidget);
    await tester.pump();
    expect(find.text('Cantidad: 3'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    productor.removeListener(contarAviso);
    productor.dispose();
  });
}
```

En esta prueba los dos cambios concretos notifican antes del `pump`. La inspección del árbol todavía encuentra el texto
anterior hasta procesar el frame; después encuentra el valor más reciente. Esto verifica el árbol en una prueba de
widgets, no la pintura física ni una garantía general de una construcción por aviso. Se desmonta el consumidor antes
de liberar la fuente. El ejemplo oficial completo se puede crear con
`flutter create --sample=widgets.ValueListenableBuilder.1 mysample`.

### Comprobación

- ¿Quién registra el listener del widget y quién entrega `cantidad` al builder?
- ¿Por qué el callback de `addListener` y el parámetro `cantidad` del builder tienen firmas distintas?
- ¿Qué comprueba D antes y después del frame? ¿Prueba que se repintó una pantalla física?

**Puedes avanzar cuando:** localizas la lectura inicial, el puente al estado del widget y su limpieza.

## 6.7. Seguir la vista del tema de DaisyUI

### El recorrido real

Lee [daisy_theme_controller.dart](../../lib/themes/application/daisy_theme_controller.dart):

1. El controlador crea y posee `_palette`, una `FlutterSignal<DaisyThemeModel>`, con el tema inicial.
2. `theme` expone un `ValueListenable<DaisyThemeModel>` mediante `_ThemeListenable`. Este adaptador es un objeto
   distinto de `_palette` y conserva una referencia a la fuente.
3. `_ThemeListenable.value` devuelve `_source.value`; `addListener` y `removeListener` reenvían el mismo callback a
   `_source`. El adaptador no almacena otro tema ni implementa un setter para `value`.
4. `setTheme(theme)` escribe en `_palette.value`. La señal es la fuente concreta que determina cómo se emiten avisos.
5. El propietario llama a `controller.dispose()` cuando deja de usar el controlador; esa operación libera la señal.

La vista limita las operaciones expuestas por su tipo y, en esta implementación, el adaptador tampoco tiene setter ni
`dispose`. Esto es más fuerte que solo asignar un `ValueNotifier` a una variable de tipo `ValueListenable`, como en A:
en A el objeto real sigue siendo el mismo `ValueNotifier`. No confundas esa restricción de API con hacer inmutable por
sí solo cualquier objeto que pueda devolver el getter.

En [daisy_theme_scope.dart](../../lib/themes/application/daisy_theme_scope.dart), el `notifier` del
`InheritedNotifier` es la vista del controlador recibido o la del servicio por defecto. `DaisyThemeScope.of(context)`
registra una dependencia del scope y lee `scope.notifier!.value`. El scope toma prestado un controlador explícito;
no es su propietario. La unidad de scopes desarrollará ese puente y su ciclo de vida.

### Ejemplo E: escuchar y leer la vista real

Prueba completa. Crea temporalmente `test/value_listenable_tema_practica_test.dart` y ejecuta:

```sh
flutter test --no-pub test/value_listenable_tema_practica_test.dart
```

Predice los valores almacenados y el último valor leído. El cambio usa temas diferentes al inicial para centrarnos en
el contrato de lectura y escucha.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('La vista permite leer el tema actual al recibir avisos', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    final ValueListenable<DaisyThemeModel> fuente = controller.theme;
    final inicial = fuente.value;
    final observados = <DaisyThemeModel>[];
    void observar() => observados.add(fuente.value);

    expect(inicial, DaisyThemes.light);
    fuente.addListener(observar);
    controller.setTheme(DaisyThemes.dark);
    controller.setTheme(DaisyThemes.cupcake);
    fuente.removeListener(observar);
    controller.setTheme(DaisyThemes.light);

    expect(observados, [DaisyThemes.dark, DaisyThemes.cupcake]);
    expect(inicial, DaisyThemes.light);
    expect(fuente.value, DaisyThemes.light);
  });
}
```

La prueba comprueba estos cambios y lecturas concretas; no prueba una pantalla ni establece una política universal de
igualdad o de temporización para todas las señales. La prueba existente
[del controlador](../../test/themes/daisy_theme_controller_test.dart) también comprueba el aislamiento de controladores,
la retirada de listeners y que las vistas públicas no exponen operaciones de mutación o liberación.

### Comprobación

- ¿Qué objeto escribe el controlador, qué objeto recibe `addListener` y hacia dónde reenvía ese registro?
- ¿Por qué `inicial` no es una lectura que se actualiza después?
- ¿Qué se pierde al guardar `controller.theme` en una referencia declarada solo como `Listenable`?

**Puedes avanzar cuando:** describes la cadena sin decir que el adaptador es la señal o que `setTheme` modifica un
`ChangeNotifier`.

## 6.8. Responsabilidad, límites y limpieza

- Una lectura obtiene el valor en ese momento; no registra un callback ni exige un frame.
- El listener sin argumentos se registra sobre una fuente concreta y se retira de esa misma fuente con el callback
  correspondiente. Si el consumidor cambia de fuente, debe resolver la suscripción anterior y la nueva.
- Una fuente `ValueListenable<T>` promete el getter y la escucha; no ofrece por su tipo un `dispose` ni confiere la
  propiedad del recurso. Quien crea o posee la implementación concreta debe decidir cuándo liberarla.
- El contrato relaciona cambios de valor y avisos, pero no especifica todas las políticas de igualdad, duplicados,
  entrega o almacenamiento. Busca esas reglas en la implementación antes de predecir casos límite.
- Una vista de lectura limita la API disponible; no convierte necesariamente en inmutable el objeto `T` devuelto ni
  impide que otro propietario autorizado cambie la fuente.
- No presupongas que una lectura ordinaria de `.value` registra una dependencia en un widget. Necesitas un mecanismo
  de observación, como el builder anterior o el scope concreto de DaisyUI.

### Comprobación

- ¿Quién retira el listener y quién dispone la fuente en el ejemplo D?
- ¿Puede un consumidor de lectura observar un dato que otro objeto cambió? ¿Contradice eso el getter sin setter?
- ¿Qué información adicional necesitas antes de predecir avisos de una fuente desconocida?

**Puedes avanzar cuando:** puedes explicar el ciclo completo sin adjudicar al tipo capacidades que no promete.

## Materiales de estudio seleccionados

Todos los materiales son gratuitos y se consultaron durante la preparación. Las referencias oficiales están en inglés;
la guía y las prácticas están en español. Lee la sección indicada y después contrasta una predicción propia.

- **F1 · Flutter: [ValueListenable](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html) y
  [value](https://api.flutter.dev/flutter/foundation/ValueListenable/value.html)** — 6.1–6.3. Localiza el getter,
  las operaciones heredadas y la relación documentada entre cambio y callbacks.
- **F2 · Flutter: [Listenable](https://api.flutter.dev/flutter/foundation/Listenable-class.html)** — 6.1–6.2.
  Compara sus operaciones con el getter añadido por `ValueListenable`.
- **D1 · Dart: [Genéricos](https://dart.dev/language/generics) y
  [getters y setters](https://dart.dev/language/methods#getters-and-setters)** — 6.2. Sustituye `T` por `int`,
  `String` y `DaisyThemeModel`, y diferencia leer una propiedad de escribirla.
- **F3 · Flutter: [ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html)** — 6.3 y 6.5.
  Reconoce una implementación concreta del contrato. Deja el análisis detallado de `==` y colecciones para la unidad 7.
- **F4 ·
  Flutter: [ValueListenableBuilder](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html)** —
  6.6. Identifica la fuente, el callback de construcción, el valor entregado y el ejemplo completo disponible.
- **F5 · Flutter: [Introducción a pruebas de widgets](https://docs.flutter.dev/cookbook/testing/widget/introduction)** —
  ejemplo D. Identifica `pumpWidget`, `pump`, un finder y una expectativa.
- **P1 · [DartPad](https://dartpad.dev/) y su [documentación](https://dart.dev/tools/dartpad)** — A–C y proyecto en
  modo Flutter; para D y E utiliza el proyecto local. DartPad no incluye automáticamente el paquete local `daisy_ui`.
- **P2 · Código del proyecto:** [controlador](../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../lib/themes/application/daisy_theme_scope.dart) y
  [pruebas](../../test/themes/daisy_theme_controller_test.dart) — 6.7.

## Proyecto de la unidad: un marcador observable

Construye un marcador de puntos con un productor y dos consumidores. La clase productora extiende `ChangeNotifier` e
implementa `ValueListenable<int>`. Sus consumidores necesitan leer y escuchar, pero el código que cambia los puntos
conserva la referencia concreta.

### Requisitos

1. Comienza con cero y proporciona el getter `value`. Escribe `sumar()` para aumentar un punto y luego notificar.
2. Crea una función `mostrar(String nombre, ValueListenable<int> fuente)` que imprima el nombre y el valor actual.
3. Conserva una lectura inicial y registra dos callbacks: `panel` y `registro`. Cada uno llama a `mostrar`.
4. Suma dos veces, retira `panel`, suma una vez más y retira `registro`.
5. Lee el valor actual y la lectura inicial. Libera el productor desde su propietario.
6. Antes de ejecutar, escribe la salida y cuenta por separado incrementos, avisos a cada consumidor y lecturas.

### Variaciones

- Usa un `ValueNotifier<int>` como productor alternativo para `mostrar`. ¿Debe cambiar la firma del consumidor?
- Retira `registro` antes del segundo incremento. ¿Qué líneas desaparecen?
- Guarda también los valores observados en una lista. ¿Qué hace falta añadir al callback para construir el historial?
- Haz una lectura sin registrar callbacks. ¿Obtienes el dato actual? ¿Se crea alguna observación futura?
- Como reto, crea un adaptador separado que implemente `ValueListenable<int>` y reenvíe getter y listeners al productor.
  Compara esa vista con una segunda referencia al mismo objeto; especifica quién conserva y libera el productor.

La solución está al final. No la copies antes de identificar dónde se almacena el dato, qué línea avisa y qué línea
lee el valor.

## Errores de comprensión que vamos a comprobar

- Confundir el callback sin argumentos de `addListener` con un callback que recibe el valor nuevo.
- Pensar que leer `.value` registra por sí solo una suscripción o reconstruye un widget.
- Creer que una lectura guardada se vuelve a asignar cuando cambia la fuente.
- Tratar `ValueListenable` como si fuera necesariamente `ValueNotifier` o `ChangeNotifier`.
- Deducir que el getter garantiza un setter, un `dispose`, un historial o una política de igualdad específica.
- Confundir una referencia con tipo de lectura al mismo objeto con un adaptador separado de solo lectura.
- Suponer que un getter sin setter convierte en inmutable el objeto devuelto.
- Confundir el listener del builder con su callback de construcción, o una notificación con un repintado.
- Liberar una fuente prestada desde un consumidor que no es su propietario.

## Comprobación final

Responde sin mirar las soluciones y justifica cada respuesta con el código o una fuente:

1. ¿Qué añade `ValueListenable<T>` a `Listenable`? ¿Qué significa `T`?
2. ¿Qué firma tiene el listener y de dónde obtiene el valor cuando lo necesita?
3. En A, ¿por qué `inicial` vale diez al final mientras la fuente devuelve cuarenta?
4. En B, ¿quién crea el historial y por qué no contiene `forest`?
5. ¿Puede una referencia `ValueListenable<int>` escribir `.value` o llamar a `dispose` por su tipo declarado?
6. En C, ¿qué comparten las dos fuentes y qué operaciones concretas cambian sus datos?
7. ¿Qué ocurre si cambia el valor pero la implementación olvida emitir el aviso? ¿Cumple la expectativa documentada?
8. ¿Qué hace `ValueListenableBuilder` entre un aviso y una construcción? ¿Qué verifica la prueba D?
9. En DaisyUI, ¿qué son `_palette`, `_ThemeListenable` y `controller.theme`? ¿Quién libera la señal?
10. ¿Qué diferencia existe entre una referencia de lectura a un objeto mutable y un adaptador separado?
11. Si el valor es una lista mutable, ¿el getter sin setter garantiza que esa lista no pueda cambiar?
12. Explica el proyecto completo: estado, registro, cambio, aviso, lectura y limpieza.

**Unidad dominada cuando:** puedes explicar el proyecto, resolver las variaciones y distinguir el contrato de las
implementaciones sin copiar la solución. Elaborar la guía no marca la unidad como dominada.

## Soluciones para contrastar después de practicar

### Ejemplo A

```text
Al inicio: 10
Aviso 1: 20
Lectura guardada: 10
Aviso 2: 30
Actual: 40; avisos: 2
```

Si se retira el listener antes de escribir treinta, solo aparece el primer aviso; la lectura final sigue siendo
cuarenta y el contador de avisos es uno. Sin registro ni retirada, desaparecen las dos líneas de aviso; los cambios
siguen ocurriendo y el contador queda en cero.

### Ejemplo B

```text
Inicial: claro
Primera lectura: claro
Actual: forest
Observados: oscuro, cupcake
Cantidad: 2
```

Si guardas el valor antes de registrar, el historial comienza con `claro`. `forest` se escribe después de retirar el
callback, por lo que no se añade automáticamente.

### Ejemplo C

```text
Número inicial: 10
Puntos iniciales: 0
Número: 11
Puntos: 1
```

Si `sumar` omite el aviso, la lectura directa posterior devuelve uno, pero el listener no se ejecuta. Una
implementación que deja de avisar al cambiar su valor incumple la expectativa documentada del contrato.

### Ejemplo D y E

En D se muestra inicialmente `Cantidad: 1` sin avisos. Las dos asignaciones producen dos avisos en ese ejemplo;
antes del frame el árbol aún contiene el texto anterior y, después de `pump`, contiene `Cantidad: 3`. En E las lecturas
observadas son `dark` y `cupcake`, la lectura inicial permanece en `light` y el valor final consultado es `light`.

### Una solución del proyecto

```dart
import 'package:flutter/foundation.dart';

class Marcador extends ChangeNotifier implements ValueListenable<int> {
  int _puntos = 0;

  @override
  int get value => _puntos;

  void sumar() {
    _puntos += 1;
    notifyListeners();
  }
}

void mostrar(String nombre, ValueListenable<int> fuente) {
  print('$nombre: ${fuente.value}');
}

void main() {
  final marcador = Marcador();
  final ValueListenable<int> fuente = marcador;
  final inicial = fuente.value;
  void panel() => mostrar('Panel', fuente);
  void registro() => mostrar('Registro', fuente);

  fuente.addListener(panel);
  fuente.addListener(registro);
  marcador.sumar();
  marcador.sumar();
  fuente.removeListener(panel);
  marcador.sumar();
  fuente.removeListener(registro);
  print('Inicial: $inicial; actual: ${fuente.value}');
  marcador.dispose();
}
```

La salida es:

```text
Panel: 1
Registro: 1
Panel: 2
Registro: 2
Registro: 3
Inicial: 0; actual: 3
```

Hay tres incrementos y tres emisiones. El panel recibe dos avisos y el registro tres. Hay siete lecturas explícitas
por el código mostrado: la inicial, cinco realizadas por `mostrar` y la final. La función `mostrar` acepta también un
`ValueNotifier<int>`, porque exige el contrato y no la clase concreta.

### Claves de la comprobación final

1. Añade un getter de valor actual; `T` determina su tipo.
2. Es `void Function()`; su cuerpo puede leer `.value` desde la fuente.
3. `inicial` guarda una lectura; `fuente.value` realiza otra consulta posterior.
4. Lo mantiene el callback; `forest` llega después de retirarlo.
5. No mediante ese tipo. Una implementación concreta puede ofrecer operaciones adicionales.
6. Ambas implementan `ValueListenable<int>`; se cambian por el setter del `ValueNotifier` y por `sumar`.
7. La lectura directa puede reflejar el cambio, pero el listener no se ejecuta; se incumple la expectativa del contrato.
8. Escucha, lee y solicita una actualización; D comprueba texto y avisos en un árbol de prueba, no pintura física.
9. `_palette` es la señal poseída; `_ThemeListenable` es el adaptador que reenvía; `theme` expone esa vista. El
   propietario dispone el controlador, que libera la señal.
10. En el primer caso el objeto real sigue siendo el mismo; en el segundo existe otro objeto que delega operaciones.
11. No. El getter limita la asignación mediante esa interfaz, no garantiza inmutabilidad del objeto devuelto.
12. El productor guarda y modifica; `notifyListeners` llama los callbacks, que leen; cada consumidor se retira y el
    propietario libera el productor.

## Qué se ha revisado y cómo se ha comprobado

- Se contrastaron el contrato, sus implementaciones y los materiales enlazados con la documentación oficial. Se
  leyeron el controlador y el scope actuales, además de la implementación local de `ValueListenableBuilder`.
- El servidor del grafo rechazó indexar esta raíz durante la unidad anterior por su configuración de acceso; las
  afirmaciones sobre el controlador y el scope se contrastaron mediante lectura directa de esos archivos.
- Se extrajeron A–C y la solución del proyecto y se comprobaron sus cuatro salidas. También pasaron los ejemplos D y E,
  dos pruebas adicionales de cambio de fuente y objeto mutable, y las tres pruebas existentes del controlador:
  **11 pruebas en total**. El analizador no encontró errores en los ejemplos completos; informó de avisos de estilo
  por `print` en las prácticas de consola.
- Se confirmó con el analizador que el tipo `ValueListenable<int>` rechaza el setter, `dispose` y `notifyListeners`.
  Se comprobaron enlaces locales, anclas, bloques de código y espacios, además de `git diff --check`.
- La prueba de widgets comprueba el árbol y los frames de prueba, no una pantalla física ni sus repintados. No se
  ejecutaron los ejemplos en DartPad. El progreso de estudio se marca al resolver y explicar las prácticas.
