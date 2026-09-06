import 'package:flutter/material.dart';

class ArabicTextView extends StatelessWidget {
  const ArabicTextView({
    super.key,
    required this.fontSize,
    required this.lineHeight,
  });

  final double fontSize;
  final double lineHeight;

  // Placeholder — o'zingiz almashtirasiz
  static const _placeholderText =
      'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ ﴿١﴾ '
      'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ ﴿٢﴾ '
      'ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ ﴿٣﴾ '
      'مَـٰلِكِ يَوْمِ ٱلدِّينِ ﴿٤﴾ '
      'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ﴿٥﴾ '
      'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ ﴿٦﴾ '
      'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ ﴿٧﴾';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          _placeholderText,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'AmiriQuran',
            fontSize: fontSize,
            height: lineHeight,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
