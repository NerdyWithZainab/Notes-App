import 'package:flutter/widgets.dart' show BuildContext;
import 'package:notes/l10n/app_localizations.dart';

extension Localization on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
