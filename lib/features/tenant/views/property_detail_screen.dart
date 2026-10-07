import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/estar_friendly_error.dart';
import '../../../shared/widgets/estar_sticky_bottom_bar.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorite_provider.dart';
import '../../inquiries/services/inquiry_service.dart';
import '../../listings/models/listing_model.dart';

class PropertyDetailScreen extends StatefulWidget {
  final ListingModel listing;
  final InquiryService? inquiryService;

  const PropertyDetailScreen({
    super.key,
    required this.listing,
    this.inquiryService,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _noteController = TextEditingController();
  int _currentPage = 0;

  late final InquiryService _inquiryService;
  bool _hasInquired = false;
  bool _isCheckingStatus = true;
  bool _isSubmitting = false;
  DateTime? _selectedViewingDate;

  @override
  void initState() {
    super.initState();
    _inquiryService = widget.inquiryService ?? InquiryService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInquiryStatus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _getTenantId() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.uid.isNotEmpty) {
        return authProvider.currentUser!.uid;
      }
    } catch (_) {}
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? '';
    } catch (_) {
      return '';
    }
  }

  String _getTenantName() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.name.isNotEmpty) {
        return authProvider.currentUser!.name;
      }
    } catch (_) {}
    try {
      return FirebaseAuth.instance.currentUser?.displayName ?? 'Tenant';
    } catch (_) {
      return 'Tenant';
    }
  }

  String? _getTenantEmail() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.email.isNotEmpty) {
        return authProvider.currentUser!.email;
      }
    } catch (_) {}
    try {
      return FirebaseAuth.instance.currentUser?.email;
    } catch (_) {
      return null;
    }
  }

  Future<void> _checkInquiryStatus() async {
    final tenantId = _getTenantId();
    if (tenantId.isEmpty) {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
      return;
    }

    try {
      final alreadyInquired = await _inquiryService.hasInquired(
        tenantId,
        widget.listing.id,
      );
      if (mounted) {
        setState(() {
          _hasInquired = alreadyInquired;
          _isCheckingStatus = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  Future<void> _pickViewingDateTime(
    BuildContext sheetContext,
    StateSetter setModalState,
  ) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedViewingDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE11D48),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedViewingDate != null
          ? TimeOfDay(
              hour: _selectedViewingDate!.hour,
              minute: _selectedViewingDate!.minute,
            )
          : const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE11D48),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime == null || !mounted) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setModalState(() {
      _selectedViewingDate = newDateTime;
    });
    setState(() {
      _selectedViewingDate = newDateTime;
    });
  }

  String _formatSchedule(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$minute $period';
  }

  Future<void> _submitViewingInquiry(
    BuildContext sheetContext,
    StateSetter setModalState,
  ) async {
    final tenantId = _getTenantId();
    final tenantName = _getTenantName();
    final tenantEmail = _getTenantEmail();

    if (tenantId.isEmpty) {
      EstarFriendlyError.showSnackBar(
        context,
        'Please log in to submit a viewing request.',
      );
      return;
    }

    setModalState(() {
      _isSubmitting = true;
    });
    setState(() {
      _isSubmitting = true;
    });

    try {
      final canInquire = await _inquiryService.checkDailyLimit(tenantId);
      if (!canInquire) {
        if (mounted) {
          setModalState(() {
            _isSubmitting = false;
          });
          setState(() {
            _isSubmitting = false;
          });
          EstarFriendlyError.showSnackBar(
            context,
            'Daily request limit reached (3 per day). Please try again tomorrow.',
          );
        }
        return;
      }

      await _inquiryService.createInquiry(
        propertyId: widget.listing.id,
        propertyTitle: widget.listing.title,
        tenantId: tenantId,
        tenantName: tenantName,
        tenantEmail: tenantEmail,
        sellerId: widget.listing.sellerId,
        scheduledDate: _selectedViewingDate,
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
      );

      if (mounted) {
        setModalState(() {
          _isSubmitting = false;
        });
        setState(() {
          _hasInquired = true;
          _isSubmitting = false;
        });

        // Close viewing modal bottom sheet
        if (sheetContext.mounted) {
          Navigator.pop(sheetContext);
        }

        EstarFriendlyError.showSuccessSnackBar(
          context,
          'Viewing request submitted! The host has been notified.',
        );
      }
    } catch (e) {
      if (mounted) {
        setModalState(() {
          _isSubmitting = false;
        });
        setState(() {
          _isSubmitting = false;
        });
        EstarFriendlyError.showSnackBar(
          context,
          EstarFriendlyError.mask(e),
        );
      }
    }
  }

  void _openViewingModal(BuildContext context) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
            final maxHeight = MediaQuery.sizeOf(context).height * 0.90;

            return Container(
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 28.0,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Drag Handle
                      Center(
                        child: Container(
                          width: 44.0,
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1F2),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: const Text(
                                    'SCHEDULE VISIT',
                                    style: TextStyle(
                                      color: Color(0xFFE11D48),
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                const Text(
                                  'Request a Viewing',
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    color: Color(0xFF111827),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF94A3B8),
                              size: 22.0,
                            ),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Select a date and send a message for ${widget.listing.title}.',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey.shade600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Viewing Date & Time Card
                      const Text(
                        'Preferred Date & Time',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isSubmitting
                              ? null
                              : () => _pickViewingDateTime(
                                    sheetContext,
                                    setModalState,
                                  ),
                          borderRadius: BorderRadius.circular(14.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 14.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: _selectedViewingDate != null
                                    ? const Color(0xFFFDA4AF)
                                    : const Color(0xFFE2E8F0),
                                width: _selectedViewingDate != null ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: _selectedViewingDate != null
                                        ? const Color(0xFFFFF1F2)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Icon(
                                    Icons.calendar_month_rounded,
                                    size: 20.0,
                                    color: _selectedViewingDate != null
                                        ? const Color(0xFFE11D48)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedViewingDate != null
                                            ? _formatSchedule(
                                                _selectedViewingDate!)
                                            : 'Select date & time (Optional)',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight:
                                              _selectedViewingDate != null
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                          color: _selectedViewingDate != null
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        _selectedViewingDate != null
                                            ? 'Tap to change schedule'
                                            : 'Visits subject to host confirmation',
                                        style: TextStyle(
                                          fontSize: 11.0,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_selectedViewingDate != null)
                                  GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        _selectedViewingDate = null;
                                      });
                                      setState(() {
                                        _selectedViewingDate = null;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 18.0,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF94A3B8),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Optional Note Input
                      const Text(
                        'Message for Landlord (Optional)',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      EstarTextField(
                        controller: _noteController,
                        hintText:
                            'Hi! I would like to view this home. Is the rate negotiable?',
                        enabled: !_isSubmitting,
                        maxLines: 3,
                        prefixIcon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20.0,
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Submit Button with Instant UI Feedback
                      EstarButton(
                        text: 'Confirm Viewing Request',
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting
                            ? null
                            : () => _submitViewingInquiry(
                                  sheetContext,
                                  setModalState,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          },
        );
      },
    );
  }

  Widget _buildImageGallery(double height) {
    final images = widget.listing.imageUrls;

    if (images.isEmpty) {
      return Container(
        height: height,
        color: const Color(0xFFF1F5F9),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.roofing_outlined,
                size: 56.0,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8.0),
              Text(
                'No photos provided',
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (images.length == 1) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: images.first,
          fit: BoxFit.cover,
          placeholder: (context, url) => EstarSkeleton(
            height: height,
            width: double.infinity,
          ),
          errorWidget: (context, url, error) => Container(
            color: const Color(0xFFF1F5F9),
            child: Icon(
              Icons.broken_image_outlined,
              size: 48.0,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => EstarSkeleton(
                height: height,
                width: double.infinity,
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFFF1F5F9),
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 48.0,
                  color: Colors.grey.shade400,
                ),
              ),
            );
          },
        ),
        // Dots indicator
        Positioned(
          bottom: 24.0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isSelected = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: isSelected ? 22.0 : 7.0,
                height: 7.0,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE11D48)
                      : Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final galleryHeight = screenHeight * 0.44;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: ClipOval(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                child: Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.80),
                      width: 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 12.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF111827),
                      size: 18.0,
                    ),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: ClipOval(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    width: 42.0,
                    height: 42.0,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.80),
                        width: 1.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 12.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Consumer<FavoriteProvider>(
                      builder: (context, favoriteProvider, _) {
                        final isFav =
                            favoriteProvider.isFavorite(widget.listing.id);
                        return IconButton(
                          icon: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFav
                                ? const Color(0xFFE11D48)
                                : Colors.grey.shade400,
                            size: 20.0,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            final userId = _getTenantId();
                            if (userId.isNotEmpty) {
                              favoriteProvider.toggleFavorite(
                                userId,
                                widget.listing,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: EstarStickyBottomBar(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        child: Row(
          children: [
            // Monthly Rate Display
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '₱${widget.listing.monthlyRate.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '/mo',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    _hasInquired ? 'Inquiry pending' : 'Available for viewing',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500,
                      color: _hasInquired
                          ? const Color(0xFF059669)
                          : Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),

            // Primary Request Viewing CTA
            Expanded(
              flex: 6,
              child: EstarButton(
                text: _hasInquired ? 'Requested' : 'Request Viewing',
                icon: Icon(
                  _hasInquired
                      ? Icons.check_circle_rounded
                      : Icons.calendar_month_rounded,
                  size: 18.0,
                  color: Colors.white,
                ),
                isLoading: _isCheckingStatus,
                onPressed: (_hasInquired || _isCheckingStatus)
                    ? null
                    : () => _openViewingModal(context),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top 40% imagery with Airbnb-style Parallax scrolling & ShaderMask bottom-to-top gradient fade
            ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.75, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  final scrollOffset = _scrollController.hasClients
                      ? _scrollController.offset
                      : 0.0;
                  final parallaxOffset =
                      (scrollOffset * 0.40).clamp(0.0, galleryHeight * 0.85);
                  return Transform.translate(
                    offset: Offset(0, parallaxOffset),
                    child: child,
                  );
                },
                child: Hero(
                  tag: 'property_image_${widget.listing.id}',
                  child: SizedBox(
                    height: galleryHeight,
                    width: double.infinity,
                    child: _buildImageGallery(galleryHeight),
                  ),
                ),
              ),
            ),

            // Property Details Content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Availability Tag & Rate Row
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12.0,
                    runSpacing: 8.0,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: widget.listing.isAvailable
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 7.0,
                              color: widget.listing.isAvailable
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              widget.listing.isAvailable
                                  ? 'Available Now'
                                  : 'Not Available',
                              style: TextStyle(
                                color: widget.listing.isAvailable
                                  ? const Color(0xFF047857)
                                  : const Color(0xFF64748B),
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₱${widget.listing.monthlyRate.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            '/mo',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),

                  // Title
                  Text(
                    widget.listing.title,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Color(0xFF111827),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Location
                  if (widget.listing.address.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18.0,
                          color: Color(0xFFE11D48),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            widget.listing.address,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey.shade600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24.0),

                  // Verified Landlord Card
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 16.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.0,
                          height: 44.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF1F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.roofing_rounded,
                              color: Color(0xFFE11D48),
                              size: 22.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Verified Landlord',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 16.0,
                                    color: const Color(0xFF10B981),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                'Typically responds within 1 hour',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                  const SizedBox(height: 24.0),

                  // Description Section
                  const Text(
                    'About this home',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.listing.description.isNotEmpty
                        ? widget.listing.description
                        : 'No description provided by the host.',
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF4B5563),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28.0),

                  // Amenities Section
                  if (widget.listing.amenities.isNotEmpty) ...[
                    const Text(
                      'Amenities & Features',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.listing.amenities.map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 16.0,
                                color: Color(0xFFE11D48),
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                amenity,
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 130.0),
                  ],
                ]
                    .animate(interval: 50.ms)
                    .fade(duration: 400.ms)
                    .slideY(begin: 0.05, curve: Curves.easeOutQuad),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
