# 03. Objetos, referencias, tipos y contratos

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 2](02-funciones-como-valores-callbacks-y-listeners.md) · **Estado:** pendiente

## Qué vas a aprender

Hasta ahora hemos guardado temas y preparado funciones para recibir avisos. En DaisyUI, esas piezas viven dentro de
objetos: el controlador conserva una fuente de tema y ofrece operaciones para utilizarla.

En esta unidad aprenderás a distinguir una clase de sus objetos, seguir dos variables que comparten un objeto y leer
un contrato sin confundirlo con su implementación. Al final podrás empezar a interpretar un tipo como
`ValueListenable<DaisyThemeModel>`.

Cada ejemplo completo es independiente. Puedes copiarlo en [DartPad](https://dartpad.dev/), elegir **Dart** y pulsar
**Run**. Antes de ejecutarlo, intenta predecir la salida. Si necesitas varias sesiones, una buena pausa es después del
apartado 3 y otra después del 5.

## 1. Una clase, dos objetos

Imagina que la aplicación tiene una selección de tema y una vista previa tiene otra. Las dos necesitan guardar un
nombre y permitir cambiarlo, pero sus valores deben ser independientes.

Una **clase** describe qué datos y operaciones tendrán objetos de ese tipo. Una **instancia** es un objeto concreto
creado a partir de esa clase. Vamos a escribir una clase y crear dos selecciones:

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
  final vistaPrevia = SeleccionTema('oscuro');

  app.cambiar('cupcake');

  print(app.nombre);
  print(vistaPrevia.nombre);
}
```

La salida es:

```text
cupcake
oscuro
```

Veamos las piezas:

1. `class SeleccionTema` declara la clase. Todavía no crea las selecciones de `main`.
2. `String nombre;` declara un **campo**: cada selección de este ejemplo guarda su propio nombre.
3. `SeleccionTema(this.nombre);` declara un **constructor**. Al crear una selección, recibe un texto y lo usa para
   inicializar el campo `nombre` del objeto nuevo. Aquí `this` se refiere a ese objeto.
4. `void cambiar(String nuevoNombre)` declara un **método**: una función que pertenece al objeto. Recibe un nombre
   y lo asigna a su campo.
5. `SeleccionTema('claro')` y `SeleccionTema('oscuro')` crean dos objetos distintos con este constructor.
   `app` permite acceder al primero y `vistaPrevia`, al segundo.
6. `app.cambiar('cupcake')` modifica el campo del primer objeto. El segundo sigue teniendo `'oscuro'`.

Usamos el punto para acceder a miembros de un objeto: `app.nombre` lee un campo y `app.cambiar(...)` llama a un método.
La clase describe la estructura compartida; cada objeto conserva sus propios datos.

### Practica 1

Añade `vistaPrevia.cambiar('forest');` antes de los `print`. ¿Qué imprime cada línea? ¿Cuántos objetos de
`SeleccionTema` hay?

<details>
<summary>Ver respuesta</summary>

Se imprime `cupcake` y después `forest`. Hay dos objetos: cada llamada a `cambiar` modificó el objeto sobre el que se
hizo la llamada. La clase se declaró una sola vez.

</details>

## 2. Dos variables pueden compartir un objeto

En la unidad 1 guardamos una lectura de un texto. Ahora trabajamos con un objeto cuyo campo puede modificarse. ¿Qué pasa
si asignamos ese objeto a otra variable?

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
  final nombreInicial = app.nombre;

  app.cambiar('oscuro');
  print(compartida.nombre);
  print(nombreInicial);

  app = SeleccionTema('cupcake');
  print(app.nombre);
  print(compartida.nombre);
}
```

La salida es:

```text
oscuro
claro
cupcake
oscuro
```

Una variable de Dart guarda una **referencia** que permite acceder a un objeto. Asignar `app` a `compartida` guarda
la referencia al mismo objeto; no crea una copia de la selección. Sigamos el programa:

