class ReaderState {
  const ReaderState({
    this.fontSize = 28,
    this.lineHeight = 2.0,
    this.isDarkMode = false,
  });

  final double fontSize;
  final double lineHeight;
  final bool isDarkMode;

  ReaderState copyWith({
    double? fontSize,
    double? lineHeight,
    bool? isDarkMode,
  }) {
    return ReaderState(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
