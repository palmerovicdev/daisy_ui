# 02. Funciones como valores: callbacks y listeners

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 1](01-estado-valor-actual-y-cambio.md) · **Estado:** pendiente

## Qué vas a aprender

En la unidad 1 vimos que cambiar un dato y enterarse de ese cambio son cosas distintas. Ahora vamos a estudiar una pieza que permite comunicarlo: **una función que entregamos para que otro código la llame**.

Al terminar podrás explicar la diferencia entre `avisar` y `avisar()`, seguir quién ejecuta un callback, entender qué variable lee una *closure* y registrar y retirar un listener. Empezaremos con Dart; al final buscaremos esas ideas en DaisyUI.

Puedes copiar cada programa completo en [DartPad](https://dartpad.dev/), elegir **Dart** y pulsar **Run**. Primero intenta predecir la salida. Puedes repartir la unidad en varias sesiones.

## 1. Una función es una acción que podemos llamar

Imagina que queremos mostrar un aviso cuando cambie el tema. En vez de escribir el mismo `print` cada vez, podemos agruparlo en una función:

```dart
void avisar() {
  print('El tema cambió');
}

void main() {
  print('Antes');
  avisar();
  print('Después');
}
```

La salida es:

```text
Antes
El tema cambió
Después
```

`avisar` es el nombre de la función. Las instrucciones entre llaves forman su **cuerpo**. Al escribir `avisar()`, la llamamos: Dart ejecuta ese cuerpo y después continúa por la línea siguiente.

Los paréntesis vacíos indican que esta llamada no necesita datos. La palabra `void` indica que no vamos a utilizar un valor devuelto por la función; aun así, puede hacer trabajo, como imprimir un mensaje.

### Practica 1

¿Qué se imprime si quitamos la línea `avisar();` de `main`? ¿Sigue existiendo la función?

<details>
<summary>Ver respuesta</summary>

Se imprimen `Antes` y `Después`. La función sigue declarada, pero nadie la llama, así que su cuerpo no se ejecuta.

</details>

## 2. Guardar una función sin ejecutarla

En Dart una función también puede usarse como valor. Eso permite guardarla en una variable para llamarla más tarde:

```dart
void avisar() {
  print('El tema cambió');
}

void main() {
  final accion = avisar;
  print('Acción preparada');

  accion();
}
```

La salida es:

```text
Acción preparada
El tema cambió
```

Fíjate en las dos líneas clave:

- `final accion = avisar;` guarda la función en `accion`. Todavía no ejecuta su cuerpo.
- `accion();` llama a la función guardada. Entonces aparece el aviso.

Piensa en guardar una receta y en cocinar siguiendo esa receta: guardar la receta no cocina. La comparación sirve para separar guardar de ejecutar; en Dart, además, una función puede utilizar variables de su entorno, como veremos después.

**`avisar` entrega la función. `avisar()` la ejecuta.** Si escribimos `final accion = avisar();`, intentamos guardar el resultado de una llamada `void`; Dart no lo permite. No habríamos dejado una acción pendiente.

### Practica 2

Predice el orden de salida:

```dart
void avisar() {
  print('Aviso');
}

void main() {
  final primera = avisar;
  print('Uno');
  primera();
  print('Dos');
  primera();
}
```

<details>
<summary>Ver respuesta</summary>

```text
Uno
Aviso
Dos
Aviso
```

Guardar `avisar` no imprime nada. Cada llamada a `primera()` ejecuta el cuerpo de la función una vez.

</details>

## 3. Entregar una función: el callback

Ahora imaginemos que otra parte del programa recibe una acción y decide cuándo ejecutarla:

```dart
void avisar() {
  print('El tema cambió');
}

void ejecutarAccion(void Function() accion) {
  print('Voy a ejecutar la acción');
  accion();
}

void main() {
  print('Inicio');
  ejecutarAccion(avisar);
  print('Fin');
}
```

Antes de ver la explicación, sigue las llamadas. La salida es:

```text
Inicio
Voy a ejecutar la acción
El tema cambió
Fin
```

1. `main` llama a `ejecutarAccion` y le entrega `avisar` **sin paréntesis**.
2. Dentro de `ejecutarAccion`, el nombre `accion` representa la función recibida.
3. `accion()` llama a esa función; por eso se imprime el aviso.
4. Al terminar, la ejecución vuelve a `main` y se imprime `Fin`.

En este ejemplo, `avisar` hace el papel de **callback**: una función entregada a otro código para que este la llame. La palabra describe su papel, no una forma especial de escribirla. Aquí se llama durante `ejecutarAccion`; en otros casos puede guardarse para llamarla más tarde. Un callback no implica por sí solo asincronía ni otro hilo.

### Cómo leer `void Function() accion`

La declaración del ejemplo dice qué espera recibir `ejecutarAccion`:

- `accion` es el nombre del **parámetro**: el dato que recibe la función.
- `void Function()` es su tipo: una función que puede llamarse sin argumentos y cuyo resultado no se utiliza.
- El primer `void`, al comienzo de `void ejecutarAccion(...)`, se refiere al resultado de `ejecutarAccion`.

Cuando escribimos `ejecutarAccion(avisar)`, `avisar` es el **argumento** que entregamos al parámetro `accion`. `void` no significa «sin argumentos»: por ejemplo, `void Function(String)` describe una función que recibe un texto y no ofrece un resultado utilizable.

En Flutter encontrarás también `VoidCallback`: es un nombre alternativo para el tipo `void Function()`. El nombre no crea ni ejecuta una función; solo describe qué clase de función se espera.

### Practica 3

En el ejemplo anterior, ¿qué deja de imprimirse si quitamos `accion();`? ¿Quién estaba a cargo de llamar al callback?

<details>
<summary>Ver respuesta</summary>

Deja de imprimirse `El tema cambió`. `ejecutarAccion` sigue recibiendo la función, pero ya no la llama. En el ejemplo original, la línea `accion()` dentro de `ejecutarAccion` era la encargada de ejecutarla.

</details>

## 4. Preparar una acción con los datos que necesita

A veces una función necesita un dato, pero el receptor espera una acción **sin argumentos**. Podemos preparar otra función que haga la llamada con ese dato cuando llegue el momento:

```dart
void seleccionarTema(String tema) {
  print('Seleccionado: $tema');
}

void ejecutarAccion(void Function() accion) {
  accion();
}

void main() {
  final alPulsar = () {
    seleccionarTema('oscuro');
  };

  print('Botón preparado');
  ejecutarAccion(alPulsar);
}
```

La salida es:

```text
Botón preparado
Seleccionado: oscuro
```

`seleccionarTema` necesita un `String` llamado `tema`. En cambio, `alPulsar` no necesita argumentos: su cuerpo ya indica que, cuando se ejecute, llamará a `seleccionarTema('oscuro')`.

La expresión `() { ... }` crea una **función anónima**, es decir, una función que no declaramos con nombre propio. La guardamos en la variable `alPulsar`. Crear esa función no ejecuta su cuerpo. El cuerpo se ejecuta cuando `ejecutarAccion` llama a `accion()`.

Cuando el cuerpo consiste en una sola expresión, Dart permite escribirlo con flecha:

```dart
final alPulsar = () => seleccionarTema('oscuro');
```

Para este ejemplo produce el mismo efecto que el bloque anterior. `=>` es una forma de escribir el cuerpo; por sí sola no ejecuta la función ni la registra en ningún lugar. Si una función devuelve un resultado, la flecha devuelve el resultado de su expresión.

Compara estas tres expresiones:

- `seleccionarTema`: la función que espera recibir un texto.
- `seleccionarTema('oscuro')`: una llamada que ocurre en ese momento.
- `() => seleccionarTema('oscuro')`: una función sin argumentos preparada para realizar esa llamada cuando la llamen.

### Practica 4

Si escribes `final alPulsar = () => seleccionarTema('claro');` y no llamas a `alPulsar`, ¿se imprime algo? ¿Qué cambiarías para que se ejecute?

<details>
<summary>Ver respuesta</summary>

No se imprime nada al crearla. Para ejecutar su cuerpo puedes llamar a `alPulsar()` o entregarla a otro código que la llame, como `ejecutarAccion(alPulsar)`.

</details>

## 5. ¿Qué valor lee una función cuando la llamamos?

Volvamos al tema de la unidad 1. Podemos preparar una función que use una variable y llamar a esa función después de cambiarla:

```dart
void main() {
  var temaActual = 'claro';
  final lecturaInicial = temaActual;

  final mostrarActual = () => print('Actual: $temaActual');
  final mostrarInicial = () => print('Inicial: $lecturaInicial');

  temaActual = 'oscuro';
  mostrarActual();
  mostrarInicial();
}
```

La salida es:

```text
Actual: oscuro
Inicial: claro
```

Cuando se crean las funciones, sus cuerpos aún no se ejecutan. Después cambiamos `temaActual` a `'oscuro'` y llamamos a ambas:

1. `mostrarActual` consulta la variable `temaActual` al ejecutarse. En ese momento vale `'oscuro'`.
2. `mostrarInicial` consulta otra variable, `lecturaInicial`. Esta recibió `'claro'` antes del cambio.

Una función que conserva acceso a variables del entorno donde se creó se llama **closure**. En este ejemplo, cada función usa una variable distinta. No confundas conservar acceso a `temaActual` con guardar una lectura anterior en `lecturaInicial`.

Ese acceso puede durar incluso después de que la función que creó la closure haya terminado:

```dart
void Function() crearAviso(String nombre) {
  return () => print('Aviso de $nombre');
}

void main() {
  final aviso = crearAviso('DaisyUI');
  print('Preparado');
  aviso();
}
```

`crearAviso` recibe `'DaisyUI'` como `nombre` y **devuelve una función** mediante `return`. Su tipo de retorno es `void Function()`. La función devuelta conserva acceso a ese `nombre`; por eso, aunque `crearAviso` ya terminó, al llamar a `aviso()` se imprime `Aviso de DaisyUI` después de `Preparado`.

### Practica 5

En el primer programa de este apartado, añade `temaActual = 'cupcake';` después de `mostrarInicial()` y vuelve a llamar a las dos funciones. ¿Qué imprimen ahora?

<details>
<summary>Ver respuesta</summary>

`mostrarActual()` imprime `Actual: cupcake` porque vuelve a leer `temaActual`. `mostrarInicial()` imprime otra vez `Inicial: claro` porque utiliza la lectura que se guardó antes. Cambiar una variable no reasigna la otra.

</details>

## 6. Un listener es un callback registrado para recibir avisos

Un **listener** es una función que registramos para que una fuente la llame al producirse un aviso. Para entender el mecanismo, construiremos una versión pequeña con una lista. Es un modelo didáctico de Dart, no la implementación de Flutter.

```dart
void main() {
  var temaActual = 'claro';
  final listeners = <void Function()>[];

  void registrar(void Function() listener) {
    listeners.add(listener);
  }

  void retirar(void Function() listener) {
    listeners.remove(listener);
  }

  void notificar() {
    for (final listener in listeners) {
      listener();
    }
  }

  final mostrarTema = () => print('Aviso: $temaActual');

  registrar(mostrarTema);
  print('Listener registrado');

  temaActual = 'oscuro';
  notificar();

  retirar(mostrarTema);
  temaActual = 'cupcake';
  notificar();
  print('Final: $temaActual');
}
```

La salida es:

```text
Listener registrado
Aviso: oscuro
Final: cupcake
```

Leamos primero la sintaxis nueva:

- `<void Function()>[]` crea una lista vacía de funciones sin argumentos.
- `add` añade un elemento y `remove` retira una entrada que coincide con el elemento entregado.
- `for (final listener in listeners)` recorre las funciones de la lista. `listener()` llama a la función de esa vuelta.

Ahora sigue el recorrido:

1. `registrar(mostrarTema)` guarda la función en la lista. En este programa, registrarla no la ejecuta.
2. Cambiamos el tema a `'oscuro'`. Esa asignación tampoco llama al listener por sí sola.
3. `notificar()` recorre la lista y llama a `mostrarTema`, que lee el tema actual e imprime el aviso.
4. `retirar(mostrarTema)` elimina su registro. Al volver a llamar a `notificar()`, ya no está en la lista y no imprime.
5. El tema sí cambia a `'cupcake'`; dejar de escuchar no impide que el dato cambie.

En Flutter encontrarás las operaciones `addListener` y `removeListener`. Las estudiaremos desde la unidad 4. No todas las fuentes tienen necesariamente la misma política de avisos o de registros repetidos. Este ejemplo tampoco intenta resolver cambios de la lista durante una notificación.

### ¿Por qué guardar la función?

Para retirarla con seguridad, conservamos la función que registramos:

```dart
final listener = () => print('Aviso');
registrar(listener);
retirar(listener);
```

Escribir otra función anónima con el mismo cuerpo en `retirar` no garantiza que sea igual a la que registramos. Tener el mismo texto no basta para recuperar una función anterior. Guardarla nos permite entregar la misma al registrar y al retirar.

### Practica 6

En el ejemplo de la lista, ¿qué ocurre si quitamos la primera llamada a `notificar()` y dejamos todo lo demás igual? ¿El registro o la asignación a `'oscuro'` imprimirán el aviso?

<details>
<summary>Ver respuesta</summary>

No se imprime `Aviso: oscuro`: en este programa ni registrar ni asignar ejecuta el listener. Después retiramos el listener antes de la segunda notificación, por lo que tampoco imprime entonces. Quedan `Listener registrado` y `Final: cupcake`.

</details>

## 7. Estas funciones en DaisyUI

Abre el [ejemplo de la aplicación](../../../example/lib/main.dart). Dentro del `build` de `_ThemeExample` encontrarás este fragmento; depende del resto del archivo y no es un programa independiente:

```dart
final theme = context.daisyTheme;

// Más adelante, dentro de ElevatedButton:
onPressed: () => DaisyThemeService.setTheme(
  theme.id == DaisyThemes.light.id
      ? DaisyThemes.dark
      : DaisyThemes.light,
),
```

`onPressed` recibe una función sin argumentos. El cuerpo usa una condición: si el tema leído es el claro, selecciona el oscuro; en caso contrario, selecciona el claro. Al construir el botón se entrega la función; cuando el usuario pulsa, el botón puede llamarla y entonces se ejecuta `setTheme`.

Esa función utiliza la variable local `theme` de esa ejecución de `build`. Si Flutter vuelve a construir el widget, se vuelve a obtener `theme` y se prepara otro callback para el botón. Estudiaremos la reconstrucción en detalle más adelante; aquí interesa reconocer qué variable usa la función y quién la llama.

En el [controlador de temas](../../../lib/themes/application/daisy_theme_controller.dart), el getter público `theme` devuelve una vista de lectura con tipo `ValueListenable<DaisyThemeModel>`. El consumidor puede registrar una función con `controller.theme.addListener(avisar)` y retirarla con `controller.theme.removeListener(avisar)`. `setTheme` asigna a `_palette.value`; `_palette` es una señal, que estudiaremos en la unidad 9, y es ella quien decide si avisa a los listeners registrados.

### Practica 7

En el botón, señala la función que se entrega a `onPressed` y la llamada que ocurre dentro de ella. ¿Qué recibe `controller.theme.addListener(avisar)`?

<details>
<summary>Ver respuesta</summary>

La función entregada empieza por `() =>`; su cuerpo llama a `DaisyThemeService.setTheme(...)`. El botón la llama al pulsarse. `addListener` recibe la función `avisar`, sin ejecutarla por el hecho de escribir su nombre.

</details>

## Ejercicio final: preparar una selección y escucharla

Escribe un programa Dart completo que:

1. Guarde el tema `'claro'` y una lectura inicial.
2. Tenga una lista de listeners `void Function()`.
3. Defina `seleccionarTema(String nuevoTema)`: cambia el tema y llama a cada listener de la lista. Para este ejercicio, notifica en cada llamada, incluso si se repite el mismo texto.
4. Guarde y registre una función que imprima el tema actual cuando reciba un aviso.
5. Prepare una función sin argumentos `alPulsar` que seleccione `'oscuro'`. Imprime el tema antes de llamarla.
6. Llame a `alPulsar()`, retire el listener y seleccione `'cupcake'`.
7. Imprima la lectura inicial y el tema final.

Predice la salida antes de ejecutarlo. Después explica quién llama al listener y por qué el segundo cambio no imprime un aviso. Como variación, registra un segundo listener y retira solamente el primero.

<details>
<summary>Ver una posible solución</summary>

```dart
void main() {
  var temaActual = 'claro';
  final lecturaInicial = temaActual;
  final listeners = <void Function()>[];

  void seleccionarTema(String nuevoTema) {
    temaActual = nuevoTema;
    for (final listener in listeners) {
      listener();
    }
  }

  final mostrarTema = () => print('Aviso: $temaActual');
  listeners.add(mostrarTema);
  final alPulsar = () => seleccionarTema('oscuro');

  print('Antes: $temaActual');
  alPulsar();
  listeners.remove(mostrarTema);
  seleccionarTema('cupcake');

  print('Inicial: $lecturaInicial');
  print('Final: $temaActual');
}
```

```text
Antes: claro
Aviso: oscuro
Inicial: claro
Final: cupcake
```

Preparar `alPulsar` no cambia el tema. Al llamarla, `seleccionarTema` asigna `'oscuro'` y recorre la lista: esa llamada al listener imprime el valor actual. Después lo retiramos; la segunda selección cambia el dato, pero la lista está vacía. `lecturaInicial` conserva el texto que recibió antes de ambos cambios.

Si registras un segundo listener y retiras solo `mostrarTema`, el segundo permanece en la lista y recibirá también el aviso de la selección `'cupcake'`.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si alguna idea no está clara.

1. ¿Qué diferencia hay entre `avisar` y `avisar()`? **Apartados 1 y 2.**
2. ¿Qué es un callback y quién decide llamarlo en nuestro ejemplo? **Apartado 3.**
3. ¿Qué significa `void Function()`? ¿Qué nombre usa Flutter para ese tipo? **Apartado 3.**
4. ¿Para qué sirve `() => seleccionarTema('oscuro')`? **Apartado 4.**
5. ¿Qué variable consulta una closure y cuándo? ¿Cómo se diferencia de una lectura guardada? **Apartado 5.**
6. ¿Qué pasos registran, llaman y retiran un listener? ¿Por qué conservar la función registrada? **Apartado 6.**
7. En DaisyUI, ¿quién ejecuta el callback del botón y dónde se registra un listener? **Apartado 7.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques estas respuestas con tus palabras. La siguiente unidad profundiza en objetos, referencias, tipos y contratos.

## Para consultar si necesitas reforzar

- [Funciones en Dart](https://dart.dev/language/functions): declaración, parámetros, funciones anónimas y closures.
- [Typedefs en Dart](https://dart.dev/language/typedefs): cómo dar un nombre a un tipo de función.
- [`VoidCallback` en Flutter](https://api.flutter.dev/flutter/dart-ui/VoidCallback.html): definición del tipo sin argumentos.
- [`Listenable` en Flutter](https://api.flutter.dev/flutter/foundation/Listenable-class.html): introducción al registro y retirada de listeners, que estudiaremos en la unidad 4.