1. La primera construcción crea una selección A con nombre `'claro'`.
2. `compartida = app` hace que ambas variables permitan acceder a A. `nombreInicial` guarda el texto leído entonces.
3. `app.cambiar('oscuro')` cambia el campo de A. Como `compartida` también accede a A, lee `'oscuro'`.
   `nombreInicial` sigue teniendo el texto `'claro'` que recibió antes.
4. `app = SeleccionTema('cupcake')` crea una selección B y hace que `app` acceda a B.
   `compartida` sigue accediendo a A, cuyo nombre es `'oscuro'`.

La diferencia está en **qué se modifica**: el método cambia un campo del objeto A; la última asignación cambia la
referencia guardada en `app`. Esa reasignación no cambia la referencia de `compartida`.

`final compartida` impide asignar otra referencia a esa variable. No impide que el objeto al que apunta tenga campos
mutables; por eso `compartida.cambiar('forest')` sería válido. Profundizaremos en `final` e inmutabilidad en la unidad 8.

### Practica 2

Al final del programa, añade `compartida.cambiar('forest');` y vuelve a imprimir `app.nombre` y
`compartida.nombre`. ¿Qué muestra cada uno?

<details>
<summary>Ver respuesta</summary>

`app.nombre` muestra `cupcake` y `compartida.nombre` muestra `forest`. En ese momento apuntan a dos selecciones
distintas; la llamada modifica solamente la selección A, a la que accede `compartida`.

</details>

## 3. Un getter permite consultar un valor

A veces queremos permitir que otros consulten un dato, pero que lo cambien mediante una operación concreta. Un
**getter** es una propiedad cuya lectura ejecuta código para obtener un resultado:

```dart
class Contador {
  Contador(this._valor);

  int _valor;

  int get valor => _valor;

  void incrementar() {
    _valor = _valor + 1;
  }
}

void main() {
  final contador = Contador(2);
  print(contador.valor);
  contador.incrementar();
  print(contador.valor);
}
```

La salida es `2` y después `3`.

- `_valor` es el campo que guarda el número en este ejemplo.
- `int get valor => _valor;` declara un getter que devuelve el número actual del campo.
- `contador.valor` ejecuta el getter. Se lee como una propiedad, sin paréntesis.
- `contador.incrementar()` llama al método que modifica el campo.

El guion bajo al comienzo de `_valor` indica privacidad dentro de la biblioteca Dart; no significa «solo esta clase».
Aquí todo el ejemplo está en el mismo archivo. No hemos declarado un **setter** para `valor`, por lo que no podemos
escribir `contador.valor = 9`. Sin embargo, el getter puede devolver otro número después de `incrementar()`: permitir
solo la lectura de una propiedad no garantiza que el objeto nunca cambie.

Un getter no tiene que limitarse a devolver un campo: también podría calcular un valor o pedirlo a otro objeto. En
cualquier caso, cada lectura ejecuta su código.

### Practica 3

Si cambiamos el getter por `int get valor => _valor * 2;`, ¿qué imprimirá el programa? ¿Qué número habrá en `_valor`
al terminar?

<details>
<summary>Ver respuesta</summary>

Imprimirá `4` y `6`. El campo termina en `3`: `incrementar()` suma uno al campo; multiplicar por dos es solo lo que
hace el getter al leerlo.

</details>

## 4. Un contrato, dos implementaciones

Supongamos que queremos una función que muestre un número. A veces el número será fijo y otras vendrá de un contador.
La función solo necesita **leer** el número; no necesita saber cómo lo conserva cada fuente.

Podemos describir esa capacidad con un **contrato**. En programación también se llama *interfaz*: aquí la palabra no
significa una pantalla. Después creamos clases que aportan el código necesario para cumplirlo.

