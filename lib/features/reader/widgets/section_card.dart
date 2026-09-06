import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/data/models/section.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.section,
    required this.fontSize,
    required this.lineHeight,
    required this.showTransliteration,
    required this.showTranslation,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  final Section section;
  final double fontSize;
  final double lineHeight;
  final bool showTransliteration;
  final bool showTranslation;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bo'lim sarlavhasi + xatcho'p belgisi
            Row(
              children: [
                if (isBookmarked)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.bookmark,
                      size: 16,
                      color: colors.primary,
                    ),
                  ),
                Expanded(
                  child: Text(
                    section.titleUz ?? section.title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Arabcha matn
            Text(
              section.arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'AmiriQuran',
                fontSize: fontSize,
                height: lineHeight,
                color: colors.onSurface,
              ),
            ),

            // Transliteratsiya
            if (showTransliteration && section.transliteration != null) ...[
              const SizedBox(height: 12),
              Text(
                section.transliteration!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize * 0.5,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],

            // Tarjima
            if (showTranslation && section.translation != null) ...[
              const SizedBox(height: 8),
              Text(
                section.translation!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize * 0.45,
                  height: 1.5,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                isBookmarked ? Icons.bookmark_remove : Icons.bookmark_add,
              ),
              title: Text(isBookmarked ? 'Xatcho\'pni olib tashlash' : 'Xatcho\'p qo\'yish'),
              onTap: () {
                Navigator.pop(context);
                onBookmarkToggle();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Arabcha matnni nusxalash'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: section.arabic));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Nusxalandi'),
                    backgroundColor: colors.inverseSurface,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
