import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/notifications/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late bool _enabled;
  late TimeOfDay _time1;
  TimeOfDay? _time2;

  @override
  void initState() {
    super.initState();
    _enabled = widget.prefs.getBool('notification_enabled') ?? false;

    final t1 = widget.prefs.getString('notification_time_1');
    _time1 = t1 != null ? _parseTime(t1) : const TimeOfDay(hour: 8, minute: 0);

    final t2 = widget.prefs.getString('notification_time_2');
    _time2 = t2 != null ? _parseTime(t2) : null;
  }

  TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    await widget.prefs.setBool('notification_enabled', _enabled);
    await widget.prefs.setString('notification_time_1', _formatTime(_time1));

    if (_time2 != null) {
      await widget.prefs.setString('notification_time_2', _formatTime(_time2!));
    } else {
      await widget.prefs.remove('notification_time_2');
    }

    await NotificationService.instance.syncFromPrefs(widget.prefs);
  }

  Future<void> _toggleEnabled(bool value) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Eslatma ruxsati berilmadi. '
                  'Sozlamalardan ruxsat bering.'),
            ),
          );
        }
        return;
      }
    }
    setState(() => _enabled = value);
    await _save();
  }

  Future<void> _pickTime(bool isFirst) async {
    final initial = isFirst ? _time1 : (_time2 ?? const TimeOfDay(hour: 20, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;

    setState(() {
      if (isFirst) {
        _time1 = picked;
      } else {
        _time2 = picked;
      }
    });
    await _save();
  }

  Future<void> _removeSecondTime() async {
    setState(() => _time2 = null);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Eslatmalar')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Kunlik eslatma'),
            subtitle: const Text("Har kuni belgilangan vaqtda eslatadi"),
            value: _enabled,
            onChanged: _toggleEnabled,
          ),
          if (_enabled) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Birinchi vaqt'),
              trailing: Text(
                _time1.format(context),
                style: theme.textTheme.titleMedium,
              ),
              onTap: () => _pickTime(true),
            ),
            if (_time2 != null)
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Ikkinchi vaqt'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _time2!.format(context),
                      style: theme.textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _removeSecondTime,
                    ),
                  ],
                ),
                onTap: () => _pickTime(false),
              )
            else
              ListTile(
                leading: const Icon(Icons.add_alarm),
                title: const Text("Ikkinchi vaqt qo'shish"),
                onTap: () => _pickTime(false),
              ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _platformNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get _platformNote {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS) {
      return 'iOS nozik joylar:\n'
          '• "Jimroq yetkazish" (Focus) rejimida eslatmalar ovoz chiqarmasligi mumkin\n'
          '• Sozlamalar > Eslatmalar > Daloil ul-Hayrot dan batafsil sozlash mumkin\n'
          '• Ilova batareyani kam sarflaydi — faqat tizim alarmi ishlaydi';
    }
    return 'Android nozik joylar:\n'
        '• Android 13+: birinchi marta ruxsat so\'rash oynasi chiqadi\n'
        '• Android 12+: aniq vaqtli alarm uchun sozlamalar sahifasi ochiladi\n'
        '• Batareya optimallashtirish eslatmani kechiktirishi mumkin — '
        'sozlamalardan ilova uchun "Cheklanmagan" rejimni tanlang\n'
        '• Telefon qayta yonganda eslatmalar avtomatik tiklanadi';
  }
}
