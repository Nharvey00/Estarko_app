import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chat/views/chat_screen.dart';
import '../../inquiries/models/inquiry_model.dart';
import '../../inquiries/services/inquiry_service.dart';

class TenantInquiriesScreen extends StatefulWidget {
  final InquiryService? inquiryService;

  const TenantInquiriesScreen({
    super.key,
    this.inquiryService,
  });

  @override
  State<TenantInquiriesScreen> createState() => _TenantInquiriesScreenState();
}

class _TenantInquiriesScreenState extends State<TenantInquiriesScreen> {
  late final InquiryService _inquiryService;

  @override
  void initState() {
    super.initState();
    _inquiryService = widget.inquiryService ?? InquiryService();
  }

  String _getTenantId(BuildContext context) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.uid.isNotEmpty) {
        return authProvider.currentUser!.uid;
      }
    } catch (_) {}
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $period';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'contacted':
        return const Color(0xFF3B82F6);
      case 'closed':
        return const Color(0xFF64748B);
      case 'pending':
      default:
        return const Color(0xFFE11D48);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_outlined,
                size: 72.0,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'No Inquiries Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Your viewing appointments and messages with property hosts will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ]
              .animate(interval: 100.ms)
              .fade(duration: 400.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutQuad),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
      itemBuilder: (context, index) {
        return EstarSkeleton(
          height: 140.0,
          width: double.infinity,
          borderRadius: BorderRadius.circular(20.0),
        );
      },
    );
  }

  Widget _buildInquiryCard(BuildContext context, InquiryModel inquiry) {
    final statusColor = _getStatusColor(inquiry.status);
    final statusText = inquiry.status.isNotEmpty
        ? inquiry.status[0].toUpperCase() + inquiry.status.substring(1)
        : 'Pending';

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFE4E6)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.home_work_outlined,
                    color: Color(0xFFE11D48),
                    size: 22.0,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inquiry.propertyTitle.isNotEmpty
                          ? inquiry.propertyTitle
                          : 'Property Viewing',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Requested ${_formatDate(inquiry.createdAt)}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              EstarStatusBadge(
                text: statusText,
                color: statusColor,
              ),
            ],
          ),

          // Scheduled Date & Time (if present)
          if (inquiry.scheduledDate != null) ...[
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 16.0,
                    color: Color(0xFFE11D48),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Viewing: ${_formatDate(inquiry.scheduledDate!)}',
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Note from tenant (if present)
          if (inquiry.note != null && inquiry.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notes_rounded,
                  size: 16.0,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    inquiry.note!.trim(),
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14.0),
          const Divider(color: Color(0xFFF1F5F9), height: 1.0),
          const SizedBox(height: 12.0),

          // Action row: Chat with Host
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        inquiryId: inquiry.id,
                        title: inquiry.propertyTitle,
                        subtitle: 'Chat with Host',
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 16.0,
                        color: Color(0xFFE11D48),
                      ),
                      SizedBox(width: 6.0),
                      Text(
                        'Chat with Host',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenantId = _getTenantId(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Inquiries',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Track viewing requests and chat with hosts',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: tenantId.isEmpty
                  ? _buildEmptyState()
                  : StreamBuilder<List<InquiryModel>>(
                      stream: _inquiryService.getTenantInquiries(tenantId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return _buildLoadingState();
                        }

                        final inquiries = snapshot.data ?? [];

                        if (inquiries.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16.0,
                          ),
                          itemCount: inquiries.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16.0),
                          itemBuilder: (context, index) {
                            return _buildInquiryCard(
                              context,
                              inquiries[index],
                            )
                                .animate(delay: (index * 80).ms)
                                .fade(duration: 400.ms)
                                .slideY(
                                  begin: 0.1,
                                  curve: Curves.easeOutQuad,
                                );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
