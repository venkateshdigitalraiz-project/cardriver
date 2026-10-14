import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/style/app_colors.dart';

class DocumentUploadTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isRequired;
  final File? file;
  final IconData icon;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onPreview;

  const DocumentUploadTile({
    super.key,
    required this.title,
    this.subtitle,
    this.isRequired = false,
    this.file,
    this.icon = Icons.description_outlined,
    this.hasError = false,
    this.errorMessage,
    required this.onTap,
    this.onRemove,
    this.onPreview,
  });

  String _getFileSizeString(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFile = file != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: hasFile
                  ? const Color(0xFFF0FDF4) // Light subtle green
                  : (hasError ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasError
                    ? AppColors.error
                    : (hasFile
                        ? const Color(0xFF22C55E) // Green
                        : Colors.grey[300]!),
                width: hasFile || hasError ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Leading Icon or Thumbnail
                if (hasFile)
                  GestureDetector(
                    onTap: onPreview ?? onTap,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            file!,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.zoom_in_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: hasError
                          ? AppColors.error.withValues(alpha: 0.1)
                          : const Color(0xFFFFB800).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: hasError ? AppColors.error : const Color(0xFFE5A600),
                      size: 24,
                    ),
                  ),

                const SizedBox(width: 14),

                // Center Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title.endsWith('*')
                                  ? title.substring(0, title.length - 1).trimRight()
                                  : title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isRequired || title.endsWith('*')) ...[
                            const SizedBox(width: 4),
                            const Text(
                              '*',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      if (hasFile) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${file!.path.split(Platform.pathSeparator).last} • ${_getFileSizeString(file!)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          subtitle ?? 'Tap to capture or upload',
                          style: TextStyle(
                            fontSize: 12,
                            color: hasError ? AppColors.error : Colors.black45,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Trailing Action Badge / Remove Button
                if (hasFile) ...[
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    tooltip: 'Remove',
                    visualDensity: VisualDensity.compact,
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isRequired
                          ? (hasError
                              ? AppColors.error.withValues(alpha: 0.12)
                              : const Color(0xFFFFB800).withValues(alpha: 0.15))
                          : Colors.grey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isRequired ? 'Required' : 'Optional',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isRequired
                            ? (hasError ? AppColors.error : const Color(0xFFB45309))
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Error message label if missing
        if (hasError && errorMessage != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 13,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
