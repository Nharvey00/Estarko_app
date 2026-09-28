import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chat/views/chat_screen.dart';
import '../models/inquiry_model.dart';
import '../services/inquiry_service.dart';

class SellerInboxScreen extends StatefulWidget {
  final String? sellerId;
  final InquiryService? inquiryService;

  const SellerInboxScreen({
    super.key,
    this.sellerId,
    this.inquiryService,
  });

  @override
  State<SellerInboxScreen> createState() => _SellerInboxScreenState();
}

class _SellerInboxScreenState extends State<SellerInboxScreen> {
  late final InquiryService _inquiryService;

  @override
  void initState() {
    super.initState();
    _inquiryService = widget.inquiryService ?? InquiryService();
  }

  String _getSellerId(BuildContext context) {
    if (widget.sellerId != null && widget.sellerId!.isNotEmpty) {
      return widget.sellerId!;
    }
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
                Icons.inbox_outlined,
                size: 72.0,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'No inquiries yet',
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
              'When tenants request viewings for your properties, they will appear here.',
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
          height: 130.0,
          width: double.infinity,
          borderRadius: BorderRadius.circular(20.0),
        );
      },
    );
  }

  Widget _buildStatusDropdown(InquiryModel inquiry) {
    const validStatuses = ['pending', 'contacted', 'closed'];
    final currentStatus = validStatuses.contains(inquiry.status)
        ? inquiry.status
        : 'pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFE11D48).withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isDense: true,
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: Color(0xFFE11D48),
            size: 20.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: Color(0xFFE11D48),
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
          ),
          items: const [
            DropdownMenuItem(
              value: 'pending',
              child: Text('Pending'),
            ),
            DropdownMenuItem(
              value: 'contacted',
              child: Text('Contacted'),
            ),
            DropdownMenuItem(
              value: 'closed',
              child: Text('Closed'),
            ),
          ],
          onChanged: (newStatus) async {
            if (newStatus != null && newStatus != inquiry.status) {
              await _inquiryService.updateInquiryStatus(inquiry.id, newStatus);
            }
          },
        ),
      ),
    );
  }

  Widget _buildInquiryCard(BuildContext context, InquiryModel inquiry) {
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
                child: Center(
                  child: Text(
                    inquiry.tenantName.isNotEmpty
                        ? inquiry.tenantName[0].toUpperCase()
                        : 'T',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE11D48),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inquiry.tenantName.isNotEmpty
                          ? inquiry.tenantName
                          : 'Prospective Tenant',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (inquiry.tenantEmail != null &&
                        inquiry.tenantEmail!.isNotEmpty) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        inquiry.tenantEmail!,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2.0),
                    Text(
                      _formatDate(inquiry.createdAt),
                      style: TextStyle(
                        fontSize: 11.0,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              _buildStatusDropdown(inquiry),
            ],
          ),
          const SizedBox(height: 14.0),
          const Divider(color: Color(0xFFF1F5F9), height: 1.0),
          const SizedBox(height: 12.0),
          Row(
            children: [
              const Icon(
                Icons.home_outlined,
                size: 18.0,
                color: Color(0xFFE11D48),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  inquiry.propertyTitle.isNotEmpty
                      ? inquiry.propertyTitle
                      : 'Property Inquiry',
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Scheduled Date & Time
          if (inquiry.scheduledDate != null) ...[
            const SizedBox(height: 10.0),
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
                      'Requested Viewing: ${_formatDate(inquiry.scheduledDate!)}',
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

          // Tenant Note
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

          const SizedBox(height: 12.0),
          const Divider(color: Color(0xFFF1F5F9), height: 1.0),
          const SizedBox(height: 12.0),

          // Action row: Chat with Tenant
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
                        title: inquiry.tenantName.isNotEmpty
                            ? inquiry.tenantName
                            : 'Tenant',
                        subtitle: inquiry.propertyTitle,
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
                        'Chat with Tenant',
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
    final sellerId = _getSellerId(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF111827),
            size: 20.0,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<InquiryModel>>(
          stream: _inquiryService.getSellerInquiries(sellerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Failed to load leads: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              );
            }

            final inquiries = snapshot.data ?? [];
            if (inquiries.isEmpty) {
              return _buildEmptyState();
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 32.0),
              children: [
                const Text(
                  'Your Leads',
                  style: TextStyle(
                    fontSize: 34.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  'Manage incoming viewing requests from tenants.',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 24.0),
                ...inquiries.map(
                  (inquiry) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildInquiryCard(context, inquiry),
                  ),
                ),
              ]
                  .animate(interval: 100.ms)
                  .fade(duration: 400.ms)
                  .slideY(begin: 0.1, curve: Curves.easeOutQuad),
            );
          },
        ),
      ),
    );
  }
}
