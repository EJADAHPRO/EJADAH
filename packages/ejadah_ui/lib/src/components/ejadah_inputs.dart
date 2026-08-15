import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/ejadah_icons.dart';
import '../theme/ejadah_theme.dart';
import '../tokens/ejadah_tokens.dart';

/// A text field.
///
/// Validation runs on blur, never on every keystroke — correcting someone
/// mid-word is hostile. The error sits below the field, is announced as a live
/// region, and pairs a colour change with words so the state is never
/// colour-only.
class EjadahInput extends StatelessWidget {
  const EjadahInput({
    required this.label,
    required this.controller,
    this.hint,
    this.errorText,
    this.helperText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onEditingComplete,
    this.enabled = true,
    this.maxLines = 1,
    this.autofillHints,
    this.focusNode,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;

  /// The approved message for this field's failure.
  final String? errorText;
  final String? helperText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final bool enabled;
  final int maxLines;
  final List<String>? autofillHints;
  final FocusNode? focusNode;

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final type = context.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          type.eyebrowText(label),
          style: type.eyebrow(color: EjadahColors.labelMuted),
        ),
        const SizedBox(height: EjadahSpacing.xxs),
        Opacity(
          opacity: enabled ? 1 : EjadahOpacity.disabled,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            onEditingComplete: onEditingComplete,
            maxLines: obscureText ? 1 : maxLines,
            autofillHints: autofillHints,
            style: type.bodyText(),
            cursorColor: EjadahColors.orange,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: type.bodyText(color: EjadahColors.labelMuted),
              filled: true,
              fillColor: EjadahColors.card,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: EjadahSpacing.sm,
                vertical: EjadahSpacing.sm,
              ),
              border: _border(EjadahColors.border),
              enabledBorder: _border(
                _hasError ? EjadahColors.danger : EjadahColors.border,
              ),
              // The focus ring is 3px orange — the same ring every focusable
              // Ejadah control uses.
              focusedBorder: _border(
                _hasError ? EjadahColors.danger : EjadahColors.orange,
                width: 3,
              ),
              errorBorder: _border(EjadahColors.danger),
              focusedErrorBorder: _border(EjadahColors.danger, width: 3),
            ),
          ),
        ),
        if (_hasError) ...[
          const SizedBox(height: EjadahSpacing.xxs),
          Semantics(
            liveRegion: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  EjadahIcons.warning,
                  size: EjadahIconSize.inline - 2,
                  color: EjadahColors.dangerText,
                ),
                const SizedBox(width: EjadahSpacing.xxs),
                Expanded(
                  child: Text(
                    errorText!,
                    style: type.small(color: EjadahColors.dangerText),
                  ),
                ),
              ],
            ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: EjadahSpacing.xxs),
          Text(helperText!, style: type.small(color: EjadahColors.labelMuted)),
        ],
      ],
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1.5}) =>
      OutlineInputBorder(
        borderRadius: EjadahRadius.all(EjadahRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );
}

/// The Career-scoped search field.
///
/// Search is deliberately scoped to Career — there is no global cross-content
/// search in Phase 1, and the placeholder says what it actually covers
/// ("University, programme or city") rather than a vague "Search".
class EjadahSearchField extends StatelessWidget {
  const EjadahSearchField({
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    this.onChanged,
    this.clearLabel = 'Clear',
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final String clearLabel;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onSubmitted: onSubmitted,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    style: context.type.bodyText(),
    cursorColor: EjadahColors.orange,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: context.type.bodyText(color: EjadahColors.labelMuted),
      filled: true,
      fillColor: EjadahColors.card,
      isDense: true,
      // The magnifier never mirrors; it sits at the logical start.
      prefixIcon: const Icon(
        EjadahIcons.search,
        size: EjadahIconSize.nav,
        color: EjadahColors.labelMuted,
      ),
      suffixIcon: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => value.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(
                  EjadahIcons.close,
                  size: EjadahIconSize.inline,
                ),
                color: EjadahColors.labelMuted,
                tooltip: clearLabel,
                onPressed: () {
                  controller.clear();
                  HapticFeedback.selectionClick();
                  onSubmitted('');
                },
              ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: EjadahSpacing.sm),
      border: EjadahInput._border(EjadahColors.border),
      enabledBorder: EjadahInput._border(EjadahColors.border),
      focusedBorder: EjadahInput._border(EjadahColors.orange, width: 3),
    ),
  );
}
