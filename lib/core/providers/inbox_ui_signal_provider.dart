import 'package:flutter_riverpod/legacy.dart';

/// Wird erhöht, wenn sich Inbox-Daten ändern (Realtime, markRead, etc.)
final inboxUiTickProvider = StateProvider<int>((ref) => 0);
