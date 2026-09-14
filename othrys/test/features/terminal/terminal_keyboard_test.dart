import 'package:flutter_test/flutter_test.dart';
import 'package:xterm/xterm.dart' as xterm;

void main() {
  test('xterm.Terminal textInput and write test', () {
    final terminal = xterm.Terminal();
    String? output;
    terminal.onOutput = (data) => output = data;

    terminal.textInput('hello');
    expect(output, equals('hello'));

    terminal.paste('pasted text');
    expect(output, equals('pasted text'));
  });

  test('xterm.Terminal selection and getText test', () {
    final terminal = xterm.Terminal();
    final controller = xterm.TerminalController();

    terminal.write('Hello DevOps World\r\n');

    // Select first line
    final anchor1 = terminal.buffer.createAnchor(0, 0);
    final anchor2 = terminal.buffer.createAnchor(5, 0);
    controller.setSelection(anchor1, anchor2);

    expect(controller.selection, isNotNull);
    final selectedText = terminal.buffer.getText(controller.selection!);
    expect(selectedText, contains('Hello'));
  });
}
