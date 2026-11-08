# 3. Duración, curvas y percepción

[Volver al plan](../plan-de-estudio-animaciones-flutter.md) · **Estado:** pendiente

## Qué vas a aprender

Dos elevaciones pueden ir de `0` a `4` y tardar lo mismo, pero sentirse distintas. En esta unidad separarás el tiempo transcurrido del avance aplicado al recorrido y aprenderás a detectar cuándo una curva puede producir valores no válidos para una propiedad.

Los cálculos son esquemas; los fragmentos con API de Flutter requieren sus imports y no son aplicaciones completas.

## 1. La duración responde a «cuánto tarda»

Para una transición de dos segundos, si transcurre un segundo, ha pasado la mitad de su duración:

```text
tiempo transcurrido / duración = 1 s / 2 s = 0.5
```

Ese `0.5` es **progreso temporal normalizado**. No significa necesariamente que el valor mostrado esté a mitad entre inicio y final. Eso solo sucede si el progreso que usamos para interpolar es también `0.5`.

Una duración más corta completa antes el recorrido; una más larga deja más tiempo para percibirlo. No hay una duración universalmente correcta: pruébala en su contexto y comprueba que el movimiento no dificulte la interacción.

### Practica

Una transición dura `400 ms`. ¿Qué progreso temporal corresponde a `100 ms`? ¿Sabes ya que una elevación de `0` a `4` mostrará `1`?

<details><summary>Ver respuesta</summary>

El progreso temporal es `100 / 400 = 0.25`. Solo será `1` si el progreso utilizado para interpolar también es `0.25`; una curva puede transformarlo.

</details>

## 2. La curva responde a «cómo se reparte el avance»

Piensa en la curva como una función que recibe progreso temporal y devuelve **progreso transformado**. Después, el tween convierte ese resultado en el valor de la propiedad:

```text
tiempo → progreso temporal → curva → progreso transformado → tween → elevación
```

Con una curva lineal, la salida coincide con la entrada. Para `0 → 4`, a mitad de tiempo:

```text
0.5 → curva lineal → 0.5 → 0 + (4 - 0) × 0.5 = 2
```

Con otra curva, a ese mismo instante la salida podría ser, por ejemplo, `0.75`:

```text
0.5 → curva de ejemplo → 0.75 → 0 + (4 - 0) × 0.75 = 3
```

El `0.75` es un ejemplo inventado para entender el cálculo, no el valor de una curva concreta. Ambas transiciones tienen el mismo inicio, final y duración, pero a mitad de tiempo muestran valores diferentes.

### Practica

Una curva devuelve `0.2` cuando ha transcurrido la mitad del tiempo. Para un recorrido de `2` a `6`, ¿qué valor muestra la interpolación lineal?

<details><summary>Ver respuesta</summary>

Muestra `2 + (6 - 2) × 0.2 = 2.8`. Ha pasado la mitad del tiempo, pero solo se aplica un quinto del recorrido.

</details>

## 3. Curvas habituales en Flutter

Flutter proporciona objetos `Curve` y una colección de curvas en `Curves`:

```dart
import 'package:flutter/animation.dart';

final progreso = Curves.easeIn.transform(0.5);
final elevacion = Tween<double>(begin: 0, end: 4).transform(progreso);
```

Este fragmento calcula un valor para un instante; no anima por sí solo. `transform` de la curva convierte el progreso temporal; `transform` del tween convierte el resultado en elevación.

- `Curves.linear`: avance uniforme.
- `Curves.easeIn`: comienza lentamente y acelera.
- `Curves.easeOut`: comienza rápido y desacelera al llegar.
- `Curves.easeInOut`: comienza y termina lentamente, avanzando más deprisa en medio.
- `Curves.bounceOut`: introduce rebotes hacia el final; su avance no es uniforme ni necesariamente siempre creciente.

Estas descripciones ayudan a elegir una primera candidata, no sustituyen verla en acción. Por ejemplo, una respuesta rápida al pasar el ratón puede necesitar una sensación distinta a una transición larga entre pantallas.

### Practica

Quieres que un elemento parezca desacelerar al llegar. ¿Qué curva probarías primero? ¿Cambiar de curva cambia automáticamente la duración configurada?

<details><summary>Ver respuesta</summary>

Probaría `Curves.easeOut`: desacelera hacia el final. Cambiar la curva modifica el reparto del avance, no la duración configurada. Ambas decisiones se pueden ajustar por separado.

</details>

## 4. Sobrepasar el intervalo y respetar la propiedad

Algunas curvas, como `Curves.elasticOut`, pueden devolver valores por encima de `1` durante el recorrido. Una salida de `1.1` aplicada linealmente a `0 → 4` daría `4.4`: se sobrepasa el destino antes de terminar. Otras curvas pueden producir valores por debajo de `0`.

