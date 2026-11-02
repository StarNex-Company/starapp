import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/utils/json.dart';

/// Which of a creator's lists is shown.
enum ConnectionsTab {
  followers,
  following;

  ConnectionsTab get other => this == followers ? following : followers;
}

/// A person in a followers / following list
/// (`GET /creators/{id}/followers`, `/following`, or `/me/…`): the
/// [CreatorSummary] fields at the top level plus [followsYou]. Whether the
/// user follows them is `followingProvider`.
class Connection {
  const Connection({required this.creator, this.followsYou = false});

  factory Connection.fromJson(Json json) => Connection(
    creator: CreatorSummary.fromJson(json),
    followsYou: json['followsYou'] as bool? ?? false,
  );

  final CreatorSummary creator;

  /// They follow the signed-in user.
  final bool followsYou;

  String get id => creator.id;

  Json toJson() => {...creator.toJson(), 'followsYou': followsYou};
}

/// Whose lists are shown: the name in the header and the two counts.
class ConnectionsOwner {
  const ConnectionsOwner({
    required this.name,
    required this.followers,
    required this.following,
  });

  final String name;
  final int followers;
  final int following;

  int count(ConnectionsTab tab) =>
      tab == ConnectionsTab.followers ? followers : following;
}
