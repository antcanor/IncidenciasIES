<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

Componentes Flutter compartidos para la aplicación de incidencias del centro.
La idea es tener en un mismo paquete las piezas que se reutilizan en varias
pantallas y poder probarlas sin levantar toda la aplicación.

## Features

- `PriorityBadge`: etiqueta de prioridad editable o solo informativa.
- `IncidentCard`: tarjeta con datos, estado y acciones de una incidencia.
- `MaquetaArBadge`: marca visual para prototipos de la vista AR.

## Getting started

El paquete se usa como dependencia local desde la aplicación principal:

```yaml
dependencies:
  incidencias_ui:
    path: packages/incidencias_ui
```

## Usage

Ejemplo mínimo de una etiqueta:

```dart
PriorityBadge(
  priority: Priority.medium,
  onChanged: (priority) {
    // Actualizar la incidencia.
  },
)
```

## Documentación

La API pública está comentada en español y la documentación HTML generada se
encuentra en [`../../docs/api`](../../docs/api). Para regenerarla desde la raíz
del repositorio:

```bash
cd packages/incidencias_ui
dart doc --validate-links --output=../../docs/api
```
