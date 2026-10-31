void avisar() {
  print('El tema cambió');
}

void main() {
  final accion = avisar;
  print('Acción preparada');

  accion.call();
}