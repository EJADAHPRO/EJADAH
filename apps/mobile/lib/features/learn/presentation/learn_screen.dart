import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:flutter/material.dart';

import '../../shell/coming_next_screen.dart';

/// Learn — recorded courses, handouts, flashcards and quizzes.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) => ComingNextScreen(
    eyebrow: context.strings.coursesEyebrow,
    title: context.strings.coursesTitle,
  );
}
