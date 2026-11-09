# 1. Estado, tiempo y valores intermedios

[Volver al plan](../plan-de-estudio-animaciones-flutter.md) · **Estado:** pendiente

## Qué vas a aprender

Un botón tiene elevación `0` y, al pasar el ratón por encima, debe llegar a `4`. Al terminar esta unidad podrás distinguir el valor que se ve, el destino y el tiempo que tarda en alcanzarlo, incluso si el destino cambia antes de terminar.

Los ejemplos de esta unidad son esquemas: no son programas ejecutables. Los valores intermedios son ilustrativos, no una promesa de que Flutter dibujará exactamente esos números.

## 1. Primero, un cambio instantáneo

Imagina que una variable `elevation` vale `0` y la cambiamos a `4`:

```dart
setState(() {
  elevation = 4;
});
```

`setState` comunica a Flutter que el estado ha cambiado y solicita una reconstrucción. Si el widget construido utiliza directamente `elevation`, su nueva configuración recibe `4`. **Ese cambio por sí solo no genera una secuencia de elevaciones intermedias.**

```text
Antes: elevation = 0
Cambio: elevation = 4
Nueva configuración: elevation = 4
```

Una herramienta de animación puede tomar ese nuevo valor como destino y producir los valores de la transición. El cambio de estado y la animación son cosas relacionadas, pero no son lo mismo.

### Practica

Si sustituyes `4` por `8` dentro de `setState`, ¿has indicado cuánto debe durar la transición?

<details><summary>Ver respuesta</summary>

No. Has cambiado el valor y solicitado una reconstrucción. No has indicado duración ni quién debe calcular valores intermedios.

</details>

## 2. Un destino no es el valor que se muestra ahora

Supongamos que una herramienta anima la elevación de `0` a `4` durante un segundo:

```text
Tiempo:             0 s       0,25 s       0,5 s       0,75 s       1 s
Valor ilustrativo:   0    →      1     →      2    →      3     →    4
Destino:             4           4            4           4          4
```

- **Estado inicial:** el valor desde el que comienza esta transición, aquí `0`.
- **Destino u objetivo:** el valor al que queremos llegar, aquí `4`.
- **Valor actual:** el valor calculado para un instante de la transición; a los `0,5 s`, en este ejemplo, es `2`.
- **Duración:** el tiempo previsto para completar esa transición, aquí un segundo.

La tabla supone avance uniforme para facilitar la cuenta. El destino puede ser `4` aunque todavía se esté mostrando `2`. En la unidad 3 veremos que no todas las transiciones avanzan uniformemente.

### Practica

Durante una transición hacia `4`, el botón muestra elevación `1,5`. ¿Cuál es el valor actual? ¿Ya ha llegado al destino?

<details><summary>Ver respuesta</summary>

El valor actual es `1,5` y el destino es `4`. Todavía no ha llegado a ese destino, aunque el estado que lo solicita ya pueda contener `4`.

</details>

## 3. Fotogramas: imágenes en distintos instantes

La pantalla muestra una sucesión de imágenes llamadas **fotogramas**. Mientras una animación está activa, Flutter puede calcular un valor correspondiente al tiempo transcurrido y dibujar con él el siguiente fotograma.

No hay que imaginar que Flutter muestra obligatoriamente `1`, `2` y `3`: los instantes de los fotogramas dependen de la cadencia disponible y de si se pueden preparar a tiempo. Puede haber saltos entre valores; lo importante es la relación entre tiempo y valor que se muestra.

### Practica

¿Una transición de `0` a `4` necesita mostrar exactamente `1`, `2` y `3` para ser una animación?

<details><summary>Ver respuesta</summary>

No. Son puntos útiles para imaginar el recorrido, pero los fotogramas pueden corresponder a otros instantes y valores.

</details>

## 4. Cambiar de idea durante el recorrido

Supongamos que el destino cambia de `4` a `0` cuando se muestra `2`. Para una herramienta que redirige la transición desde el valor actual, el recorrido sería:

```text
Primera transición:  0 ─────→ 2 ─ ─ ─→ 4
                               destino cambia aquí
Nueva transición:              2 ─────→ 0
```

El `4` deja de ser el destino; no hace falta alcanzarlo antes de volver. El nuevo inicio es el valor visible en el momento del cambio, no necesariamente el inicio original. **Esto describe el comportamiento de una herramienta concreta de redirección, no una regla automática de cualquier animación.** En el [caso del botón](00-elevacion-boton-daisy-ui.md) verás cómo lo hace `TweenAnimationBuilder`.

### Practica

Si el destino cambia a `0` cuando se muestra `2,5`, y la herramienta parte del valor actual, ¿desde dónde empieza el nuevo recorrido? ¿Tiene que pasar antes por `4`?

<details><summary>Ver respuesta</summary>

Parte de `2,5` hacia `0`. No tiene que pasar por `4`: ese era el destino anterior y fue sustituido.

</details>

## 5. Ejercicio: cuenta la historia completa

Una elevación parte de `0`, apunta a `4` durante un segundo y, a mitad de una transición uniforme, cambia su destino a `0`. La herramienta inicia otra transición desde el valor actual. Dibuja ambos recorridos e identifica valor actual y destino justo antes y después del cambio. ¿Qué papel cumple `setState` si se usa para cambiar el destino?

<details><summary>Ver respuesta</summary>

```text
0 → 2 → 0
    ↑ cambia el destino de 4 a 0
```

Justo antes del cambio, el valor actual es `2` y el destino `4`. Después, el valor actual sigue siendo `2`, pero el destino pasa a `0`. `setState` puede comunicar el nuevo destino y solicitar la reconstrucción; la herramienta de animación es la que debe producir la transición. No podemos deducir la duración de la segunda transición sin conocer su configuración.

</details>

## Antes de avanzar

- ¿Puedes señalar el valor actual sin confundirlo con el destino?
- ¿Por qué `setState` no basta para producir una transición?
- ¿Qué información necesitas para saber cómo se comporta una transición interrumpida?

**Para profundizar:** [Animaciones de Flutter: introducción](https://docs.flutter.dev/ui/animations) presenta las piezas generales; no necesitas estudiarlas todas antes de seguir.
