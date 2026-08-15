import 'dart:typed_data';

import 'package:ejadah_core/ejadah_core.dart';
import 'package:ejadah_localization/ejadah_localization.dart';
import 'package:ejadah_models/ejadah_models.dart';
import 'package:ejadah_ui/ejadah_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'upload_repository.dart';

/// A file the user chose, before it has been sent anywhere.
class PickedFile {
  const PickedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// Opening the platform's file browser.
///
/// Behind a provider because a widget test cannot open one: the tests override
/// this with a function that returns bytes directly, which keeps the upload,
/// the failure states and the "chosen" affordance under test even though the
/// picker itself is not.
typedef FilePickerFn = Future<PickedFile?> Function(UploadPurpose purpose);

final filePickerProvider = Provider<FilePickerFn>((ref) => _pickWithPlatform);

Future<PickedFile?> _pickWithPlatform(UploadPurpose purpose) async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: purpose.extensions,
  );
  if (file == null) return null;
  // The bytes, not a path: the app never reads the user's filesystem itself,
  // and this is the one form that works identically on every platform.
  return PickedFile(name: file.name, bytes: await file.readAsBytes());
}

/// Choose a file, upload it, and show what was chosen.
///
/// The uploaded key — never the file — is what the form records, so a step that
/// is saved and revisited shows "chosen" without re-uploading anything.
class EjadahFileField extends ConsumerStatefulWidget {
  const EjadahFileField({
    required this.label,
    required this.purpose,
    required this.onUploaded,
    this.storedKey,
    this.enabled = true,
    this.helperText,
    super.key,
  });

  final String label;
  final UploadPurpose purpose;

  /// Called with the stored key once the server has accepted the file.
  final ValueChanged<StoredFile> onUploaded;

  /// What the form already holds, if the step is being revisited.
  final String? storedKey;
  final bool enabled;
  final String? helperText;

  @override
  ConsumerState<EjadahFileField> createState() => _EjadahFileFieldState();
}

class _EjadahFileFieldState extends ConsumerState<EjadahFileField> {
  bool _uploading = false;
  String? _chosenName;
  Failure? _failure;

  bool get _hasFile => widget.storedKey != null || _chosenName != null;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final type = context.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          type.eyebrowText(widget.label),
          style: type.eyebrow(color: EjadahColors.labelMuted),
        ),
        const SizedBox(height: EjadahSpacing.xxs),
        if (_hasFile) ...[
          Row(
            children: [
              const Icon(
                EjadahIcons.check,
                size: EjadahIconSize.inline,
                color: EjadahColors.successText,
              ),
              const SizedBox(width: EjadahSpacing.xs),
              Expanded(
                child: Text(
                  _chosenName == null
                      ? strings.fileChosen(_fileNameOf(widget.storedKey!))
                      : strings.fileChosen(_chosenName!),
                  style: type.bodyText(),
                ),
              ),
            ],
          ),
          const SizedBox(height: EjadahSpacing.xs),
        ],
        EjadahSecondaryButton(
          label: _hasFile
              ? strings.replaceFile
              : (widget.purpose == UploadPurpose.avatar
                    ? strings.choosePhoto
                    : strings.chooseFile),
          isLoading: _uploading,
          onPressed: widget.enabled && !_uploading ? _choose : null,
          expand: false,
          // Disabled means the form is locked — an application under review.
          // A file picker that will not open needs to say which.
          disabledReason: strings.notEditableNow,
          onDisabledTap: (reason) => showEjadahToast(context, message: reason),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: EjadahSpacing.xxs),
          Text(
            widget.helperText!,
            style: type.caption(color: EjadahColors.textSecondary),
          ),
        ],
        if (_failure != null) ...[
          const SizedBox(height: EjadahSpacing.xs),
          // A refused upload says what was wrong with the file — "not accepted"
          // with no reason leaves someone retrying the same PDF.
          InlineAlert(
            message: _failure!.message(context),
            tone: AlertTone.danger,
          ),
        ],
      ],
    );
  }

  Future<void> _choose() async {
    final picked = await ref.read(filePickerProvider)(widget.purpose);
    if (picked == null || !mounted) return;

    // Checked before the request, so an oversized photograph is refused in a
    // moment rather than after a long upload on a mobile connection.
    if (picked.bytes.length > UploadRepository.maxBytes) {
      setState(() => _failure = ValidationFailure(message: _tooLarge));
      return;
    }

    setState(() {
      _uploading = true;
      _failure = null;
    });

    try {
      final stored = await ref
          .read(uploadRepositoryProvider)
          .upload(purpose: widget.purpose, bytes: picked.bytes);
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _chosenName = picked.name;
      });
      widget.onUploaded(stored);
    } on Failure catch (failure) {
      if (!mounted) return;
      // The name is not kept: showing "chosen" over a file the server refused
      // would let someone submit believing a certificate was attached.
      setState(() {
        _uploading = false;
        _failure = failure;
      });
    }
  }

  /// `document/<user>/<token>.pdf` → `<token>.pdf`.
  ///
  /// The original filename is not stored — it can carry a person's name and
  /// there is no reason for the server to keep one — so a revisited step names
  /// the file by its key rather than inventing a label.
  static String _fileNameOf(String key) => key.split('/').last;
}

const LocalizedText _tooLarge = LocalizedText(
  en: 'That file is larger than 5 MB. Try a smaller one.',
  ar: 'حجم الملف أكبر من 5 ميجابايت. جرّب ملفًا أصغر.',
);
