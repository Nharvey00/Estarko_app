import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class MockCheckoutScreen extends StatefulWidget {
  const MockCheckoutScreen({super.key});

  @override
  State<MockCheckoutScreen> createState() => _MockCheckoutScreenState();
}

class _MockCheckoutScreenState extends State<MockCheckoutScreen> {
  final _cardNumberController =
      TextEditingController(text: '4532 •••• •••• 8921');
  final _cardHolderController =
      TextEditingController(text: 'EstarKo Verified Host');
  final _expiryController = TextEditingController(text: '12/28');
  final _cvvController = TextEditingController(text: '888');

  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment successful! You now have unlimited listing quota.',
        ),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context, true);
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 16.0,
              color: Color(0xFFE11D48),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Massive Header
              const Text(
                'Upgrade to Pro',
                style: TextStyle(
                  fontSize: 34.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Free tier allows up to 1 active listing. Upgrade to publish unlimited rental properties.',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24.0),

              // Pricing Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22.0),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pro Landlord Tier',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE11D48),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₱499',
                          style: TextStyle(
                            fontSize: 36.0,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE11D48),
                            letterSpacing: -1.0,
                          ),
                        ),
                        SizedBox(width: 6.0),
                        Text(
                          '/ month',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                    const SizedBox(height: 14.0),
                    _buildBenefit('Publish unlimited rental property listings'),
                    _buildBenefit('Priority placement on Tenant discovery map'),
                    _buildBenefit('Direct inquiry lead management & notifications'),
                    _buildBenefit('Zero commission fees on tenant bookings'),
                  ],
                ),
              ),
              const SizedBox(height: 28.0),

              // Mock Card Form
              const Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 14.0),
              EstarTextField(
                controller: _cardNumberController,
                hintText: 'Card Number (e.g. 4532 •••• •••• 8890)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              EstarTextField(
                controller: _cardHolderController,
                hintText: 'Cardholder Name',
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: EstarTextField(
                      controller: _expiryController,
                      hintText: 'MM/YY',
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: EstarTextField(
                      controller: _cvvController,
                      hintText: 'CVV',
                      isPassword: true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),

              EstarButton(
                text: 'Complete Payment (₱499)',
                isLoading: _isProcessing,
                onPressed: _handlePayment,
              ),
            ]
                .animate(interval: 100.ms)
                .fade(duration: 400.ms)
                .slideY(begin: 0.1, curve: Curves.easeOutQuad),
          ),
        ),
      ),
    );
  }
}
