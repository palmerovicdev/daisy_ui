# Caso de partida: la elevación del botón de DaisyUI

[Volver al plan de animaciones](../plan-de-estudio-animaciones-flutter.md) · **Estado:** pendiente

## Qué vas a aprender

Al colocar el ratón sobre el botón de DaisyUI, su elevación puede pasar de `0` a `4`. Cuando lo pulsas, puede volver a `0`. El código que lo anima parece extraño:

```dart
Tween(begin: elevation, end: elevation)
```

Si el inicio y el final son iguales, ¿de dónde salen los valores intermedios? Al terminar podrás explicar la primera aparición del botón, los cambios posteriores, qué sucede cuando una animación se interrumpe y qué papel cumplen `TweenAnimationBuilder`, `InkWell` y `Material`.

Este caso es una puerta de entrada al plan: presenta las ideas necesarias para entender el botón sin asumir que ya has estudiado controladores o curvas en profundidad. Los fragmentos aislados no son programas completos; en el apartado 7 encontrarás un ejemplo independiente para ejecutar.

## 1. Cambiar un valor no es lo mismo que animarlo

Imagina que una propiedad empieza con valor `0` y queremos que llegue a `4`.

```text
Cambio instantáneo:       0 → 4
Cambio a lo largo del tiempo:  0 → valores intermedios → 4
```

En el segundo caso, el valor que se muestra va cambiando durante un tiempo. El **destino** es `4`; el **valor actual** es el que se está mostrando en un instante concreto y puede ser, por ejemplo, `2.5`.

En Flutter, cambiar una variable dentro de `setState` solicita una reconstrucción. Eso no crea por sí mismo los valores intermedios: necesitamos una herramienta de animación para producirlos.

### Practica 1

Si un botón está mostrando elevación `2.5` y se está animando hacia `4`, ¿cuál es el valor actual y cuál el destino?

<details>
<summary>Ver respuesta</summary>

El valor actual es `2.5`; el destino es `4`. La animación puede seguir generando valores hasta llegar al destino, a menos que se cambie o interrumpa antes.

</details>

## 2. Qué aporta un `Tween`

Este fragmento describe un recorrido entre dos números:

```dart
final recorrido = Tween<double>(begin: 0, end: 4);
```

`Tween<double>` representa valores de tipo `double`; `begin` es el inicio y `end` el final. Si el avance fuera lineal, podríamos imaginar:

```text
Progreso:     0 %          50 %          100 %
Valor:         0     →       2      →       4
```

El cálculo de un valor entre otros dos se llama **interpolación**. El `Tween` sabe calcular ese valor para un progreso dado, pero no hace que pase el tiempo por sí solo. Otra pieza debe llevar el progreso hacia delante y pedir los valores correspondientes. En este botón se ocupa de ello `TweenAnimationBuilder`.

### Practica 2

Con un recorrido lineal de `2` a `6`, ¿qué valor corresponde al progreso del 50 %? ¿El `Tween` avanza solo con el tiempo?

<details>
<summary>Ver respuesta</summary>

El valor es `4`, a mitad entre `2` y `6`. El `Tween` no avanza solo: necesita una animación u otra fuente que le proporcione el progreso.

</details>

## 3. Por qué `begin` y `end` coinciden

