import 'package:flutter/foundation.dart';

void avisar() {
  if (kDebugMode) {
    print('El tema cambió');
  }
}

void main() {
  final accion = avisar;
  if (kDebugMode) {
    print('Acción preparada');
  }

  accion.call();
}