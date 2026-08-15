import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:flutter/material.dart';

import '../../shell/coming_next_screen.dart';

/// People — tutoring, mentoring and consulting.
class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) => ComingNextScreen(
    eyebrow: context.strings.connectEyebrow,
    title: context.strings.connectTitle,
  );
}
