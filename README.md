
A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Paquete local `incidencias_ui`

La aplicación consume el paquete Flutter local `packages/incidencias_ui`
mediante una dependencia `path:` en `pubspec.yaml`. El widget
`MaquetaArBadge` demuestra que la aplicación importa y utiliza componentes del
paquete sin depender de una publicación externa.

## Catálogo de componentes

El catálogo Widgetbook de `PriorityBadge` e `IncidentCard` está disponible en
[`tool/widgetbook.dart`](tool/widgetbook.dart). Incluye todas las prioridades,
las variantes con y sin comentario y los temas claro y oscuro. La valoración de
las herramientas consideradas está documentada en
[`docs/widgetbook-evaluacion.md`](docs/widgetbook-evaluacion.md).

Para ejecutarlo:

```bash
flutter run -d chrome -t tool/widgetbook.dart
```
