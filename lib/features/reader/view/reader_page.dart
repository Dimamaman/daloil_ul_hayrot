import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reader_bloc.dart';
import '../bloc/reader_event.dart';
import '../bloc/reader_state.dart';
import '../widgets/arabic_text_view.dart';
import '../widgets/settings_bottom_sheet.dart';

class ReaderPage extends StatelessWidget {
  const ReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderBloc, ReaderState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Daloil ul-Hayrot'),
            actions: [
              IconButton(
                icon: Icon(
                  state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () =>
                    context.read<ReaderBloc>().add(const ThemeToggled()),
              ),
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () => SettingsBottomSheet.show(context),
              ),
            ],
          ),
          body: ArabicTextView(
            fontSize: state.fontSize,
            lineHeight: state.lineHeight,
          ),
        );
      },
    );
  }
}
