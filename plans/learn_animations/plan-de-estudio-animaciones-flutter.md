# Plan de estudio: animaciones en Flutter y DaisyUI

## Objetivo

Aprender a leer, diseñar, implementar, probar y depurar animaciones de Flutter, desde un cambio sencillo de elevación hasta movimientos coordinados con control explícito. El recorrido empieza por los conceptos que permiten entender el botón de DaisyUI y continúa hasta el ciclo de vida, las pruebas, el rendimiento y la accesibilidad.

Cada unidad puede ocupar varias sesiones. El plan es un mapa de lo que estudiaremos: **solo están desarrolladas las guías que tienen enlace**. No se da por dominada ninguna unidad por el hecho de estar enumerada aquí.

## Cómo estudiar

1. Lee primero el caso del botón si quieres resolver la duda que motivó el plan; después sigue las unidades en orden. El caso adelanta algunos términos que se explicarán con más detalle en el recorrido.
2. En cada unidad identifica el problema, sigue un ejemplo pequeño, predice el resultado y resuelve las prácticas antes de abrir las respuestas.
3. Distingue lo que cambia en los datos, quién produce los valores intermedios y qué widget los dibuja. Un cambio de estado no implica por sí solo una animación.
4. Ejecuta los ejemplos completos cuando se proporcione una guía; prueba también a interrumpir una transición antes de que termine.
5. Marca una unidad como dominada solo cuando puedas explicar y aplicar sus criterios. Las casillas reflejan tu propio progreso.

**Conocimientos previos:** variables, funciones y callbacks de Dart; `Widget`, `StatefulWidget`, `build` y `setState`. Si necesitas repasar estado y ciclo de vida, consulta el [plan de reactividad](../learn_states/plan-de-estudio-reactividad-daisy-ui.md), especialmente sus unidades sobre estado, callbacks y propiedad de recursos. Los conceptos específicos de animación se introducen en este plan.

## Caso de partida: elevación del botón

[Guía: por qué `begin` y `end` son iguales y cómo se anima la elevación](temarios/00-elevacion-boton-daisy-ui.md). Sigue el recorrido desde `InkWell` hasta `Material`, incluye prácticas y un ejemplo completo para experimentar.

## Bloque 1. Qué es una animación

### 1. Estado, tiempo y valores intermedios

- **Conceptos:** estado inicial y destino, cambio instantáneo, transición, duración, fotograma y valor actual.
- **Comprender:** una animación representa valores a lo largo del tiempo; el destino puede cambiar mientras se está llegando a él.
- **Práctica:** describir y dibujar el recorrido de `0` a `4` y qué sucede si vuelve a `0` a mitad.
- [ ] **Dominado cuando:** distingues valor actual, valor objetivo y avance temporal sin confundir `setState` con la animación.

### 2. Interpolación y `Tween`

- **Conceptos:** interpolación, progreso normalizado, `begin`, `end`, `Tween<T>`, `lerp`, `evaluate`, valores nulos y tipos interpolables.
- **Comprender:** un `Tween` transforma un progreso en un valor; por sí solo no hace avanzar el tiempo. Los tipos concretos pueden necesitar tweens específicos.
- **Práctica:** calcular valores lineales entre dos números y explorar `ColorTween`.
- [ ] **Dominado cuando:** puedes explicar qué aporta el `Tween` y qué otra pieza necesita para animarse.

### 3. Duración, curvas y percepción

- **Conceptos:** duración, progreso temporal frente a progreso transformado, `Curve`, `Curves.linear`, `easeIn`, `easeOut`, `easeInOut`, curvas con rebote y posibles valores fuera del intervalo.
- **Comprender:** la curva cambia cómo se reparte el avance en el tiempo; algunas curvas pueden sobrepasar los límites esperados y ciertas propiedades restringen sus valores.
- **Práctica:** comparar el mismo cambio con varias curvas y explicar por qué a mitad de tiempo no siempre se obtiene el punto medio.
- [ ] **Dominado cuando:** eliges una curva y duración coherentes y detectas si el valor resultante es válido para la propiedad.

## Bloque 2. Animaciones implícitas

### 4. Rebuild, identidad y estado conservado

- **Conceptos:** configuración `Widget`, elemento, `State`, identidad por tipo, posición y clave; `build`, `setState` y actualización frente a sustitución.
- **Comprender:** reconstruir una configuración no significa necesariamente crear de nuevo el estado de la animación; cambiar la identidad puede reiniciarla.
- **Práctica:** comparar una actualización con la sustitución mediante una clave distinta.
- [ ] **Dominado cuando:** explicas por qué el botón puede recordar el valor anterior entre reconstrucciones.

