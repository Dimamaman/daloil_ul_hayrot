import 'package:flutter_bloc/flutter_bloc.dart';
import 'reader_event.dart';
import 'reader_state.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  ReaderBloc() : super(const ReaderState()) {
    on<FontSizeChanged>((event, emit) {
      emit(state.copyWith(fontSize: event.size));
    });
    on<LineHeightChanged>((event, emit) {
      emit(state.copyWith(lineHeight: event.height));
    });
    on<ThemeToggled>((event, emit) {
      emit(state.copyWith(isDarkMode: !state.isDarkMode));
    });
  }
}
