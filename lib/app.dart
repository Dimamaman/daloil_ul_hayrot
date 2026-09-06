import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/data/database/app_database.dart';
import 'core/data/repository/book_repository.dart';
import 'core/data/repository/calendar_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/reader/bloc/reader_bloc.dart';
import 'features/reader/bloc/reader_event.dart';
import 'features/reader/bloc/reader_state.dart';
import 'features/reader/view/reader_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatelessWidget {
  const App({super.key, required this.prefs, required this.db});

  final SharedPreferences prefs;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    final bookRepo = BookRepository(prefs);
    final calendarRepo = CalendarRepository(db);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: prefs),
        RepositoryProvider.value(value: bookRepo),
        RepositoryProvider.value(value: calendarRepo),
      ],
      child: BlocProvider(
        create: (_) => ReaderBloc(
          bookRepo: bookRepo,
          calendarRepo: calendarRepo,
        )..add(const BookLoadRequested()),
        child: BlocBuilder<ReaderBloc, ReaderState>(
          buildWhen: (prev, curr) => prev.isDarkMode != curr.isDarkMode,
          builder: (context, state) {
            return MaterialApp(
              title: 'Daloil ul-Hayrot',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const ReaderPage(),
            );
          },
        ),
      ),
    );
  }
}
