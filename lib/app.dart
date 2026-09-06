import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/reader/bloc/reader_bloc.dart';
import 'features/reader/bloc/reader_state.dart';
import 'features/reader/view/reader_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReaderBloc(),
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
    );
  }
}
