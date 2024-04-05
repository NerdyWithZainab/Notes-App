import 'package:flutter/widgets.dart';
import 'package:notes/extensions/buildcontext/loc.dart';
import 'package:notes/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) async {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.generic_error_prompt,
    content: text,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}
