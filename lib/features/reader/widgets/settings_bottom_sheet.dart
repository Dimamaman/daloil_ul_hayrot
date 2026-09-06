import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reader_bloc.dart';
import '../bloc/reader_event.dart';
import '../bloc/reader_state.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ReaderBloc>(),
        child: const SettingsBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderBloc, ReaderState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _SliderRow(
                label: 'Shrift kattaligi',
                value: state.fontSize,
                min: 16,
                max: 40,
                displayValue: '${state.fontSize.round()}',
                onChanged: (v) =>
                    context.read<ReaderBloc>().add(FontSizeChanged(v)),
              ),
              const SizedBox(height: 16),
              _SliderRow(
                label: 'Qatorlar oralig\'i',
                value: state.lineHeight,
                min: 1.4,
                max: 3.5,
                displayValue: state.lineHeight.toStringAsFixed(1),
                onChanged: (v) =>
                    context.read<ReaderBloc>().add(LineHeightChanged(v)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            Text(displayValue, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
