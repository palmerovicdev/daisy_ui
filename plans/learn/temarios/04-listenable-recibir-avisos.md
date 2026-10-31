# 04. Listenable: recibir avisos

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 3](03-objetos-referencias-tipos-y-contratos.md)

- **Bloque:** el sistema de notificaciones de Flutter.
- **Estado de estudio:** pendiente.
- **Investigación de fuentes:** 19 de octubre de 2026.

## Qué vas a conseguir

Podrás seguir el recorrido de dos listeners, explicar quién los conserva y ejecuta, retirar uno y predecir quién
recibe el siguiente aviso. También podrás leer una variable de tipo `Listenable` sin atribuirle un valor actual,
una política concreta de cambios o una reconstrucción de pantalla.

Esta unidad desarrolla **objeto observable**, **fuente de avisos**, **listener**, **suscripción**, **notificación**, **
`Listenable`**, **`addListener`** y **`removeListener`**. Utilizaremos los contratos de la unidad 3 y las funciones
como valores de la unidad 2.

Las preguntas que acompañan cada paso son: **¿sobre qué fuente se registró la función?, ¿quién la llama?, ¿qué hace
su cuerpo?, ¿quién deja de escuchar?**

## Ruta y progreso

Antes de empezar, comprueba que distingues `avisar` de `avisar()` y el tipo declarado de una variable del objeto
al que permite acceder. Si estas piezas se mezclan, repasa las unidades 2 y 3.