Eso puede ser expresivo para una posición, pero no toda propiedad admite cualquier número. Por ejemplo, `Opacity.opacity` exige un valor entre `0.0` y `1.0`, y `Material.elevation` no admite elevación negativa. Antes de elegir una curva, comprueba su salida y el contrato de la propiedad que recibe el valor.

Limitar el resultado al rango permitido puede evitar valores inválidos, pero también recorta el sobrepaso y cambia la forma percibida de la animación. Otra opción es elegir una curva que permanezca dentro del rango; decide según el efecto buscado.

### Practica

Una curva entrega `-0.1` a un tween de elevación `0 → 4`. ¿Qué valor resulta? ¿Puedes pasarlo sin más a `Material.elevation`?

<details><summary>Ver respuesta</summary>

Resulta `0 + 4 × -0.1 = -0.4`. No: `Material.elevation` no admite valores negativos. Hay que elegir o adaptar el recorrido teniendo en cuenta ese contrato.

</details>

## 5. Ejercicio: compara dos recorridos

Ambas transiciones van de `0` a `4` en `400 ms`. A los `100 ms`, la primera usa progreso lineal; la segunda transforma el progreso temporal `0.25` en `0.1`. Calcula ambos valores y explica qué cambia y qué no cambia.

<details><summary>Ver respuesta</summary>

La primera muestra `1` (`4 × 0.25`); la segunda, `0.4` (`4 × 0.1`). Ambas tienen el mismo inicio, destino y duración configurada. Cambia cómo se reparte el avance: en ese instante la segunda ha recorrido menos distancia. El `0.1` es un dato hipotético, no una afirmación sobre una curva específica de Flutter.

</details>

## 6. Experimenta con las curvas

Este es un programa completo e independiente. Crea un proyecto Flutter de prueba con `flutter create curvas_demo`, sustituye el contenido de su `lib/main.dart` por el siguiente código y ejecuta `flutter run` desde ese proyecto. No necesitas modificar DaisyUI.

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: CurvasDemo()));

class CurvasDemo extends StatefulWidget {
  const CurvasDemo({super.key});

  @override
  State<CurvasDemo> createState() => _CurvasDemoState();
}

class _CurvasDemoState extends State<CurvasDemo> {
  bool derecha = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Curvas')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            pista('linear', Curves.linear),
            pista('easeIn', Curves.easeIn),
            pista('easeOut', Curves.easeOut),
            pista('bounceOut', Curves.bounceOut),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => derecha = !derecha),
              child: const Text('Cambiar destino'),
            ),
          ],
        ),
      ),
    );
  }

  Widget pista(String nombre, Curve curva) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nombre),
        AnimatedAlign(
          alignment: derecha ? Alignment.centerRight : Alignment.centerLeft,
          duration: const Duration(seconds: 2),
          curve: curva,
          child: const Icon(Icons.circle, size: 24),
        ),
      ],
    );
  }
}
```

Al pulsar el botón, los cuatro círculos se desplazan a la derecha durante dos segundos, cada uno con su curva. Al pulsarlo de nuevo van a la izquierda. `derecha` guarda el destino; `setState` solicita reconstruir la interfaz y `AnimatedAlign` anima el cambio de `alignment`. El mismo método `pista` recibe una curva diferente para cada fila. La animación implícita se estudiará con más detalle en el bloque siguiente.

**Prueba:** pulsa el botón y vuelve a pulsarlo antes de que terminen. Observa el cambio de dirección; después cambia la duración a un segundo y compara. ¿Cambiar la duración ha cambiado la curva elegida?

<details><summary>Ver respuesta</summary>

No: cada fila sigue recibiendo la misma curva. Al reducir la duración se completa antes el recorrido, pero cada curva sigue determinando cómo se reparte su avance. Al cambiar el destino durante el movimiento, `AnimatedAlign` redirige desde la posición que está mostrando, sin esperar a llegar al destino anterior.

</details>

## Antes de avanzar

- ¿Puedes distinguir progreso temporal, progreso transformado y valor interpolado?
- ¿Por qué dos transiciones de igual duración pueden mostrar valores distintos en el mismo instante?
- ¿Qué comprobarías antes de aplicar una curva elástica a una propiedad restringida?

**Para profundizar:** [API de Curves](https://api.flutter.dev/flutter/animation/Curves-class.html) muestra las curvas disponibles; [Opacity](https://api.flutter.dev/flutter/widgets/Opacity/opacity.html) y [Material.elevation](https://api.flutter.dev/flutter/material/Material/elevation.html) documentan las restricciones de esas propiedades.
