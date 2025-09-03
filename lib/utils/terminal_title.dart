import 'dart:io';

String? _originalTitle;
bool _isSupported = true;

void setTerminalTitle(String title) {
  if (!_isSupported || !_isTerminalCapable()) {
    return;
  }

  try {
    if (_originalTitle == null) {
      _captureOriginalTitle();
    }

    stdout.write('\x1b]2;$title\x07');
    stdout.write('\x1b]0;$title\x07');
  } catch (e) {
    _isSupported = false;
  }
}

void restoreTerminalTitle() {
  if (!_isSupported || _originalTitle == null || !_isTerminalCapable()) {
    return;
  }

  try {
    stdout.write('\x1b]2;$_originalTitle\x07');
    stdout.write('\x1b]0;$_originalTitle\x07');
  } catch (e) {
    _isSupported = false;
  }
}

void _captureOriginalTitle() {
  final terminalProgram = Platform.environment['TERM_PROGRAM'];
  final term = Platform.environment['TERM'];

  if (terminalProgram != null || term != null) {
    _originalTitle = Platform.environment['PWD']?.split('/').last ?? 'Terminal';
  }
}

bool _isTerminalCapable() {
  if (!stdout.hasTerminal) {
    return false;
  }

  final term = Platform.environment['TERM'];

  if (term == 'dumb') {
    return false;
  }

  return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
}

void resetTerminalTitle() {
  _originalTitle = null;
  _isSupported = true;
}
