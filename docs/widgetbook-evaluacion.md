# Widgetbook y valoración de herramientas

## Catálogo

El catálogo se encuentra en [`tool/widgetbook.dart`](../tool/widgetbook.dart) y
se ejecuta con:

```bash
flutter run -d chrome -t tool/widgetbook.dart
```

Incluye:

- `PriorityBadge`: las prioridades `BAJA`, `MEDIA`, `ALTA` y `URGENTE`.
- `IncidentCard`: las cuatro prioridades con las variantes con y sin acción de
  comentario.
- `MaterialThemeAddon`: selector entre los temas claro y oscuro de la
  aplicación.

Por tanto, el catálogo contiene 4 estados de `PriorityBadge` y 8 estados de
`IncidentCard`, todos disponibles en claro y oscuro.

## Valoración comparativa

| Herramienta | Puntos fuertes | Limitaciones | Valoración |
|---|---|---|---|
| **Widgetbook** | Catálogo navegable, casos de uso explícitos, addons para temas y controles, ejecución local sencilla y buena integración con Flutter. | Añade una dependencia de desarrollo y requiere mantener los casos de uso. | **Elegida**: es la mejor combinación para revisar estados manualmente y documentar componentes reutilizables. |
| **Storybook Toolkit** | Modelo de historias familiar para equipos que ya usan Storybook en web y API orientada a componentes. | Comunidad y ecosistema Flutter más pequeños; menos integración estandarizada con temas y dispositivos que Widgetbook. | Adecuada para equipos con experiencia previa en Storybook, pero menos conveniente aquí. |
| **Flutter DevTools** | Inspector oficial, árbol de widgets, diagnóstico de layout y rendimiento sin añadir dependencias de catálogo. | No proporciona un catálogo persistente ni historias reproducibles de estados. | Imprescindible para depuración, pero complementaria y no sustitutiva de un catálogo. |
| **Golden Toolkit** | Facilita pruebas golden, escenarios y tolerancias visuales automatizadas en CI. | Es una herramienta de regresión visual, no un catálogo interactivo para explorar componentes. | Muy útil junto a Widgetbook; no cubre por sí sola la inspección manual solicitada. |

### Decisión

Se adopta Widgetbook como catálogo interactivo porque permite agrupar los
estados por componente y cambiar entre claro y oscuro desde la interfaz. Se
mantiene además el test golden existente para detectar regresiones visuales
automáticamente en CI; ambas herramientas cubren necesidades distintas y se
complementan.
