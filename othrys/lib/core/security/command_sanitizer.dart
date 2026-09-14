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

  /// Whitelists identifier to safe characters `[a-zA-Z0-9._@-]`.
  static String sanitizeIdentifier(String identifier) {
    final trimmed = identifier.trim();
    if (trimmed.isEmpty || !_identifierRegex.hasMatch(trimmed)) {
      throw ArgumentError('Invalid identifier contains unsafe characters: "$identifier"');
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

  /// Validates hostname, FQDN, IPv4 or IPv6 format.
  static bool isValidHostname(String host) {
    final trimmed = host.trim();
    if (trimmed.isEmpty || trimmed.length > 253) return false;
    return _hostnameRegex.hasMatch(trimmed) || _ipv4Regex.hasMatch(trimmed) || _ipv6Regex.hasMatch(trimmed);
  }
}