En [DaisyButton](../../../lib/themes/presentation/action/button.dart), el widget se construye con:

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: elevation, end: elevation),
  // ...
)
```

Supongamos que al aparecer el botón `elevation` es `0`:

```dart
Tween(begin: 0, end: 0)
```

En la **primera construcción**, `TweenAnimationBuilder` usa esos valores como inicio y final. Como coinciden, no hay transición inicial visible: el botón aparece con elevación `0`.

Ahora entra el ratón y el objetivo pasa a ser `4`. Al reconstruirse el botón se proporciona un nuevo tween equivalente a:

```dart
Tween(begin: 4, end: 4)
```

El resultado puede parecer sorprendente: **sí se anima de `0` a `4`**. El `TweenAnimationBuilder` ya existente conserva internamente la información de la animación. Cuando recibe un `end` diferente:

1. Toma el valor que está mostrando en ese momento: en este ejemplo, `0`.
2. Usa el nuevo `end`, `4`, como destino.
3. Inicia una transición desde el valor actual hasta ese destino.

El `begin` del nuevo tween se ignora para esta actualización. Esto funciona mientras Flutter conserve el mismo estado del `TweenAnimationBuilder`, como ocurre en el caso habitual de este botón. Si se elimina y se vuelve a insertar o cambia su identidad, hay una nueva primera construcción; estudiaremos esa identidad en la unidad 4 del plan.

```text
Primera construcción:  begin 0, end 0 → aparece en 0
Nuevo destino:         end 4          → anima desde el valor actual a 4
Nuevo destino:         end 0          → anima desde el valor actual a 0
```

Si se cambia el destino antes de terminar, se parte del valor actual. Por ejemplo, si el ratón sale cuando se muestra `2.5`, la nueva transición va de `2.5` a `0`; no espera a alcanzar `4`.

En este caso también se podría escribir:

```dart
tween: Tween<double>(end: elevation),
```

Cuando el `begin` inicial es `null`, `TweenAnimationBuilder` lo inicializa con el valor de `end`. En actualizaciones posteriores mantiene el comportamiento de partir del valor actual hacia el nuevo destino. En ambos casos el widget toma posesión del tween que se le entrega y puede modificarlo, por lo que no debemos guardar esa instancia para modificarla desde fuera.

### Practica 3

El botón aparece con `elevation = 4`. Después, cuando la animación ya muestra `2.5` en dirección a `0`, el destino cambia a `4`. ¿Qué ocurre en cada momento?

<details>
<summary>Ver respuesta</summary>

Al aparecer, `begin` y `end` son `4`, por lo que aparece en `4` sin transición inicial visible. Más tarde, al recibir `4` como nuevo destino mientras muestra `2.5`, inicia una transición desde `2.5` hasta `4`.

</details>

## 4. Cómo decide DaisyUI la elevación objetivo

El código real calcula `elevation` antes de construir la animación:

```dart
final elevation = _isPressed
    ? widget.theme?.pressedElevation ?? 0
    : _isHovering
    ? widget.theme?.hoverElevation ?? widget.theme?.elevation ?? 0
    : widget.theme?.elevation ?? 0;
```

El operador `condición ? valorSiEsCierta : valorSiEsFalsa` elige entre dos expresiones. Aquí hay dos condiciones encadenadas. Se puede leer así:

1. Si el botón está pulsado, usar `pressedElevation` o, si no hay valor, `0`.
2. Si no está pulsado y el ratón está encima, usar `hoverElevation`; si no está disponible, `elevation`; y, como último recurso, `0`.
3. En los demás casos, usar `elevation` o `0`.

`??` significa «si el valor de la izquierda es `null`, usa el de la derecha». El acceso `?.` permite que `theme` sea `null` sin intentar acceder a su propiedad en ese caso.

Los valores por defecto de [DaisyButtonTheme](../../../lib/themes/domain/button_theme.dart) son:

```dart
elevation: 0,
hoverElevation: 4,
pressedElevation: 0,
```

Así, con el tema predeterminado, el destino habitual es `0` en reposo, `4` con el ratón encima y `0` al pulsar. **Pulsado tiene prioridad sobre hover**, porque se comprueba primero. Son valores configurables, no una obligación de todos los temas.

### Practica 4

Con el tema predeterminado, el ratón está encima y además el botón está pulsado. ¿Cuál es el destino? ¿Y al soltar sin mover el ratón?

<details>
<summary>Ver respuesta</summary>

Mientras está pulsado, el destino es `pressedElevation`, que vale `0`. Al soltar, si sigue activo el estado hover, el destino pasa a `hoverElevation`, que vale `4`.

</details>

## 5. De la interacción al nuevo destino

`InkWell` detecta la interacción. Estos son fragmentos del botón real:

```dart
onHighlightChanged: _isEnabled ? _setPressed : null,

onHover: _isEnabled
    ? (value) {
        setState(() => _isHovering = value);
        widget.onHover?.call(value);
      }
    : null,
