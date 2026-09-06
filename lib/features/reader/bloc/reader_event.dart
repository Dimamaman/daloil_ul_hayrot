sealed class ReaderEvent {
  const ReaderEvent();
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
