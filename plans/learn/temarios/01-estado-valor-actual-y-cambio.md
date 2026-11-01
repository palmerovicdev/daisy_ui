# 01. Estado, valor actual y cambio

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · **Estado:** pendiente

## Qué vas a aprender

Al terminar podrás seguir un dato que cambia, distinguir su valor actual de una lectura anterior y explicar por qué
cambiar un dato no garantiza por sí solo que la pantalla se actualice. Usaremos el tema claro y oscuro como ejemplo.

No necesitas conocer Signals, listeners ni el funcionamiento interno de Flutter para empezar. Si alguna parte se te
hace pesada, para después de un ejercicio y continúa en otra sesión.

## 1. ¿Qué es el estado?

Imagina una aplicación con un botón para cambiar entre el tema claro y el oscuro. Cuando la abres, la aplicación necesita
saber cuál de los dos está seleccionado. Esa selección es un ejemplo de **estado**: información que describe una
situación de la aplicación en un momento dado.

El estado puede cambiar. Si eliges el tema oscuro, la selección pasa de «claro» a «oscuro». Otros ejemplos de estado
son el texto escrito en un formulario, el número de productos en un carrito o si una petición está cargando.

En nuestro ejemplo hay tres cosas diferentes:

- El **dato**: el tema seleccionado. Puede valer `'claro'` o `'oscuro'`.
- El **botón**: permite pedir un cambio.
- La **etiqueta**: muestra en pantalla un texto como «Tema: claro».

El botón no es la selección. La etiqueta la representa, pero tampoco es necesariamente el lugar donde se guarda.
Vamos a guardar la selección nosotros mismos para ver la diferencia.

> **Prueba rápida:** en un carrito que contiene tres productos, ¿qué información es el estado: el número `3`, el
> botón «Añadir» o el texto que se muestra? **Respuesta:** la cantidad guardada es el estado; el botón pide una
> acción y el texto presenta esa cantidad. Una pantalla puede tener más estado además de esa cantidad.

## 2. Guardar y cambiar un valor

Empecemos con Dart, sin pantalla. Una variable nos permite guardar un valor y acceder a él usando un nombre:

```dart
void main() {
  var temaActual = 'claro';
  print(temaActual);

  temaActual = 'oscuro';
  print(temaActual);
}
```

