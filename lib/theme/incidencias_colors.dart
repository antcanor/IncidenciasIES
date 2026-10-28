import 'package:flutter/material.dart';
import '../models/estado.dart';
import '../models/prioridad.dart';

/// Extensión de tema Material 3 para colores semánticos de Incidencias.
/// Garantiza coherencia visual (RA1.d) adaptándose entre modo claro y oscuro.
class IncidenciasColors extends ThemeExtension<IncidenciasColors> {
  final Color prioridadUrgente;
  final Color prioridadAlta;
  final Color prioridadMedia;
  final Color prioridadBaja;

  final Color estadoAbierta;
  final Color estadoEnProceso;
  final Color estadoResuelta;
  final Color estadoCerrada;

  final Color badgeBackground;
  final Color badgeText;

  const IncidenciasColors({
    required this.prioridadUrgente,
    required this.prioridadAlta,
    required this.prioridadMedia,
    required this.prioridadBaja,
    required this.estadoAbierta,
    required this.estadoEnProceso,
    required this.estadoResuelta,
    required this.estadoCerrada,
    required this.badgeBackground,
    required this.badgeText,
  });

  /// Paleta semántica para Modo Claro
  static const light = IncidenciasColors(
    prioridadUrgente: Color(0xFFDC2626), // Rojo vivo
    prioridadAlta: Color(0xFFEA580C),    // Naranja
    prioridadMedia: Color(0xFFD97706),   // Ámbar
    prioridadBaja: Color(0xFF475569),    // Gris azulado
    estadoAbierta: Color(0xFFE11D48),    // Rosa / Rojo alerta
    estadoEnProceso: Color(0xFF2563EB),  // Azul progreso
    estadoResuelta: Color(0xFF16A34A),   // Verde éxito
    estadoCerrada: Color(0xFF64748B),    // Gris neutro
    badgeBackground: Color(0xFFEFF6FF),  // Azul suave
    badgeText: Color(0xFF1E3A8A),        // Azul oscuro
  );

  /// Paleta semántica para Modo Oscuro (tonos desaturados y legibles sobre fondos oscuros)
  static const dark = IncidenciasColors(
    prioridadUrgente: Color(0xFFF87171),
    prioridadAlta: Color(0xFFFB923C),
    prioridadMedia: Color(0xFFFBBF24),
    prioridadBaja: Color(0xFF94A3B8),
    estadoAbierta: Color(0xFFFB7185),
    estadoEnProceso: Color(0xFF60A5FA),
    estadoResuelta: Color(0xFF4ADE80),
    estadoCerrada: Color(0xFF94A3B8),
    badgeBackground: Color(0xFF1E293B),
    badgeText: Color(0xFF93C5FD),
  );

  Color colorParaPrioridad(Prioridad p) {
    switch (p) {
      case Prioridad.urgente:
        return prioridadUrgente;
      case Prioridad.alta:
        return prioridadAlta;
      case Prioridad.media:
        return prioridadMedia;
      case Prioridad.baja:
        return prioridadBaja;
    }
  }

  Color colorParaEstado(Estado e) {
    switch (e) {
      case Estado.abierta:
        return estadoAbierta;
      case Estado.enProceso:
        return estadoEnProceso;
      case Estado.resuelta:
        return estadoResuelta;
      case Estado.cerrada:
        return estadoCerrada;
    }
  }

  @override
  ThemeExtension<IncidenciasColors> copyWith({
    Color? prioridadUrgente,
    Color? prioridadAlta,
    Color? prioridadMedia,
    Color? prioridadBaja,
    Color? estadoAbierta,
    Color? estadoEnProceso,
    Color? estadoResuelta,
    Color? estadoCerrada,
    Color? badgeBackground,
    Color? badgeText,
  }) {
    return IncidenciasColors(
      prioridadUrgente: prioridadUrgente ?? this.prioridadUrgente,
      prioridadAlta: prioridadAlta ?? this.prioridadAlta,
      prioridadMedia: prioridadMedia ?? this.prioridadMedia,
      prioridadBaja: prioridadBaja ?? this.prioridadBaja,
      estadoAbierta: estadoAbierta ?? this.estadoAbierta,
      estadoEnProceso: estadoEnProceso ?? this.estadoEnProceso,
      estadoResuelta: estadoResuelta ?? this.estadoResuelta,
      estadoCerrada: estadoCerrada ?? this.estadoCerrada,
      badgeBackground: badgeBackground ?? this.badgeBackground,
      badgeText: badgeText ?? this.badgeText,
    );
  }

  @override
  ThemeExtension<IncidenciasColors> lerp(
    covariant ThemeExtension<IncidenciasColors>? other,
    double t,
  ) {
    if (other is! IncidenciasColors) return this;
    return IncidenciasColors(
      prioridadUrgente: Color.lerp(prioridadUrgente, other.prioridadUrgente, t)!,
      prioridadAlta: Color.lerp(prioridadAlta, other.prioridadAlta, t)!,
      prioridadMedia: Color.lerp(prioridadMedia, other.prioridadMedia, t)!,
      prioridadBaja: Color.lerp(prioridadBaja, other.prioridadBaja, t)!,
      estadoAbierta: Color.lerp(estadoAbierta, other.estadoAbierta, t)!,
      estadoEnProceso: Color.lerp(estadoEnProceso, other.estadoEnProceso, t)!,
      estadoResuelta: Color.lerp(estadoResuelta, other.estadoResuelta, t)!,
      estadoCerrada: Color.lerp(estadoCerrada, other.estadoCerrada, t)!,
      badgeBackground: Color.lerp(badgeBackground, other.badgeBackground, t)!,
      badgeText: Color.lerp(badgeText, other.badgeText, t)!,
    );
  }
}
