# 05. ChangeNotifier: producir avisos

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 4](04-listenable-recibir-avisos.md)

- **Bloque:** el sistema de notificaciones de Flutter.
- **Estado de estudio:** pendiente.
- **Investigación de fuentes:** 29 de octubre de 2026.

## Qué vas a conseguir

Podrás construir un objeto que conserva un contador y decide cuándo avisar a quienes escuchan. Seguirás cada paso
entre una llamada a `incrementar()`, el cambio del dato, `notifyListeners()` y la ejecución de los callbacks.
También podrás explicar qué ocurre si falta el aviso, si se emite sin cambiar el dato y cuando termina la vida del
notificador.

Esta unidad desarrolla **`ChangeNotifier`**, **subclase**, **`notifyListeners`**, **política de avisos**, **notificación
síncrona**, **`dispose`** y el puente hacia un widget consumidor. Utiliza los contratos de la unidad 3
y los registros de la unidad 4. `ValueListenable`, `ValueNotifier` y Signals se estudiarán después.

## Ruta y progreso

Antes de comenzar, asegúrate de poder explicar la diferencia entre entregar `listener` y ejecutar `listener()`, y
entre el tipo de una referencia y el objeto al que accede. Si hace falta, repasa las unidades 2–4.

Los ejemplos A–C y la solución del proyecto son programas completos e independientes. En
[DartPad](https://dartpad.dev/) selecciona un ejemplo de **Flutter**, copia un programa a la vez y observa la
consola. Importan `package:flutter/foundation.dart`, que requiere el entorno Flutter; no dependen del paquete
DaisyUI. El fragmento del widget y el ejemplo del controlador real se leen en su contexto: no son programas
independientes. Los materiales oficiales están en inglés; esta guía y los ejercicios están en español.

- [ ] [5.1. Del contrato al mecanismo de notificación](#51-del-contrato-al-mecanismo-de-notificación).
- [ ] [5.2. Construir un contador que avisa](#52-construir-un-contador-que-avisa).
- [ ] [5.3. Separar modificar y notificar](#53-separar-modificar-y-notificar).
- [ ] [5.4. Seguir la ejecución de los listeners](#54-seguir-la-ejecución-de-los-listeners).
- [ ] [5.5. Comprender la política de registros](#55-comprender-la-política-de-registros).
- [ ] [5.6. Terminar la vida del notificador](#56-terminar-la-vida-del-notificador).
- [ ] [5.7. Conectar un aviso con un widget](#57-conectar-un-aviso-con-un-widget).
- [ ] [5.8. Comparar con el controlador de DaisyUI](#58-comparar-con-el-controlador-de-daisyui).
- [ ] [Completar el proyecto de la unidad](#proyecto-de-la-unidad-un-contador-con-una-política-explícita).
- [ ] [Superar la comprobación final](#comprobación-final).

Puedes estudiar 5.1–5.3 en una sesión, 5.4–5.6 en otra y terminar con 5.7–5.8 y el proyecto. Marca las casillas
cuando puedas explicar tus predicciones y resolver las variaciones sin copiar las soluciones.

## 5.1. Del contrato al mecanismo de notificación

### El problema

En la unidad 4 creamos una lista de callbacks y un método `emitir`. Eso permitió estudiar el contrato, pero la clase
didáctica no resolvía casos como retirar un listener durante la emisión. ¿Cómo construir una fuente de avisos usando
el mecanismo que Flutter ya ofrece?

### La idea

[`Listenable`](https://api.flutter.dev/flutter/foundation/Listenable-class.html) describe operaciones para registrar y
retirar callbacks. [`ChangeNotifier`](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) es una
clase de Flutter que implementa ese contrato y aporta un mecanismo para conservar los registros y notificarlos.
Una subclase puede añadir sus propios datos y métodos; decide cuándo llamar a `notifyListeners()`.

Imagina una libreta de avisos: ofrece apuntar y borrar destinatarios y una operación para llamar a los apuntados.
La persona que administra el contador decide cuándo usar esa operación. La libreta no sabe qué significa incrementar
ni comprueba por sí misma si cambió un número. Es una analogía del reparto de responsabilidades, no de llamadas
telefónicas, tiempos de espera o concurrencia.

`ChangeNotifier` se puede extender o usar como mixin. Aquí empleamos `extends`: la subclase hereda las operaciones de
escucha y de notificación. Esas operaciones no crean por sí solas un contador ni un getter `value`. El campo y los
métodos de negocio los escribimos nosotros.

`notifyListeners()` está anotado con `@protected` y `@visibleForTesting`: en código de aplicación corresponde
llamarlo desde la implementación/subclase, no usarlo como API pública de un consumidor. El analizador puede advertir
si se invoca desde fuera; la anotación no es una barrera de privacidad en tiempo de ejecución. Véase
[notifyListeners](https://api.flutter.dev/flutter/foundation/ChangeNotifier/notifyListeners.html).

### Comprobación

- ¿Qué piezas aporta `ChangeNotifier` y cuáles tendrá que aportar nuestro contador?
- ¿Por qué un parámetro de tipo `Listenable` no permite llamar a `notifyListeners()`?
- ¿Quién decide que una operación del contador debe emitir un aviso?

**Puedes avanzar cuando:** distingues el contrato de escucha, el mecanismo que distribuye avisos y la política que
escribe la subclase.

## 5.2. Construir un contador que avisa

### Ejemplo A: una operación, dos consumidores

Programa completo. Antes de ejecutarlo predice las siete líneas. Señala el valor del contador y los registros antes
de cada llamada a `incrementar()`.

```dart
import 'package:flutter/foundation.dart';

class Contador extends ChangeNotifier {
  int _cantidad = 0;

  int get cantidad => _cantidad;

  void incrementar() {
    _cantidad += 1;
    notifyListeners();
  }
}

void main() {
  final contador = Contador();
  void panel() => print('Panel: ${contador.cantidad}');
  void registro() => print('Registro: ${contador.cantidad}');

  print('Inicial: ${contador.cantidad}');
  contador.addListener(panel);
  contador.addListener(registro);
  print('Antes');
  contador.incrementar();
  print('Después');
  contador.removeListener(panel);
  contador.incrementar();
  contador.removeListener(registro);
  contador.dispose();
  print('Fin');
}
```

### Recorrido paso a paso

1. `Contador()` crea un objeto con `_cantidad` igual a cero y sin listeners registrados.
2. El getter `cantidad` permite leer el número; `_cantidad` es privado de su biblioteca Dart. El getter no registra
   una escucha ni produce una copia que se mantenga actualizada.
3. `addListener(panel)` y `addListener(registro)` entregan funciones. No ejecutan sus cuerpos en este ejemplo.
4. `incrementar()` ejecuta primero `_cantidad += 1`: el dato pasa a uno.
5. La línea `notifyListeners()` inicia la distribución. Flutter llama a los callbacks registrados; cada uno consulta
   `contador.cantidad` al ejecutarse, por lo que ambos leen uno.
6. Al terminar la distribución vuelve la ejecución a `incrementar`, después a `main` y se imprime `Después`.
7. Retirar `panel` deja activo `registro`. El segundo incremento cambia el dato a dos y solo ese listener imprime.
   Luego se retira el registro y el propietario libera el contador.

Aquí hay una llamada a `notifyListeners` por incremento porque así está escrito el método. No es una regla universal
para cualquier operación de `ChangeNotifier`. Las soluciones aparecen al final para que primero puedas predecir.

### Comprobación

- Mueve `notifyListeners()` antes de `_cantidad += 1`. ¿Qué imprimen los listeners en el primer incremento y qué
  valor queda al terminar?
- Retira `registro` antes del primer incremento. ¿Cuántas veces se ejecuta cada función?
- Guarda `final anterior = contador.cantidad` antes de incrementar. ¿Cambia ese entero al recibir el aviso?
- ¿En qué línea se llama a cada listener: en `addListener` o durante la distribución?

**Puedes avanzar cuando:** puedes narrar quién cambia el dato, quién solicita la distribución y qué lee cada callback.

## 5.3. Separar modificar y notificar

### El problema

¿Cambiar un campo de una subclase obliga a `ChangeNotifier` a avisar? ¿Una llamada a `notifyListeners` demuestra que
el valor ha cambiado?

### Ejemplo B: tres operaciones diferentes

Programa completo. Predice las seis líneas y cuenta cambios del dato, llamadas a `notifyListeners` y ejecuciones del
listener por separado.

```dart
import 'package:flutter/foundation.dart';

class Contador extends ChangeNotifier {
  int _cantidad = 0;

  int get cantidad => _cantidad;

  void incrementarSinAvisar() {
    _cantidad += 1;
  }

  void avisarSinCambiar() {
    notifyListeners();
  }

  void incrementar() {
    _cantidad += 1;
    notifyListeners();
  }
}

void main() {
  final contador = Contador();
  var avisos = 0;
  void observar() {
    avisos += 1;
    print('Aviso $avisos: ${contador.cantidad}');
  }

  contador.addListener(observar);
  contador.incrementarSinAvisar();
  print('Tras cambio silencioso: ${contador.cantidad}');
  contador.avisarSinCambiar();
  contador.avisarSinCambiar();
  contador.incrementar();
  contador.removeListener(observar);
  contador.incrementar();
  print('Valor final: ${contador.cantidad}');
  print('Avisos recibidos: $avisos');
  contador.dispose();
}
```

### Qué demuestra

El primer método modifica el campo, pero no llama al mecanismo de distribución: no se ejecuta `observar` en ese
momento. Los dos avisos siguientes ejecutan el callback aunque el número permanezca en uno. `incrementar` cambia y
avisa; después de la retirada vuelve a cambiar y llama a `notifyListeners`, pero ese callback ya no está registrado.

No hay comparación de igualdad incorporada para el campo `_cantidad`. La subclase decide si y cuándo notifica.
Esto contrasta con las políticas de otras implementaciones; estudiaremos la comparación de `ValueNotifier` en la
unidad 7, sin convertirla en una propiedad general de `Listenable` o `ChangeNotifier`.

En una aplicación, omitir un aviso necesario puede dejar a un consumidor de interfaz mostrando una lectura anterior
hasta que se reconstruya por otra causa. Emitir un aviso innecesario puede provocar trabajo adicional. Estas son
consecuencias posibles del consumidor concreto, no una actualización de pantalla que `notifyListeners` haga por sí solo.

### Comprobación

- Elimina las dos llamadas a `avisarSinCambiar`. ¿Qué valor y cuántos avisos quedan al final?
- Coloca dos `notifyListeners()` dentro de `incrementar`, uno detrás de otro. ¿Cuántas veces se ejecuta un listener
  que permanece registrado? ¿Cuántos incrementos ocurrieron?
- Si lees el valor tras `incrementarSinAvisar`, ¿encuentras el dato anterior o el nuevo? ¿Por qué?

**Puedes avanzar cuando:** puedes contar cambios, emisiones y ejecuciones independientemente.

## 5.4. Seguir la ejecución de los listeners

### Ejemplo C: qué ocurre dentro de la llamada

Programa completo. Predice todas las líneas antes de ejecutarlo. `otro` se añade durante el primer aviso.

```dart
import 'package:flutter/foundation.dart';

class Campana extends ChangeNotifier {
  void sonar() {
    print('Entra sonar');
    notifyListeners();
    print('Sale sonar');
  }
}

void main() {
  final campana = Campana();
  void otro() => print('Otro');
  var agregado = false;
  void primero() {
    print('Primero');
    if (!agregado) {
      agregado = true;
      campana.addListener(otro);
    }
  }
  void segundo() => print('Segundo');

  campana.addListener(primero);
  campana.addListener(segundo);
  print('Antes');
  campana.sonar();
  print('Entre avisos');
  campana.sonar();
  print('Después');
  campana.removeListener(primero);
  campana.removeListener(segundo);
  campana.removeListener(otro);
  campana.dispose();
}
```

En la implementación documentada, `notifyListeners` recorre los registros y llama directamente a las funciones antes
de regresar. Por eso `Sale sonar` aparece después de los callbacks de esa emisión. Esto describe esta implementación,
no una promesa de ejecución síncrona aplicable a toda fuente `Listenable`.

El primer recorrido comenzó antes de que `otro` fuera añadido, por lo que ese registro no se visita en ese recorrido.
En el segundo ya estaba registrado al comenzar y sí se visita. Los listeners retirados durante el recorrido no se
visitan después de su retirada, con la salvedad de los registros duplicados explicada en 5.5. Si un callback lanza
una excepción, Flutter la captura y reporta mediante `FlutterError.reportError`; no significa que la operación del
listener haya tenido éxito. Estas reglas proceden de
[notifyListeners](https://api.flutter.dev/flutter/foundation/ChangeNotifier/notifyListeners.html).

Una llamada desde un listener que vuelve a provocar `notifyListeners` se denomina **reentrante**: comienza otra
emisión antes de que termine la anterior. Puede producir recursión infinita si no existe una condición de parada.
No necesitamos diseñar un flujo reentrante para el proyecto de esta unidad.

### Comprobación

- En C, ¿por qué `Otro` no aparece en el primer aviso y sí en el segundo?
- Si `primero` retira `segundo` antes de que le toque en el primer recorrido, ¿recibirá `segundo` ese aviso,
  suponiendo que solo estaba registrado una vez?
- ¿Se imprime `Sale sonar` antes o después de los listeners? ¿Qué línea del método te ayuda a razonarlo?

**Puedes avanzar cuando:** separas el recorrido actual de uno posterior y sabes dónde continúa la ejecución.

## 5.5. Comprender la política de registros

Según [addListener](https://api.flutter.dev/flutter/foundation/ChangeNotifier/addListener.html), registrar el mismo
callback dos veces crea dos registros. Fuera de una emisión, retirarlo una vez elimina uno; hace falta retirarlo el
mismo número de veces para que deje de ser llamado. Una retirada de un callback no registrado se ignora.

Si la retirada ocurre **durante** la notificación y hay registros duplicados, la propia documentación advierte que el
mismo callback puede volver a ser llamado en ese recorrido aunque se haya retirado una vez. No extrapoles al caso
duplicado la intuición de «retiré la función, ya nunca se ejecutará». Consulta también
[removeListener](https://api.flutter.dev/flutter/foundation/ChangeNotifier/removeListener.html). Esta política es
específica de `ChangeNotifier`; el contrato `Listenable` por sí solo no determina cómo otra implementación maneja
duplicados.

`hasListeners` existe, pero es un miembro protegido para la implementación. No es un contador público de registros y
la documentación advierte que los consumidores no deben hacer depender su lógica de si existen otros listeners.
Consulta [hasListeners](https://api.flutter.dev/flutter/foundation/ChangeNotifier/hasListeners.html).

### Comprobación

- Registra `panel` dos veces en A, retíralo una vez fuera de la emisión y vuelve a incrementar. ¿Recibe otro aviso?
- ¿Cuántas retiradas compensan dos registros iguales?
- ¿Puedes concluir que cualquier implementación de `Listenable` conserva duplicados igual? ¿Por qué?

**Puedes avanzar cuando:** cuentas registros, no solo funciones distintas, y reconoces el caso especial durante la
emisión.

## 5.6. Terminar la vida del notificador

### Propiedad y limpieza

El **propietario** crea o recibe la responsabilidad de mantener un notificador y decide cuándo ha terminado su uso.
El consumidor que solo lo escucha debe retirar su propio registro cuando deja de necesitarlo. Retirar un callback
no destruye el notificador ni retira los demás. En A, `main` crea el contador, retira ambos callbacks y finalmente
llama a `dispose()`.

Según [dispose](https://api.flutter.dev/flutter/foundation/ChangeNotifier/dispose.html), el objeto ya no debe usarse
tras liberarlo; la operación limpia la lista y **no envía** un último aviso. No se deben registrar nuevos listeners
ni llamar a `notifyListeners` después. La documentación permite `removeListener` después de `dispose` para facilitar
la limpieza de consumidores; eso no reactiva el objeto. No llames `dispose` durante una notificación en curso.

Si una subclase sobrescribe `dispose` para limpiar recursos que posee, debe llamar a `super.dispose()`:

```dart
@override
void dispose() {
  // Liberar aquí los recursos adicionales que posee esta subclase.
  super.dispose();
}
```

Este fragmento pertenece al cuerpo de una subclase; por sí solo no es un programa. La anotación `@mustCallSuper`
figura en la API. El ciclo de vida de widgets y los recursos prestados se tratarán con más detalle en la unidad 13.
No uses fallos de `assert` como mecanismo de control de flujo: las comprobaciones de depuración no son una promesa de
validación idéntica en todos los modos de ejecución.

### Comprobación

- ¿Envía `dispose` un aviso de despedida?
- Si dos consumidores escuchan un contador compartido, ¿por qué uno no debería liberarlo al dejar de escucharlo?
- ¿Qué debe hacer una subclase que añade su propia limpieza a `dispose`?

**Puedes avanzar cuando:** diferencias terminar una suscripción de terminar la vida del objeto.

## 5.7. Conectar un aviso con un widget

Un `ChangeNotifier` puede funcionar sin ninguna pantalla, como muestran A–C. Para actualizar una interfaz hace
falta un consumidor que escuche y conecte el aviso con el sistema de construcción de Flutter.
[`ListenableBuilder`](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html) acepta un `Listenable` y
construye una parte de la interfaz al recibir sus avisos.

Fragmento para leer: presupone un `contador` vivo y un contexto de construcción válido.

```dart
ListenableBuilder
(
listenable: contador,
builder: (context, child) {
return Text('Cantidad: ${contador.cantidad}');
},
)
```

El `builder` consulta el dato actual cuando Flutter lo ejecuta. El widget escuchador enlaza la notificación con una
actualización de su subárbol; no es `notifyListeners()` pintando directamente. La primera construcción también muestra
el valor inicial sin necesitar una notificación previa. Flutter puede construir widgets por otras causas y agrupar
trabajo entre frames: no deduzcas un repintado ni un número fijo de construcciones solo por contar avisos.

Si quitas el puente, un callback que imprime en consola puede seguir recibiendo avisos, pero no hay que atribuirle por
ello la reconstrucción de ese `Text`. La API oficial incluye un ejemplo completo de contador y otro de lista;
también ofrece `flutter create --sample=foundation.ChangeNotifier.1 mysample` para crear el primero localmente.

### Comprobación

- ¿Quién almacena la cantidad, quién solicita el aviso y quién conecta el aviso con el árbol?
- Si un listener solo imprime, ¿qué prueba su impresión y qué no prueba?
- ¿De dónde obtiene `Text` el número que muestra?

**Puedes avanzar cuando:** puedes trazar dato, aviso, consumidor y lectura sin confundir notificar con pintar.

## 5.8. Comparar con el controlador de DaisyUI

La guía usa `ChangeNotifier` para aprender el mecanismo de Flutter; **el controlador actual de DaisyUI no hereda de
`ChangeNotifier`**. Comprueba [daisy_theme_controller.dart](../../lib/themes/application/daisy_theme_controller.dart):

```dart
final FlutterSignal<DaisyThemeModel> _palette;

void setTheme(DaisyThemeModel theme) {
  _palette.value = theme;
}
```

Este es un fragmento de la clase real. El controlador posee la señal `_palette` y escribe en ella mediante
`setTheme`. Su getter `theme` ofrece una vista de lectura `ValueListenable<DaisyThemeModel>`: `_ThemeListenable`
reenvía `addListener` y `removeListener` a la fuente. El consumidor puede escuchar esa vista; las reglas concretas
de la señal deben estudiarse en su propia implementación, no suponerse idénticas a las de `ChangeNotifier`.

En [daisy_theme_scope.dart](../../lib/themes/application/daisy_theme_scope.dart), `DaisyThemeScope` entrega esa vista a
`InheritedNotifier`, que conecta sus avisos con los dependientes del scope. La lectura `of(context)` registra una
dependencia y consulta el tema. El scope toma prestado un controlador explícito; el propietario de ese controlador
lo libera. La unidad 4 incluye una prueba local con listeners y las posteriores profundizan en Signals y scopes.

La comparación conserva la pregunta central: **¿quién guarda el dato, quién provoca la emisión y quién escucha?**
En el contador didáctico la subclase llama explícitamente a `notifyListeners`; en DaisyUI `setTheme` escribe en una
señal. No hay una llamada equivalente a `notifyListeners` en ese método del controlador.

### Comprobación

- ¿Qué línea cambia el dato en cada caso?
- ¿Por qué no podemos buscar `notifyListeners()` dentro de `setTheme` para explicar el recorrido real?
- ¿Qué objeto conecta el tema de DaisyUI con los dependientes de Flutter?

**Puedes avanzar cuando:** explicas la analogía sin atribuir al controlador una herencia o política que no tiene.

## Materiales de estudio seleccionados

Todos estos recursos se pueden consultar gratis. Las referencias técnicas son oficiales; las páginas están en inglés.
Cada enlace apunta a un recurso concreto y contiene una tarea para convertir la lectura en práctica.

- **F1 · Flutter: [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)** — 5.1–5.2.
  Identifica el contrato que implementa, la posibilidad de extenderlo y los dos ejemplos ejecutables de la página.
- **F2 · Flutter: [notifyListeners](https://api.flutter.dev/flutter/foundation/ChangeNotifier/notifyListeners.html)** —
  5.2–5.4. Lee cuándo se llama, las anotaciones y las reglas de altas, bajas y excepciones durante una emisión.
- **F3 · Flutter: [addListener](https://api.flutter.dev/flutter/foundation/ChangeNotifier/addListener.html) y
  [removeListener](https://api.flutter.dev/flutter/foundation/ChangeNotifier/removeListener.html)** — 5.5. Explica
  registros repetidos y el caso especial de retirarlos durante el recorrido.
- **F4 · Flutter: [dispose](https://api.flutter.dev/flutter/foundation/ChangeNotifier/dispose.html)** — 5.6. Localiza
  quién debe liberar el objeto y si esa operación envía un aviso.
- **F5 · Flutter: [ListenableBuilder](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html)** — 5.7.
  Recorre su ejemplo de contador y localiza el widget que escucha y la lectura que construye el texto.
- **F6 ·
  Flutter: [Simple app state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple#changenotifier)** —
  después de 5.3. Lee la sección `ChangeNotifier` del carrito y señala cada modificación y aviso; el resto del tutorial
  utiliza el paquete adicional `provider`, que no hace falta instalar para esta unidad.
- **F7 · Flutter: [Introducción a pruebas unitarias](https://docs.flutter.dev/cookbook/testing/unit/introduction)** —
  para contrastar el proyecto: identifica la clase, la prueba y la expectativa sin confundir pruebas unitarias con
  pruebas visuales.
- **P1 · [DartPad](https://dartpad.dev/) y su [documentación](https://dart.dev/tools/dartpad)** — ejecuta A–C y el
  proyecto seleccionando Flutter. El paquete local `daisy_ui` no está disponible simplemente por importarlo en un pad.
- **P2 · Código del proyecto:** [controlador](../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../lib/themes/application/daisy_theme_scope.dart) y
  [pruebas del controlador](../../test/themes/daisy_theme_controller_test.dart). Son material local para 5.8.

## Proyecto de la unidad: un contador con una política explícita

Construye una clase `ContadorLimitado` que extienda `ChangeNotifier`. Su cantidad inicial es cero y su máximo es dos.
Dos consumidores, `panel` y `registro`, consultan el contador cuando reciben un aviso.

### Requisitos

1. Expón un getter de lectura `cantidad` y escribe un método `incrementar()`.
2. Si la cantidad es menor que dos, incrementa primero y después avisa una vez.
3. Si ya es dos, no cambies el dato y no emitas aviso. Esta es **tu política**, no una comparación automática de
   `ChangeNotifier`.
4. Registra ambos listeners, intenta incrementar tres veces, retira el panel y llama a `reiniciar()`.
5. `reiniciar()` cambia la cantidad a cero y avisa una vez solo si el valor no era cero. Llámalo dos veces.
6. Retira el registro y libera el contador en el código propietario. Predice los valores y la salida antes de ejecutar.

### Variaciones

- ¿Qué ocurre si `reiniciar` siempre notifica, incluso con cero? Calcula el cambio en el número de avisos.
- Registra `panel` dos veces y retíralo dos veces fuera de las emisiones. ¿Qué ocurriría tras una sola retirada?
- Cambia el orden de modificación y aviso: ¿qué valores observan los callbacks y cuál queda finalmente?
- Dibuja las relaciones fuente–callback y marca en qué momento cada relación deja de existir.

Una solución completa está al final. Antes de verla explica qué líneas implementan la política y cuáles usan el
mecanismo heredado.

## Errores de comprensión que vamos a comprobar

- Creer que `addListener` ejecuta inmediatamente la función entregada.
- Suponer que modificar cualquier campo de un `ChangeNotifier` emite automáticamente un aviso.
- Pensar que `notifyListeners` recibe o entrega el valor nuevo como argumento.
- Confundir una emisión con una modificación, una ejecución de listener, una construcción o un repintado.
- Suponer que `ChangeNotifier` compara todos los campos o que todas las fuentes `Listenable` tienen su política.
- Llamar al método protegido como operación habitual del consumidor, en lugar de exponer una acción del modelo.
- Liberar un notificador prestado o esperar un último aviso de `dispose`.
- Atribuir `ChangeNotifier` al `DaisyThemeController` actual porque ambos permiten observar cambios.

## Comprobación final

Responde sin mirar las soluciones y justifica cada respuesta con una línea de código o una referencia:

1. ¿Qué añade `ChangeNotifier` al contrato `Listenable` y qué decisiones siguen siendo de la subclase?
2. En A, ¿qué valor ve cada listener en el primer incremento y por qué?
3. En B, ¿cuántos cambios, llamadas a `notifyListeners` y ejecuciones de `observar` hay?
4. ¿Puede producirse un aviso sin modificar el dato? ¿Y una modificación sin aviso?
5. En C, ¿por qué `otro` se ejecuta solo en el segundo recorrido?
6. ¿Qué ocurre con dos registros iguales y una retirada fuera de una emisión? ¿Qué precaución hay durante ella?
7. ¿Qué hace y qué no hace `dispose`? ¿Quién debe llamarlo?
8. ¿Qué pieza conecta un aviso con la construcción del texto en 5.7? ¿Demuestra una impresión que hubo repintado?
9. ¿Dónde se escribe el tema en DaisyUI y qué papel cumple la vista `theme`?
10. Explica de principio a fin un incremento del proyecto, desde la decisión de la política hasta la lectura del
    consumidor. Después explica qué ocurre al intentar incrementar por encima del límite.

**Unidad dominada cuando:** puedes construir y explicar el proyecto, justificar sus variaciones y responder estas
preguntas sin copiar la solución. Preparar el material no marca la unidad como dominada.

## Soluciones para contrastar después de practicar

### Ejemplo A

```text
Inicial: 0
Antes
Panel: 1
Registro: 1
Después
Registro: 2
Fin
```

Con la notificación antes del incremento, los primeros callbacks leen cero; al terminar el método la cantidad es
uno. El orden forma parte de la implementación de nuestro método.

### Ejemplo B

```text
Tras cambio silencioso: 1
Aviso 1: 1
Aviso 2: 1
Aviso 3: 2
Valor final: 3
Avisos recibidos: 3
```

Hay tres cambios del dato, cuatro llamadas a `notifyListeners` y tres ejecuciones de `observar`: la última emisión
ocurre después de retirar el callback. Sin los dos avisos sin cambio queda valor tres y un aviso recibido.

### Ejemplo C

```text
Antes
Entra sonar
Primero
Segundo
Sale sonar
Entre avisos
Entra sonar
Primero
Segundo
Otro
Sale sonar
Después
```

La primera emisión comienza con dos registros. `otro` se incorpora durante ese recorrido y participa en el
siguiente. Si `primero` retira el único registro de `segundo` antes de su turno, `segundo` no se visita en ese
recorrido.

### Una solución del proyecto

```dart
import 'package:flutter/foundation.dart';

class ContadorLimitado extends ChangeNotifier {
  int _cantidad = 0;

  int get cantidad => _cantidad;

  void incrementar() {
    if (_cantidad >= 2) return;
    _cantidad += 1;
    notifyListeners();
  }

  void reiniciar() {
    if (_cantidad == 0) return;
    _cantidad = 0;
    notifyListeners();
  }
}

void main() {
  final contador = ContadorLimitado();
  void panel() => print('Panel: ${contador.cantidad}');
  void registro() => print('Registro: ${contador.cantidad}');

  contador.addListener(panel);
  contador.addListener(registro);
  contador.incrementar();
  contador.incrementar();
  contador.incrementar();
  contador.removeListener(panel);
  contador.reiniciar();
  contador.reiniciar();
  contador.removeListener(registro);
  contador.dispose();
}
```

La salida es:

```text
Panel: 1
Registro: 1
Panel: 2
Registro: 2
Registro: 0
```

Hay tres emisiones: dos incrementos efectivos y un reinicio efectivo. El panel recibe dos avisos y el registro tres.
Si el segundo reinicio también avisa, el registro recibe un cuarto aviso con cero. Si el panel se registra dos veces,
una sola retirada fuera de la emisión deja un registro activo y ese panel recibe el aviso del reinicio.

### Claves de la comprobación final

1. Implementa registro, retirada y distribución; la subclase define datos, operaciones y cuándo avisa.
2. Ambos leen uno: el incremento precede a la distribución.
3. Tres cambios, cuatro emisiones y tres ejecuciones; la última no tiene ese listener.
4. Sí en ambos casos: B separa explícitamente las dos operaciones.
5. Se añadió cuando el primer recorrido ya había comenzado.
6. Queda un registro; durante el recorrido la documentación advierte del comportamiento conservador con duplicados.
7. Libera recursos y borra registros sin notificar; lo llama el propietario cuando termina el uso.
8. `ListenableBuilder` escucha y conecta con la construcción; una impresión solo prueba que se ejecutó ese callback.
9. `setTheme` escribe `_palette.value`; `theme` ofrece lectura y escucha mediante una vista que delega en la señal.
10. Si está bajo el límite, primero cambia el campo y luego notifica; los callbacks leen el valor actual. En el
    límite, el retorno temprano evita tanto el cambio como el aviso.

## Qué se ha revisado y cómo se ha comprobado

- Se contrastaron los contratos, las reglas de distribución, los registros duplicados y la liberación con las
  referencias oficiales enlazadas. Se leyeron directamente el controlador y el scope actuales de DaisyUI.
- El servidor del grafo rechazó indexar esta raíz por su configuración de acceso. Las afirmaciones sobre estos dos
  archivos se contrastaron mediante lectura directa, no mediante cobertura del grafo.
- Se extrajeron A–C y la solución del proyecto; cuatro pruebas temporales verificaron sus salidas y pasaron las tres
  pruebas existentes del controlador. El analizador no señaló errores: informó de avisos de estilo por `print` en
  estos ejemplos de consola y por nombres de parámetros en el arnés temporal.
- Se comprobaron enlaces locales, anclas y bloques de código, además de `git diff --check`.
- Estas comprobaciones no ejecutan DartPad ni validan pulsaciones, construcciones o repintados de una interfaz real.
  Los ejemplos de consola verifican sus recorridos concretos; el progreso se marca al estudiar y resolver la unidad.