Puedes copiar el programa en [DartPad](https://dartpad.dev/), elegir **Dart** y pulsar **Run**. Antes, intenta decir
qué imprimirá cada `print`.

La salida es:

```text
claro
oscuro
```

Léelo en este orden:

1. `var temaActual = 'claro';` crea la variable `temaActual` con el texto `'claro'`. Las comillas indican que es texto.
2. `print(temaActual);` consulta el valor que tiene en ese momento y lo muestra en la consola.
3. `temaActual = 'oscuro';` asigna otro valor a la **misma variable**.
4. El segundo `print` vuelve a consultarla y encuentra `'oscuro'`.

Llamamos **valor actual** al que obtenemos al consultar el dato en un momento concreto. Al principio es `'claro'`;
después de la asignación es `'oscuro'`. El programa se lee de arriba abajo: cuándo hacemos la lectura importa.

### Practica 1

Sin ejecutarlo, escribe qué se imprime:

```dart
void main() {
  var tema = 'claro';
  tema = 'oscuro';
  tema = 'claro';
  print(tema);
}
```

<details>
<summary>Ver respuesta</summary>

Se imprime `claro`. Cuando llega a `print`, la última asignación ya ha puesto ese valor en `tema`. Las asignaciones
anteriores ocurrieron, pero esta variable conserva el valor de la última.

</details>

## 3. Una lectura guardada no sigue los cambios

Ahora queremos recordar qué tema había **antes** de cambiarlo. Para ello guardamos una lectura en otra variable:

```dart
void main() {
  var temaActual = 'claro';
  final temaAnterior = temaActual;

  temaActual = 'oscuro';

  print(temaAnterior);
  print(temaActual);
}
```

`final` significa que esa variable se asigna una sola vez. En la segunda línea, Dart lee el valor que tiene
`temaActual` **en ese instante** y lo asigna a `temaAnterior`. Más tarde cambiamos `temaActual`, pero no asignamos
nada nuevo a `temaAnterior`.

| Momento | `temaActual` | `temaAnterior` |
| --- | --- | --- |
| Después de crear `temaActual` | `claro` | Todavía no existe |
| Después de guardar la lectura | `claro` | `claro` |
| Después de cambiar el tema | `oscuro` | `claro` |

Por eso el programa imprime primero `claro` y después `oscuro`. La segunda línea no crea un enlace que mantenga ambas
variables sincronizadas. A esta consulta hecha en un momento concreto la llamaremos **lectura puntual**.

¿Y si usáramos `var` en vez de `final` para `temaAnterior`? El resultado sería el mismo: `var` permite reasignarla,
pero no hace que se actualice sola. Para que reciba el valor nuevo tendríamos que escribir
`temaAnterior = temaActual;` después del cambio.

En estos ejemplos usamos textos (`String`), que son inmutables. Con un objeto mutable, como una lista, dos variables
pueden referirse al mismo objeto y ver una modificación de su contenido. Guardar una lectura tampoco significa hacer
una copia independiente de cualquier objeto. Estudiaremos referencias e inmutabilidad en las unidades 3 y 8.

### Practica 2

Predice las tres líneas de salida y explica cuándo se obtuvo cada valor:

```dart
void main() {
  var tema = 'claro';
  final primeraLectura = tema;
  tema = 'oscuro';
  final segundaLectura = tema;
  tema = 'claro';

  print(primeraLectura);
  print(segundaLectura);
  print(tema);
}
```

<details>
<summary>Ver respuesta</summary>

```text
claro
oscuro
claro
```

La primera lectura se guardó antes del primer cambio; la segunda, después. El último `print` consulta `tema` tras la
última asignación. Ninguna asignación posterior volvió a ejecutar las dos lecturas guardadas.

</details>

## 4. ¿Cuál es la fuente de verdad?

Supongamos que guardamos por separado el tema y una etiqueta ya construida:

```dart
void main() {
  var temaActual = 'claro';
  final etiqueta = 'Tema: $temaActual';

  temaActual = 'oscuro';

  print(temaActual);
  print(etiqueta);
  print('Tema: $temaActual');
}
```

Dentro de un texto, `$temaActual` inserta el valor de la variable **cuando se construye ese texto**. Por tanto, la salida
es:

```text
oscuro
Tema: claro
Tema: oscuro
```

`etiqueta` se construyó cuando el tema era claro y conserva ese texto. La última línea construye otro texto después del
cambio. Una etiqueta antigua puede ser útil para un historial; el problema aparece si la tratamos como si siempre
describiera el tema actual.

Para saber qué tema está seleccionado en este ejemplo, tomamos `temaActual` como **fuente de verdad**: el dato que
consultamos y actualizamos para esa selección. Cuando necesitemos una etiqueta actualizada, la construiremos a partir
de una lectura actual. Así evitamos tener que mantener dos datos por separado y que se contradigan.

Esto no significa que toda la aplicación deba tener una única variable global. Una vista previa puede tener su propia
selección de tema, independiente de la selección principal. Cada selección necesita una fuente clara para su ámbito.

### Practica 3

Una pantalla guarda `tema = 'claro'` y `mensaje = 'Tema: claro'`. Después cambia solo `tema` a `'oscuro'`.
¿Qué problema aparece? ¿Cómo construirías un mensaje que refleje el valor al consultarlo?

<details>
<summary>Ver respuesta</summary>

El mensaje guardado sigue diciendo «Tema: claro», aunque el tema ya sea oscuro. Podemos construir
`'Tema: $tema'` cuando necesitemos mostrarlo: en ese momento la expresión lee el valor actual. Eso no significa que una
pantalla que ya lo mostró vuelva a construirlo por sí sola; veremos esa conexión a continuación.

</details>

## 5. Del dato a la pantalla hay un paso más

En los ejemplos anteriores nosotros decidíamos cuándo ejecutar cada `print`. ¿Qué pasa con un texto que ya está en
pantalla si después cambiamos la variable?

Imagina esta secuencia:

1. El dato contiene `'claro'`.
2. La pantalla lee ese dato y muestra «Tema: claro».
3. El dato cambia a `'oscuro'`.
4. Para mostrar «Tema: oscuro», la interfaz necesita volver a construirse usando el dato nuevo.

La asignación del paso 3 cambia el dato. Una asignación ordinaria, por sí sola, no le dice a Flutter que reconstruya
la interfaz. La pantalla podría reconstruirse por otro motivo y mostrar entonces el nuevo valor, pero no podemos
depender de que eso ocurra justo cuando nos interesa.

En un `State` de Flutter, una forma de conectar ambos pasos es `setState`:

```dart
setState(() {
  temaActual = 'oscuro';
});
```

La función que pasamos a `setState` se ejecuta inmediatamente: ahí cambia el dato. Después, `setState` solicita que
Flutter reconstruya ese `State`; en una reconstrucción posterior, `build` puede leer el valor nuevo. Más adelante
estudiaremos `State`, funciones y reconstrucción con calma. Aquí solo necesitamos separar **cambiar el dato** de
**volver a construir la interfaz**.

También existe otra necesidad: que alguien se entere de cambios futuros. Leer un dato una vez no registra por sí
solo a nadie para recibir avisos. Los listeners y las señales de las próximas unidades ofrecen mecanismos para esa
comunicación; recibir un aviso y reconstruir una pantalla siguen siendo pasos que hay que conectar.

### Practica 4

Una pantalla ya muestra «Tema: claro». El programa cambia la variable a `'oscuro'`, pero esa operación no solicita una
reconstrucción. ¿Qué valor tiene la variable? ¿Tiene garantizado el texto actualizarse en ese momento?

<details>
<summary>Ver respuesta</summary>

La variable contiene `'oscuro'`. El texto no tiene garantizada una actualización en ese momento: para mostrar el dato
nuevo, la interfaz debe volver a construirse y leerlo. Otra causa podría provocar esa reconstrucción más tarde.

</details>

## 6. La misma idea en DaisyUI

El [controlador de temas](../../../lib/themes/application/daisy_theme_controller.dart) contiene estas piezas:

```dart
DaisyThemeController({
  DaisyThemeModel initialTheme = DaisyThemes.light,
}) : _palette = ValueNotifier<DaisyThemeModel>(initialTheme);

final ValueNotifier<DaisyThemeModel> _palette;

ValueListenable<DaisyThemeModel> get theme => _palette;

void setTheme(DaisyThemeModel theme) => _palette.value = theme;
```

El constructor recibe el tema inicial y crea `_palette`, el notificador que conserva el valor actual de ese controlador.
`controller.theme.value` lo consulta; `controller.setTheme(nuevoTema)` propone otro valor. El getter `theme` devuelve el
mismo notificador con el tipo de lectura `ValueListenable`, no una copia ni un objeto adaptador.

Si guardas el resultado de una lectura y después cambias el tema, la variable guardada conserva el modelo que obtuvo
antes. Para conocer el valor actual tienes que consultar de nuevo. La unidad 7 explica cómo decide `ValueNotifier` si
acepta y notifica un cambio.

El [servicio de temas](../../../lib/themes/application/daisy_theme_service.dart) conserva un controlador predeterminado.
También puedes crear otro controlador para una selección independiente, como una vista previa.

### Practica 5

En el archivo del controlador, localiza el tema inicial, el notificador, el getter público y el método de cambio.
¿Cómo consultarías el valor actual y cómo propondrías otro?

<details>
<summary>Ver respuesta</summary>

El constructor crea `_palette` a partir de `initialTheme`. Puedes consultar `controller.theme.value` y proponer otro
valor con `controller.setTheme(nuevoTema)`, que asigna a `_palette.value`.

</details>

## Ejercicio final: tres momentos de una selección

Escribe un programa Dart completo que:

1. Empiece con el tema `'claro'` y guarde una primera lectura.
2. Cambie el tema a `'oscuro'` y guarde una segunda lectura.
3. Vuelva a cambiar el tema a `'claro'`.
4. Imprima las dos lecturas, el tema actual y una etiqueta construida con el valor actual.

Antes de ejecutarlo, escribe la salida esperada. Después explica por qué cada línea muestra ese valor. Como variación,
añade una variable para el tema de una vista previa, cambia solo la selección principal y comprueba qué conserva la
vista previa.

<details>
<summary>Ver una posible solución</summary>

```dart
void main() {
  var tema = 'claro';
  final primera = tema;

  tema = 'oscuro';
  final segunda = tema;

  tema = 'claro';

  print(primera);
  print(segunda);
  print(tema);
  print('Tema: $tema');
}
```

La salida es `claro`, `oscuro`, `claro` y `Tema: claro`, cada uno en su línea. Las dos primeras líneas conservan las
lecturas hechas en momentos distintos; las otras dos consultan el valor tras el último cambio. Si la vista previa se
guarda en otra variable y solo reasignas `tema`, la variable de la vista previa conserva su propio valor.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar. Si dudas, vuelve al apartado indicado y repite su práctica.

1. ¿Qué dato representa el estado cuando elegimos entre tema claro y oscuro? **Apartado 1.**
2. Si guardas una lectura y luego reasignas la variable original, ¿qué conserva la lectura? **Apartados 2 y 3.**
3. ¿Por qué una etiqueta construida antes del cambio puede quedar antigua? **Apartado 4.**
4. ¿Por qué cambiar el dato no garantiza actualizar inmediatamente la pantalla? **Apartado 5.**
5. ¿Dónde se conserva el tema en el controlador y cómo se consulta o cambia? **Apartado 6.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques estas respuestas con tus palabras.
La próxima unidad introduce las funciones que podremos registrar para recibir avisos.

## Para consultar si necesitas reforzar

- [Variables en Dart](https://dart.dev/language/variables): declaraciones, asignaciones y `final`.
- [Estado en Flutter](https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app): ejemplos de información
  que una interfaz necesita recordar.
- [`setState`](https://api.flutter.dev/flutter/widgets/State/setState.html): qué ocurre al ejecutar su función y cómo
  se solicita una reconstrucción.
- [Single source of truth](https://docs.flutter.dev/app-architecture/concepts#single-source-of-truth): el principio de
  mantener una fuente autorizada para un dato.
