import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar factory específico de plataforma (sqflite_common_ffi en escritorio, sqflite nativo en Android)
  DatabaseHelper.initializeDatabaseFactory();

  // Inicializar la base de datos y asegurar creación de tablas
  await DatabaseHelper.instance.database;

  runApp(const IncidenciasApp());
}

class IncidenciasApp extends StatelessWidget {
  const IncidenciasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IncidenciasIES',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Indigo / Azul IES
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const DatabaseStatusScreen(),
    );
  }
}

class DatabaseStatusScreen extends StatefulWidget {
  const DatabaseStatusScreen({super.key});

  @override
  State<DatabaseStatusScreen> createState() => _DatabaseStatusScreenState();
}

class _DatabaseStatusScreenState extends State<DatabaseStatusScreen> {
  late Future<Map<String, dynamic>> _dbStatusFuture;

  @override
  void initState() {
    super.initState();
    _dbStatusFuture = DatabaseHelper.instance.checkDatabaseStatus();
  }

  String get _platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isLinux) return 'Linux (Desktop)';
    if (Platform.isWindows) return 'Windows (Desktop)';
    if (Platform.isAndroid) return 'Android (Móvil / Emulador)';
    if (Platform.isMacOS) return 'macOS (Desktop)';
    if (Platform.isIOS) return 'iOS';
    return 'Desconocida';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IncidenciasIES — SQLite Status'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dbStatusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      'Error inicializando base de datos:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final String path = data['path'] as String;
          final bool fks = data['foreignKeysEnabled'] as bool;
          final List<String> tables = data['tables'] as List<String>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'Base de Datos Conectada',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(height: 28),
                        _buildInfoRow(
                          icon: Icons.computer,
                          title: 'Plataforma detectada',
                          value: _platformName,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.vpn_key,
                          title: 'Claves Foráneas (PRAGMA)',
                          value: fks ? 'ACTIVADAS (foreign_keys = 1)' : 'DESACTIVADAS',
                          valueColor: fks ? Colors.green[800] : Colors.red,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.folder,
                          title: 'Ruta SQLite',
                          value: path,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tablas creadas (${tables.length}/4)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildTableChip('aula', tables.contains('aula'), Icons.meeting_room),
                    _buildTableChip('equipo', tables.contains('equipo'), Icons.devices),
                    _buildTableChip('incidencia', tables.contains('incidencia'), Icons.report_problem),
                    _buildTableChip('comentario', tables.contains('comentario'), Icons.comment),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableChip(String name, bool exists, IconData icon) {
    return Chip(
      avatar: Icon(
        exists ? icon : Icons.cancel,
        size: 18,
        color: exists ? Colors.green[800] : Colors.red,
      ),
      label: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: exists ? Colors.green[900] : Colors.red[900],
        ),
      ),
      backgroundColor: exists ? Colors.green[50] : Colors.red[50],
      side: BorderSide(color: exists ? Colors.green : Colors.red),
    );
  }
}