```dart
abstract interface class LecturaNumero {
  int get valor;
}

class NumeroFijo implements LecturaNumero {
  NumeroFijo(this._numero);

  final int _numero;

  @override
  int get valor => _numero;
}

class Contador implements LecturaNumero {
  Contador(this._numero);

  int _numero;

  @override
  int get valor => _numero;

  void incrementar() {
    _numero = _numero + 1;
  }
}

void mostrar(LecturaNumero fuente) {
  print(fuente.valor);
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

La salida es:

```text
7
2
3
```

Léelo por partes:

1. `LecturaNumero` declara una operación: consultar `valor` y obtener un `int`. La declaración termina en `;` porque
   aquí no aporta un cuerpo para ese getter.
2. `abstract interface class` declara este contrato sin poder construirlo directamente. `interface` permite que otras
   bibliotecas lo implementen, pero impide que lo extiendan.
3. `implements LecturaNumero` indica que `NumeroFijo` y `Contador` cumplen el contrato. Cada clase concreta debe aportar
   el getter requerido; `implements` no hereda la implementación de la clase que nombra.
4. `@override` señala la intención de implementar o redefinir un miembro. Ayuda al analizador, pero no crea el getter
   ni es lo que hace funcionar la relación.
5. `mostrar` recibe una `fuente` de tipo `LecturaNumero` y consulta `fuente.valor`. Cuando le pasamos el contador, se
   ejecuta el getter de `Contador`; cuando le pasamos el número fijo, se ejecuta el de `NumeroFijo`.

**El tipo y el objeto responden a preguntas diferentes.** Dentro de `mostrar`, el tipo declarado de `fuente` permite
usar las operaciones de `LecturaNumero`, como leer `valor`. El objeto recibido puede ser un `Contador`, que además
sabe incrementar. El contrato de `fuente` no incluye `incrementar()`, así que `fuente.incrementar()` daría error en
esa función. En `main`, `contador` tiene tipo inferido `Contador`, por eso allí sí podemos llamar al método.

Entregar el contador a `mostrar` no crea otro contador ni elimina su método: el tipo del parámetro determina qué puede
usar ese código. Los tipos pueden afinarse en determinadas condiciones, pero no necesitamos hacerlo en este ejemplo.

### Practica 4

1. ¿Podría `mostrar` leer un tercer objeto que también implemente `LecturaNumero`?
2. ¿Promete el contrato que el número permanecerá siempre igual o que se notificará cada cambio?
3. ¿Por qué `mostrar(contador)` no necesita conocer el método `incrementar()`?

<details>
<summary>Ver respuesta</summary>

1. Sí. Si la clase cumple `LecturaNumero`, `mostrar` puede consultar su getter sin cambiar su propio código.
2. No. El contrato de este ejemplo solo promete una lectura de tipo `int`.
3. Porque su trabajo es consultar `valor`, operación que sí está en el contrato. El contador puede ofrecer otras
   operaciones a quien lo use mediante un tipo que las incluya.

</details>

## 5. `extends` reutiliza implementación

Ya vimos `implements`: una clase promete cumplir una interfaz y aporta sus propios miembros. Con `extends`, en cambio,
una clase puede heredar comportamiento de otra y especializarlo.

```dart
class NumeroBase {
  int get valor => 5;

  String describir() => 'Número: $valor';
}

class NumeroDoble extends NumeroBase {
  @override
  int get valor => super.valor * 2;
}

void main() {
  final base = NumeroBase();
  final doble = NumeroDoble();

  print(base.describir());
  print(doble.describir());
}
```

La salida es:

```text
Número: 5
Número: 10
```

`NumeroDoble extends NumeroBase` declara una subclase. Hereda el método `describir()` y redefine el getter `valor`.
En ese getter, `super.valor` accede a la implementación de la clase base, que devuelve `5`; después se multiplica por
2. `super` no crea otro objeto.

Cuando llamamos a `doble.describir()`, se ejecuta el método heredado sobre el objeto `doble`. Al leer `valor`, se usa
el getter redefinido para ese objeto y obtiene `10`. `@override` señala esa redefinición, igual que en el apartado
anterior señalaba la implementación de un miembro del contrato.

### Practica 5

Si el getter de `NumeroDoble` devuelve `super.valor * 3`, ¿qué muestra `doble.describir()`? ¿De dónde sale el método
`describir()`?

<details>
<summary>Ver respuesta</summary>

Muestra `Número: 15`: el getter de la clase base devuelve `5` y el de `NumeroDoble` lo multiplica por tres.
`describir()` se hereda de `NumeroBase`; no tuvimos que volver a escribirlo.

</details>

## 6. Genéricos: el mismo contrato para distintos tipos

Nuestro contrato `LecturaNumero` solo permite leer enteros. ¿Y si queremos expresar la misma idea para un texto o para
un modelo de tema?

Un **parámetro de tipo** permite escribir el contrato una vez y concretar el tipo del valor al utilizarlo:

```dart
abstract interface class Lectura<T> {
  T get valor;
}