```

Cuando entra el ratón, `onHover` recibe `true` y `setState` actualiza `_isHovering`. Flutter vuelve a ejecutar `build`, donde se calcula otra elevación objetivo. El `TweenAnimationBuilder` conservado recibe ese destino y produce los valores de la transición.

El método que recibe los cambios de pulsación sigue la misma idea:

```dart
void _setPressed(bool value) {
  if (_isPressed != value) {
    setState(() => _isPressed = value);
  }
}
```

La condición evita llamar a `setState` si `_isPressed` ya tiene ese valor. El botón está habilitado solo si `widget.enabled` es verdadero y existe `onPressed` u `onLongPress`. Cuando deja de estar habilitado, su `didUpdateWidget` limpia `_isHovering` y `_isPressed`.

La cadena completa es:

```text
Interacción → InkWell → setState → build → nuevo destino
            → TweenAnimationBuilder → valores intermedios → Material
```

### Practica 5

¿Quién decide que el destino para hover sea `4`: `InkWell`, `TweenAnimationBuilder` o la lógica del botón junto con su tema?

<details>
<summary>Ver respuesta</summary>

La lógica del botón consulta el tema y decide el destino. `InkWell` informa de la interacción; `TweenAnimationBuilder` anima hacia el destino recibido.

</details>

## 6. Leer el bloque de animación

Este es el bloque real, con el contenido del `InkWell` resumido:

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: elevation, end: elevation),
  duration: const Duration(milliseconds: 50),
  curve: Curves.easeOut,
  builder: (context, value, child) => Material(
    color: Colors.transparent,
    shape: shape,
    elevation: value,
    animationDuration: Duration.zero,
    child: child,
  ),
  child: InkWell(
    // Interacciones y contenido del botón.
  ),
)
```

- **`TweenAnimationBuilder<double>`:** administra una animación implícita que entrega números `double`. El código del botón no necesita crear ni liberar un controlador de animación propio.
- **`tween`:** su `end` indica el destino. Al cambiar ese destino, el widget inicia una transición desde el valor actual.
- **`duration`:** cada nueva transición tiene una duración configurada de `50` milisegundos, es decir, `0,05` segundos.
- **`curve`:** `Curves.easeOut` hace que el avance comience más rápido y se suavice cerca del destino. Por eso, a mitad del tiempo no tenemos por qué estar justo a mitad entre los dos valores.
- **`builder`:** Flutter lo llama con el `value` correspondiente a cada actualización de la animación. Aquí crea un `Material` cuya `elevation` es ese valor.
- **`Material`:** aplica la elevación y puede mostrar la sombra asociada. La propiedad no desplaza ni escala el botón por sí misma. `shape` define su forma y `color` se establece como transparente.
- **`animationDuration: Duration.zero`:** `Material` dispone de animación interna para cambios de algunas propiedades. La duración cero hace que aplique inmediatamente los valores recibidos; la transición de elevación la dirige el `TweenAnimationBuilder` exterior.
- **`child`:** el `InkWell` se pasa al constructor y el `builder` lo incorpora al `Material`. Así se reutiliza ese subárbol durante los fotogramas de esta animación. El `build` del botón padre sí puede proporcionar un nuevo hijo cuando cambia su estado.

### Practica 6

Si cambias `duration` a `500` milisegundos, ¿cambia el destino de elevación? ¿Y si el padre reconstruye con el mismo destino, se inicia una nueva transición por ese solo motivo?

<details>
<summary>Ver respuesta</summary>

No cambia el destino: cada nueva transición se configura para durar medio segundo. Si el destino no cambia, una reconstrucción por sí sola no inicia una transición nueva en ese `TweenAnimationBuilder` conservado.

</details>

## 7. Ejemplo completo para experimentar

Copia este programa en [DartPad](https://dartpad.dev/), selecciona **Flutter** y pulsa **Run**. Usa el botón para alternar el destino entre `0` y `4`. La duración es de dos segundos para que puedas observarla; la del botón real es de `50` milisegundos. Este ejemplo usa solo Flutter y no modifica DaisyUI.

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: EjemploElevacion()));

class EjemploElevacion extends StatefulWidget {
  const EjemploElevacion({super.key});

  @override
  State<EjemploElevacion> createState() => _EjemploElevacionState();
}

