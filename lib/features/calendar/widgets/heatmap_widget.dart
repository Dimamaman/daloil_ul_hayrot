import 'package:flutter/material.dart';
import '../../../core/calendar/reading_day.dart';

class ReadingHeatmap extends StatelessWidget {
  const ReadingHeatmap({
    super.key,
    required this.today,
    required this.completedDays,
    this.weeksToShow = 12,
    this.onDayTap,
  });

  final ReadingDay today;
  final Set<ReadingDay> completedDays;
  final int weeksToShow;
  final ValueChanged<ReadingDay>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalDays = weeksToShow * 7;
    final startDay = today.addDays(-totalDays + 1);
    // Haftaning boshiga (dushanba) tekislash
    final startWeekday = startDay.toDateTime().weekday; // 1=Mon
    final alignedStart = startDay.addDays(-(startWeekday - 1));

    final emptyColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
    final doneColor = colorScheme.primary;
    final todayBorder = colorScheme.tertiary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = (constraints.maxWidth - (weeksToShow - 1) * 3) / weeksToShow;
        final clampedSize = cellSize.clamp(8.0, 20.0);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(weeksToShow, (weekIndex) {
              return Padding(
                padding: EdgeInsets.only(right: weekIndex < weeksToShow - 1 ? 3 : 0),
                child: Column(
                  children: List.generate(7, (dayIndex) {
                    final day = alignedStart.addDays(weekIndex * 7 + dayIndex);
                    final isFuture = day > today;
                    final isCompleted = completedDays.contains(day);
                    final isToday = day == today;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: GestureDetector(
                        onTap: isFuture ? null : () => onDayTap?.call(day),
                        child: Container(
                          width: clampedSize,
                          height: clampedSize,
                          decoration: BoxDecoration(
                            color: isFuture
                                ? Colors.transparent
                                : isCompleted
                                    ? doneColor.withValues(alpha: 0.85)
                                    : emptyColor,
                            borderRadius: BorderRadius.circular(3),
                            border: isToday
                                ? Border.all(color: todayBorder, width: 2)
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
