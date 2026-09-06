import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class BookRepository {
  BookRepository(this._prefs);

  final SharedPreferences _prefs;

  Book? _cachedBook;

  Future<Book> loadBook() async {
    if (_cachedBook != null) return _cachedBook!;
    final jsonStr = await rootBundle.loadString('assets/data/book.json');
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _cachedBook = Book.fromJson(json);
    return _cachedBook!;
  }

  // --- Skroll pozitsiyasi (indeks bo'yicha) ---

  void saveScrollPosition(String hizbId, int sectionIndex) {
    _prefs.setString('last_hizb_id', hizbId);
    _prefs.setInt('last_section_index', sectionIndex);
  }

  ({String? hizbId, int sectionIndex}) loadScrollPosition() {
    return (
      hizbId: _prefs.getString('last_hizb_id'),
      sectionIndex: _prefs.getInt('last_section_index') ?? 0,
    );
  }

  // --- Xatcho'plar ---

  Set<String> loadBookmarks() {
    return (_prefs.getStringList('bookmarks') ?? []).toSet();
  }

  Future<void> saveBookmarks(Set<String> bookmarks) {
    return _prefs.setStringList('bookmarks', bookmarks.toList());
  }

  // --- Sozlamalar ---

  bool get showTransliteration => _prefs.getBool('show_translit') ?? false;
  set showTransliteration(bool v) => _prefs.setBool('show_translit', v);

  bool get showTranslation => _prefs.getBool('show_translation') ?? false;
  set showTranslation(bool v) => _prefs.setBool('show_translation', v);
}
