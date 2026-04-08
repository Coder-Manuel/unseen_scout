import 'package:intl/intl.dart';

extension StringExt on String? {
  String get inital {
    if (this == null) return '--';

    if (this!.isEmpty) return '--';

    final words = this!.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';

    String initials = '';
    for (final word in words) {
      if (word.isNotEmpty) {
        initials += word[0].toUpperCase();
      }
    }

    return initials;
  }

  bool get isStrongPassword {
    if (this == null) return false;
    if (this!.isEmpty) return false;
    final regExp = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9])\S{8,}$',
    );
    return regExp.hasMatch(this!);
  }
}

extension NumExt on num {
  bool get isApiSuccess {
    return this == 200 || this == 201;
  }

  String get asCurrency {
    final oCcy = NumberFormat("#,##0", "en_US");
    return oCcy.format(this);
  }
}
