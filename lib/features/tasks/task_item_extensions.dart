import '../../data/models/models.dart';

/// Buy-feed inventory tasks created from Fix the gap recommendations.
const kTaskActionBuyFeed = 'buy_feed';

extension TaskItemBuyFeed on TaskItem {
  bool get isBuyFeedInventoryTask {
    if (actionKind == kTaskActionBuyFeed) return true;
    return iconName == 'wallet' &&
        title.toLowerCase().startsWith('buy ');
  }

  /// Product name parsed from "Buy {product}" when metadata is missing.
  String? get inferredFeedProductName {
    if (feedProductName != null && feedProductName!.isNotEmpty) {
      return feedProductName;
    }
    const prefix = 'Buy ';
    if (title.startsWith(prefix)) return title.substring(prefix.length);
    return null;
  }
}
