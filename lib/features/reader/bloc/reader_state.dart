import '../.././../core/data/models/hizb.dart';
import '../.././../core/data/models/section.dart';

class ReaderState {
  const ReaderState({
    this.fontSize = 28,
    this.lineHeight = 2.0,
    this.isDarkMode = false,
    this.isLoading = true,
    this.currentHizb,
    this.sections = const [],
    this.showTransliteration = false,
    this.showTranslation = false,
    this.firstVisibleSectionIndex = 0,
    this.bookmarkedSectionIds = const {},
    this.todayMarked = false,
    this.todayHizbNumber = 1,
  });

  final double fontSize;
  final double lineHeight;
  final bool isDarkMode;
  final bool isLoading;
  final Hizb? currentHizb;
  final List<Section> sections;
  final bool showTransliteration;
  final bool showTranslation;
  final int firstVisibleSectionIndex;
  final Set<String> bookmarkedSectionIds;
  final bool todayMarked;
  final int todayHizbNumber;

  double get progress =>
      sections.isEmpty ? 0 : (firstVisibleSectionIndex + 1) / sections.length;

  ReaderState copyWith({
    double? fontSize,
    double? lineHeight,
    bool? isDarkMode,
    bool? isLoading,
    Hizb? currentHizb,
    List<Section>? sections,
    bool? showTransliteration,
    bool? showTranslation,
    int? firstVisibleSectionIndex,
    Set<String>? bookmarkedSectionIds,
    bool? todayMarked,
    int? todayHizbNumber,
  }) {
    return ReaderState(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLoading: isLoading ?? this.isLoading,
      currentHizb: currentHizb ?? this.currentHizb,
      sections: sections ?? this.sections,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showTranslation: showTranslation ?? this.showTranslation,
      firstVisibleSectionIndex:
          firstVisibleSectionIndex ?? this.firstVisibleSectionIndex,
      bookmarkedSectionIds:
          bookmarkedSectionIds ?? this.bookmarkedSectionIds,
      todayMarked: todayMarked ?? this.todayMarked,
      todayHizbNumber: todayHizbNumber ?? this.todayHizbNumber,
    );
  }
}
