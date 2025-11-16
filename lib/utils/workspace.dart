import 'dart:convert';
import 'dart:io';

/// Information about the workspace context of a directory
class WorkspaceInfo {
  /// Whether the directory is part of a pub workspace
  final bool isWorkspace;

  /// The workspace root directory (null if not in a workspace)
  final Directory? workspaceRoot;

  /// The current package directory
  final Directory currentPackage;

  /// Whether this is a package within a workspace (not the root)
  final bool isWorkspacePackage;

  WorkspaceInfo({
    required this.isWorkspace,
    this.workspaceRoot,
    required this.currentPackage,
  }) : isWorkspacePackage = isWorkspace &&
            workspaceRoot != null &&
            workspaceRoot.path != currentPackage.path;
}

/// Cache for workspace info to avoid repeated process calls
final Map<String, WorkspaceInfo> _workspaceInfoCache = {};

/// Clears the workspace info cache (useful for testing)
void clearWorkspaceInfoCache() {
  _workspaceInfoCache.clear();
}

/// Gets workspace information for the given directory by running
/// `dart pub workspace list --json` and parsing the output
Future<WorkspaceInfo> getWorkspaceInfo(Directory directory) async {
  // Check cache first
  final cacheKey = directory.absolute.path;
  if (_workspaceInfoCache.containsKey(cacheKey)) {
    return _workspaceInfoCache[cacheKey]!;
  }

  try {
    // Run dart pub workspace list --json
    final result = await Process.run(
      'dart',
      ['pub', 'workspace', 'list', '--json'],
      workingDirectory: directory.path,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      // Command failed, not a workspace
      final info = WorkspaceInfo(
        isWorkspace: false,
        workspaceRoot: null,
        currentPackage: directory,
      );
      _workspaceInfoCache[cacheKey] = info;
      return info;
    }

    // Parse JSON output
    final jsonOutput = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    final packages = (jsonOutput['packages'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>() ?? [];

    if (packages.isEmpty) {
      // No packages found, not a workspace
      final info = WorkspaceInfo(
        isWorkspace: false,
        workspaceRoot: null,
        currentPackage: directory,
      );
      _workspaceInfoCache[cacheKey] = info;
      return info;
    }

    // Check if this is a workspace
    // A workspace has multiple packages and the first one is named "_"
    if (packages.length > 1 && packages[0]['name'] == '_') {
      final workspaceRootPath = packages[0]['path'] as String;
      final info = WorkspaceInfo(
        isWorkspace: true,
        workspaceRoot: Directory(workspaceRootPath),
        currentPackage: directory,
      );
      _workspaceInfoCache[cacheKey] = info;
      return info;
    }

    // Single package, not a workspace
    final info = WorkspaceInfo(
      isWorkspace: false,
      workspaceRoot: null,
      currentPackage: directory,
    );
    _workspaceInfoCache[cacheKey] = info;
    return info;
  } catch (e) {
    // Error running command, assume not a workspace
    final info = WorkspaceInfo(
      isWorkspace: false,
      workspaceRoot: null,
      currentPackage: directory,
    );
    _workspaceInfoCache[cacheKey] = info;
    return info;
  }
}