class Caja<T> implements Lectura<T> {
  Caja(this._contenido);

  final T _contenido;

  @override
  T get valor => _contenido;
}

void mostrarNumero(Lectura<int> fuente) {
  print(fuente.valor + 1);
}

void mostrarTexto(Lectura<String> fuente) {
  print(fuente.valor.toUpperCase());
}

void main() {
  final numero = Caja<int>(5);
  final texto = Caja<String>('claro');

  mostrarNumero(numero);
  mostrarTexto(texto);
}
```

La salida es `6` y después `CLARO`.

- En `Lectura<T>`, `T` representa el tipo que se concretará al usar el contrato. El getter devuelve un valor de ese tipo.
- `Lectura<int>` es una lectura cuyo `valor` es un entero. `mostrarNumero` puede sumarle `1`.
- `Lectura<String>` es una lectura cuyo `valor` es un texto. `mostrarTexto` puede usar `toUpperCase()` para pasarlo a
  mayúsculas.
- En `Caja<int>(5)`, `<int>` es un **argumento de tipo** y `(5)` entrega el **valor** al constructor. En esa caja,
  el contenido y el getter tienen tipo `int`.

Aunque `Caja` sigue la misma estructura en ambos casos, `Caja<int>` no es una `Lectura<String>`. El tipo ayuda a detectar
usos incompatibles: por ejemplo, `mostrarTexto(numero)` no sería válido.

### Practica 6

Para `Caja<String>('oscuro')`, ¿qué representa `String` y qué representa `'oscuro'`? Si una función recibe
`Lectura<String>`, ¿qué tipo devuelve `fuente.valor`?

<details>
<summary>Ver respuesta</summary>

`String` concreta el tipo del contenido; `'oscuro'` es el valor entregado al constructor. La lectura
`fuente.valor` devuelve un `String`.

</details>

## 7. Leer estas piezas en DaisyUI

El [controlador de temas](../../../lib/themes/application/daisy_theme_controller.dart) contiene:

```dart
final ValueNotifier<DaisyThemeModel> _palette;

ValueListenable<DaisyThemeModel> get theme => _palette;