Los ejemplos A–D son programas completos e independientes. Importan Flutter, así que utiliza un pad de **Flutter**
en [DartPad](https://dartpad.dev/), con la consola visible. Copia un programa cada vez: la clase didáctica se repite
para que cada ejemplo se pueda leer por separado. Aquí observamos impresiones; no construimos una pantalla.
La [documentación de DartPad](https://dart.dev/tools/dartpad) explica su soporte de bibliotecas de Flutter.

El ejemplo E utiliza DaisyUI y `flutter_test`: se ejecuta en este repositorio siguiendo sus instrucciones.
Los demás bloques breves se identifican como fragmentos para leer o modificaciones de un ejemplo.

- [ ] [4.1. Entender qué significa poder escuchar un objeto](#41-entender-qué-significa-poder-escuchar-un-objeto).
- [ ] [4.2. Leer el contrato de Listenable](#42-leer-el-contrato-de-listenable).
- [ ] [4.3. Seguir dos registros, dos avisos y dos retiradas](#43-seguir-dos-registros-dos-avisos-y-dos-retiradas).
- [ ] [4.4. Separar el dato del aviso](#44-separar-el-dato-del-aviso).
- [ ] [4.5. Retirar el callback de la fuente correcta](#45-retirar-el-callback-de-la-fuente-correcta).
- [ ] [4.6. Distinguir contrato y política de notificaciones](#46-distinguir-contrato-y-política-de-notificaciones).
- [ ] [4.7. Separar recibir un aviso de reconstruir Flutter](#47-separar-recibir-un-aviso-de-reconstruir-flutter).
- [ ] [4.8. Seguir los listeners reales de DaisyUI](#48-seguir-los-listeners-reales-de-daisyui).
- [ ] [Completar el proyecto de la unidad](#proyecto-de-la-unidad-observadores-que-pueden-dejar-de-escuchar).
- [ ] [Superar la comprobación final](#comprobación-final).

Puedes repartirlo en varias sesiones: primero 4.1–4.3; después 4.4–4.6; finalmente 4.7–4.8 y el proyecto.
Marca las casillas cuando puedas explicar el mecanismo y resolver las variaciones sin copiar las soluciones.

## 4.1. Entender qué significa poder escuchar un objeto

### El problema

Un panel quiere enterarse de que la selección de tema puede haberse actualizado. Un registro de diagnóstico también
necesita enterarse. Consultar una variable una vez no deja preparada ninguna de esas acciones futuras.

¿Cómo puede una fuente conservar las funciones interesadas y llamarlas cuando corresponda?

### La idea y el vocabulario

Un **objeto observable** permite que otros se registren para recibir avisos. En esta unidad llamamos **fuente** al
objeto a través del cual escuchamos. Un **listener** es la función registrada; **suscribirse** es establecer esa
relación y **notificar** es ejecutar las funciones que corresponda avisar.

Flutter ofrece el contrato [`Listenable`](https://api.flutter.dev/flutter/foundation/Listenable-class.html) para
registrar y retirar esos listeners. Separa tres participantes:

1. **Fuente observable:** ofrece las operaciones de registro y retirada.
2. **Productor del aviso:** la implementación o el código autorizado decide cuándo emitirlo.
3. **Consumidor:** aporta una función cuyo cuerpo realiza una acción al recibirlo.

Estos papeles no exigen tres objetos distintos. Una clase puede conservar el estado y producir avisos, mientras otra
vista reenvía el registro a esa fuente. Lo importante es localizar cada responsabilidad en el código.

Piensa en apuntarte a una lista para que te avisen cuando una sala esté disponible. Apuntarte, recibir la llamada y
borrarte son momentos distintos. La llamada puede indicarte que consultes la disponibilidad actual.
La analogía no establece tiempos de espera, hilos ni una política de envío: esas decisiones dependen del mecanismo.

### Comprobación

- En el problema del panel y el diagnóstico, identifica los dos consumidores.
- Explica qué relación hace falta conservar para poder avisarlos más tarde.
- Si una función recibe un aviso y solo imprime un texto, señala exactamente la acción que realiza.

**Puedes avanzar cuando:** describes fuente, función registrada y ejecución como piezas distintas.

## 4.2. Leer el contrato de Listenable

### El problema

Una función recibe un parámetro `Listenable fuente`. ¿Qué puede pedirle sin conocer su clase concreta?

### Las dos operaciones de escucha

Estos son los miembros de escucha del contrato, presentados como fragmento para leer sus firmas:

```dart
void addListener(VoidCallback listener);

void removeListener(VoidCallback listener);
```

Lee cada parte:

- `addListener` recibe una función que se registra para los avisos de la fuente.
- `removeListener` recibe una función registrada para retirarla.
- `listener` es el nombre del parámetro, no una palabra reservada de Dart.
- `VoidCallback` equivale a `void Function()`: función sin argumentos cuyo resultado no se utiliza como dato.
- El `void` de cada método indica que la operación no devuelve un objeto de suscripción.

Las referencias son [`addListener`](https://api.flutter.dev/flutter/foundation/Listenable/addListener.html),
[`removeListener`](https://api.flutter.dev/flutter/foundation/Listenable/removeListener.html) y
[`VoidCallback`](https://api.flutter.dev/flutter/dart-ui/VoidCallback.html).

En `fuente.addListener(avisar)`, el método de registro se ejecuta ahora y recibe la función `avisar`.
El cuerpo de `avisar` se ejecuta cuando la implementación la llama. Es la distinción de la unidad 2 entre entregar
una función y ejecutarla. No deduzcas una llamada inicial por el hecho de registrarla; comprueba la implementación.

### Qué puedes deducir del tipo

`Listenable` es una clase abstracta utilizada como contrato. No puedes construir directamente un
`Listenable()` para obtener un avisador listo para emitir. Sus declaraciones de escucha no aportan los cuerpos que
guardan o llaman a los callbacks. La API también tiene una fábrica `Listenable.merge`; combinar fuentes queda fuera
de esta práctica.

El contrato de escucha no ofrece `.value`, `setTheme`, `notifyListeners` ni `dispose`. Una implementación puede
añadir esas operaciones, pero un parámetro declarado solamente como `Listenable` no las concede.

Tampoco permite deducir qué cambio merece aviso, si hay una comparación de igualdad, cómo se tratan registros
repetidos o qué ocurre si un listener lanza una excepción. Para responder hay que conocer la implementación.

### Comprobación

Para un parámetro `Listenable fuente`, decide qué llamadas permite el tipo y justifica las demás:

1. `fuente.addListener(avisar)`.
2. `fuente.removeListener(avisar)`.
3. `fuente.value`.
4. `fuente.notifyListeners()`.
5. `fuente.dispose()`.

Después explica por qué `fuente.addListener(avisar())` intenta entregar el resultado de una ejecución.
Si `avisar` devuelve `void`, ese resultado no sirve como callback.

**Puedes avanzar cuando:** lees las firmas y separas las operaciones de escucha de las capacidades adicionales de
una clase concreta.

## 4.3. Seguir dos registros, dos avisos y dos retiradas

### El problema

Registramos un panel y un diagnóstico. Avisamos, retiramos el panel y avisamos otra vez.
¿Qué funciones existen, cuáles están registradas y quién las ejecuta en cada momento?

### Ejemplo A: construir una implementación pequeña

Programa completo. Predice las siete líneas y dibuja la lista de listeners antes de cada `emitir()`.

```dart
import 'package:flutter/foundation.dart';

class AvisadorManual implements Listenable {
  final _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void emitir() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

void main() {
  final avisador = AvisadorManual();
  final Listenable fuente = avisador;

  void panel() => print('Panel avisado');
  void diagnostico() => print('Diagnostico avisado');

  print('Antes de registrar');
  fuente.addListener(panel);
  fuente.addListener(diagnostico);

  print('Antes del primer aviso');
  avisador.emitir();

  fuente.removeListener(panel);
  print('Antes del segundo aviso');
  avisador.emitir();

  fuente.removeListener(diagnostico);
  avisador.emitir();
  print('Fin');
}
```

### Seguir la implementación

`implements Listenable` exige aportar los miembros de escucha. La clase los implementa con una lista:

- `<VoidCallback>[]` crea una lista vacía de funciones con esa firma.
- `_listeners.add(listener)` conserva un registro de la función; no contiene `listener()`.
- `_listeners.remove(listener)` retira la primera entrada que resulte igual al callback entregado.
- El `for` visita las entradas; `listener()` ejecuta la función de cada vuelta.

El método `emitir` es una operación propia de `AvisadorManual`. No lo aporta `Listenable`.
La variable `fuente` y la variable `avisador` acceden al mismo objeto. Sus tipos declarados permiten operaciones
distintas: `fuente` permite escuchar; `avisador` permite además pedir una emisión.

### Recorrido paso a paso

1. Al construir el avisador, su lista está vacía.
2. Registrar `panel` deja una entrada; registrar `diagnostico` deja dos. Sus cuerpos todavía no se han llamado.
3. El primer `emitir` recorre esas dos entradas y llama primero a `panel` y después a `diagnostico`.
4. Retirar `panel` elimina su entrada. La función sigue existiendo en el alcance de `main`.
5. El segundo `emitir` encuentra solamente `diagnostico`.
6. Retirar `diagnostico` deja la lista vacía. El tercer `emitir` no tiene funciones que llamar.
7. `Fin` se imprime después de que termine ese recorrido vacío.

Aquí el orden y la ejecución antes de retornar de `emitir` se deducen del `for`. No se deducen de la palabra
`Listenable`.

### Límites deliberados del modelo

Este avisador es una herramienta de estudio. Las prácticas registran y retiran **fuera de una emisión**, y sus
listeners no lanzan excepciones. No resuelve modificaciones de la lista mientras se recorre, avisos recursivos,
manejo de errores ni liberación de recursos. No lo copies como sustituto de los mecanismos del proyecto.

### Comprobación

- Retira `panel` antes del primer aviso. Predice toda la salida.
- Quita las tres llamadas a `emitir()`. Identifica qué impresiones permanecen.
- Llama a `panel()` después de retirarlo. Explica por qué puedes ejecutarlo directamente.
- Sustituye `avisador.emitir()` por `fuente.emitir()`. Explica el rechazo a partir del tipo declarado.

**Puedes avanzar cuando:** puedes enumerar los registros en cada momento y localizar la única línea que ejecuta
los cuerpos dentro del avisador.

## 4.4. Separar el dato del aviso

### El problema

Un listener no recibe argumentos. ¿Cómo podría consultar el tema actual? ¿Y qué relación hay entre modificar ese
tema y recorrer los listeners?

### La idea

Una función sin argumentos puede acceder a variables de su contexto mediante una closure. El aviso hace que se
ejecute; su cuerpo decide qué consultar entonces. Un texto leído antes y una consulta nueva siguen siendo cosas
distintas, como en las unidades 1 y 2.

### Ejemplo B: cambios sin aviso y avisos sin un cambio nuevo

Programa completo. Predice sus cinco líneas y cuenta por separado asignaciones al tema y ejecuciones del listener.

```dart
import 'package:flutter/foundation.dart';

class AvisadorManual implements Listenable {
  final _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void emitir() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

void main() {
  final avisador = AvisadorManual();
  var tema = 'claro';
  final guardado = tema;

  void mostrar() => print('Actual: $tema; guardado: $guardado');
  avisador.addListener(mostrar);

  tema = 'oscuro';
  print('Sin aviso: $tema');
  avisador.emitir();
  avisador.emitir();

  tema = 'cupcake';
  avisador.emitir();

  avisador.removeListener(mostrar);
  tema = 'forest';
  avisador.emitir();
  print('Final: $tema');
}
```

### Qué explica cada observación

- Asignar `'oscuro'` cambia `tema`. Esa asignación no contiene ninguna llamada al avisador.
- El primer aviso ejecuta `mostrar`, que consulta el contenido actual de `tema`.
- El segundo aviso vuelve a ejecutar la función aunque no haya otra asignación entre ambos.
- `guardado` conserva el texto obtenido al principio. El aviso no lo actualiza.
- Después de retirar `mostrar`, el dato puede seguir cambiando y el avisador puede seguir emitiendo.

Este modelo permite avisar sin un cambio nuevo porque `emitir()` no compara datos. Otra implementación puede
unir una escritura y su notificación. Tendremos que leerla para saberlo.

El callback tampoco recibe el tema anterior, el nuevo ni una explicación del cambio: su firma es `void Function()`.
En B consulta una variable capturada. En la unidad 6 estudiaremos cómo
[`ValueListenable<T>`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html) añade una lectura
actual mediante `.value`.

### Comprobación

- Elimina el primer `emitir()`. Predice cuántas veces aparece `'oscuro'` en toda la salida.
- Conserva los dos primeros avisos, pero mueve la asignación a `'oscuro'` después de ambos. ¿Qué lee `mostrar`?
- Haz que `mostrar` imprima solamente `guardado`. Explica por qué seguirá leyendo `'claro'`.
- Explica por qué `Listenable` puede servir para recibir avisos sin ofrecer ningún `.value` común.

**Puedes avanzar cuando:** cuentas modificaciones y notificaciones por separado y explicas dónde se obtiene el dato
que imprime cada callback.

## 4.5. Retirar el callback de la fuente correcta

### El problema

Tenemos una fuente para la aplicación y otra para la vista previa. Registramos una función en la primera y pedimos
retirarla de la segunda. ¿Qué relación hemos modificado?

### La pareja que hay que conservar

Para dejar de escuchar necesitas identificar **la fuente usada para registrar y el callback registrado**.
Retirar una función no la destruye, no deshace el trabajo ya realizado y no retira otros listeners.

### Ejemplo C: dos fuentes y un callback conservado

Programa completo. Predice las tres líneas y señala qué fuente tiene el registro en cada emisión.

```dart
import 'package:flutter/foundation.dart';

class AvisadorManual implements Listenable {
  final _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void emitir() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

void main() {
  final app = AvisadorManual();
  final preview = AvisadorManual();
  var avisos = 0;

  final VoidCallback listener = () {
    avisos += 1;
    print('Aviso $avisos');
  };

  app.addListener(listener);
  preview.removeListener(listener);
  app.emitir();
  preview.emitir();

  app.removeListener(listener);
  app.emitir();

  preview.addListener(listener);
  preview.emitir();
  preview.removeListener(listener);
  print('Fin: $avisos');
}
```

La retirada de `preview` al principio no encuentra ninguna entrada en **su** lista. No toca la lista de `app`.
Más adelante, registrar la misma función en `preview` establece una relación nueva con esa fuente.
El contador pertenece a la closure compartida; no pasa a ser un contador almacenado por cada avisador.

### No reconstruir el callback a partir de su cuerpo

Este fragmento intenta volver a escribir la función para retirarla:

```dart
fuente.addListener
(
() => print('Aviso'));
fuente.removeListener(() => print('Aviso
'
)
);
```

No es una forma fiable de recuperar el callback registrado. Dart no garantiza que diferentes evaluaciones de
funciones anónimas produzcan funciones iguales. Tampoco es correcto afirmar que siempre sean distintas.
La referencia es [`Function.operator ==`](https://api.dart.dev/dart-core/Function/operator_equals.html).

El ejemplo C conserva la función entregada en `listener`. Al retirarla vuelve a entregar ese callback sobre la
fuente correspondiente. Los tear-offs de un mismo método sobre el mismo objeto tienen reglas de igualdad propias;
no necesitas depender de ellas para resolver esta práctica.

### Dejar de escuchar y liberar la fuente

`removeListener` termina un registro de escucha según las reglas de la implementación. `dispose`, cuando una
clase lo ofrece, pertenece al ciclo de vida de ese recurso. Un consumidor que recibe una fuente prestada debe retirar
su observación; decidir cuándo liberar la fuente corresponde a su propietario.

Si el consumidor cambia de fuente, primero debe resolver su registro anterior y después el nuevo.
Perder la referencia que permitía retirar un callback puede dejar activa una observación innecesaria. Si la fuente
conserva una closure, también puede mantener accesibles los objetos que esa closure utiliza.
La unidad 13 desarrollará propiedad y liberación; aquí basta con distinguir las operaciones.

### Comprobación

- Registra también `listener` en `preview` al principio de C. Predice qué cambia, teniendo en cuenta la retirada
  que ya viene inmediatamente después.
- Quita `app.removeListener(listener)`. Predice el contador final.
- Explica por qué retirar un listener no impide que la fuente siga avisando a otro.
- Si una variable cambia de una fuente A a una B, explica qué referencia necesitas para retirar el registro de A.

**Puedes avanzar cuando:** puedes señalar la pareja fuente–callback que se conserva, se retira o se sustituye.

## 4.6. Distinguir contrato y política de notificaciones

### El problema

Añadimos el mismo callback dos veces y lo retiramos una. ¿Seguirá escuchando?

El nombre `Listenable` no basta para responder. Debes preguntar qué hace la implementación con los registros.

### Ejemplo D: la política de nuestra lista

Programa completo. Predice las tres líneas y cuenta las entradas que quedan antes de cada emisión.

```dart
import 'package:flutter/foundation.dart';

class AvisadorManual implements Listenable {
  final _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void emitir() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

void main() {
  final avisador = AvisadorManual();
  var llamadas = 0;
  void listener() => llamadas += 1;

  avisador.addListener(listener);
  avisador.addListener(listener);
  avisador.emitir();
  print('Tras dos registros: $llamadas');

  avisador.removeListener(listener);
  avisador.emitir();
  print('Tras una retirada: $llamadas');

  avisador.removeListener(listener);
  avisador.emitir();
  print('Tras dos retiradas: $llamadas');
}
```

### Contrastar implementaciones reales

En `AvisadorManual`, la lista admite dos entradas iguales y cada retirada elimina una. `ChangeNotifier` también
documenta que los registros repetidos requieren las retiradas correspondientes. Lee
[`ChangeNotifier.addListener`](https://api.flutter.dev/flutter/foundation/ChangeNotifier/addListener.html).

La versión **7.1.0** de `signals_flutter` instalada en este proyecto utiliza un mapa de callbacks en
`lib/src/mixins/value_notifier.dart`, dentro de `ValueNotifierSignalMixin`. `putIfAbsent` evita añadir otra suscripción
para una clave de callback ya registrada; `removeListener` retira la entrada y llama a su limpieza.
Es un detalle de esa versión, verificado en el paquete local. No lo conviertas en una regla universal de `Listenable`.

También pertenecen a la implementación estas decisiones:

- Si registrar ejecuta un callback inicial. En A–D y en el controlador actual de DaisyUI no lo ejecuta.
- Qué escrituras provocan un aviso y qué igualdad, si alguna, se utiliza para decidirlo.
- El momento y el orden en que se ejecutan los callbacks.
- Qué ocurre con altas o bajas durante un aviso, avisos recursivos y excepciones.

Por ejemplo, [
`ChangeNotifier.notifyListeners`](https://api.flutter.dev/flutter/foundation/ChangeNotifier/notifyListeners.html)
documenta reglas para listeners añadidos o retirados durante una notificación y para errores lanzados por callbacks.
El pequeño `for` de nuestros ejemplos no reproduce ese comportamiento. Estudiaremos `ChangeNotifier` en la unidad 5.

### Comprobación

- Explica por qué dos llamadas a `addListener` no permiten afirmar lo mismo sobre todas las implementaciones.
- En D, mueve la primera retirada antes del primer aviso. Predice los tres contadores impresos.
- Una prueba muestra que una escritura equivalente no avisa en DaisyUI. ¿Es una prueba de una política concreta
  o una regla que puedas atribuir a cualquier `Listenable`?
- ¿Qué fuente consultarías para decidir qué pasa si un callback retira otro durante un aviso?

**Puedes avanzar cuando:** justificas cada predicción con el cuerpo de una implementación o su documentación,
sin trasladar automáticamente sus reglas al contrato común.

## 4.7. Separar recibir un aviso de reconstruir Flutter

### El problema

Registramos una función que imprime `Aviso`. Cambia el tema y aparece esa impresión.
¿Qué trabajo sobre la interfaz hemos demostrado que se haya solicitado?

### La acción depende del consumidor

En A–D, `listener()` ejecuta código de nuestros ejemplos. Si ese código imprime, obtenemos una impresión.
Para solicitar una actualización de Flutter hace falta que algún consumidor conecte el aviso con el mecanismo
correspondiente del árbol de widgets.

Flutter ofrece consumidores que hacen esa conexión. Por ejemplo,
[`ListenableBuilder`](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html) escucha una fuente
y utiliza un callback `builder` para producir una parte de la interfaz con los datos que consulte.
No debes añadirlo todavía a DaisyUI para entender esta unidad: el proyecto ya utiliza un scope.

### El recorrido del scope actual

En DaisyUI podemos identificar estas responsabilidades:

1. El controlador conserva una señal interna y su método `setTheme` escribe en ella.
2. La señal proporciona el mecanismo de avisos que utiliza la vista pública del tema.
3. `DaisyThemeScope` entrega esa vista como `notifier` a `InheritedNotifier`.
4. El elemento interno de `InheritedNotifier` registra su callback sobre el notifier.
5. Cuando lo recibe, marca la necesidad de construir y conecta la actualización con sus dependientes.
6. Una lectura mediante `DaisyThemeScope.of(context)` declara la dependencia en ese scope; una construcción posterior
   puede volver a consultar el tema actual.

La documentación de [`InheritedNotifier`](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html)
explica esa conexión y la agrupación de varios avisos entre frames. Contar avisos no equivale a contar
reconstrucciones ni repintados.

Para esta unidad basta con identificar el puente. En las unidades de widgets y scopes seguiremos su ciclo de vida,
el registro de dependencias y la planificación de las reconstrucciones. Registrar un callback propio que imprime
un texto no realiza por sí mismo todo ese recorrido.

### Comprobación

- Si un listener incrementa un contador de diagnóstico, identifica qué demuestra ver ese contador aumentar.
- Explica qué consumidor conecta los avisos con el árbol de Flutter en el DaisyUI actual.
- Si se emiten tres avisos entre dos frames, ¿puedes concluir que habrá tres reconstrucciones de cada dependiente?
- Distingue la función registrada mediante `addListener` del callback `builder` de un widget consumidor.

**Puedes avanzar cuando:** describes la acción del listener y señalas el mecanismo que solicita actualizar la
interfaz cuando realmente existe esa conexión.

## 4.8. Seguir los listeners reales de DaisyUI

Los fragmentos de este apartado se contrastaron con el código actual del repositorio. Aquí estudiamos la cadena de
escucha; los detalles de Signals y del ciclo de vida de Flutter se desarrollarán en sus unidades.

### La vista pública también puede usarse como Listenable

En [daisy_theme_controller.dart](../../../lib/themes/application/daisy_theme_controller.dart), `theme` ofrece un
`ValueListenable<DaisyThemeModel>`. Ese contrato extiende `Listenable`, así que podemos conservar esta referencia:

```dart

final Listenable avisos = controller.theme;
```

Es un fragmento que necesita un `controller` ya creado. No transforma la vista en otro objeto. Permite tratarla como
fuente de avisos utilizando solamente el contrato básico. A través de `avisos` puedes registrar y retirar listeners;
para consultar el valor necesitarías una referencia cuyo tipo ofrezca esa lectura.

### El adaptador reenvía el callback

La clase privada `_ThemeListenable` contiene:

```dart
@override
void addListener(VoidCallback listener) => _source.addListener(listener);

@override
void removeListener(VoidCallback listener) =>
    _source.removeListener(listener);
```

No hay `listener()` en esos cuerpos. La vista recibe la función y la entrega a su fuente. No crea otra closure para
envolverla ni necesita una lista propia de listeners. En este controlador, la fuente que recibe el adaptador es la
señal `_palette`.

Por tanto, hay que separar el objeto sobre el que escribimos `addListener` de la implementación que mantiene
efectivamente la observación. Escuchar a través de una vista delegada sigue necesitando retirar el callback
correspondiente al terminar.

### Ejemplo E: dos listeners sobre un controlador real

Esta es una prueba completa para ejecutar localmente. Copia el bloque a un archivo temporal llamado
`test/listenable_practica_test.dart` y ejecuta desde la raíz:

```sh
flutter test --no-pub test/listenable_practica_test.dart
```

Antes de ejecutarla, escribe los dos contadores después del registro y después de cada cambio de tema.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dos listeners y retirada independiente', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    final Listenable avisos = controller.theme;

    var panel = 0;
    var diagnostico = 0;
    void actualizarPanel() => panel += 1;
    void registrarDiagnostico() => diagnostico += 1;

    avisos.addListener(actualizarPanel);
    avisos.addListener(registrarDiagnostico);
    expect(panel, 0);
    expect(diagnostico, 0);

    controller.setTheme(DaisyThemes.dark);
    expect(panel, 1);
    expect(diagnostico, 1);

    avisos.removeListener(actualizarPanel);
    controller.setTheme(DaisyThemes.cupcake);
    expect(panel, 1);
    expect(diagnostico, 2);

    avisos.removeListener(registrarDiagnostico);
    controller.setTheme(DaisyThemes.light);
    expect(panel, 1);
    expect(diagnostico, 2);
  });
}
```

El controlador es local y su tema inicial predeterminado es `DaisyThemes.light`. Cambiamos a temas diferentes para
centrarnos en las suscripciones. La igualdad y las escrituras equivalentes se estudian más adelante.

Aquí `actualizarPanel` incrementa un entero: el nombre de la función no añade un widget ni pide reconstruirlo.
Las comprobaciones establecen el comportamiento de los listeners en estas operaciones concretas.

### Encontrarlo en las pruebas existentes

En [daisy_theme_controller_test.dart](../../../test/themes/daisy_theme_controller_test.dart), localiza
`Theme views notify on changes and support listener removal`. Recorre el registro, la escritura equivalente,
el cambio a otro tema, la retirada y el siguiente cambio.
La prueba aplica el recorrido tanto a la vista del servicio global como a la de un controlador local.

Puedes ejecutar ese archivo sin crear ningún material adicional:

```sh
flutter test --no-pub test/themes/daisy_theme_controller_test.dart
```

El [servicio](../../../lib/themes/application/daisy_theme_service.dart) delega en su controlador predeterminado.
El [scope](../../../lib/themes/application/daisy_theme_scope.dart) entrega la vista del controlador recibido, o la del
servicio cuando no recibe uno, a `InheritedNotifier`.
La [extensión de contexto](../../../lib/themes/core/extension/build_context.dart)
delega en `DaisyThemeScope.of` y el [ejemplo](../../../example/lib/main.dart) utiliza esa lectura en sus construcciones.
Así puedes localizar registro de escucha, fuente de estado y consumidor de interfaz por separado.

### Comprobación

- En E, retira `actualizarPanel` antes del cambio a oscuro. Predice qué expectativas debes modificar.
- Conserva los listeners y elimina solo el cambio a `cupcake`. Predice ambos contadores antes de la última retirada.
- Explica por qué `_ThemeListenable.addListener` no ejecuta directamente el cuerpo recibido.
- Identifica quién posee y libera el controlador en E. Explica por qué el tipo `Listenable` no ofrece esa liberación.

**Puedes avanzar cuando:** sigues el registro desde la vista hasta la señal y distingues esta prueba de listeners
de una prueba que pulsa botones o comprueba widgets reconstruidos.

## Materiales de estudio seleccionados

La explicación y los ejercicios están en español. Las fuentes principales son documentación oficial en inglés.
Lee la parte indicada, vuelve al ejemplo y justifica una predicción con lo que acabas de leer.

- **F1 · Flutter: [Listenable](https://api.flutter.dev/flutter/foundation/Listenable-class.html)** — nodos 4.1–4.2.
  Identifica los miembros de escucha y separa los consumidores citados de la fuente observable.
- **F2 · Flutter: [addListener](https://api.flutter.dev/flutter/foundation/Listenable/addListener.html) y
  [removeListener](https://api.flutter.dev/flutter/foundation/Listenable/removeListener.html)** — nodos 4.2–4.5.
  Lee las firmas. Señala qué función se entrega y sobre qué fuente.
- **F3 · Flutter: [VoidCallback](https://api.flutter.dev/flutter/dart-ui/VoidCallback.html)** — nodo 4.2.
  Escribe su firma sin el alias y explica por qué el listener de B necesita consultar el tema por otro camino.
- **D1 · Dart: [Function.operator ==](https://api.dart.dev/dart-core/Function/operator_equals.html)** — nodo 4.5.
  Lee las reglas de igualdad de funciones anónimas y métodos extraídos. Justifica por qué conservamos el callback.
- **F4 ·
  Flutter: [ChangeNotifier.addListener](https://api.flutter.dev/flutter/foundation/ChangeNotifier/addListener.html)**
  y [removeListener](https://api.flutter.dev/flutter/foundation/ChangeNotifier/removeListener.html) — nodo 4.6.
  Lee la política de registros repetidos. Todavía no necesitas aprender su implementación interna.
- **F5 ·
  Flutter: [ChangeNotifier.notifyListeners](https://api.flutter.dev/flutter/foundation/ChangeNotifier/notifyListeners.html)**
  — nodo 4.6. Reconoce que las altas, bajas y excepciones durante un aviso tienen reglas explícitas en esa clase.
- **F6 · Flutter: [ListenableBuilder](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html)** e
  [InheritedNotifier](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html) — nodo 4.7.
  Identifica qué conecta los avisos con las actualizaciones de widgets. El estudio completo de esos widgets vendrá
  después.
- **F7 · Flutter: [ValueListenable](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html)** — nodo 4.8.
  Identifica el getter añadido y los miembros de escucha heredados. Su desarrollo corresponde a la unidad 6.
- **P1 · [DartPad](https://dartpad.dev/)** — A–D y proyecto en modo Flutter. Para E utiliza el repositorio local.
  No confundas importar `package:flutter` con disponer del paquete local `daisy_ui` en un pad público.

## Proyecto de la unidad: observadores que pueden dejar de escuchar

Escribe un programa con `AvisadorManual` y consumidores que conozcan solamente `Listenable`.

### Requisitos

1. Reutiliza la clase didáctica y sus límites: las retiradas se realizan fuera de una emisión.
2. Escribe `VoidCallback observar(Listenable fuente, String etiqueta)`.
3. Dentro, crea un contador propio para esa observación y un listener que lo incremente e imprima etiqueta y contador.
4. Registra ese listener y devuelve una función que lo retire de la misma fuente. La función devuelta servirá para
   detener esa observación; la decides tú, no la devuelve `addListener`.
5. Crea dos avisadores independientes, `app` y `preview`. Observa `app` con las etiquetas `Panel` y `Log`; observa
   `preview` con la etiqueta `Preview`.
6. Emite en `app`, detén `Panel`, vuelve a emitir en `app` y emite en `preview`.
7. Detén las observaciones restantes y emite en ambas fuentes. Después registra un listener nuevo en `app`, emite
   y retíralo. Demuestra que retirar consumidores permite seguir utilizando la fuente.
8. Predice la salida completa e identifica qué pareja fuente–callback conserva cada función de limpieza.

El tipo de retorno `VoidCallback` significa que `observar` devuelve una función sin argumentos.
Llamar a `observar(...)` prepara la observación; llamar después a la función obtenida la retira.
Es el uso de funciones como valores y closures de la unidad 2.

### Variaciones

- Cambia la etiqueta de una observación y comprueba si eso modifica las demás.
- Vuelve a observar `app` después de detener `Panel`. Predice el contador inicial de esa nueva observación.
- Explica qué fallaría si la función de limpieza fabricara otra closure para retirar el listener.
- Añade un dato mutable fuera del avisador y haz que un listener lo consulte. Cambia el dato sin emitir y después
  emite dos veces sin volver a cambiarlo.
- Explica qué parte podrías reutilizar con el tema de DaisyUI sin exigir que el consumidor conozca Signals.

**Entrega de estudio:** código, predicción, salida obtenida y explicación del registro, emisión y retirada de cada
observación. No hace falta construir una pantalla para superar esta unidad.

## Errores de comprensión que vamos a comprobar

- Confundir una lectura puntual con una suscripción.
- Creer que `Listenable` aporta por sí mismo la lista concreta y el método de emisión de cualquier implementación.
- Entregar `listener()` cuando se necesita entregar `listener`.
- Suponer que el listener recibe el nuevo tema como argumento.
- Esperar que un aviso reemplace una lectura guardada anteriormente.
- Confundir la fuente que expone el registro con el objeto que guarda internamente la observación.
- Reescribir una función anónima y dar por hecho que retira la registrada.
- Retirar el callback de una fuente distinta de aquella sobre la que se registró.
- Atribuir a todo `Listenable` la política de duplicados, igualdad o errores de una implementación.
- Confundir dejar de escuchar, destruir una función y liberar el recurso observado.
- Dar por probada una reconstrucción de pantalla al ver un log o aumentar un contador.
- Contar avisos como si cada uno tuviera que producir una reconstrucción y un repintado independientes.

## Comprobación final

Responde sin consultar las soluciones:

1. ¿Qué relación establece una suscripción y qué participantes puedes identificar?
2. ¿Qué operaciones de escucha garantiza `Listenable`? ¿Dónde aparecen sus implementaciones concretas?
3. ¿Qué significa `VoidCallback` y qué devuelve `addListener`?
4. En A, ¿cuál es la única línea del avisador que ejecuta el cuerpo de una función registrada?
5. ¿Qué contiene la lista antes de cada una de las tres emisiones de A?
6. ¿Por qué `fuente` y `avisador` acceden al mismo objeto, pero no permiten las mismas llamadas?
7. En B, ¿dónde vive el dato actual, qué conserva `guardado` y cómo accede el listener a ambos?
8. ¿Cómo muestra B un cambio sin aviso y dos avisos sin una escritura nueva entre ambos?
9. ¿Qué pareja hay que conservar para retirar una observación? ¿Por qué falla la primera retirada de C?
10. ¿Qué puedes afirmar sobre la igualdad de dos funciones anónimas escritas con el mismo cuerpo?
11. En D, ¿por qué una retirada deja todavía un registro? ¿Puedes trasladarlo a toda implementación?
12. ¿Qué política distinta tiene el puente de listeners de Signals verificado en este proyecto?
13. ¿Qué debe hacer un consumidor que deja de necesitar una fuente prestada? ¿Quién decide liberarla?
14. ¿Qué hace `_ThemeListenable` con los callbacks que recibe y quién proporciona el mecanismo de avisos?
15. En E, ¿qué valores tienen los contadores en cada punto? ¿Qué comportamiento demuestra la prueba?
16. ¿Quién conecta los avisos con las dependencias de Flutter en DaisyUI? ¿Por qué un log no demuestra ese trabajo?
17. ¿Por qué tres avisos no permiten deducir tres reconstrucciones de cada consumidor?
18. ¿Qué devuelve nuestra función `observar` y qué referencias necesita conservar para funcionar después?

Marca la unidad como dominada cuando puedas resolver el proyecto sin copiar y describir estos recorridos.
Si se mezclan entrega y ejecución, vuelve a la unidad 2. Si se mezclan contrato e implementación, vuelve a la 3.
Si ya puedes señalar quién escucha y cómo se retira, continúa con `ChangeNotifier` en la unidad 5 para estudiar una
implementación de producción de los avisos.

## Soluciones para contrastar después de practicar

<details>
<summary>Ver salidas, solución del proyecto y claves de las comprobaciones</summary>

### Ejemplo A

```text
Antes de registrar
Antes del primer aviso
Panel avisado
Diagnostico avisado
Antes del segundo aviso
Diagnostico avisado
Fin
```

Las listas antes de emitir son `[panel, diagnostico]`, `[diagnostico]` y `[]`.
Registrar y retirar no llaman a los cuerpos en esta implementación. Una llamada directa a `panel()` después de
retirarlo sigue imprimiendo su texto porque la función continúa disponible.

### Ejemplo B

```text
Sin aviso: oscuro
Actual: oscuro; guardado: claro
Actual: oscuro; guardado: claro
Actual: cupcake; guardado: claro
Final: forest
```

Hay tres reasignaciones a `tema` y tres ejecuciones de `mostrar`. Eso no establece una correspondencia entre ellas:
el cambio a `forest` no lo observa el listener y la segunda emisión lee `oscuro` sin otra escritura intermedia.
Si quitas el primer aviso, `'oscuro'` aparece dos veces en la salida: en la impresión directa y en el aviso restante.
Si mueves su asignación después de los dos primeros avisos, ambos leen todavía `'claro'`.

### Ejemplo C

```text
Aviso 1
Aviso 2
Fin: 2
```

La primera emisión de `app` ejecuta el callback. La primera de `preview` no tiene listeners.
La segunda de `app` ocurre después de su retirada. La segunda de `preview` ocurre después de su propio registro.
Si quitas la retirada de `app`, su segunda emisión incrementa el contador y el valor final pasa a `3`.

### Ejemplo D

```text
Tras dos registros: 2
Tras una retirada: 3
Tras dos retiradas: 3
```

Antes de emitir quedan dos, una y cero entradas. El contador acumula llamadas, no cuenta los registros actuales.
Si adelantas la primera retirada hasta antes de la primera emisión, los contadores impresos pasan a `1`, `2`, `2`.
Las retiradas posteriores no encuentran más entradas después de eliminar la que quedaba.

### Ejemplo E

Los pares `(panel, diagnostico)` son `(0, 0)`, `(1, 1)`, `(1, 2)` y `(1, 2)`.
Las retiradas afectan de forma independiente a cada callback. El último cambio se realiza con ambos retirados.
La prueba comprueba listeners y contadores sobre un controlador real; no contiene widgets ni pulsaciones.

Si retiras el panel antes del primer cambio, se mantiene en `0` y el diagnóstico recorre `0`, `1`, `2`, `2`.
Si eliminas solo el cambio a `cupcake`, el diagnóstico sigue en `1` antes de retirarlo y el último cambio tampoco lo
incrementa. Retirar el panel no altera los avisos del diagnóstico.

### Una solución del proyecto

Programa completo para un pad de Flutter. Cada llamada a `observar` crea su propio contador y conserva su fuente
y su listener en la función de limpieza devuelta.

```dart
import 'package:flutter/foundation.dart';

class AvisadorManual implements Listenable {
  final _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void emitir() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

VoidCallback observar(Listenable fuente, String etiqueta) {
  var avisos = 0;

  void listener() {
    avisos += 1;
    print('$etiqueta: $avisos');
  }

  fuente.addListener(listener);
  return () => fuente.removeListener(listener);
}

void main() {
  final app = AvisadorManual();
  final preview = AvisadorManual();

  final detenerPanel = observar(app, 'Panel');
  final detenerLog = observar(app, 'Log');
  final detenerPreview = observar(preview, 'Preview');

  app.emitir();
  detenerPanel();
  app.emitir();
  preview.emitir();

  detenerLog();
  detenerPreview();
  app.emitir();
  preview.emitir();

  print('Fuentes disponibles');
  void nuevo() => print('Nuevo observador');
  app.addListener(nuevo);
  app.emitir();
  app.removeListener(nuevo);
}
```

Salida:

```text
Panel: 1
Log: 1
Log: 2
Preview: 1
Fuentes disponibles
Nuevo observador
```

`observar` no pide `.value`, una escritura ni una operación de liberación. Trabaja con el contrato de escucha.
Las funciones devueltas conocen la fuente y el callback de su propia llamada. `addListener` sigue devolviendo `void`;
el mecanismo de limpieza devuelto lo hemos construido en nuestra función.

### Claves de la comprobación final

1. Una fuente conserva o delega un registro asociado a un callback de un consumidor; la implementación produce el aviso.
2. El contrato ofrece registro y retirada. Los cuerpos los aporta cada implementación, directamente o por delegación.
3. `VoidCallback` es `void Function()`. `addListener` devuelve `void`.
4. `listener()` dentro del `for`.
5. Dos entradas, solamente el diagnóstico y ninguna entrada.
6. Asignar la referencia no crea otro objeto; el tipo declarado limita las operaciones disponibles.
7. `tema` conserva la referencia actual; `guardado`, el texto inicial. La closure accede a ambas variables.
8. La asignación no llama al avisador y el segundo `emitir` no requiere otra escritura.
9. La fuente usada para registrar y el callback correspondiente. La retirada inicial de C se pide a otra fuente.
10. Repetir el cuerpo de una función anónima no garantiza igualdad ni desigualdad entre evaluaciones.
11. Nuestra lista admite duplicados y retira una entrada. Esa política no la fija el contrato común.
12. En el puente local de Signals 7.1.0, el mapa evita otra suscripción para el mismo callback.
13. Retirar su observación. El propietario de la fuente decide cuándo termina su vida útil.
14. Reenvía registro y retirada a `_source`; la señal interna proporciona la observación subyacente.
15. Los cuatro pares indicados en E; verifica registro sin llamada inicial, avisos y retiradas independientes.
16. `InheritedNotifier` conecta la fuente con sus dependientes. Imprimir solo demuestra la ejecución de esa impresión.
17. Los avisos pueden agruparse entre frames; notificación, reconstrucción y repintado son operaciones distintas.
18. Devuelve un callback de limpieza que conserva la fuente y el listener registrados en esa observación.

</details>

## Qué se ha revisado y cómo se ha comprobado

- Se contrastaron el contrato y las firmas con las referencias oficiales enlazadas y el SDK de Flutter instalado.
- Se leyeron el controlador, el servicio, el scope, la extensión de contexto, el ejemplo y las pruebas de controladores.
- El servidor MCP rechazó indexar esta raíz. La búsqueda y la comprobación de cobertura no encontraron un proyecto
  indexado; las afirmaciones sobre el repositorio se contrastaron mediante lectura directa de los archivos indicados.
- Se revisó el puente de listeners de `signals_flutter 7.1.0` instalado y el elemento interno de `InheritedNotifier`
  para distinguir delegación, política de suscripciones y conexión con Flutter.
- Los seis programas completos (A–E y solución del proyecto) se extrajeron del documento y se analizaron con **Dart
  3.13.5**, sin incidencias. Se ejecutaron mediante pruebas temporales con **Flutter 3.47.7**.
- Pasaron **18 pruebas**: las cinco salidas de A–D y el proyecto, siete variaciones de los ejercicios, E, dos
  contrastes de registros repetidos y las tres pruebas existentes del controlador. Las salidas coincidieron con
  las soluciones documentadas.
- Se confirmó el rechazo de cinco usos incorrectos: `.value`, `notifyListeners`, `dispose` y `emitir` sobre un
  `Listenable`, y entregar el resultado `void` de `avisar()` a `addListener`.
- Se comprobaron los enlaces locales, las anclas de navegación, los bloques de código, las soluciones y los espacios.
  `git diff --check` terminó sin incidencias.
- Estas pruebas ejecutan ejemplos y controladores; no validan pulsaciones, reconstrucciones ni repintados de una
  interfaz real. El progreso de estudio se marca al resolver y explicar las prácticas, no al elaborar la guía.
