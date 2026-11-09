# 2. Interpolación y `Tween`

[Volver al plan](../plan-de-estudio-animaciones-flutter.md) · **Estado:** pendiente

## Qué vas a aprender

Ya sabemos que una transición necesita valores intermedios. Ahora vamos a calcularlos: partiremos de dos números y veremos cómo `Tween` transforma un progreso en un valor. Al terminar podrás explicar por qué todavía necesita otra pieza para animarse.

Los fragmentos requieren los imports indicados y son ejemplos aislados, no aplicaciones completas.

## 1. Calcular un punto entre dos valores

Queremos recorrer de `0` a `4`. Llamamos **progreso normalizado** a una forma de expresar el avance en la que `0` corresponde al inicio y `1` al final. Así, `0.25` representa un cuarto del recorrido y `0.5`, la mitad.

Para interpolar linealmente dos números usamos:

```text
valor = inicio + (final - inicio) × progreso
```

Por ejemplo, con inicio `0`, final `4` y progreso `0.25`:

```text
0 + (4 - 0) × 0.25 = 1
```

No es lo mismo que el tiempo transcurrido: aquí recibimos un progreso y calculamos un valor. Cómo se obtiene ese progreso, y cómo una curva puede modificarlo, se estudia después.

### Practica

Entre `2` y `6`, ¿qué valor corresponde a `0.5`? ¿Y a `0.25`?

<details><summary>Ver respuesta</summary>

Para `0.5`: `2 + (6 - 2) × 0.5 = 4`. Para `0.25`: `2 + 4 × 0.25 = 3`.

</details>

## 2. `Tween<double>` guarda el recorrido

```dart
import 'package:flutter/animation.dart';

final recorrido = Tween<double>(begin: 0, end: 4);
final mitad = recorrido.transform(0.5); // 2.0
```

`Tween<double>` describe la transformación para valores `double`. `begin` es el valor de inicio y `end` el de final. `transform` recibe el progreso y devuelve el valor correspondiente; no espera ni dibuja nada. Por ejemplo, con progreso `0.25`, devuelve `1.0`.

Los extremos pueden ser descendentes: con `begin: 4` y `end: 0`, `transform(0.25)` devuelve `3.0`.

### Practica

¿Qué devuelve `Tween<double>(begin: 10, end: 14).transform(0.75)`?

<details><summary>Ver respuesta</summary>

Devuelve `13.0`: `10 + (14 - 10) × 0.75`. El avance es tres cuartos de la diferencia, no tres cuartos del valor final.

</details>

## 3. `lerp` y `evaluate`: dos formas de llegar al cálculo

`lerp` significa interpolación lineal. En `Tween`, es el método que calcula el valor a partir de un progreso:

```dart
final recorrido = Tween<double>(begin: 0, end: 4);
final valor = recorrido.lerp(0.5); // 2.0
```

Para convertir directamente un progreso suele ser más expresivo usar `transform`. En cambio, `evaluate` lee el valor actual de un objeto `Animation<double>` y lo transforma:

```dart
final recorrido = Tween<double>(begin: 0, end: 4);
const progreso = AlwaysStoppedAnimation<double>(0.5);
final valor = recorrido.evaluate(progreso); // 2.0
```

`AlwaysStoppedAnimation` proporciona aquí un valor fijo: sirve para observar la relación sin que pase el tiempo. `evaluate` no hace avanzar esa animación; lee su valor en el momento de la llamada. Una fuente que cambie con el tiempo y un mecanismo que vuelva a consultar el valor son necesarios para producir actualizaciones visibles.

### Practica

Si llamas dos veces a `recorrido.evaluate(progreso)` del ejemplo sin cambiar nada, ¿por qué obtienes el mismo valor?

<details><summary>Ver respuesta</summary>

Porque `progreso` siempre proporciona `0.5`. El tween transforma ese mismo progreso las dos veces: no tiene reloj propio.

</details>

## 4. Extremos nulos y tipos

`Tween<T>` permite declarar `begin` o `end` sin valor, pero eso **no garantiza que puedas interpolar con extremos nulos**. Un `Tween<double>` ordinario necesita extremos numéricos válidos al evaluar el recorrido. Algunos consumidores inicializan extremos omitidos; por ejemplo, el caso del botón explica cómo lo hace `TweenAnimationBuilder`. No extrapoles esa ayuda a una llamada independiente a `transform`.

No cualquier tipo funciona automáticamente solo por escribir `Tween<MiTipo>`. El tween genérico usa operaciones que el tipo debe soportar. Flutter ofrece tweens específicos para otros tipos; por ejemplo, `ColorTween` interpola colores con su propia lógica:

```dart
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

final colores = ColorTween(
  begin: const Color(0xFF000000),
  end: const Color(0xFFFFFFFF),
);
final inicio = colores.transform(0.0); // negro
final finalColor = colores.transform(1.0); // blanco
```

El resultado de `ColorTween` es `Color?`: sus extremos pueden ser nulos y el tipo obliga a considerar esa posibilidad. No necesitas calcular a mano el color intermedio para entender su papel: recibe progreso y produce un color interpolado.

### Practica

¿Basta crear `Tween<double>(begin: 0, end: 4)` para que la pantalla vaya cambiando? ¿Es seguro asumir que todo `Tween` con un extremo omitido puede evaluarse directamente?

<details><summary>Ver respuesta</summary>

No en ambos casos. El tween describe una transformación; necesita una fuente de progreso y algo que utilice los valores. Además, el tratamiento de extremos nulos depende del tween y del consumidor: el `Tween<double>` ordinario requiere valores válidos al calcular.

</details>

## 5. Ejercicio: un recorrido completo

Una elevación cambia linealmente de `4` a `0`. Calcula sus valores para progresos `0`, `0.25`, `0.5` y `1`. Explica qué faltaría para que el botón los mostrase con el tiempo.

<details><summary>Ver respuesta</summary>

```text
Progreso:  0      0.25     0.5      1
Elevación: 4       3        2       0
```

La fórmula es `4 + (0 - 4) × progreso`. Falta una fuente de progreso que cambie con el tiempo y una forma de aplicar sus resultados al dibujo. Un widget de animación puede encargarse de esas piezas; el `Tween` por sí solo no lo hace.

</details>

## Antes de avanzar

- ¿Qué representa `0.5` y cómo se convierte en un valor?
- ¿Qué diferencia hay entre darle un progreso a `transform` y pasar una animación a `evaluate`?
- ¿Por qué hay tweens específicos y qué debes comprobar ante un extremo nulo?

**Para profundizar:** [API de Tween](https://api.flutter.dev/flutter/animation/Tween-class.html) y [API de ColorTween](https://api.flutter.dev/flutter/animation/ColorTween-class.html), para consultar sus contratos y métodos.