class _EjemploElevacionState extends State<EjemploElevacion> {
  double destino = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elevación animada')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: destino, end: destino),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Valor actual: ${value.toStringAsFixed(2)}'),
                    const SizedBox(height: 24),
                    Material(
                      color: Colors.blue.shade100,
                      elevation: value,
                      animationDuration: Duration.zero,
                      child: child,
                    ),
                  ],
                );
              },
              child: const SizedBox(
                width: 160,
                height: 80,
                child: Center(child: Text('Observa mi sombra')),
              ),
            ),
            const SizedBox(height: 24),
            Text('Destino: ${destino.toStringAsFixed(0)}'),
            FilledButton(
              onPressed: () {
                setState(() => destino = destino == 0 ? 4 : 0);
              },
              child: const Text('Cambiar destino'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Resultado esperado:** al abrir, el valor actual y el destino son `0`. Al pulsar «Cambiar destino», el destino pasa inmediatamente a `4` y el valor actual cambia gradualmente hasta alcanzarlo. Si vuelves a pulsar antes de terminar, el destino pasa a `0` y el valor actual comienza a volver desde donde se encontraba. Los valores exactos visibles dependen del instante de cada fotograma.

El ejemplo añade un `Text` dentro del `builder` para ver `value`; el botón real pasa ese valor directamente a `Material.elevation`. `toStringAsFixed(2)` solo limita a dos los decimales que se muestran. El botón exterior modifica `destino` mediante `setState`; no es el mismo mecanismo de hover y pulsación que usa `InkWell` en DaisyUI.

### Practica 7

En el ejemplo, cambia el tween a `Tween<double>(begin: 0, end: destino)`. Si el programa comienza con `destino = 0` y después pulsas para subir, ¿cambia el punto de inicio de esa actualización a causa del `begin: 0` nuevo?

<details>
<summary>Ver respuesta</summary>

No. Durante una actualización del mismo `TweenAnimationBuilder`, el nuevo `begin` se ignora y la transición parte del valor actual. En este primer cambio el valor actual también es `0`, por lo que el resultado parece coincidir. Pulsa de nuevo a mitad de transición: la vuelta empieza desde el valor actual, no desde el `begin: 0` recién escrito.

</details>

## 8. Ejercicio final

Con los valores por defecto del tema, sigue esta secuencia:

1. El botón aparece en reposo.
2. El ratón entra y esperas a que termine la transición.
3. Pulsas sin mover el ratón y esperas.
4. Sueltas sin mover el ratón.
5. El ratón sale mientras la elevación mostrada es `2.5`.

Para cada paso, identifica el destino y, si lo hay, el inicio de la transición. ¿Qué pieza ha decidido el destino y qué pieza proporciona los valores intermedios?

<details>
<summary>Ver respuesta</summary>

1. Aparece en `0`, sin cambio inicial visible: inicio y destino coinciden.
2. El destino pasa a `4` y la transición empieza en `0`.
3. El destino pasa a `0` y la transición empieza en `4`; pulsado tiene prioridad sobre hover.
4. El destino vuelve a `4` y la transición empieza en `0`.
5. El destino pasa a `0` y la nueva transición empieza desde el valor que se mostraba, `2.5`.

El botón calcula el destino a partir de sus estados y su tema. `TweenAnimationBuilder` administra la transición y entrega cada valor al `builder`, que lo aplica al `Material`.

</details>

## Comprueba si puedes continuar

- ¿Puedes explicar por qué el primer `begin` importa, pero el de un tween entregado en una actualización se ignora?
- ¿Puedes diferenciar el destino `elevation` del `value` que se muestra durante la transición?
- ¿Puedes seguir la interacción desde `InkWell` hasta `Material`?
- ¿Puedes explicar qué ocurre si el destino cambia antes de que termine el recorrido?

Después, vuelve al [plan](../plan-de-estudio-animaciones-flutter.md) y empieza por la unidad 1 para estudiar estas ideas desde sus bases.

## Para ampliar

- [`TweenAnimationBuilder`](https://api.flutter.dev/flutter/widgets/TweenAnimationBuilder-class.html): comportamiento de `begin` y `end`, cambios de destino y propiedad del tween.
- [`Tween`](https://api.flutter.dev/flutter/animation/Tween-class.html): interpolación y relación con `Animation`.
- [`Material.elevation`](https://api.flutter.dev/flutter/material/Material/elevation.html): significado de la elevación en `Material`.

La explicación del proyecto y el comportamiento de `TweenAnimationBuilder` se contrastaron mediante lectura del código de DaisyUI y del SDK de Flutter configurado en el proyecto. El ejemplo de esta guía está preparado para ejecutarse en DartPad; la lectura del código no equivale a una comprobación visual en un dispositivo.