### 5. Widgets implícitos habituales

- **Conceptos:** `ImplicitlyAnimatedWidget`, `AnimatedContainer`, `AnimatedOpacity`, `AnimatedPadding`, `AnimatedAlign`, `AnimatedPositioned` y sus restricciones de uso.
- **Comprender:** cada widget anima las propiedades que soporta cuando cambian sus valores; no todas las propiedades ni todos los cambios de árbol se interpolan.
- **Práctica:** animar tamaño, color y margen con un estado y reconocer qué sucede si el valor objetivo no cambia.
- [ ] **Dominado cuando:** eliges un widget implícito adecuado y puedes identificar duración, curva y destino.

### 6. `TweenAnimationBuilder` en profundidad

- **Conceptos:** `tween`, `builder`, `value`, `child`, `onEnd`, propiedad del tween, primera construcción, nuevo `end` y retargeting.
- **Comprender:** en la primera construcción se utiliza `begin`; en actualizaciones posteriores se parte del valor actual hacia el nuevo `end`. Flutter toma posesión y puede modificar el tween entregado.
- **Práctica:** reproducir el caso de elevación, interrumpirlo y comparar `Tween(begin: x, end: x)` con `Tween(end: x)`.
- [ ] **Dominado cuando:** puedes seguir la transición completa y explicar por qué reconstruir el padre no la reinicia necesariamente.

### 7. Cambios de hijo y transiciones de entrada y salida

- **Conceptos:** `AnimatedSwitcher`, `AnimatedCrossFade`, claves, transición de entrada y salida, identidad de hijos y `transitionBuilder`.
- **Comprender:** cambiar propiedades del mismo hijo y sustituir un hijo son problemas distintos; la identidad afecta a si Flutter considera que hay sustitución.
- **Práctica:** alternar dos textos y observar qué cambia al proporcionar claves.
- [ ] **Dominado cuando:** puedes explicar por qué un cambio de contenido puede no disparar la transición esperada.

### 8. Fin de animación y cambios rápidos

- **Conceptos:** `onEnd`, destino igual o diferente, interrupción, reversión y encadenamiento de acciones.
- **Comprender:** una interacción nueva puede reemplazar un destino anterior; no hay que asumir que cada destino interrumpido producirá una finalización independiente.
- **Práctica:** cambiar repetidamente el destino antes de terminar y registrar las finalizaciones observadas.
- [ ] **Dominado cuando:** puedes razonar sobre transiciones interrumpidas sin depender de que cada interacción llegue al final.

## Bloque 3. Animaciones explícitas

### 9. `Animation<T>` y escucha de valores

- **Conceptos:** `Animation<T>`, `value`, `status`, `Listenable`, listeners de valor y de estado; estados `dismissed`, `forward`, `reverse` y `completed`.
- **Comprender:** una animación expone un valor y avisos; distinguir el progreso de su dirección y sus límites.
- **Práctica:** observar valores y cambios de estado en una transición controlada.
- [ ] **Dominado cuando:** sabes qué información ofrece cada escucha y cuándo retirarla.

### 10. `AnimationController` y `Ticker`

- **Conceptos:** controlador, `vsync`, `Ticker`, `SingleTickerProviderStateMixin`, `TickerProviderStateMixin`, duración y límites.
- **Comprender:** el controlador genera progreso con el tiempo; el proveedor de ticks lo conecta al ciclo de vida y al entorno de Flutter.
- **Práctica:** crear un controlador en un `State` y mostrar su valor.
- [ ] **Dominado cuando:** explicas quién crea, usa y libera el controlador y por qué necesita `vsync`.

### 11. Controlar el recorrido

- **Conceptos:** `forward`, `reverse`, `repeat`, `stop`, `reset`, `animateTo`, `animateBack`, dirección y valor actual.
- **Comprender:** qué hace cada operación, cómo se comporta una inversión a mitad y cómo influyen las duraciones configuradas.
- **Práctica:** crear controles para iniciar, invertir y detener una animación.
- [ ] **Dominado cuando:** puedes elegir una operación y predecir desde qué valor empieza el siguiente recorrido.

### 12. Ciclo de vida, cancelación y asincronía

