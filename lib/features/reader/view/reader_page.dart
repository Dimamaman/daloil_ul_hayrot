import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/reader_bloc.dart';
import '../bloc/reader_event.dart';
import '../bloc/reader_state.dart';
import '../widgets/section_card.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../../settings/view/notification_settings_page.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = [];
  bool _restoredScroll = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReaderBloc, ReaderState>(
      listenWhen: (prev, curr) =>
          prev.isLoading && !curr.isLoading && !_restoredScroll,
      listener: (context, state) {
        // Kitob yuklanganda saqlangan pozitsiyaga qaytish
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToIndex(state.firstVisibleSectionIndex);
          _restoredScroll = true;
        });
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Har bir section uchun GlobalKey
        while (_itemKeys.length < state.sections.length) {
          _itemKeys.add(GlobalKey());
        }

        return Scaffold(
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final index = _findFirstVisibleIndex();
                context.read<ReaderBloc>().add(ScrollPositionChanged(index));
              }
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  title: Text(
                    state.currentHizb?.titleUz ??
                        'Hizb ${state.todayHizbNumber}',
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        state.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: () => context
                          .read<ReaderBloc>()
                          .add(const ThemeToggled()),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationSettingsPage(
                            prefs: context.read<SharedPreferences>(),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () => SettingsBottomSheet.show(context),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(3),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 3,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    List.generate(state.sections.length, (i) {
                      final section = state.sections[i];
                      return KeyedSubtree(
                        key: _itemKeys[i],
                        child: SectionCard(
                          section: section,
                          fontSize: state.fontSize,
                          lineHeight: state.lineHeight,
                          showTransliteration: state.showTransliteration,
                          showTranslation: state.showTranslation,
                          isBookmarked: state.bookmarkedSectionIds
                              .contains(section.id),
                          onBookmarkToggle: () => context
                              .read<ReaderBloc>()
                              .add(BookmarkToggled(section.id)),
                        ),
                      );
                    }),
                  ),
                ),
                // Pastdan bo'sh joy — FAB ustma-ust tushmasligi uchun
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),
          floatingActionButton: state.todayMarked
              ? FloatingActionButton.small(
                  onPressed: null,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : FloatingActionButton.extended(
                  onPressed: () => _confirmComplete(context),
                  icon: const Icon(Icons.done_all),
                  label: const Text('Tugatdim'),
                ),
        );
      },
    );
  }

  void _scrollToIndex(int index) {
    if (index <= 0 || index >= _itemKeys.length) return;
    final ctx = _itemKeys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: Duration.zero);
    }
  }

  int _findFirstVisibleIndex() {
    for (var i = 0; i < _itemKeys.length; i++) {
      final ctx = _itemKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox;
      final itemBottom = box.localToGlobal(Offset.zero).dy + box.size.height;
      if (itemBottom > 100) return i;
    }
    return 0;
  }

  void _confirmComplete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tasdiqlash'),
        content: const Text('Bugungi o\'qishni tugatdingizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yo\'q'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<ReaderBloc>()
                  .add(const TodayReadingCompleted());
            },
            child: const Text('Ha, tugatdim'),
          ),
        ],
      ),
    );
  }
}
