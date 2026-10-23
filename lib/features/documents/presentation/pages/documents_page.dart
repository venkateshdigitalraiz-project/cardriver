import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/media_permission_helper.dart';
import '../../../../injection_container.dart';
import '../../../profile/domain/entities/driver_documents_entity.dart';
import '../../../profile/domain/entities/driver_profile_entity.dart';
import '../bloc/documents_bloc.dart';
import '../bloc/documents_event.dart';
import '../bloc/documents_state.dart';

class DocumentsPage extends StatelessWidget {
  final DriverDocumentsEntity? documents;
  final DriverProfileEntity? profile;

  const DocumentsPage({super.key, this.documents, this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectionContainer.createDocumentsBloc(
        documents: documents,
        profile: profile,
      ),
      child: const _DocumentsView(),
    );
  }
}

class _DocumentsView extends StatelessWidget {
  const _DocumentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => context.safePop(),
        ),
        centerTitle: true,
        title: const Text(
          'Verification Documents',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Documents',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2B78E4)),
            onPressed: () {
              context.read<DocumentsBloc>().add(const RefreshDocumentsEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<DocumentsBloc, DocumentsState>(
        listener: (context, state) {
          if (state is DocumentsLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          } else if (state is DocumentsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DocumentsLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading driver documents...',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                ],
              ),
            );
          } else if (state is DocumentsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<DocumentsBloc>().add(
                          const RefreshDocumentsEvent(),
                        );
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B78E4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is DocumentsLoaded) {
            final docs = state.driverDocuments;
            final verifiedCount = state.verifiedCount;
            final missingCount = state.missingCount;
            final totalCount = docs.length;
            final progress = totalCount > 0
                ? (verifiedCount / totalCount)
                : 0.0;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DocumentsBloc>().add(
                  const RefreshDocumentsEvent(),
                );
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Summary Card
                    _VerificationSummaryCard(
                      verifiedCount: verifiedCount,
                      totalCount: totalCount,
                      progress: progress,
                      missingCount: missingCount,
                    ),
                    const SizedBox(height: 20),

                    // Section Heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Required Documents',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '$verifiedCount of $totalCount Verified',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Document Cards List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = docs[index];
                        return _DocumentCard(
                          doc: item,
                          onTap:
                              () {}, //=> _showDocumentDetailSheet(context, item),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showUploadSheet(
    BuildContext context,
    DocumentItem doc, {
    String? defaultSide,
  }) {
    String selectedSide =
        defaultSide ??
        (doc.key == 'aadhaar'
            ? (doc.fileUrl == null &&
                      (doc.localPath == null || doc.localPath!.isEmpty)
                  ? 'front'
                  : 'back')
            : 'front');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Upload ${doc.title}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc.documentNumber != null
                          ? 'Document ID: ${doc.documentNumber}'
                          : 'Please provide a clear image or document file',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),

                    // Side selector for Aadhaar
                    if (doc.key == 'aadhaar') ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Select Document Side:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Front Side'),
                              selected: selectedSide == 'front',
                              onSelected: (val) {
                                if (val) {
                                  setSheetState(() => selectedSide = 'front');
                                }
                              },
                              selectedColor: const Color(0xFFEBF3FF),
                              labelStyle: TextStyle(
                                color: selectedSide == 'front'
                                    ? const Color(0xFF2B78E4)
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Back Side'),
                              selected: selectedSide == 'back',
                              onSelected: (val) {
                                if (val) {
                                  setSheetState(() => selectedSide = 'back');
                                }
                              },
                              selectedColor: const Color(0xFFEBF3FF),
                              labelStyle: TextStyle(
                                color: selectedSide == 'back'
                                    ? const Color(0xFF2B78E4)
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Camera Option
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF3FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF2B78E4),
                        ),
                      ),
                      title: const Text(
                        'Take Photo with Camera',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        doc.key == 'aadhaar'
                            ? 'Capture clear ${selectedSide.toUpperCase()} photo'
                            : 'Capture clear document photo',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        final file = await MediaPermissionHelper.pickImage(
                          context: context,
                          source: ImageSource.camera,
                        );
                        if (file != null && context.mounted) {
                          final name = file.path
                              .split(Platform.pathSeparator)
                              .last;
                          context.read<DocumentsBloc>().add(
                            UpdateDocumentFileEvent(
                              documentKey: doc.key,
                              filePath: file.path,
                              fileName: name,
                              side: selectedSide,
                            ),
                          );
                        }
                      },
                    ),

                    // Gallery Option
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      title: const Text(
                        'Choose from Gallery',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Select photo from your gallery',
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        final file = await MediaPermissionHelper.pickImage(
                          context: context,
                          source: ImageSource.gallery,
                        );
                        if (file != null && context.mounted) {
                          final name = file.path
                              .split(Platform.pathSeparator)
                              .last;
                          context.read<DocumentsBloc>().add(
                            UpdateDocumentFileEvent(
                              documentKey: doc.key,
                              filePath: file.path,
                              fileName: name,
                              side: selectedSide,
                            ),
                          );
                        }
                      },
                    ),

                    // PDF Document File Picker Option
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                      title: const Text(
                        'Upload PDF / Document File',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Select PDF from your files',
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        try {
                          final result = await FilePicker.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                          );
                          if (result.isNotEmpty &&
                              result.first.path != null &&
                              context.mounted) {
                            final path = result.first.path!;
                            final name = result.first.name;
                            context.read<DocumentsBloc>().add(
                              UpdateDocumentFileEvent(
                                documentKey: doc.key,
                                filePath: path,
                                fileName: name,
                                side: selectedSide,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to pick document: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDocumentDetailSheet(BuildContext context, DocumentItem doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doc.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      _StatusBadge(isVerified: doc.isVerified),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (doc.documentNumber != null &&
                      doc.documentNumber!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Document Number',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                doc.documentNumber!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            tooltip: 'Copy Number',
                            icon: const Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: Color(0xFF2B78E4),
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: doc.documentNumber!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Number copied to clipboard!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Document Preview(s)
                  if (doc.key == 'aadhaar') ...[
                    // Aadhaar Front Preview
                    const Text(
                      'Front Side',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildPreviewBox(
                      localPath: doc.localPath,
                      fileUrl: doc.fileUrl,
                      placeholderText: 'Front side not available',
                    ),
                    const SizedBox(height: 14),

                    // Aadhaar Back Preview
                    const Text(
                      'Back Side',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildPreviewBox(
                      localPath: doc.localBackPath,
                      fileUrl: doc.backFileUrl,
                      placeholderText: 'Back side not available',
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    // Single Document Preview
                    _buildPreviewBox(
                      localPath: doc.localPath,
                      fileUrl: doc.fileUrl,
                      placeholderText: 'Document image not available',
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Action Buttons
                  if (doc.key == 'aadhaar') ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              _showUploadSheet(
                                context,
                                doc,
                                defaultSide: 'front',
                              );
                            },
                            icon: const Icon(
                              Icons.upload_file_rounded,
                              size: 16,
                            ),
                            label: const Text('Update Front'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2B78E4),
                              side: const BorderSide(color: Color(0xFF2B78E4)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              _showUploadSheet(
                                context,
                                doc,
                                defaultSide: 'back',
                              );
                            },
                            icon: const Icon(
                              Icons.upload_file_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Update Back',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B78E4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _showUploadSheet(context, doc);
                        },
                        icon: const Icon(
                          Icons.upload_file_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          doc.isVerified
                              ? 'Update Document'
                              : 'Upload Document',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B78E4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewBox({
    String? localPath,
    String? fileUrl,
    required String placeholderText,
  }) {
    if (localPath != null &&
        localPath.trim().isNotEmpty &&
        File(localPath).existsSync()) {
      return Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: localPath.endsWith('.pdf')
            ? const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                    SizedBox(width: 8),
                    Text(
                      'PDF Attached',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : Image.file(File(localPath), fit: BoxFit.cover),
      );
    } else if (fileUrl != null && fileUrl.trim().isNotEmpty) {
      return Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          ApiEndpoints.resolveImageUrl(fileUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              placeholderText,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Text(
          placeholderText,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _VerificationSummaryCard extends StatelessWidget {
  final int verifiedCount;
  final int totalCount;
  final double progress;
  final int missingCount;

  const _VerificationSummaryCard({
    required this.verifiedCount,
    required this.totalCount,
    required this.progress,
    required this.missingCount,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAllVerified = (missingCount == 0);
    final String statusMessage = isAllVerified
        ? 'All documents verified successfully!'
        : '$missingCount documents pending verification';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isAllVerified
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFEBF3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: isAllVerified
                      ? const Color(0xFF10B981)
                      : const Color(0xFF2B78E4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Document Verification',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: isAllVerified
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEA580C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$verifiedCount/$totalCount',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentItem doc;
  final VoidCallback onTap;

  const _DocumentCard({required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    if (doc.key == 'aadhaar') {
      icon = Icons.badge_outlined;
      iconColor = const Color(0xFFEA580C);
      iconBg = const Color(0xFFFFF7ED);
    } else if (doc.key == 'drivingLicense') {
      icon = Icons.drive_eta_rounded;
      iconColor = const Color(0xFF2B78E4);
      iconBg = const Color(0xFFEBF3FF);
    } else if (doc.key == 'pancard') {
      icon = Icons.credit_card_rounded;
      iconColor = const Color(0xFF7C3AED);
      iconBg = const Color(0xFFF5F3FF);
    } else if (doc.key == 'passport') {
      icon = Icons.menu_book_rounded;
      iconColor = const Color(0xFF0D9488);
      iconBg = const Color(0xFFF0FDFA);
    } else {
      icon = Icons.account_circle_outlined;
      iconColor = const Color(0xFF4F46E5);
      iconBg = const Color(0xFFEEF2FF);
    }

    final isVerified = doc.isVerified;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isVerified ? const Color(0xFFD1FAE5) : const Color(0xFFFFEDD5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),

              // Title and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (((doc.documentNumber != null &&
                                doc.documentNumber!.trim().isNotEmpty) ||
                            doc.subtitle.trim().isNotEmpty)) ...[
                      const SizedBox(height: 3),
                      Text(
                        (doc.documentNumber != null &&
                                doc.documentNumber!.trim().isNotEmpty)
                            ? doc.documentNumber!.trim()
                            : (doc.subtitle.contains(':')
                                ? doc.subtitle.split(':').last.split('·').first.trim()
                                : doc.subtitle.split('·').first.trim()),
                        style: TextStyle(
                          fontSize: 12,
                          color: isVerified
                              ? const Color(0xFF64748B)
                              : const Color(0xFFEA580C),
                          fontWeight: isVerified
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Status Badge: Verified or Not Verified only
              _StatusBadge(isVerified: isVerified),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isVerified;

  const _StatusBadge({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 14,
            ),
            SizedBox(width: 4),
            Text(
              'Verified',
              style: TextStyle(
                color: Color(0xFF065F46),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFEA580C), size: 14),
          SizedBox(width: 4),
          Text(
            'Not Verified',
            style: TextStyle(
              color: Color(0xFF9A3412),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
