# 03. Objetos, referencias, tipos y contratos

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 2](02-funciones-como-valores-callbacks-y-listeners.md)

- **Bloque:** las bases para comprender la observación.
- **Estado de estudio:** pendiente.
- **Investigación de fuentes:** 19 de octubre de 2026.

## Qué vas a conseguir

Podrás distinguir una clase de sus objetos, seguir referencias compartidas y explicar qué operaciones permite el tipo
de una variable. Después leerás `ValueListenable<DaisyThemeModel>` separando el contrato, su implementación y el tipo
del valor que ofrece.

Esta unidad desarrolla **clase**, **instancia**, **referencia**, **campo**, **método**, **tipo declarado**, **objeto
real**, **genéricos `<T>`**, **interfaz**, **`implements`**, **`extends`** y **`@override`**.
Introducimos también constructor, `this`, getter, `super` y privacidad para poder leer los ejemplos sin saltos.

Las preguntas que acompañan cada paso son: **¿a qué objeto accedemos?, ¿qué permite su tipo?, ¿qué código se ejecuta?**

## Ruta y progreso

Antes de empezar, comprueba que distingues guardar un valor de volver a consultar su fuente y entregar una función de
llamarla. Usaremos las funciones, parámetros, retornos y flechas de la unidad 2.

Seguimos la estructura de las unidades anteriores: problema, explicación, predicción, recurso y comprobación.
Los ejemplos A–F son programas independientes para un pad de **Dart** de [DartPad](https://dartpad.dev/).
Copia un programa cada vez; algunas clases se repiten entre ejemplos. Los fragmentos de DaisyUI se leen en el
repositorio.

- [ ] [3.1. Separar clase, instancia y miembros](#31-separar-clase-instancia-y-miembros).
- [ ] [3.2. Seguir referencias compartidas](#32-seguir-referencias-compartidas).
- [ ] [3.3. Distinguir un campo de un getter](#33-distinguir-un-campo-de-un-getter).
- [ ] [3.4. Definir un contrato y aportar implementaciones](#34-definir-un-contrato-y-aportar-implementaciones).
- [ ] [3.5. Comprender extends y override](#35-comprender-extends-y-override).
- [ ] [3.6. Sustituir T por un tipo concreto](#36-sustituir-t-por-un-tipo-concreto).
- [ ] [3.7. Leer estas piezas en DaisyUI](#37-leer-estas-piezas-en-daisyui).
- [ ] [Completar el proyecto de la unidad](#proyecto-de-la-unidad-dos-fuentes-con-el-mismo-contrato).
- [ ] [Superar la comprobación final](#comprobación-final).

Puedes repartirlo en varias sesiones: primero 3.1–3.3; después 3.4–3.5; finalmente 3.6–3.7 y el proyecto.
Para empezar basta con trabajar el ejemplo A. Marca las casillas cuando puedas explicar y resolver las comprobaciones.

## 3.1. Separar clase, instancia y miembros

### El problema

La aplicación y una vista previa necesitan conservar selecciones de tema independientes. Ambas tienen un nombre y
permiten cambiarlo. ¿Cómo describimos esa estructura una vez y creamos dos selecciones?

### La idea

Una **clase** declara una estructura y unas operaciones. Una **instancia** es un objeto concreto de esa clase.
En estos ejemplos, un **campo de instancia** conserva un dato de cada objeto y un **método de instancia** describe una
operación que se ejecuta sobre él. Campos y métodos son miembros de la clase.
Consulta [Classes](https://dart.dev/language/classes).

Puedes pensar en el diseño de una ficha y en dos fichas rellenadas siguiendo ese diseño. Una clase permite describir
ambas fichas; cada ficha conserva sus propios datos. La analogía ayuda a distinguir estructura e instancia, pero no
representa los detalles de memoria ni todos los mecanismos de Dart.

### Ejemplo A: una clase, dos objetos

Programa completo. Predice las dos líneas que imprime antes de ejecutarlo.

```dart
class SeleccionTema {
  SeleccionTema(this.nombre);

  String nombre;

  void cambiar(String nuevoNombre) {
    nombre = nuevoNombre;
  }
}

void main() {
  final app = SeleccionTema('claro');
  final preview = SeleccionTema('oscuro');

  app.cambiar('cupcake');

  print(app.nombre);
  print(preview.nombre);
}
```

Descompón su sintaxis:

- `class SeleccionTema` declara la clase; todavía no crea las dos selecciones de `main`.
- `String nombre;` declara un campo de instancia que contiene una referencia a un texto.
- `SeleccionTema(this.nombre);` declara el **constructor** que utilizaremos para crear cada objeto.
  `this` se refiere a la instancia que se está inicializando; `this.nombre` es aquí un parámetro que inicializa su
  campo.
- `SeleccionTema('claro')` llama al constructor con un argumento. Este constructor crea una instancia y fija su nombre.
- `app.cambiar('cupcake')` llama al método sobre el objeto al que accede `app`.
- `app.nombre` lee el campo de ese objeto mediante la sintaxis de propiedad.

El constructor no declara un tipo de retorno como una función ordinaria. La forma `this.nombre` evita escribir por
separado un parámetro y la inicialización del campo. La referencia es
[Initializing formal parameters](https://dart.dev/language/constructors#use-initializing-formal-parameters).

Aquí hay dos llamadas a un constructor generativo y dos objetos distintos. Más adelante encontraremos constructores
`factory` y objetos `const`; no aplicaremos a todos los constructores la regla de que cada llamada crea un objeto nuevo.

### Comprobación

- Añade `preview.cambiar('forest')` antes de las impresiones. Predice qué dato modifica.
- Señala la declaración de clase, cada construcción, el campo, el método, su parámetro y el argumento recibido.
- Explica qué objeto proporciona el `nombre` que utiliza el cuerpo de `cambiar` en cada llamada.

**Puedes avanzar cuando:** distingues la clase compartida de los datos de cada instancia y sigues sobre qué objeto se
ejecuta el método.

## 3.2. Seguir referencias compartidas

### El problema

Escribes `final compartida = app;`. Después cambias el nombre a través de `app`. ¿Has creado otra selección o tienes
dos formas de acceder a la misma?

### La idea

Las variables Dart conservan **referencias** a objetos. Asignar una variable a otra conserva la referencia obtenida;
no clona el objeto. Consulta [Variables](https://dart.dev/language/variables).

Separa dos operaciones:

1. Modificar el objeto al que accedes: otras referencias al mismo objeto permiten consultar sus datos modificados.
2. Reasignar una variable para que acceda a otro objeto: las demás variables conservan sus propias referencias.

### Ejemplo B: compartir un objeto y después cambiar una referencia

Programa completo. Dibuja las referencias después de cada asignación y predice las cuatro líneas.

```dart
class SeleccionTema {
  SeleccionTema(this.nombre);

  String nombre;

  void cambiar(String nuevoNombre) {
    nombre = nuevoNombre;
  }
}

void main() {
  var app = SeleccionTema('claro');
  final compartida = app;
  final nombreGuardado = app.nombre;

  app.cambiar('oscuro');
  print(compartida.nombre);
  print(nombreGuardado);

  app = SeleccionTema('cupcake');
  print(app.nombre);
  print(compartida.nombre);
}
```

Sigue el recorrido:

1. La primera construcción crea una selección A. `app` permite acceder a ella.
2. `compartida = app` conserva una referencia a A. No aparece otra selección.
3. `nombreGuardado` recibe el texto leído entonces, `'claro'`; no conserva una instrucción para releer `nombre`.
4. `app.cambiar('oscuro')` modifica el campo de A. Leerlo a través de `compartida` obtiene `'oscuro'`.
5. La segunda construcción crea una selección B. La asignación cambia la referencia de `app`.
6. `compartida` sigue accediendo a A, cuyo nombre continúa siendo `'oscuro'`.

`final compartida` impide volver a asignar esa variable. El campo `nombre` del objeto sigue siendo mutable.
La diferencia entre referencia fija, identidad, igualdad e inmutabilidad se desarrollará en la unidad 8.

El tipo de `app` se infiere como `SeleccionTema` a partir de su inicialización. `var` permite reasignar la variable
con valores compatibles con ese tipo; no significa que pueda recibir después cualquier clase de dato.

### Comprobación

- Sustituye `final compartida = app;` por `final compartida = SeleccionTema(app.nombre);`. ¿Qué construcción añades?
- Añade `compartida.cambiar('forest')` al final de B y vuelve a imprimir ambos nombres. ¿Qué selección cambia?
- Intenta asignar `compartida = SeleccionTema('light');`. Explica qué impide `final`.
- Relaciona `nombreGuardado` con las lecturas puntuales de la unidad 1.

**Puedes avanzar cuando:** sigues por separado las variables y los objetos y justificas por qué modificar un campo y
reasignar una variable tienen efectos diferentes.

## 3.3. Distinguir un campo de un getter

### El problema

Quieres permitir consultar el número de un contador, pero cambiarlo mediante una operación concreta.
¿Leer `contador.valor` exige que haya un campo público llamado `valor`?

### La idea

Un **getter** es un miembro que se consulta con sintaxis de propiedad y ejecuta código para obtener un resultado.
`int get valor => _valor;` ofrece una lectura llamada `valor` cuyo resultado es un entero.
Se escribe `contador.valor`, sin los paréntesis de `contador.incrementar()`.
Consulta [Getters and setters](https://dart.dev/language/methods#getters-and-setters).

La lectura puede devolver un dato almacenado, calcularlo o pedirlo a otro objeto. La presencia de un getter no promete
que exista un campo con ese nombre ni que el resultado se mantenga igual entre lecturas.

### Ejemplo C: leer y modificar por caminos distintos

Programa completo. Predice las dos líneas.

```dart
class Contador {
  Contador(this._valor);

  int _valor;

  int get valor => _valor;

  void incrementar() {
    _valor += 1;
  }
}

void main() {
  final contador = Contador(2);
  print(contador.valor);

  contador.incrementar();
  print(contador.valor);
}
```

`_valor` es el campo que conserva el entero. `valor` es el getter que lo consulta. `incrementar` modifica ese campo;
`_valor += 1` equivale aquí a `_valor = _valor + 1`.

El guion bajo hace privado el identificador a su **biblioteca Dart**. Un archivo y sus archivos `part` forman una
biblioteca; en este ejemplo todo el programa está en la misma. No significa «accesible solamente desde esta clase».
Consulta [Libraries & imports](https://dart.dev/language/libraries).

No declaramos un setter para `valor`, así que `contador.valor = 9` no está permitido. El getter sigue pudiendo devolver
otro número tras llamar a `incrementar()`. Que una propiedad sea de solo lectura no hace inmutable el objeto.

### Comprobación

- Cambia el cuerpo del getter a `=> _valor * 2`. Predice qué imprime C y qué número conserva el campo después de
  incrementar.
- Explica la diferencia entre `_valor`, `valor` e `incrementar`.
- Intenta `contador.valor = 9` y explica qué operación falta.
- ¿Algún paso de C ha registrado un listener o solicitado reconstruir una pantalla?

**Puedes avanzar cuando:** distingues el almacenamiento de la operación de consulta y explicas por qué un getter puede
mostrar un resultado distinto en una lectura posterior.

## 3.4. Definir un contrato y aportar implementaciones

### El problema

Una función necesita leer un número. Puede venir de una fuente fija o de un contador. ¿Debe conocer las dos clases y
sus detalles internos para poder imprimirlo?

### La idea y la sintaxis

Una **interfaz** describe operaciones que un consumidor puede utilizar. Aquí «interfaz» se refiere al contrato de
programación, no a una pantalla. Una **implementación** aporta el código que cumple ese contrato.

En `abstract interface class LecturaNumero`:

- `abstract` impide construir directamente esa clase y permite declarar miembros sin cuerpo.
- `interface` permite que otras bibliotecas la implementen, pero impide que la extiendan.
- `int get valor;` promete una lectura de un entero. El punto y coma cierra una declaración sin implementación.

Consulta [abstract interface](https://dart.dev/language/class-modifiers#abstract-interface).

`implements LecturaNumero` declara la relación con el contrato. Una clase concreta debe satisfacer sus miembros;
`implements` no hereda los cuerpos de la clase implementada. Dart también define una interfaz implícita para cada
clase, aunque no lleve el modificador
`interface`: [Implicit interfaces](https://dart.dev/language/classes#implicit-interfaces).

### Ejemplo D: un consumidor y dos implementaciones

Programa completo. Predice la salida y señala qué getter se utiliza en cada llamada a `mostrar`.

```dart
abstract interface class LecturaNumero {
  int get valor;
}

class NumeroFijo implements LecturaNumero {
  NumeroFijo(this._valor);

  final int _valor;

  @override
  int get valor => _valor;
}

class Contador implements LecturaNumero {
  Contador(this._valor);

  int _valor;

  @override
  int get valor => _valor;

  void incrementar() {
    _valor += 1;
  }
}

void mostrar(LecturaNumero fuente) {
  print(fuente.valor);
  // fuente.incrementar(); // No forma parte de este contrato.
  // fuente.valor = 9; // El contrato no ofrece un setter.
}

void main() {
  final fijo = NumeroFijo(7);
  final contador = Contador(2);

  mostrar(fijo);
  mostrar(contador);
  contador.incrementar();
  mostrar(contador);
}
```

Dentro de `mostrar`, el **tipo declarado** del parámetro es `LecturaNumero`. Ese tipo permite consultar `valor`.
El **objeto real** recibido puede ser un `NumeroFijo` o un `Contador`, y la lectura ejecuta el getter de ese objeto.
Pasarlo a la función no lo copia ni lo transforma en otro objeto.

`Contador` tiene además `incrementar()`. En `main`, `contador` tiene tipo inferido `Contador` y permite llamarlo.
Dentro de `mostrar`, el parámetro solo permite las operaciones de `LecturaNumero`, además de las comunes de `Object`.
El objeto conserva sus capacidades, aunque ese parámetro no las exponga todas.

Un tipo es una descripción que usa el analizador para comprobar las operaciones. Puede estar escrito o inferido.
Los controles de tipo también existen durante la ejecución; no necesitamos `dynamic` ni conversiones para resolver este
ejemplo. Consulta [The Dart type system](https://dart.dev/language/type-system).

Usamos el parámetro de `mostrar` para comprobar el contrato. Dart puede promover el tipo de una variable cuando su flujo
demuestra información adicional; por eso no conviene generalizar diciendo que el tipo disponible nunca puede afinarse.

### Comprobación

- Descomenta las dos líneas de `mostrar`, una cada vez. Predice el error antes de usar el analizador.
- Quita el getter de `NumeroFijo` y conserva `implements`. ¿Qué promesa queda sin cumplir?
- Añade una tercera clase que implemente `LecturaNumero` y devuelva `10 + 5`. ¿Necesita cambiar `mostrar`?
- ¿El contrato promete que el número sea fijo, que esté almacenado o que se avise al cambiar?

**Puedes avanzar cuando:** separas lo que puede pedir `mostrar` de lo que puede hacer cada objeto y explicas por qué
dos implementaciones distintas sirven al mismo consumidor.

## 3.5. Comprender extends y override

### El problema

Ahora quieres aprovechar un método ya escrito y especializar una parte de su comportamiento.
¿Qué mecanismo permite heredar esa implementación?

### La idea

`extends` crea una subclase que hereda implementación de una superclase. Puede añadir miembros y redefinir otros.
`super` permite acceder a la implementación de la superclase. No representa un segundo objeto independiente.
Consulta [Extend a class](https://dart.dev/language/extend).

`@override` expresa que el miembro pretende implementar o redefinir un miembro del contrato que recibe la clase.
Ayuda al analizador a detectar errores en esa intención, como un nombre mal escrito. La anotación no es la que crea
la herencia o cambia el comportamiento durante la
ejecución: [override](https://api.dart.dev/dart-core/override-constant.html).
Por eso también aparece en las clases que utilizan `implements` en D.

### Ejemplo E: heredar un método y redefinir una lectura

Programa completo. Predice ambas líneas y sigue qué `valor` lee `describir`.

```dart
class NumeroBase {
  int get valor => 5;

  String describir() => 'Número: $valor';
}

class NumeroDoble extends NumeroBase {
  @override
  int get valor => super.valor * 2;
}

void mostrar(NumeroBase fuente) {
  print(fuente.describir());
}

void main() {
  mostrar(NumeroBase());
  mostrar(NumeroDoble());
}
```

1. `NumeroBase` aporta el getter y `describir`.
2. `NumeroDoble` hereda `describir`; no hemos copiado ese método en su cuerpo.
3. Al ejecutarlo sobre un `NumeroDoble`, la lectura de `valor` utiliza el getter redefinido.
4. Ese getter utiliza `super.valor`, obtiene `5` y lo multiplica por dos.

`extends` hereda implementación; `implements` exige cumplir una interfaz. Ninguno obliga a que el consumidor conozca
la clase concreta. Los constructores no se heredan como los métodos; sus reglas se explican en
[Constructor inheritance](https://dart.dev/language/constructors#constructor-inheritance).

### Comprobación

- Cambia el getter de `NumeroDoble` por `int get valor => 12;`. ¿Necesitas modificar `describir`?
- Quita `@override` conservando el getter. Predice si cambia la salida y explica qué información pierde el analizador.
- Sustituye `extends NumeroBase` por `implements NumeroBase`. Antes de ejecutar, señala qué implementación deja de
  heredarse y por qué `super.valor` deja de servir.

**Puedes avanzar cuando:** justificas qué cuerpo se hereda, qué miembro se redefine y qué aporta la anotación.

## 3.6. Sustituir T por un tipo concreto

### El problema

El contrato anterior solo ofrece enteros. Quieres expresar también una lectura de texto o de un modelo de tema
manteniendo una estructura común y los controles de tipos.

### La idea

Un **genérico** tiene parámetros de tipo. En `Lectura<T>`, `T` representa el tipo que elegiremos al utilizarlo.
En `Lectura<int>`, el getter `T get valor` devuelve un `int`; en `Lectura<String>`, devuelve un `String`.
Consulta [Generics](https://dart.dev/language/generics).

`T` no es un valor de tema ni una variable cuyo contenido pasamos al constructor. En `Caja<int>(5)`, `<int>` indica
el argumento de tipo y `(5)` contiene el argumento de valor.

### Ejemplo F: una estructura para distintos tipos

Programa completo. Predice ambas líneas y el tipo de cada lectura.

```dart
abstract interface class Lectura<T> {
  T get valor;
}

class Caja<T> implements Lectura<T> {
  Caja(this._valor);

  final T _valor;

  @override
  T get valor => _valor;
}

void mostrarTexto(Lectura<String> fuente) {
  print(fuente.valor.toUpperCase());
}

void main() {
  final numero = Caja<int>(5);
  final nombre = Caja<String>('claro');

  print(numero.valor + 1);
  mostrarTexto(nombre);
  // mostrarTexto(numero); // Una lectura de int no es una lectura de String.
}
```

`toUpperCase()` es un método de `String` que devuelve el texto en mayúsculas. En `mostrarTexto`, el analizador sabe que
`fuente.valor` es un `String` porque el contrato está utilizado con ese argumento de tipo.

Esta estructura también puede describir `Lectura<DaisyThemeModel>` dentro del proyecto: la lectura ofrecería un modelo
de tema. No estamos cambiando la clase original ni creando una copia de cada valor por utilizar un genérico.

### Comprobación

- Sustituye mentalmente cada `T` de `Caja<T>` por `int`, y luego por `String`.
- Descomenta `mostrarTexto(numero)` y explica la incompatibilidad antes de leer el diagnóstico.
- Intenta `Caja<int>('claro')`. ¿Cuál de sus dos argumentos es incompatible?
- ¿Añadir `<T>` define por sí mismo un mecanismo de notificación?

**Puedes avanzar cuando:** lees juntos el nombre genérico y su argumento de tipo y distingues ese argumento del dato
recibido por el constructor.

## 3.7. Leer estas piezas en DaisyUI

Los siguientes fragmentos se contrastan con los archivos actuales del proyecto. Aquí identificamos tipos, objetos y
relaciones; los mecanismos de notificación y reconstrucción se desarrollarán en las siguientes unidades.

### El modelo es el tipo del dato de tema

En [theme.dart](../../lib/themes/domain/theme.dart), `DaisyThemeModel` describe un tema con identificador, nombre,
descripción, colores, radios, tamaños y borde. El constructor `const factory DaisyThemeModel(...)` redirige a
`_DaisyThemeModel`. Esa fábrica permite obtener una implementación del tipo abstracto; no construye una instancia
directa de la clase abstracta. La generación de Freezed queda fuera de esta unidad.

Para este paso, distingue el tipo `DaisyThemeModel` de cada modelo concreto que representa una selección de tema.
Un modelo de tema tampoco es el controlador que permite cambiar la selección.

### El controlador ofrece un contrato de lectura y escucha

En [daisy_theme_controller.dart](../../lib/themes/application/daisy_theme_controller.dart) aparece este getter:

```dart
ValueListenable<DaisyThemeModel> get theme => _theme;
```

Descompón el tipo:

1. `ValueListenable<T>` es el contrato genérico de Flutter.
2. Aquí `T` es `DaisyThemeModel`: consultar `.value` devuelve un modelo de tema.
3. El contrato también permite `addListener` y `removeListener`, que reciben funciones como las de la unidad 2.
4. No ofrece un setter para `value`. Su definición está en
   [ValueListenable](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html).

En este controlador, `_theme` se inicializa con un objeto `_ThemeListenable` que recibe `_palette` como fuente.
El getter `theme` devuelve esa vista. El controlador y la vista son objetos distintos con responsabilidades distintas.

### La implementación reenvía las operaciones a su fuente

El mismo archivo contiene esta clase completa:

```dart
final class _ThemeListenable implements ValueListenable<DaisyThemeModel> {
  const _ThemeListenable(this._source);

  final ValueListenable<DaisyThemeModel> _source;

  @override
  DaisyThemeModel get value => _source.value;

  @override
  void addListener(VoidCallback listener) => _source.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _source.removeListener(listener);
}
```

Léela con las piezas de esta unidad:

- `_ThemeListenable` es una clase privada a esta biblioteca.
- `implements` declara qué contrato cumple. Los cuerpos de los tres miembros están escritos en la clase.
- `_source` conserva una referencia a la fuente; su tipo permite leerla y registrar o retirar listeners.
- `get value => _source.value` vuelve a consultar esa fuente cuando se lee el getter. No guarda el resultado inicial.
- Las dos funciones reciben `listener` y lo entregan a la fuente. No llaman a `listener()` en esos cuerpos.
- `@override` indica qué miembros implementan el contrato.

`final class` limita la creación de subtipos desde otras bibliotecas. Es un modificador de clase, distinto del `final`
de una variable, y no hace inmutables por sí mismo los datos de sus instancias. `const` en el constructor no convierte
cualquier fuente recibida en un objeto inmutable.

El controlador modifica la selección mediante `setTheme(DaisyThemeModel theme)`, cuyo cuerpo asigna
`_palette.value = theme`. La vista no ofrece ese método ni un setter `value`. Una lectura posterior de su getter puede
obtener el nuevo tema porque consulta la fuente. Observa la relación con C y D: **lectura disponible y cambio permitido
son operaciones diferentes**.

### El scope hereda una implementación de Flutter

En [daisy_theme_scope.dart](../../lib/themes/application/daisy_theme_scope.dart) aparece:

```dart
class DaisyThemeScope extends InheritedNotifier<ValueListenable<DaisyThemeModel>>
{
```

Este es un fragmento de declaración, no un programa completo. Léelo desde dentro:

1. `DaisyThemeModel` describe el tipo del valor de tema.
2. `ValueListenable<DaisyThemeModel>` describe la fuente que permite consultar ese valor y escuchar avisos.
3. `InheritedNotifier<...>` recibe ese tipo de fuente como argumento de tipo.
4. `DaisyThemeScope` utiliza `extends` para heredar implementación de `InheritedNotifier`.

El alcance de esta unidad es reconocer esas relaciones. Seguir quién registra una dependencia y solicita reconstruir
widgets corresponde a las unidades de `Listenable`, scopes y árbol de Flutter.

### Comprobación

En el controlador, señala el campo de la señal, el campo de la vista, el getter público y el método que cambia el tema.
Después explica:

- Qué tipo ofrece `theme`, qué objeto devuelve su implementación y qué tipo tiene `theme.value`.
- Qué operación de `_ThemeListenable` consulta el dato y cuáles reenvían funciones.
- Por qué una vista de solo lectura puede mostrar otro tema más adelante.
- Qué clase utiliza `implements`, cuál utiliza `extends` y qué aporta cada relación.

**Puedes avanzar cuando:** sigues el controlador, la vista y el modelo como piezas distintas y lees los tipos anidados
sin atribuirles por sí solos almacenamiento, notificación o reconstrucción.

## Materiales de estudio seleccionados

La guía y las tareas están en español. Las referencias principales son documentación oficial en inglés.
Lee solo las partes indicadas y vuelve después al ejemplo correspondiente.

- **D1 · Dart: [Classes](https://dart.dev/language/classes)** — nodos 3.1 y 3.4. Identifica miembros de instancia e
  interfaces implícitas. Relaciona cada concepto con una línea de A o D.
- **D2 · Dart: [Constructors](https://dart.dev/language/constructors)** — nodos 3.1 y 3.5. Lee parámetros de
  inicialización y herencia de constructores. Los detalles de fábricas y constantes pueden esperar.
- **D3 · Dart: [Variables](https://dart.dev/language/variables)** — nodo 3.2. Repasa referencias, inferencia y `final`.
  Explica qué conserva cada variable de B.
- **D4 · Dart: [Getters and setters](https://dart.dev/language/methods#getters-and-setters)** y
  [Libraries & imports](https://dart.dev/language/libraries) — nodo 3.3. Distingue consulta de almacenamiento y localiza
  la unidad de privacidad de los identificadores con guion bajo.
- **D5 · Dart: [abstract interface](https://dart.dev/language/class-modifiers#abstract-interface)** — nodo 3.4.
  Explica la función de cada palabra. Repasa también `final` al leer la clase privada del controlador.
- **D6 · Dart: [The Dart type system](https://dart.dev/language/type-system)** — nodo 3.4. Lee la introducción y
  la sección de inferencia. Las conversiones, varianza y reglas avanzadas de promoción quedan para después.
- **D7 · Dart: [Extend a class](https://dart.dev/language/extend)** y
  [override](https://api.dart.dev/dart-core/override-constant.html) — nodo 3.5. Sigue el cuerpo heredado y el miembro
  redefinido de E antes de consultar el ejemplo oficial.
- **D8 · Dart: [Generics](https://dart.dev/language/generics)** — nodo 3.6. Empieza por los parámetros de tipo y
  su uso con constructores. Escribe cómo queda la firma de lectura al utilizar `int`, `String` y `DaisyThemeModel`.
- **D9 · Flutter: [ValueListenable](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html)** — nodo 3.7.
  Identifica el getter y los métodos heredados. La política concreta de avisos se estudiará después.
- **P1 · [DartPad](https://dartpad.dev/)** — práctica A–F y proyecto. Usa programas de Dart independientes.
  Para navegar por los fragmentos reales, utiliza los enlaces a archivos del nodo 3.7.

### Comprobación técnica de los materiales

Los seis ejemplos completos y la solución del proyecto se analizaron y ejecutaron con **Dart 3.13.5**; sus salidas
coincidieron con las soluciones. También se comprobó el rechazo de ocho variantes incorrectas: método fuera del
contrato, asignación sin setter en dos casos, getter sin implementar, cambio de `extends` a `implements`, dos
incompatibilidades de tipos y reasignación de una variable `final`.
Esta comprobación valida los ejemplos; el progreso de estudio se marca al resolver y explicar los ejercicios.

## Proyecto de la unidad: dos fuentes con el mismo contrato

Escribe un programa de Dart desde cero, sin Flutter, que permita leer números con un contrato común.

### Requisitos

1. Declara `Lectura<T>` con un getter `T get valor` y sin setter.
2. Implementa `NumeroFijo` como `Lectura<int>`. Recibe un entero en su constructor y lo conserva en un campo `final`.
3. Implementa `Contador` como `Lectura<int>`. Conserva un entero y ofrece además `incrementar()`.
4. Escribe `mostrar(Lectura<int> fuente)`, que imprime `fuente.valor`. No debe conocer las clases concretas.
5. En `main`, crea un `NumeroFijo(7)` y un `Contador(2)`. Conserva otra referencia al contador y una lectura de su valor
   inicial en variables distintas.
6. Muestra ambas fuentes mediante la misma función. Incrementa a través de la segunda referencia, muestra otra vez el
   contador y finalmente imprime la lectura inicial.
7. Predice toda la salida antes de ejecutar. Explica cuántos objetos `Contador` construiste y qué se compartió.

### Variaciones

- Añade una tercera implementación cuyo getter calcule el doble de un campo. Conserva `mostrar`.
- Introduce una vista que reciba un `Lectura<int>` y reenvíe su getter. Explica qué referencia debe conservar para
  seguir leyendo la fuente en vez de guardar solamente el entero inicial.
- Explica cómo adaptarías el contrato para una lectura de texto y qué función necesitaría aceptar `Lectura<String>`.
- Decide si `NumeroFijo` necesita heredar de `Contador` para cumplir el mismo contrato y justifica tu respuesta.

**Entrega de estudio:** código, salida predicha y explicación de los tipos, referencias y operaciones de cada objeto.

## Errores de comprensión que vamos a comprobar

- Confundir declarar una clase con construir una instancia.
- Suponer que cada nombre de variable representa un objeto distinto.
- Pensar que asignar una referencia copia los campos del objeto.
- Esperar que reasignar una variable reasigne las demás referencias al objeto anterior.
- Interpretar `final` como garantía de inmutabilidad de cualquier objeto referenciado.
- Confundir un getter con un campo almacenado o con una promesa de valor constante.
- Pensar que un contrato de lectura concede todas las operaciones de la implementación.
- Creer que entregar un objeto con un tipo de interfaz lo convierte en otro objeto.
- Suponer que `implements` hereda cuerpos o que `@override` crea por sí mismo el comportamiento.
- Confundir el argumento de tipo `<int>` con el argumento de valor `(5)`.
- Atribuir notificaciones o reconstrucciones a una clase, un getter o un genérico sin identificar su mecanismo.

## Comprobación final

Responde sin consultar las soluciones:

1. En A, ¿qué se declara una vez y qué se construye dos veces?
2. ¿Qué inicializa `this.nombre` y sobre qué objeto actúa `app.cambiar(...)`?
3. En B, ¿cuándo hay dos referencias al mismo objeto y cuándo aparece un segundo objeto?
4. ¿Por qué cambiar un campo y reasignar `app` producen efectos distintos sobre `compartida`?
5. ¿Qué impide `final` y qué no garantiza sobre el objeto?
6. ¿Qué diferencia hay entre un campo, un getter y un método llamado con paréntesis?
7. En D, ¿qué permite el tipo de `fuente` y qué operaciones adicionales tiene el contador?
8. ¿Quién aporta el cuerpo del getter que se ejecuta al llamar a `mostrar(contador)`?
9. ¿Qué diferencia hay entre `implements` y `extends`? ¿Qué papel tiene `@override` en ambos casos?
10. En E, ¿por qué un método heredado muestra `10` para el objeto `NumeroDoble`?
11. ¿Qué significan `T`, `<int>` y `(5)` en las declaraciones y construcciones de F?
12. ¿Qué devuelve `.value` en `ValueListenable<DaisyThemeModel>` y qué otras operaciones permite ese contrato?
13. En DaisyUI, ¿qué objeto devuelve el getter `theme` y dónde se cambia la selección?
14. ¿Por qué `_ThemeListenable.value` puede devolver un tema distinto sin ofrecer un setter?
15. ¿Qué puedes deducir de los tipos de `DaisyThemeScope` y qué mecanismo queda todavía por estudiar?

Marca la unidad como dominada cuando puedas resolver el proyecto sin copiar y explicar estas respuestas.
Si se mezclan variables y objetos, vuelve a 3.2; si se mezclan contrato e implementación, vuelve a 3.4 antes de estudiar
`Listenable` en la unidad 4.

## Soluciones para contrastar después de practicar

<details>
<summary>Ver salidas, solución del proyecto y claves de las comprobaciones</summary>

### Ejemplo A

```text
cupcake
oscuro
```

Cada llamada al constructor de este ejemplo crea una selección independiente. Añadir el cambio de `preview` haría que
su impresión mostrase `forest`.

### Ejemplo B

```text
oscuro
claro
cupcake
oscuro
```

Después de la segunda construcción, `app` accede a B y `compartida` a A. Modificar A a través de `compartida` no cambia
el nombre de B. Si construyes otra selección al inicializar `compartida`, ambas serán independientes desde el inicio.
Reasignar `compartida` es un error porque la variable es `final`.

### Ejemplo C

```text
2
3
```

Con el getter que multiplica por dos se imprimen `4` y `6`; el campo conserva `3` tras incrementar.
Asignar a `contador.valor` requiere un setter que la clase no ofrece. No se ha registrado ninguna observación.

### Ejemplo D

```text
7
2
3
```

Cada objeto aporta el getter que satisface `LecturaNumero`. El contrato no exige almacenamiento, estabilidad del valor
ni avisos. Dentro de `mostrar`, las dos líneas comentadas fallan porque no hay método `incrementar` ni setter `valor`
en ese contrato. Quitar el getter de `NumeroFijo` deja una clase concreta sin implementar un miembro requerido.

### Ejemplo E

```text
Número: 5
Número: 10
```

Al cambiar el getter redefinido a `12`, la segunda línea termina en `12`. Quitar la anotación conserva el
comportamiento;
el analizador pierde la indicación explícita de que pretendíamos redefinir un miembro.
Con `implements`, falta aportar `describir` y `super.valor` no está disponible: ya no se hereda de `NumeroBase`.

### Ejemplo F

```text
6
CLARO
```

Para `Caja<int>`, el campo y el getter tienen tipo `int`; para `Caja<String>`, tienen tipo `String`.
`mostrarTexto(numero)` entrega un `Caja<int>` donde se necesita un `Lectura<String>`.
`Caja<int>('claro')` elige un tipo válido, pero le entrega un texto al constructor que necesita un entero.

### Una solución del proyecto

```dart
abstract interface class Lectura<T> {
  T get valor;
}

class NumeroFijo implements Lectura<int> {
  NumeroFijo(this._valor);

  final int _valor;

  @override
  int get valor => _valor;
}

class Contador implements Lectura<int> {
  Contador(this._valor);

  int _valor;

  @override
  int get valor => _valor;

  void incrementar() {
    _valor += 1;
  }
}

void mostrar(Lectura<int> fuente) {
  print(fuente.valor);
}

void main() {
  final fijo = NumeroFijo(7);
  final contador = Contador(2);
  final otraReferencia = contador;
  final lecturaInicial = contador.valor;

  mostrar(fijo);
  mostrar(contador);
  otraReferencia.incrementar();
  mostrar(contador);
  print(lecturaInicial);
}
```

Salida:

```text
7
2
3
2
```

Hay un `NumeroFijo` y un `Contador`. `contador` y `otraReferencia` acceden al mismo contador; `lecturaInicial` conserva
el entero obtenido antes de incrementar. Pasar el contador a `mostrar` no crea un segundo contador.

### Claves para leer DaisyUI

El controlador conserva la señal y una vista `_ThemeListenable`. El getter público ofrece esa vista con tipo
`ValueListenable<DaisyThemeModel>`; consultar su `.value` obtiene un modelo de tema desde la fuente.
El controlador ofrece `setTheme` para cambiar la selección. El getter de la vista reenvía cada lectura, por lo que no
equivale a un modelo guardado una sola vez.

`_ThemeListenable` implementa el contrato escribiendo los cuerpos que reenvían operaciones.
`DaisyThemeScope` hereda de `InheritedNotifier` con el tipo de fuente indicado entre los genéricos.
Para explicar los avisos y las reconstrucciones aún hay que seguir el mecanismo de escucha y las dependencias de
Flutter; esas palabras no quedan explicadas solamente con los tipos.

</details>
