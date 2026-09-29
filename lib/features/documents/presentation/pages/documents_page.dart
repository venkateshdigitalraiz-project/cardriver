import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/documents_bloc.dart';
import '../bloc/documents_event.dart';
import '../bloc/documents_state.dart';
import 'package:file_picker/file_picker.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DocumentsBloc()..add(LoadDocumentsEvent()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'Documents',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<DocumentsBloc, DocumentsState>(
          builder: (context, state) {
            if (state is DocumentsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DocumentsLoaded) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                count: state.verifiedCount.toString(),
                                label: 'Verified',
                                backgroundColor: const Color(0xFFC8E6C9),
                                textColor: const Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                count: state.expiringCount.toString(),
                                label: 'Expiring',
                                backgroundColor: const Color(0xFFF5DEB3),
                                textColor: const Color(0xFFE65100),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                count: state.missingCount.toString(),
                                label: 'Missing',
                                backgroundColor: const Color(0xFFFFCDD2),
                                textColor: const Color(0xFFC62828),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Chips
                        Row(
                          children: [
                            _FilterChip(
                              label: 'All',
                              isSelected: state.selectedFilter == 'All',
                              onTap: () => context.read<DocumentsBloc>().add(
                                FilterDocumentsEvent('All'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _FilterChip(
                              label: 'Driver',
                              isSelected: state.selectedFilter == 'Driver',
                              onTap: () => context.read<DocumentsBloc>().add(
                                FilterDocumentsEvent('Driver'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _FilterChip(
                              label: 'Vehicle',
                              isSelected: state.selectedFilter == 'Vehicle',
                              onTap: () => context.read<DocumentsBloc>().add(
                                FilterDocumentsEvent('Vehicle'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Driver Documents Section
                        if (state.selectedFilter == 'All' ||
                            state.selectedFilter == 'Driver') ...[
                          const Text(
                            'Driver documents',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DocumentGroup(documents: state.driverDocuments),
                          const SizedBox(height: 24),
                        ],

                        // Vehicle Documents Section
                        if (state.selectedFilter == 'All' ||
                            state.selectedFilter == 'Vehicle') ...[
                          const Text(
                            'Vehicle documents · TS 09 EA 1234',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DocumentGroup(documents: state.vehicleDocuments),
                        ],

                        // Bottom padding for the fixed button and nav bar
                        const SizedBox(height: 160),
                      ],
                    ),
                  ),

                  // Fixed Bottom Button
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom:
                        0, // Above bottom nav if any, but since we have a bottom nav in design, we put it above it.
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 80,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, -4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final result = await FilePicker.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf'],
                              );
                              if (result.isNotEmpty) {
                                if (!context.mounted) return;
                                // PDF attached successfully
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Attached: ${result.first.name}',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.upload_file,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Upload document',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B78E4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Fake Bottom Nav (just for design match)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _BottomNavItem(
                            icon: Icons.home_outlined,
                            label: 'Home',
                            isSelected: false,
                          ),
                          _BottomNavItem(
                            icon: Icons.map_outlined,
                            label: 'Trips',
                            isSelected: false,
                          ),
                          _BottomNavItem(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Earnings',
                            isSelected: false,
                          ),
                          _BottomNavItem(
                            icon: Icons.grid_view,
                            label: 'Service',
                            isSelected: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String count;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatCard({
    required this.count,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _DocumentGroup extends StatelessWidget {
  final List<DocumentItem> documents;

  const _DocumentGroup({required this.documents});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: documents.length,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.grey.shade300, height: 1),
        itemBuilder: (context, index) {
          final doc = documents[index];
          return _DocumentListItem(doc: doc);
        },
      ),
    );
  }
}

class _DocumentListItem extends StatefulWidget {
  final DocumentItem doc;

  const _DocumentListItem({required this.doc});

  @override
  State<_DocumentListItem> createState() => _DocumentListItemState();
}

class _DocumentListItemState extends State<_DocumentListItem> {
  String? uploadedFileName;

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconBgColor;
    Color iconColor;

    if (widget.doc.title.contains('Insurance') ||
        widget.doc.title.contains('PUC') ||
        widget.doc.title.contains('Police')) {
      iconBgColor = const Color(0xFFFBE9E7); // light red/orange
      iconColor = Colors.deepOrange;
      iconData = Icons.description_outlined;
    } else {
      iconBgColor = const Color(0xFFE8EAF6); // light indigo
      iconColor = Colors.indigo;
      iconData = Icons.credit_card_outlined;
    }

    String displaySubtitle = uploadedFileName != null
        ? 'Successfully loaded ${uploadedFileName!}'
        : widget.doc.subtitle;

    Color subtitleColor = uploadedFileName != null
        ? Colors.green.shade700
        : (widget.doc.statusType == 'upload'
              ? Colors.red.shade700
              : Colors.grey.shade600);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doc.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displaySubtitle,
                  style: TextStyle(color: subtitleColor, fontSize: 12),
                ),
              ],
            ),
          ),
          if (uploadedFileName == null)
            _buildStatus(context, widget.doc.status, widget.doc.statusType)
          else
            _buildStatus(context, 'Uploaded', 'success'),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context, String status, String type) {
    if (type == 'upload') {
      return GestureDetector(
        onTap: () async {
          try {
            final result = await FilePicker.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
            );
            if (result.isNotEmpty) {
              if (!context.mounted) return;
              setState(() {
                uploadedFileName = result.first.name;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Attached: ${result.first.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Text(
          status,
          style: const TextStyle(
            color: Color(0xFF2B78E4),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    Color bgColor;
    Color textColor;
    if (type == 'success') {
      bgColor = const Color(0xFFC8E6C9);
      textColor = const Color(0xFF2E7D32);
    } else {
      bgColor = const Color(0xFFF5DEB3);
      textColor = const Color(0xFFE65100);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF2B78E4) : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2B78E4) : Colors.grey,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
