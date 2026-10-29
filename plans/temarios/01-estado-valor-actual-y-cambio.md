# 01. Estado, valor actual y cambio

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md)

- **Bloque:** las bases para comprender la observación.
- **Estado de estudio:** pendiente.
- **Investigación de fuentes:** 19 de octubre de 2026.

## Qué vas a conseguir

Podrás seguir un dato desde que se guarda hasta que se vuelve a leer, explicar por qué una lectura anterior puede
conservar un valor distinto y reconocer qué falta para que una pantalla refleje un cambio.

Los cinco conceptos centrales son **estado**, **valor actual**, **lectura puntual**, **cambio** y **fuente de verdad**.
Los estudiaremos con nombres de temas antes de entrar en los mecanismos de Signals y Flutter.

## Cómo seguiremos el enfoque de roadmap.sh

Tomamos como referencia el [roadmap de Flutter](https://roadmap.sh/flutter), sus
[temas con recursos asociados](https://roadmap.sh/flutter/state-management) y la práctica mediante
[proyectos](https://roadmap.sh/projects). Esta unidad adapta esa estructura a nuestro proyecto: nodos pequeños, un orden
explícito, recursos seleccionados y un ejercicio que conecta todo.

La explicación paso a paso, las preguntas y los criterios de dominio que aparecen aquí son nuestra adaptación docente.

En cada nodo trabajaremos así:

1. Partiremos de un problema concreto.
2. Explicaremos una idea y el vocabulario que necesita.
3. Predecirás el resultado de un ejemplo antes de ejecutarlo.
4. Estudiarás el recurso indicado para contrastar la explicación.
5. Resolverás una variación sin copiar y explicarás el resultado con tus palabras.

Una casilla marcada significa que puedes resolver y explicar la comprobación. Haber leído una página o terminado un
vídeo sirve para estudiar; la comprobación demuestra qué has comprendido.

## Ruta y progreso

Antes de empezar basta con reconocer un texto entre comillas, una variable, una asignación con `=` y `print`.
El nodo 1.2 incluye el repaso necesario. Si algo de esa sintaxis resulta nuevo, lo explicaremos al llegar a ella.

- [ ] [1.1. Reconocer el estado](#11-reconocer-el-estado).
- [ ] [1.2. Leer el valor que existe ahora](#12-leer-el-valor-que-existe-ahora).
- [ ] [1.3. Seguir un cambio en el tiempo](#13-seguir-un-cambio-en-el-tiempo).
- [ ] [1.4. Elegir la fuente de verdad](#14-elegir-la-fuente-de-verdad).
- [ ] [1.5. Separar lectura, observación y actualización visual](#15-separar-lectura-observación-y-actualización-visual).
- [ ] [1.6. Reconocer estas piezas en DaisyUI](#16-reconocer-estas-piezas-en-daisyui).
- [ ] [Completar el proyecto de la unidad](#proyecto-de-la-unidad-un-tema-y-tres-lecturas).
- [ ] [Superar la comprobación final](#comprobación-final).

Puedes repartir la ruta en varias sesiones. Para empezar, trabaja solamente los nodos 1.1 y 1.2.

## 1.1. Reconocer el estado

### El problema

Una aplicación muestra el tema claro. Pulsas un botón y quieres que muestre el oscuro. Antes de hablar de pantallas o
notificaciones necesitamos responder: ¿qué dato representa la selección que está vigente?

### La idea

Para esta unidad, el estado es la información que necesitamos para describir cómo debe estar la aplicación en un
momento determinado. Algunos ejemplos son el tema elegido, el contenido de un formulario o si una operación está
cargando. Flutter propone una definición útil para la interfaz: los datos necesarios para poder reconstruirla.
Consulta la introducción
de [Ephemeral state and app state](https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app).

En nuestro ejemplo, el dato que interesa es el tema elegido. El botón permite solicitar un cambio; el texto que aparece
en pantalla representa ese dato.

Imagina una ficha donde se escribe «claro» u «oscuro». La ficha conserva la selección y un cartel muestra lo que alguien
leyó de ella. Si se escribe otra selección en la ficha, hay que ocuparse también de actualizar el cartel. La analogía
sirve para separar almacenamiento y presentación; los detalles de memoria y reconstrucción se estudiarán con código.

### Vocabulario que debes separar

- **Estado:** el dato o conjunto de datos que describe la situación que nos interesa.
- **Valor:** el contenido concreto de ese dato en un momento: por ejemplo, `'claro'`.
- **Variable:** un nombre con el que el programa puede acceder a una referencia. Puede utilizarse para representar
  estado, un resultado temporal o una lectura anterior.
- **Interfaz:** lo que la aplicación presenta a partir de los datos que leyó.

El concepto general de estado también existe en un programa Dart sin pantalla. La clase `State` de Flutter es una pieza
concreta del framework y la estudiaremos en las unidades de widgets. Aquí nos basta con distinguir ambos significados.

### Comprobación

En una pantalla hay un botón «Cambiar tema», una selección guardada como `'claro'` y una etiqueta «Tema: claro».
Explica qué conserva la selección, qué solicita cambiarla y qué la representa visualmente.

**Puedes avanzar cuando:** identificas el dato que interesa sin confundirlo con el botón o con su representación.

## 1.2. Leer el valor que existe ahora

### El problema

Lees el tema actual, guardas el resultado y después cambias el tema. ¿La variable donde guardaste la lectura cambia
también?

### Repaso mínimo de Dart

- `var temaActual = 'claro';` declara una variable y la inicializa con un texto.
- `temaActual = 'oscuro';` vuelve a asignar esa variable.
- `final lecturaAntes = temaActual;` evalúa la expresión de la derecha y guarda su resultado. Esa variable `final`
  solo puede asignarse una vez.
- `print(lecturaAntes);` muestra su valor en la consola.

En Dart, las variables conservan referencias a objetos. Asignar una variable a otra no establece una relación que
vuelva a ejecutar la expresión cuando cambie la primera. Puedes contrastarlo con
[Variables](https://dart.dev/language/variables).

### Ejemplo A: una lectura guardada

Este programa está completo. Puedes ejecutarlo en un pad de **Dart** de [DartPad](https://dartpad.dev/).
Antes de pulsar Run, escribe las cuatro líneas que esperas ver.

```dart
void main() {
  var temaActual = 'claro';
  final lecturaAntes = temaActual;

  print(temaActual);

  temaActual = 'oscuro';
  final lecturaDespues = temaActual;

  print(lecturaAntes);
  print(temaActual);
  print(lecturaDespues);
}
```

Recorre el programa deteniéndote después de cada asignación:

1. `temaActual` permite acceder al texto `'claro'`.
2. `lecturaAntes` recibe el resultado de leer `temaActual` en ese momento.
3. La nueva asignación hace que `temaActual` permita acceder a `'oscuro'`.
4. `lecturaAntes` sigue conservando la referencia que recibió.
5. `lecturaDespues` obtiene el resultado de una lectura nueva.

A esa consulta realizada en un momento concreto la llamaremos **lectura puntual**. El valor actual depende de cuándo
vuelves a consultar la fuente.

En este ejemplo usamos textos, que son [objetos inmutables](https://api.dart.dev/dart-core/String-class.html). Guardar
una
referencia a un objeto mutable, como una lista, permite compartir ese mismo objeto: una lectura guardada no equivale a
una copia profunda. Profundizaremos en referencias e inmutabilidad en las unidades 3 y 8.

### Comprobación

Cambia `final lecturaAntes` por `var lecturaAntes`. Predice si eso hará que se actualice por sí sola. Después añade una
asignación explícita `lecturaAntes = temaActual;` tras el cambio y explica qué diferencia introduce.

**Puedes avanzar cuando:** justificas por qué una lectura anterior y otra nueva pueden dar resultados diferentes.

## 1.3. Seguir un cambio en el tiempo

### El problema

Decir «el tema cambió» es ambiguo si no sabemos qué valor tenía antes, qué operación ocurrió y qué valor tiene después.

### La idea

Un cambio de valor se describe comparando dos momentos de la misma fuente:

1. Antes de la operación, `temaActual` contiene `'claro'`.
2. Se ejecuta `temaActual = 'oscuro';`.
3. Una lectura posterior obtiene `'oscuro'`.

Separa estas tres preguntas: **¿qué ocurrió?, ¿qué dato se modificó?, ¿quién se enteró?**

Una pulsación es un evento. La asignación es una operación sobre el dato. Que otro participante reciba un aviso necesita
un mecanismo de comunicación. El ejemplo A solo demuestra asignaciones y lecturas; no contiene una suscripción.

También puedes ejecutar `temaActual = 'oscuro';` cuando ya tiene ese texto. Hay una asignación, aunque el valor textual
antes y después sea el mismo. Qué avisos produce una implementación observable depende de su política; estudiaremos
esas políticas en las unidades de notifiers y señales.

### Comprobación

Partiendo de `'claro'`, realiza estas operaciones y anota el valor después de cada una:

1. Asignar `'oscuro'`.
2. Leer y guardar el resultado en `primeraLectura`.
3. Asignar otra vez `'oscuro'`.
4. Asignar `'claro'`.
5. Leer de nuevo la fuente.

Explica qué conserva `primeraLectura` al terminar y qué pasos modificaron el valor textual respecto al anterior.

**Puedes avanzar cuando:** describes la secuencia con valores concretos y distingues una asignación de una observación.

## 1.4. Elegir la fuente de verdad

### El problema

La aplicación conserva un tema seleccionado y también una etiqueta guardada por separado. Cambias uno y olvidas
actualizar el otro. Ahora una parte dice «oscuro» y otra sigue diciendo «Tema: claro».

### La idea

La **fuente de verdad** es la autoridad que consultamos para saber cuál es el dato vigente y a través de la cual
administramos sus cambios. La documentación de Flutter presenta este principio como
[Single source of truth](https://docs.flutter.dev/app-architecture/concepts#single-source-of-truth).

Para el tema de este ejercicio elegiremos `temaActual`. El texto que lo describe puede calcularse a partir de una
lectura de esa variable. Si además guardamos ese texto como otro dato que pretendemos mantener actualizado, tendremos
dos valores que coordinar.

### Ejemplo B: una descripción que quedó antigua

Programa completo para un pad de Dart. Predice sus tres líneas de salida.

```dart
void main() {
  var temaActual = 'claro';
  final etiquetaGuardada = 'Tema: $temaActual';

  temaActual = 'oscuro';

  print(temaActual);
  print(etiquetaGuardada);
  print('Tema: $temaActual');
}
```

La expresión `'Tema: $temaActual'` construye un texto utilizando el valor leído al evaluarla. El texto guardado conserva
ese resultado. La última línea vuelve a evaluar la expresión y puede producir un texto distinto.
La [API de String](https://api.dart.dev/dart-core/String-class.html) documenta esta interpolación.

Conservar una lectura antigua es útil si queremos un historial o una comparación. El error aparece cuando la utilizamos
como si representara necesariamente el valor vigente.

Una fuente de verdad se elige para un dato y un ámbito. La selección de tema de toda la aplicación y la selección de una
vista previa pueden ser dos estados independientes. Cada uno puede tener su propio responsable. Compartir el mismo
tipo de dato no obliga a compartir una instancia global.

### Comprobación

Diseña en papel una selección de tema con un nombre y un texto «Tema seleccionado: …». Señala qué guardarás, qué
calcularás al leer y por dónde aceptarás cambios. Después añade una vista previa con su propia selección.

**Puedes avanzar cuando:** identificas una autoridad para cada selección y explicas qué datos se obtienen de ella.

## 1.5. Separar lectura, observación y actualización visual

### El problema

Un `print` confirma que el dato ya contiene `'oscuro'`, pero la pantalla sigue mostrando «claro». ¿Cuál de las dos
observaciones es incorrecta?

### Las tres operaciones

1. **Leer:** consultar el valor en ese momento.
2. **Observar cambios:** establecer una relación para recibir avisos futuros según un mecanismo concreto.
3. **Actualizar la interfaz:** conseguir que Flutter vuelva a construir la parte correspondiente utilizando los datos
   que queremos mostrar.

Las dos observaciones del problema pueden ser correctas: el dato cambió y la interfaz todavía presenta el resultado de
una lectura anterior. Para comprender el modelo declarativo, lee
[Start thinking declaratively](https://docs.flutter.dev/data-and-backend/state-mgmt/declarative).

La expresión habitual `UI = f(state)` indica que describimos la interfaz a partir del estado. Para que refleje otro
valor, el flujo de actualización debe provocar una construcción que lo vuelva a utilizar. Un texto creado antes no se
reescribe por una asignación posterior a una variable.

Flutter ofrece mecanismos distintos para conectar datos y consumidores. Como anticipo, el contrato
[`Listenable`](https://api.flutter.dev/flutter/foundation/Listenable-class.html) permite registrar funciones que
recibirán
avisos. Leer un valor y registrar una función son operaciones diferentes. Su implementación será el centro de las
unidades siguientes.

### Un primer puente con Flutter

Para estado local administrado en un objeto `State`, `setState` ejecuta inmediatamente la función que recibe y después
solicita al framework una reconstrucción. La asignación ocurre durante esa función; la nueva interfaz se construye
posteriormente. Consulta la descripción inicial de
[`State.setState`](https://api.flutter.dev/flutter/widgets/State/setState.html).

Una asignación ordinaria a un campo no solicita por sí sola esa reconstrucción. La pantalla puede llegar a mostrar el
nuevo dato si otro motivo provoca una reconstrucción; ese resultado accidental no demuestra que exista una observación
del campo. Reconstrucción y pintura son etapas diferentes que estudiaremos en la unidad 18.

### Laboratorio guiado de Flutter

Este código es un andamiaje para experimentar. Las clases, los callbacks y los métodos se explicarán en sus unidades.
Ahora sigue el campo `temaActual`, las lecturas y las solicitudes de reconstrucción.

Ejecuta el programa completo en un pad de **Flutter** de DartPad. Usa los botones, sin editar código ni hacer hot reload
durante la secuencia.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: LaboratorioEstado()));
}

class LaboratorioEstado extends StatefulWidget {
  const LaboratorioEstado({super.key});

  @override
  State<LaboratorioEstado> createState() => _LaboratorioEstadoState();
}

class _LaboratorioEstadoState extends State<LaboratorioEstado> {
  String temaActual = 'claro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estado y lectura')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tema leído al construir: $temaActual'),
            ElevatedButton(
              onPressed: () {
                temaActual = 'oscuro';
                debugPrint('Valor actual: $temaActual');
              },
              child: const Text('1. Cambiar solamente el dato'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  temaActual = 'claro';
                });
              },
              child: const Text('2. Cambiar y solicitar reconstrucción'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // El dato ya cambió; queremos volver a mostrarlo.
                });
              },
              child: const Text('3. Reconstruir con el valor actual'),
            ),
          ],
        ),
      ),
    );
  }
}
```

Haz este recorrido:

1. Al iniciar, predice el valor del campo y el texto mostrado.
2. Pulsa el botón 1. Compara la consola con el texto. El campo ya contiene `'oscuro'`, aunque esta operación no ha
   solicitado reconstruir el texto.
3. Pulsa el botón 3. Explica por qué ahora puede mostrarse `'oscuro'` sin asignar otro valor.
4. Pulsa el botón 2. Localiza la asignación y la solicitud de reconstrucción.

El botón 3 sirve para aislar la reconstrucción en este experimento. En una actualización normal de este campo local,
agruparemos el cambio y su solicitud como hace el botón 2.

**Puedes avanzar cuando:** explicas por separado qué cambió en memoria, qué se leyó y quién pidió reconstruir.

## 1.6. Reconocer estas piezas en DaisyUI

Ahora abre el [controlador de temas](../../lib/themes/application/daisy_theme_controller.dart). Los fragmentos
siguientes
pertenecen a ese archivo; se leen dentro de su contexto y no son programas independientes.

La inicialización y el campo interno son:

```dart
DaisyThemeController
(
{
DaisyThemeModel
initialTheme = DaisyThemes.light})
    : _palette = signal<DaisyThemeModel>(initialTheme);

final FlutterSignal<DaisyThemeModel> _palette;
```

Para esta unidad, reconoce que cada controlador posee una señal que conserva su tema actual. El tema inicial procede
del argumento `initialTheme`. El [modelo](../../lib/themes/domain/theme.dart) describe los datos de un tema, entre ellos
su identificador y su nombre.

La operación de cambio es:

```dart
void setTheme(DaisyThemeModel theme) {
  _palette.value = theme;
}
```

Localiza la autoridad para esa selección: el controlador administra las escrituras y su señal conserva el valor.
La mecánica de notificaciones se estudiará en la unidad 9.

La API pública `controller.theme` da acceso a una vista de lectura. En el adaptador privado, la lectura termina aquí:

```dart
DaisyThemeModel get value => _source.value;
```

Ese getter consulta la fuente cuando se ejecuta. Si guardas el resultado de `controller.theme.value`, conservas el
modelo obtenido en esa lectura. Una consulta posterior puede devolver el tema nuevo. El adaptador no guarda otro tema
que tengamos que sincronizar.

El [servicio predeterminado](../../lib/themes/application/daisy_theme_service.dart) conserva un controlador y delega en
él.
Es una forma de compartir una selección. Crear otro controlador permite administrar otra selección independiente.

### Comprobación sobre el archivo real

Señala, en este orden:

1. Dónde se recibe el tema inicial.
2. Qué objeto conserva el valor actual.
3. Qué método permite cambiarlo.
4. Dónde termina una consulta del valor a través de la vista pública.
5. Qué conservaría una variable que guardó el resultado antes de una sustitución del tema.

**Puedes avanzar cuando:** conectas almacenamiento, escritura y lectura con líneas concretas del controlador.

## Materiales de estudio seleccionados

Los recursos de esta ruta son documentación pública, herramientas abiertas y lecciones de YouTube publicadas en abierto.
Cada recurso tiene una tarea. Puedes elegir el apoyo audiovisual en el idioma que prefieras y consultar el otro para
reforzar una duda.

### Documentación y práctica oficial

- **D1 ·
  Flutter: [Ephemeral state and app state](https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app)**
  — inglés, lectura principal del nodo 1.1. Lee la definición inicial de estado y reconoce dos ejemplos propios.
  Las secciones de estado local y compartido son una ampliación; la página explica que esa clasificación depende de las
  necesidades de la aplicación.
- **D2 · Dart: [Variables](https://dart.dev/language/variables)** — inglés, referencia del nodo 1.2. Lee el inicio y la
  explicación de `final`. Responde qué guarda una variable y qué operación está permitida sobre ella.
- **D3 · Dart: [String](https://api.dart.dev/dart-core/String-class.html)** — inglés, referencia de los nodos 1.2 y 1.4.
  Busca los párrafos sobre inmutabilidad e interpolación; no necesitas recorrer todos sus métodos.
- **D4 · Flutter: [Start thinking declaratively](https://docs.flutter.dev/data-and-backend/state-mgmt/declarative)**
  — inglés, lectura principal del nodo 1.5. Explica la relación entre el estado y la descripción de la interfaz.
- **D5 · Flutter: [Single source of truth](https://docs.flutter.dev/app-architecture/concepts#single-source-of-truth)**
  — inglés, lectura principal del nodo 1.4. Lee esa sección y aplica el principio al tema y a su etiqueta.
- **D6 · Flutter: [setState](https://api.flutter.dev/flutter/widgets/State/setState.html)** — inglés, consulta del
  laboratorio. Lee hasta el primer ejemplo de persistencia. Identifica lo que sucede inmediatamente y lo que se
  programa para después. La persistencia y el resto de detalles quedan como ampliación.
- **P1 · Dart: [DartPad](https://dartpad.dev/)** y su [guía oficial](https://dart.dev/tools/dartpad) — herramienta
  gratuita
  para ejecutar los ejemplos A y B como Dart y el laboratorio como Flutter. No necesitan paquetes adicionales.
- **P2 · Google
  Codelabs: [Tu primera app de Flutter](https://codelabs.developers.google.com/codelabs/flutter-codelab-first?hl=es-419)**
  — español, ampliación práctica. En el paso «Agrega un riel de navegación», localiza los apartados «setState» y
  «Usa selectedIndex»: permiten comparar guardar la selección y utilizarla al construir. El codelab completo introduce
  más conceptos y dependencias que esta unidad; esos fragmentos pueden estudiarse como lectura acompañada.
- **D7 · Flutter: [Listenable](https://api.flutter.dev/flutter/foundation/Listenable-class.html)** — inglés, puente
  opcional a las próximas unidades. Lee solamente la descripción inicial y reconoce que registrar una observación es
  otra operación.

### YouTube en español

- **V-ES1 · [Widget: StatelessWidget y StatefulWidget](https://www.youtube.com/watch?v=kEFi_zXbvFc)**
  — Yeison Developer, 22 de octubre de 2020. Apoyo introductorio: su descripción presenta el concepto de widgets con y
  sin estado. Después de estudiarlo, explica qué dato cambia en nuestro ejemplo y dónde lo guardarías.
  Contrasta la terminología con D4 y D6: un `StatelessWidget` también puede reconstruirse.
- **V-ES2 · [12- StatefulWidget](https://www.youtube.com/watch?v=QaMaM1GVNrM)**
  — Fernando Herrera, 3 de diciembre de 2021. Apoyo alternativo del nodo 1.5. Es una lección publicada como parte de su
  curso; la ruta utiliza este vídeo abierto. Identifica el dato administrado por el objeto `State` y la operación que
  solicita actualizar su presentación.

### YouTube en inglés

- **V-EN1 · [What is State?](https://www.youtube.com/watch?v=QlwiL_yLh6E)**
  — canal oficial Flutter, 14 de abril de 2021. Apoyo conceptual de los nodos 1.1 y 1.5. La ficha incluye los capítulos
  «Stateless widget misconceptions» en 2:20 y «What is State?» en 4:30. Comprueba si puedes explicar por qué cambiar un
  dato y ver un cambio en pantalla son pasos que necesitan conectarse.
- **V-EN2 · [Stateful widgets in Flutter](https://www.youtube.com/watch?v=Gzz8FwSlsUg)**
  — canal oficial Flutter, 8 de abril de 2026. Es el vídeo enlazado por el
  [tutorial oficial](https://docs.flutter.dev/learn/pathway/tutorial/stateful-widget). Para esta unidad, prioriza los
  capítulos publicados de 0:58 sobre `StatefulWidget` y `State`, 1:32 sobre la finalidad de `State` y 2:27 sobre
  `setState`. El ciclo de vida se estudiará después.

### Qué se revisó de los recursos

Se leyeron las páginas oficiales citadas y se revisaron los títulos, autores, fechas, descripciones y capítulos que
ofrecían las fichas públicas indexadas de los vídeos. El acceso de investigación no permitió reproducir YouTube ni
obtener sus transcripciones; la selección audiovisual es de apoyo y no supone una revisión completa de cada vídeo.
La precisión técnica de la unidad se contrasta con las referencias oficiales.

Los vídeos de 2020 y 2021 pueden mostrar herramientas o sintaxis de otra época. Utiliza los ejemplos de esta guía para
la práctica y las referencias oficiales para resolver diferencias. La traducción del codelab también puede ir por detrás
de la documentación principal; aquí aprovechamos sus explicaciones de estado y selección.

Se ejecutaron los ejemplos A y B y sus salidas coinciden con las soluciones. Ambos ejemplos y el laboratorio de Flutter
pasan el análisis estático. El recorrido interactivo del laboratorio queda para la práctica: no se ha validado mediante
ejecución de la interfaz.

## Proyecto de la unidad: un tema y tres lecturas

Construye un programa pequeño de Dart en un pad nuevo. Escríbelo desde cero utilizando lo aprendido en A y B.

### Requisitos

1. Conserva una selección actual de tema con valor inicial `'claro'`.
2. Guarda una primera lectura.
3. Cambia la selección a `'oscuro'` y guarda una segunda lectura.
4. Vuelve a cambiarla a `'claro'`.
5. Muestra la primera lectura, la segunda y el valor actual, en ese orden.
6. Construye una etiqueta con la selección actual al mostrarla.

Antes de ejecutar, escribe la salida esperada. Después justifica cada línea indicando cuándo se obtuvo su valor.

### Variaciones para demostrar comprensión

- Añade otra variable que represente la selección de una vista previa y empieza también en `'claro'`. Cambia únicamente
  el tema principal y explica el resultado de consultar ambas selecciones.
- Guarda una etiqueta antes del cambio y genera otra al final. Explica cuál describe cada momento.
- Relaciona ese recorrido con una consulta de `controller.theme.value` y una llamada a `setTheme` en DaisyUI.

**Entrega de estudio:** tu código, tu predicción inicial y una explicación de qué valores guardaste y cuáles volviste
a consultar. Si la predicción falla, localiza la primera asignación o lectura que interpretaste de otra manera.

## Errores de comprensión que vamos a comprobar

- Pensar que una variable que recibió una lectura queda vinculada a las futuras asignaciones de la fuente.
- Atribuir a `final` el comportamiento de observar cambios o la capacidad de volver inmutable cualquier objeto.
- Tratar una etiqueta calculada antes del cambio como si representara siempre el estado vigente.
- Confundir el evento de pulsar un botón con el cambio del dato y con el aviso a sus consumidores.
- Dar por hecho que cualquier escritura en memoria solicita reconstruir una pantalla.
- Pensar que el nombre `StatelessWidget` impide que Flutter vuelva a ejecutar su `build`.
- Interpretar «fuente de verdad» como la obligación de usar una única variable global para toda la aplicación.
- Confundir conservar un valor en memoria con guardarlo entre ejecuciones. La persistencia necesita su propio mecanismo.

## Comprobación final

Responde sin mirar los ejemplos y utiliza una secuencia de valores cuando haga falta:

1. ¿Qué representa el estado en el ejemplo del tema?
2. ¿Qué diferencia hay entre el valor actual de la fuente y una lectura que guardaste antes?
3. Si dos variables contienen `'claro'` y reasignas una a `'oscuro'`, ¿qué permite saber el valor de la otra?
4. ¿Por qué cambiar `final` por `var` no crea una observación?
5. ¿Qué problema produce mantener el tema y su etiqueta como datos que debes actualizar por separado?
6. ¿Cómo pueden tener la aplicación y una vista previa fuentes independientes para sus selecciones?
7. ¿Puede cambiar el dato sin que el texto de la pantalla se actualice todavía? Explica el recorrido.
8. ¿Qué hace inmediatamente `setState` y qué solicita al framework después?
9. En el controlador real, ¿quién conserva el tema, quién acepta el cambio y qué hace la vista de lectura?
10. ¿Qué tendrías que añadir conceptualmente para enterarte de cambios futuros sin consultar una y otra vez?

Marca la unidad como dominada cuando puedas explicar las diez respuestas, resolver el proyecto sin copiar y reconocer
las tres operaciones del laboratorio. Si una respuesta falla, vuelve al nodo correspondiente.

## Soluciones para contrastar después de practicar

<details>
<summary>Ver las salidas y las ideas que deben aparecer en las respuestas</summary>

El ejemplo A imprime:

```text
claro
claro
oscuro
oscuro
```

La primera línea ocurre antes del cambio. La segunda corresponde a la lectura guardada antes. Las dos últimas
corresponden a la fuente ya reasignada y a la lectura posterior. Usar `var` para la lectura anterior permite
reasignarla,
pero hace falta ejecutar esa nueva asignación para que guarde otro resultado.

En el nodo 1.3, los valores actuales después de cada paso son `'oscuro'`, `'oscuro'`, `'oscuro'`, `'claro'` y `'claro'`.
`primeraLectura` conserva `'oscuro'`. Los pasos 1 y 4 cambian el contenido textual respecto al momento anterior.

El ejemplo B imprime:

```text
oscuro
Tema: claro
Tema: oscuro
```

La etiqueta guardada se construyó antes de reasignar la selección. La última expresión se evaluó después.

En el proyecto, las tres lecturas mostradas deben ser `'claro'`, `'oscuro'` y `'claro'`; la etiqueta final debe
describir
`'claro'`. Una vista previa independiente conserva su propio valor cuando solo cambia la selección principal.

En el laboratorio, el botón 1 modifica el campo y lo imprime. El botón 3 pide reconstruir para volver a leerlo; el botón
2 agrupa una asignación con esa solicitud. En el flujo normal de este experimento, la pantalla recorre claro, oscuro
tras usar 1 y luego 3, y claro tras usar 2.

En DaisyUI, cada controlador posee `_palette`; `setTheme` asigna su `.value` y el adaptador consulta a su fuente.
Guardar el modelo obtenido antes de una sustitución no vuelve a ejecutar esa consulta. Recibir avisos futuros requiere
establecer una observación; después hay que conectar esos avisos con el consumidor que deba actualizarse.

</details>
