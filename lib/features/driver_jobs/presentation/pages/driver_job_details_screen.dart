import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/driver_job_entity.dart';
import '../bloc/driver_job_details_bloc.dart';
import '../bloc/driver_job_details_event.dart';
import '../bloc/driver_job_details_state.dart';

// User specified name alias support
typedef driverjobdetails = DriverJobDetailsScreen;
typedef drivrtjobdetails = DriverJobDetailsScreen;

class DriverJobDetailsScreen extends StatelessWidget {
  final String jobId;
  final String? driverToken;
  final DriverJobEntity? initialJob;

  const DriverJobDetailsScreen({
    super.key,
    required this.jobId,
    this.driverToken,
    this.initialJob,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectionContainer.createDriverJobDetailsBloc(
        jobId: jobId,
        driverToken: driverToken,
        initialJob: initialJob,
      )..add(LoadDriverJobDetailsEvent(jobId: jobId, token: driverToken)),
      child: _DriverJobDetailsView(jobId: jobId, driverToken: driverToken),
    );
  }
}

class _DriverJobDetailsView extends StatelessWidget {
  final String jobId;
  final String? driverToken;

  const _DriverJobDetailsView({
    required this.jobId,
    this.driverToken,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverJobDetailsBloc, DriverJobDetailsState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          (current.errorMessage != null &&
              previous.errorMessage != current.errorMessage) ||
          (current.successMessage != null &&
              previous.successMessage != current.successMessage),
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.successMessage!,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state.errorMessage != null && state.job != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0F172A),
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Job Details',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF0F172A),
                ),
                tooltip: 'Refresh',
                onPressed: () {
                  context.read<DriverJobDetailsBloc>().add(
                        LoadDriverJobDetailsEvent(
                          jobId: jobId,
                          token: driverToken,
                          refresh: true,
                        ),
                      );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: const Color(0xFFE2E8F0), height: 1),
            ),
          ),
          body: _buildBody(context, state),
          bottomNavigationBar: state.job != null
              ? _buildBottomBar(context, state.job!, state)
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DriverJobDetailsState state) {
    if (state.isLoading && state.job == null) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFF0066FF),
        ),
      );
    }

    if (state.isFailure && state.job == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: Colors.red,
              ),
              const SizedBox(height: 14),
              Text(
                'Failed to Load Job Details',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.errorMessage ??
                    'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<DriverJobDetailsBloc>().add(
                        LoadDriverJobDetailsEvent(
                          jobId: jobId,
                          token: driverToken,
                        ),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final job = state.job!;

    return RefreshIndicator(
      color: const Color(0xFF0066FF),
      onRefresh: () async {
        context.read<DriverJobDetailsBloc>().add(
              LoadDriverJobDetailsEvent(
                jobId: jobId,
                token: driverToken,
                refresh: true,
              ),
            );
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          job.jobId,
                          style: GoogleFonts.jetBrainsMono(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 15,
                          color: Color(0xFF64748B),
                        ),
                        tooltip: 'Copy Job ID',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: job.jobId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Job ID copied to clipboard'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF059669),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'OPEN',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF059669),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Headline Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MONTHLY SALARY',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF15803D),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              job.formattedSalary,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            job.formattedJobType,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Target Joining Date: ',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        job.formattedJoiningDate,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  if (job.hours != null && job.hours! > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Daily Working Hours: ',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '${job.hours} Hours / Day',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Work Location Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: Color(0xFF0066FF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Work Location / Duty Area',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.location.isNotEmpty
                        ? job.location
                        : 'Exact pickup & duty area will be coordinated upon application.',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Description Card
            if (job.description.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.description_rounded,
                          size: 18,
                          color: Color(0xFF0066FF),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Job Requirements & Description',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      job.description,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFF475569),
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Car Owner / Listing Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Verified Listing Details',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (job.customerName != null && job.customerName!.isNotEmpty) ...[
                    _buildDetailRow('Posted By', job.customerName!),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                  ],
                  _buildDetailRow('Listing Status', 'Active & Verified', isBadge: true),
                  if (job.formattedCreatedAt.isNotEmpty) ...[
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildDetailRow('Posted On', job.formattedCreatedAt),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBadge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF047857),
              ),
            ),
          )
        else
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    DriverJobEntity job,
    DriverJobDetailsState state,
  ) {
    final isApplied = state.isApplied;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: (isApplied || state.isApplying)
                ? null
                : () => _confirmApply(context, job),
            icon: state.isApplying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isApplied
                        ? Icons.check_circle_rounded
                        : Icons.send_rounded,
                    size: 18,
                  ),
            label: Text(
              isApplied
                  ? 'Application Submitted'
                  : state.isApplying
                      ? 'Submitting...'
                      : 'Apply for This Job',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApplied
                  ? const Color(0xFF059669)
                  : const Color(0xFF0066FF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmApply(BuildContext context, DriverJobEntity job) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.work_rounded,
                  color: Color(0xFF0066FF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Apply for Job?',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to apply for this driver position?',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text(
                      job.jobId,
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: const Color(0xFF0066FF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          color: const Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your verified driver profile will be shared with the employer.',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                context.read<DriverJobDetailsBloc>().add(
                      ApplyDriverJobDetailsEvent(
                        jobId: job.jobId.isNotEmpty ? job.jobId : job.id,
                        token: driverToken,
                      ),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Confirm & Apply'),
            ),
          ],
        );
      },
    );
  }
}
