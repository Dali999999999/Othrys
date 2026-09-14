/// Utility functions for secure shell command execution.
/// Ensures that arbitrary user arguments are safely escaped according to POSIX standards,
/// preventing command injection vulnerabilities.
class ShellUtils {
  ShellUtils._();

  /// Escapes a single string argument for use in a POSIX shell.
  /// 
  /// Wraps the argument in single quotes and safely escapes internal single quotes.
  /// Example: `foo'bar` becomes `'foo'\''bar'`
  static String escapeArg(String arg) {
    if (arg.isEmpty) {
      return "''";
    }
    // Replace each ' with '\'' and wrap the entire string in single quotes
    final escaped = arg.replaceAll("'", r"'\''");
    return "'$escaped'";
  }

  /// Builds a secure shell command string with a base binary and escaped arguments.
  /// 
  /// [baseCommand] is assumed to be a safe binary name (e.g. 'docker', 'systemctl', 'tar').
  /// All items in [args] are strictly escaped with single quotes.
  static String buildSafeCommand(String baseCommand, List<String> args) {
    if (args.isEmpty) {
      return baseCommand;
    }
    final escapedArgs = args.map(escapeArg).join(' ');
    return '$baseCommand $escapedArgs';
  }

  /// Validates whether a file path is an absolute POSIX path without traversal or null bytes.
  static bool isValidSafePath(String path) {
    if (path.isEmpty || !path.startsWith('/')) return false;
    if (path.contains('\x00')) return false;
    // Disallow relative traversal sequences
    final parts = path.split('/');
    for (final part in parts) {
      if (part == '..') return false;
    }
    return true;
  }
}
