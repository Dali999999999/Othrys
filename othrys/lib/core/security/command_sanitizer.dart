/// Utility for neutralizing shell injection attacks and validating input parameters.
class CommandSanitizer {
  static final RegExp _identifierRegex = RegExp(r'^[a-zA-Z0-9._@-]+$');
  static final RegExp _hostnameRegex = RegExp(
    r'^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]))*$',
  );
  static final RegExp _ipv4Regex = RegExp(r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
  static final RegExp _ipv6Regex = RegExp(r'^[0-9a-fA-F:]+$');

  /// Escapes a single argument with POSIX single quotes.
  static String escapeArg(String arg) => "'${arg.replaceAll("'", "'\\''")}'";

  /// Sanitizes POSIX path, rejecting dangerous command injection sequences.
  static String sanitizePath(String path) {
    if (path.isEmpty) throw ArgumentError('Path cannot be empty');
    final dangerousTokens = [';', '&&', '||', '|', '>', '<', '`', '\$(', '\$', '\x00', '\n', '\r'];
    for (final token in dangerousTokens) {
      if (path.contains(token)) {
        throw ArgumentError('Malicious shell sequence "$token" rejected in path');
      }
    }
    return escapeArg(path);
  }

  /// Whitelists identifier to safe characters `[a-zA-Z0-9._@-]` and rejects leading hyphens.
  static String sanitizeIdentifier(String identifier) {
    final trimmed = identifier.trim();
    if (trimmed.isEmpty || !_identifierRegex.hasMatch(trimmed)) {
      throw ArgumentError('Invalid identifier contains unsafe characters: "$identifier"');
    }
    if (trimmed.startsWith('-')) {
      throw ArgumentError('Identifier cannot start with a hyphen: "$identifier"');
    }
    return trimmed;
  }

  /// Builds a safely escaped command line from binary and arguments.
  static String buildSafeCommand(String binary, List<String> args) {
    final safeBinary = sanitizeIdentifier(binary);
    final escapedArgs = args.map(escapeArg).join(' ');
    return escapedArgs.isEmpty ? safeBinary : '$safeBinary $escapedArgs';
  }

  /// Validates standard TCP/UDP port range (1-65535).
  static bool isValidPort(int port) => port >= 1 && port <= 65535;

  /// Validates a port or port range string (e.g. "80", "443", "8000:8080").
  static bool isValidPortOrRange(String port) {
    final trimmed = port.trim();
    if (trimmed.isEmpty) return false;
    final singleMatch = RegExp(r'^\d+$').firstMatch(trimmed);
    if (singleMatch != null) {
      final p = int.tryParse(trimmed);
      return p != null && isValidPort(p);
    }
    final rangeMatch = RegExp(r'^(\d+):(\d+)$').firstMatch(trimmed);
    if (rangeMatch != null) {
      final start = int.tryParse(rangeMatch.group(1)!);
      final end = int.tryParse(rangeMatch.group(2)!);
      return start != null && end != null && isValidPort(start) && isValidPort(end) && start <= end;
    }
    return false;
  }

  /// Validates IPv4, IPv6 or CIDR notation (e.g. "192.168.1.1", "10.0.0.0/24").
  static bool isValidIpOrCidr(String ip) {
    final trimmed = ip.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains('/')) {
      final parts = trimmed.split('/');
      if (parts.length != 2) return false;
      final addr = parts[0];
      final prefix = int.tryParse(parts[1]);
      if (prefix == null) return false;
      if (_ipv4Regex.hasMatch(addr)) {
        return prefix >= 0 && prefix <= 32;
      }
      if (_ipv6Regex.hasMatch(addr)) {
        return prefix >= 0 && prefix <= 128;
      }
      return false;
    }
    return _ipv4Regex.hasMatch(trimmed) || _ipv6Regex.hasMatch(trimmed);
  }

  /// Validates a docker-compose argument or flag.
  static bool isValidComposeToken(String token) {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return false;
    final dangerousTokens = [';', '&&', '||', '|', '>', '<', '`', r'$(', r'$', '\x00', '\n', '\r'];
    for (final dt in dangerousTokens) {
      if (trimmed.contains(dt)) return false;
    }
    // Allow flags like -d, --build, --scale=web=2, or safe identifier/path tokens
    final flagRegex = RegExp(r'^--?[a-zA-Z0-9_-]+(=[a-zA-Z0-9_./=-]+)?$');
    final identRegex = RegExp(r'^[a-zA-Z0-9._/-]+$');
    return flagRegex.hasMatch(trimmed) || identRegex.hasMatch(trimmed);
  }

  /// Validates hostname, FQDN, IPv4 or IPv6 format.
  static bool isValidHostname(String host) {
    final trimmed = host.trim();
    if (trimmed.isEmpty || trimmed.length > 253) return false;
    return _hostnameRegex.hasMatch(trimmed) || _ipv4Regex.hasMatch(trimmed) || _ipv6Regex.hasMatch(trimmed);
  }
}
