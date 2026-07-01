import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveTab extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}

final activeTabProvider = NotifierProvider<ActiveTab, int>(ActiveTab.new);
