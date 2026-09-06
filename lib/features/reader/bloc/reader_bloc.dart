import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/calendar/day_boundary.dart';
import '../../../core/calendar/hizb_cycle.dart';
import '../../../core/data/repository/book_repository.dart';
import '../../../core/data/repository/calendar_repository.dart';
import 'reader_event.dart';
import 'reader_state.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  ReaderBloc({
    required this.bookRepo,
    required this.calendarRepo,
  }) : super(const ReaderState()) {
    on<BookLoadRequested>(_onBookLoad);
    on<FontSizeChanged>((e, emit) => emit(state.copyWith(fontSize: e.size)));
    on<LineHeightChanged>((e, emit) => emit(state.copyWith(lineHeight: e.height)));
    on<ThemeToggled>((e, emit) => emit(state.copyWith(isDarkMode: !state.isDarkMode)));
    on<TransliterationToggled>(_onTranslitToggle);
    on<TranslationToggled>(_onTranslationToggle);
    on<ScrollPositionChanged>(_onScrollChanged);
    on<BookmarkToggled>(_onBookmarkToggle);
    on<TodayReadingCompleted>(_onTodayComplete);
  }

  final BookRepository bookRepo;
  final CalendarRepository calendarRepo;
  Timer? _saveTimer;

  Future<void> _onBookLoad(
    BookLoadRequested event,
    Emitter<ReaderState> emit,
  ) async {
    final book = await bookRepo.loadBook();

    // Bugungi hizb raqamini aniqlash
    final today = currentReadingDay(
      DateTime.now(),
      mode: DayBoundaryMode.maghrib,
    );
    // Tsikl boshi sozlanmagan bo'lsa bugundan boshlaymiz
    final cycleStart = today;
    final hizbNumber = hizbForDay(today, cycleStart);
    final hizb = book.hizbs.firstWhere(
      (h) => h.order == hizbNumber,
      orElse: () => book.hizbs.first,
    );

    // Saqlangan pozitsiyani tiklash
    final saved = bookRepo.loadScrollPosition();
    var sectionIndex = 0;
    if (saved.hizbId == hizb.id) {
      sectionIndex = saved.sectionIndex.clamp(0, hizb.sections.length - 1);
    }

    final marked = await calendarRepo.isDayMarked(today);

    emit(state.copyWith(
      isLoading: false,
      currentHizb: hizb,
      sections: hizb.sections,
      firstVisibleSectionIndex: sectionIndex,
      todayHizbNumber: hizbNumber,
      todayMarked: marked,
      showTransliteration: bookRepo.showTransliteration,
      showTranslation: bookRepo.showTranslation,
      bookmarkedSectionIds: bookRepo.loadBookmarks(),
    ));
  }

  void _onTranslitToggle(
    TransliterationToggled event,
    Emitter<ReaderState> emit,
  ) {
    final v = !state.showTransliteration;
    bookRepo.showTransliteration = v;
    emit(state.copyWith(showTransliteration: v));
  }

  void _onTranslationToggle(
    TranslationToggled event,
    Emitter<ReaderState> emit,
  ) {
    final v = !state.showTranslation;
    bookRepo.showTranslation = v;
    emit(state.copyWith(showTranslation: v));
  }

  void _onScrollChanged(
    ScrollPositionChanged event,
    Emitter<ReaderState> emit,
  ) {
    emit(state.copyWith(firstVisibleSectionIndex: event.sectionIndex));

    // 1 soniya debounce — har pikselda saqlamaslik uchun
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), () {
      final hizb = state.currentHizb;
      if (hizb != null) {
        bookRepo.saveScrollPosition(hizb.id, event.sectionIndex);
      }
    });
  }

  void _onBookmarkToggle(
    BookmarkToggled event,
    Emitter<ReaderState> emit,
  ) {
    final updated = Set<String>.from(state.bookmarkedSectionIds);
    if (updated.contains(event.sectionId)) {
      updated.remove(event.sectionId);
    } else {
      updated.add(event.sectionId);
    }
    bookRepo.saveBookmarks(updated);
    emit(state.copyWith(bookmarkedSectionIds: updated));
  }

  Future<void> _onTodayComplete(
    TodayReadingCompleted event,
    Emitter<ReaderState> emit,
  ) async {
    final today = currentReadingDay(
      DateTime.now(),
      mode: DayBoundaryMode.maghrib,
    );
    await calendarRepo.markDay(today, state.todayHizbNumber);
    emit(state.copyWith(todayMarked: true));
  }

  @override
  Future<void> close() {
    _saveTimer?.cancel();
    return super.close();
  }
}
