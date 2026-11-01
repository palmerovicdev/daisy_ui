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

  void panel() {
    if (kDebugMode) {
      print('Panel avisado');
    }
  }
  void diagnostico() {
    if (kDebugMode) {
      print('Diagnóstico avisado');
    }
  }

  fuente.addListener(panel);
  fuente.addListener(diagnostico);
  if (kDebugMode) {
    print('Registrados');
  }

  avisador.emitir();

  fuente.removeListener(panel);
  if (kDebugMode) {
    print('Panel retirado');
  }
  avisador.emitir();

  fuente.removeListener(diagnostico);
  avisador.emitir();
  if (kDebugMode) {
    print('Fin');
  }
}