- **Conceptos:** `initState`, `didUpdateWidget`, `dispose`, propiedad de recursos, `TickerFuture`, `orCancel`, `TickerCanceled` y `mounted` después de `await`.
- **Comprender:** actualizar configuración, limpiar controladores y listeners, y gestionar que una animación se cancele mientras se espera su finalización.
- **Práctica:** cerrar una pantalla durante una transición esperada y comprobar que no se utiliza un `State` ya retirado.
- [ ] **Dominado cuando:** puedes explicar quién libera cada recurso y qué pasa si se cancela el futuro esperado.

### 13. Convertir progreso en valores útiles

- **Conceptos:** `Tween.animate`, `drive`, `Animatable`, `CurveTween`, `CurvedAnimation`, `reverseCurve` y composición.
- **Comprender:** separar la fuente de progreso, su curva y la transformación final; cuidar la propiedad y limpieza de objetos que se suscriben.
- **Práctica:** derivar una escala y un color desde un mismo controlador.
- [ ] **Dominado cuando:** puedes trazar el valor desde el controlador hasta la propiedad visual e identificar cada curva aplicada.

### 14. Reconstruir a partir de una animación

- **Conceptos:** `AnimatedBuilder`, `ListenableBuilder`, `AnimatedWidget`, `addListener` con `setState` y subárbol `child`.
- **Comprender:** diferentes formas de escuchar, sus responsabilidades y el coste de reconstruir subárboles; `child` solo optimiza la parte que no depende de la animación.
- **Práctica:** implementar una escala con `AnimatedBuilder` y conservar un hijo independiente.
- [ ] **Dominado cuando:** eliges una forma de escucha y localizas qué se reconstruye en cada actualización.

## Bloque 4. Composición y movimiento de interfaz

### 15. Animar varias propiedades

- **Conceptos:** varias animaciones derivadas, `TweenSequence`, pesos, `Interval` y tiempos escalonados.
- **Comprender:** coordinar propiedades con un controlador sin confundir el intervalo global con el progreso local.
- **Práctica:** aparecer, desplazarse y cambiar de tamaño en fases parcialmente solapadas.
- [ ] **Dominado cuando:** puedes dibujar la línea de tiempo y calcular qué fase está activa en un instante.

### 16. Transiciones integradas

- **Conceptos:** `FadeTransition`, `ScaleTransition`, `SlideTransition`, `RotationTransition`, `SizeTransition`, `AlignTransition` y sus diferencias con widgets implícitos.
- **Comprender:** estas transiciones reciben una `Animation` externa; sus efectos tienen unidades, puntos de origen y restricciones propios.
- **Práctica:** comparar `SlideTransition` con un desplazamiento en píxeles y combinar escala con opacidad.
- [ ] **Dominado cuando:** eliges la transición apropiada y explicas el significado de sus valores.

### 17. Layout, pintura y transformaciones

- **Conceptos:** restricciones, layout, pintura, `Transform`, origen, `Offset`, recorte, sombras y pruebas de impacto de puntero.
- **Comprender:** algunos movimientos modifican la disposición y otros transforman el dibujo; el espacio reservado y la interacción pueden comportarse de forma distinta.
- **Práctica:** comparar mover un elemento mediante layout y mediante transformación.
- [ ] **Dominado cuando:** puedes explicar qué espacio ocupa el elemento y dónde se detectan las pulsaciones.

### 18. Listas, inserciones y eliminación

- **Conceptos:** identidad de elementos, claves estables, `AnimatedList`, inserción, retirada y conservación temporal del contenido que sale.
- **Comprender:** diferenciar el cambio de datos de la animación visual y preservar la identidad al reordenar.
- **Práctica:** insertar y eliminar un elemento animado sin reutilizar una clave incorrecta.
- [ ] **Dominado cuando:** puedes explicar cuándo se modifica la colección y qué se necesita para mostrar la salida.

### 19. Navegación y elementos compartidos

- **Conceptos:** transiciones de ruta, `PageRouteBuilder`, animaciones de entrada y salida, `Hero`, etiquetas y elementos compartidos.
- **Comprender:** el ciclo de vida de dos rutas y cómo se vinculan los elementos durante una transición.
- **Práctica:** crear una transición entre dos pantallas y compartir una imagen con `Hero`.
- [ ] **Dominado cuando:** puedes diagnosticar una etiqueta o jerarquía incorrecta y seguir la transición entre rutas.

### 20. Gestos y animación interactiva

- **Conceptos:** arrastre, progreso controlado por el usuario, normalización, velocidad, umbrales, cancelación y continuación al soltar.
- **Comprender:** cómo convertir un gesto en progreso y decidir el destino a partir de la posición y la velocidad.
- **Práctica:** arrastrar un panel y decidir si vuelve o completa su apertura.
- [ ] **Dominado cuando:** puedes explicar cómo evitar saltos entre el gesto y la animación posterior.

