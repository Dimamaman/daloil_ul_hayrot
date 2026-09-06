sealed class ReaderEvent {
  const ReaderEvent();
}

final class BookLoadRequested extends ReaderEvent {
  const BookLoadRequested();
}

final class FontSizeChanged extends ReaderEvent {
  const FontSizeChanged(this.size);
  final double size;
}

final class LineHeightChanged extends ReaderEvent {
  const LineHeightChanged(this.height);
  final double height;
}

final class ThemeToggled extends ReaderEvent {
  const ThemeToggled();
}

final class TransliterationToggled extends ReaderEvent {
  const TransliterationToggled();
}

final class TranslationToggled extends ReaderEvent {
  const TranslationToggled();
}

final class ScrollPositionChanged extends ReaderEvent {
  const ScrollPositionChanged(this.sectionIndex);
  final int sectionIndex;
}

final class BookmarkToggled extends ReaderEvent {
  const BookmarkToggled(this.sectionId);
  final String sectionId;
}

final class TodayReadingCompleted extends ReaderEvent {
  const TodayReadingCompleted();
}