void setTheme(DaisyThemeModel theme) => _palette.value = theme;
```

El constructor crea `_palette` con el tema inicial. Su tipo concreto, `ValueNotifier<DaisyThemeModel>`, permite leer,
escribir y escuchar. El getter `theme` devuelve ese **mismo objeto** con tipo declarado
`ValueListenable<DaisyThemeModel>`: mediante ese tipo se puede leer y escuchar, pero no asignar a `.value` ni llamar a
`dispose`. Un cast al tipo concreto puede recuperar esas capacidades; el tipo público no crea un adaptador separado.

`DaisyThemeModel` es el tipo del valor devuelto por `.value`. Para proponer otro tema, el controlador ofrece
`setTheme`. En el [scope](../../../lib/themes/application/daisy_theme_scope.dart) aparece además:

```dart
class DaisyThemeScope
    extends InheritedNotifier<ValueListenable<DaisyThemeModel>> {
```

`DaisyThemeScope` hereda de `InheritedNotifier` y le proporciona un tipo concreto. Sus dependencias y reconstrucciones
se estudian más adelante.

### Practica 7

¿Qué tipo obtiene quien lee `controller.theme.value`? ¿El getter público crea otro notificador? ¿Cómo se propone un
tema nuevo?

<details>
<summary>Ver respuesta</summary>

La lectura devuelve un `DaisyThemeModel`. `theme` devuelve el mismo `_palette` bajo el tipo `ValueListenable`; para
proponer un cambio se llama a `controller.setTheme(nuevoTema)`.

</details>

## Ejercicio final: dos fuentes, una lectura

Escribe un programa Dart completo que:

1. Declare `Lectura<T>` con un getter `T get valor;`.
2. Implemente `NumeroFijo` como `Lectura<int>`. Debe recibir un número en su constructor y devolverlo desde el getter.
3. Implemente `Contador` como `Lectura<int>`, con un getter y un método `incrementar()`.
4. Declare `mostrar(Lectura<int> fuente)`, que imprima el valor sin conocer la clase concreta.
5. Cree un número fijo `7` y un contador `2`. Guarde otra referencia al contador y también una lectura de su valor
   inicial.
6. Muestre ambas fuentes, incremente el contador usando la otra referencia, vuelva a mostrarlo e imprima la lectura
   inicial.

Predice la salida. Después explica cuántos objetos `Contador` hay, qué comparten las dos referencias y por qué
`mostrar` acepta ambas fuentes. Como variación, añade una tercera implementación que devuelva un número calculado.

<details>
<summary>Ver una posible solución</summary>

```dart
abstract interface class Lectura<T> {
  T get valor;
}

class NumeroFijo implements Lectura<int> {
  NumeroFijo(this._numero);

  final int _numero;

  @override
  int get valor => _numero;
}

class Contador implements Lectura<int> {
  Contador(this._numero);

  int _numero;

  @override
  int get valor => _numero;

  void incrementar() {
    _numero = _numero + 1;
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

```text
7
2
3
2
```

Se construye un solo `Contador`. `contador` y `otraReferencia` permiten acceder a ese mismo objeto; incrementar mediante
una referencia afecta a lo que lee la otra. `lecturaInicial` conserva el número obtenido antes del incremento.
`mostrar` acepta el número fijo y el contador porque ambos cumplen `Lectura<int>`.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; si dudas, vuelve al apartado indicado y repite su práctica.

1. ¿Qué diferencia hay entre declarar una clase y crear dos instancias? **Apartado 1.**
2. ¿Qué cambia al modificar un campo compartido y qué cambia al reasignar una variable? **Apartado 2.**
3. ¿En qué se diferencian el campo `_valor`, el getter `valor` y el método `incrementar()`? **Apartado 3.**
4. ¿Qué puede pedir `mostrar` a una `LecturaNumero` y quién aporta el código de esa lectura? **Apartado 4.**
5. ¿Qué diferencia hay entre `implements` y `extends`? ¿Para qué sirve `@override`? **Apartados 4 y 5.**
6. ¿Qué representan `T`, `<int>` y `(5)` en `Caja<int>(5)`? **Apartado 6.**
7. ¿Qué tipo devuelve `controller.theme.value` y dónde se cambia el tema? **Apartado 7.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques las respuestas con tus palabras.
La siguiente unidad utiliza estas ideas para estudiar el contrato `Listenable` y sus avisos.

## Para consultar si necesitas reforzar

- [Clases en Dart](https://dart.dev/language/classes): clases, instancias e interfaces implícitas.
- [Getters y setters](https://dart.dev/language/methods#getters-and-setters): lectura y escritura de propiedades.
- [Modificadores de clase](https://dart.dev/language/class-modifiers#abstract-interface): el contrato
  `abstract interface`.
- [Herencia en Dart](https://dart.dev/language/extend): `extends`, redefinición y `super`.
- [Genéricos en Dart](https://dart.dev/language/generics): parámetros y argumentos de tipo.
- [`ValueListenable` en Flutter](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html): el contrato
  de lectura y escucha que aparece en el controlador.