### 21. Física y simulaciones

- **Conceptos:** `Simulation`, velocidad inicial, muelle, amortiguación, `SpringSimulation`, fricción y `animateWith`.
- **Comprender:** cuándo conviene un movimiento basado en física y cómo afecta su configuración al resultado; no toda transición necesita una simulación.
- **Práctica:** comparar un retorno con curva y otro con muelle tras un arrastre.
- [ ] **Dominado cuando:** puedes justificar la elección y describir cómo afectan velocidad y amortiguación.

## Bloque 5. Calidad y aplicación

### 22. Accesibilidad y preferencias de movimiento

- **Conceptos:** movimiento reducido, `MediaQuery.disableAnimations`, `AnimationBehavior`, contraste, efectos no esenciales y alternativas comprensibles.
- **Comprender:** respetar las preferencias del usuario según el comportamiento concreto de cada API; la información y las acciones deben seguir disponibles.
- **Práctica:** ofrecer una transición reducida y comprobar que el cambio de estado sigue siendo perceptible.
- [ ] **Dominado cuando:** puedes adaptar una animación sin hacer depender de ella una acción esencial.

### 23. Rendimiento y diagnóstico

- **Conceptos:** presupuesto por fotograma, fases de build/layout/pintura, `child` estable, `RepaintBoundary`, DevTools, modo profile y costes de opacidad, sombras y recortes.
- **Comprender:** medir antes de optimizar; reconstruir, hacer layout y pintar son costes distintos, y el beneficio de aislar pintura depende del caso.
- **Práctica:** localizar una transición lenta en DevTools y comprobar el efecto de un cambio con la misma medición.
- [ ] **Dominado cuando:** puedes describir qué mediste, en qué dispositivo y fase aparece el coste y qué mejoró realmente.

### 24. Pruebas de animaciones

- **Conceptos:** `WidgetTester`, `pump`, avance de tiempo controlado, fotogramas, `pumpAndSettle`, pruebas de estados intermedios e interrupciones.
- **Comprender:** una prueba de widget puede verificar valores y comportamiento en tiempos controlados; no sustituye la revisión visual ni de rendimiento en dispositivo.
- **Práctica:** verificar inicio, un valor intermedio, destino y cambio de dirección antes de terminar.
- [ ] **Dominado cuando:** puedes elegir avances de tiempo deliberados y explicar qué demuestra y qué no demuestra la prueba.

### 25. Diseñar una animación reutilizable en DaisyUI

- **Conceptos:** API pública, valores por defecto, interacción habilitada y deshabilitada, tema, cambios en caliente, propiedad del controlador, accesibilidad y pruebas.
- **Comprender:** elegir entre animación implícita y explícita según el control requerido y mantener la responsabilidad de cada recurso clara.
- **Práctica:** diseñar un componente animado, justificar sus decisiones y revisar cambios rápidos de estado, desmontaje y movimiento reducido.
- [ ] **Dominado cuando:** puedes implementar y revisar el componente completo, incluyendo sus límites y validación visual.

## Proyecto final

Construye una pequeña pantalla de catálogo con un botón como el de DaisyUI y una tarjeta que entra, cambia de tamaño y se puede retirar. Añade una transición de ruta, un gesto que pueda interrumpirse, una opción de movimiento reducido y pruebas del estado inicial, intermedio y final. Explica qué animaciones son implícitas, cuáles explícitas y quién libera sus recursos. Mide y revisa el resultado visual en un dispositivo antes de afirmar que su movimiento y rendimiento son adecuados.

## Recursos para acompañar el estudio

- [Introducción oficial a las animaciones](https://docs.flutter.dev/ui/animations): panorama de animaciones implícitas, explícitas y transiciones.
- [Catálogo de widgets de animación](https://docs.flutter.dev/ui/widgets/animation): buscar la herramienta que corresponde a una propiedad o transición.
- [Referencia de `TweenAnimationBuilder`](https://api.flutter.dev/flutter/widgets/TweenAnimationBuilder-class.html): comportamiento inicial, cambios de destino y propiedad del tween.
- [Guía de pruebas de widgets](https://docs.flutter.dev/cookbook/testing/widget/introduction): base para controlar y comprobar el comportamiento en pruebas.
- [DevTools Performance](https://docs.flutter.dev/tools/devtools/performance): investigar fotogramas lentos mediante mediciones.
