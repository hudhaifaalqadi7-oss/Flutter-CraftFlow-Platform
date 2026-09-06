import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/workshop.dart';
import '../state/app_store.dart';

class FeaturePage extends StatelessWidget {
  const FeaturePage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.workshop,
    required this.actions,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Workshop workshop;
  final List<FeatureAction> actions;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: workshop.color.withValues(alpha: .12),
                child: Icon(icon, color: workshop.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: textMuted)),
          const SizedBox(height: 20),
          ...actions.map(
            (action) => Card(
              child: ListTile(
                leading: Icon(action.icon, color: workshop.color),
                title: Text(
                  action.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(action.detail),
                trailing: action.trailing ?? const Icon(Icons.chevron_left),
                onTap: action.onTap ??
                    () => showFeatureActionSheet(context, workshop, action),
              ),
            ),
          ),
        ],
      );
}

Future<void> showFeatureActionSheet(
  BuildContext context,
  Workshop workshop,
  FeatureAction action,
) {
  final noteController = TextEditingController();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(action.icon, color: workshop.color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  action.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(action.detail, style: const TextStyle(color: textMuted)),
          const SizedBox(height: 16),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'ملاحظة أو تحديث',
              hintText: 'أدخل التفاصيل الخاصة بهذا الإجراء',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(sheetContext);
              final saved = await StoreScope.of(context).recordEvent(type: 'feature_action', workshopId: workshop.id, payload: '${action.title}: ${noteController.text}');
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved ? 'تم تنفيذ وحفظ: ${action.title}' : 'تعذر حفظ الإجراء')));
            },
            icon: const Icon(Icons.check),
            label: const Text('حفظ التنفيذ'),
          ),
        ],
      ),
    ),
  );
}

class FeatureAction {
  const FeatureAction({
    required this.title,
    required this.detail,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String detail;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
}