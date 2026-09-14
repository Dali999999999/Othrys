import 'package:flutter/foundation.dart';

/// Supported types of Nginx virtual hosts.
enum WebSiteType {
  reverseProxy,
  staticSite;

  String get label => switch (this) {
        WebSiteType.reverseProxy => 'Reverse Proxy',
        WebSiteType.staticSite => 'Static Website',
      };
}

/// Representation of a website / virtual host configured on remote Nginx.
@immutable
class WebSiteEntity {
  final String domain;
  final WebSiteType type;
  final String target;
  final bool isEnabled;
  final bool hasSsl;
  final String? configFile;

  const WebSiteEntity({
    required this.domain,
    required this.type,
    required this.target,
    this.isEnabled = false,
    this.hasSsl = false,
    this.configFile,
  });

  WebSiteEntity copyWith({
    String? domain,
    WebSiteType? type,
    String? target,
    bool? isEnabled,
    bool? hasSsl,
    String? configFile,
  }) {
    return WebSiteEntity(
      domain: domain ?? this.domain,
      type: type ?? this.type,
      target: target ?? this.target,
      isEnabled: isEnabled ?? this.isEnabled,
      hasSsl: hasSsl ?? this.hasSsl,
      configFile: configFile ?? this.configFile,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSiteEntity &&
          runtimeType == other.runtimeType &&
          domain == other.domain &&
          type == other.type &&
          target == other.target &&
          isEnabled == other.isEnabled &&
          hasSsl == other.hasSsl;

  @override
  int get hashCode =>
      domain.hashCode ^
      type.hashCode ^
      target.hashCode ^
      isEnabled.hashCode ^
      hasSsl.hashCode;
}
