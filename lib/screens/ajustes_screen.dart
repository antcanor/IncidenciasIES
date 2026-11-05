import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../settings/settings.dart';
import '../theme/theme_controller.dart';

class AjustesScreen extends StatefulWidget {
  final ThemeController themeController;
  final LocaleController localeController;

  const AjustesScreen({
    super.key,
    required this.themeController,
    required this.localeController,
  });

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  PermissionStatus? _cameraStatus;
  PermissionStatus? _microphoneStatus;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshStatuses();
  }

  Future<void> _refreshStatuses() async {
    try {
      final statuses = await Future.wait([
        Permission.camera.status,
        Permission.microphone.status,
      ]);
      if (!mounted) return;
      setState(() {
        _cameraStatus = statuses[0];
        _microphoneStatus = statuses[1];
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '${AppStrings.text(context, 'permissionError')} $error');
    }
  }

  Future<void> _request(Permission permission) async {
    try {
      await permission.request();
      await _refreshStatuses();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.text(context, 'permissionUpdated'))),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _error = '${AppStrings.text(context, 'permissionError')} $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.themeController, widget.localeController]),
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(AppStrings.text(context, 'settings'))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(AppStrings.text(context, 'language'), style: Theme.of(context).textTheme.titleLarge),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'es', label: Text(AppStrings.text(context, 'spanish'))),
                ButtonSegment(value: 'en', label: Text(AppStrings.text(context, 'english'))),
              ],
              selected: {widget.localeController.locale.languageCode},
              onSelectionChanged: (value) => widget.localeController.setLocale(Locale(value.first)),
            ),
            const SizedBox(height: 24),
            Text(AppStrings.text(context, 'theme'), style: Theme.of(context).textTheme.titleLarge),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.light, label: Text(AppStrings.text(context, 'light'))),
                ButtonSegment(value: ThemeMode.dark, label: Text(AppStrings.text(context, 'dark'))),
              ],
              selected: {widget.themeController.themeMode},
              onSelectionChanged: (value) => widget.themeController.setThemeMode(value.first),
            ),
            const SizedBox(height: 24),
            Text(AppStrings.text(context, 'permissions'), style: Theme.of(context).textTheme.titleLarge),
            Text(AppStrings.text(context, 'permissionOnlyOnUse')),
            const SizedBox(height: 8),
            _permissionTile(
              icon: Icons.camera_alt,
              title: AppStrings.text(context, 'camera'),
              status: _cameraStatus,
              onRequest: () => _request(Permission.camera),
            ),
            _permissionTile(
              icon: Icons.mic,
              title: AppStrings.text(context, 'microphone'),
              status: _microphoneStatus,
              onRequest: () => _request(Permission.microphone),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _permissionTile({
    required IconData icon,
    required String title,
    required PermissionStatus? status,
    required VoidCallback onRequest,
  }) {
    final granted = status?.isGranted ?? false;
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(status == null
            ? '...'
            : AppStrings.text(context, granted ? 'granted' : 'denied')),
        trailing: OutlinedButton(
          onPressed: onRequest,
          child: Text(AppStrings.text(context, 'request')),
        ),
      ),
    );
  }
}
