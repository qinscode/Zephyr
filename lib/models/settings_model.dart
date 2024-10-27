import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

enum FontSize {
  small,
  medium,
  large,
  huge,
}

enum SortBy {
  byCreationDate,
  byModificationDate,
}

enum NoteLayout {
  list,
  grid,
}

class SettingsModel extends ChangeNotifier {
  FontSize _fontSize = FontSize.medium;
  SortBy _sortBy = SortBy.byModificationDate;
  NoteLayout _layout = NoteLayout.grid;
  bool _highPriorityReminders = false;

  FontSize get fontSize => _fontSize;
  SortBy get sortBy => _sortBy;
  NoteLayout get layout => _layout;
  bool get highPriorityReminders => _highPriorityReminders;

  void setFontSize(FontSize size) {
    _fontSize = size;
    notifyListeners();
  }

  void setSortBy(SortBy sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setLayout(NoteLayout layout) {
    _layout = layout;
    notifyListeners();
  }

  void setHighPriorityReminders(bool value) {
    _highPriorityReminders = value;
    notifyListeners();
  }
}

