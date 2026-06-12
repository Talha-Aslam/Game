import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/payment_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String packageId;
  final Map<String, dynamic> packageData;

  const CheckoutScreen({
    super.key,
    required this.packageId,
    required this.packageData,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0; 
  // 0: Order Summary
  // 1: Payment Method
  // 2: Card Details
  // 3: Processing
  // 4: Success
  // 5: Failed

  String _selectedMethod = 'Debit/Credit Card';
  String _failReason = '';

  final _nameCtrl = TextEditingController();
  final _cardCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cardCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient)),
          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_currentStep < 3)
                        GestureDetector(onTap: () {
                          if (_currentStep == 2) {
                            setState(() => _currentStep = 1);
                          } else if (_currentStep == 1) {
                            setState(() => _currentStep = 0);
                          } else {
                            context.pop();
                          }
                        }, child: const Icon(Icons.arrow_back, color: Colors.white)),
                      const SizedBox(width: 16),
                      const Text('SECURE CHECKOUT', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const Spacer(),
                      const Icon(Icons.lock, color: AppColors.mintGreen, size: 16),
                    ],
                  ),
                ),
                Expanded(child: _buildCurrentStep()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildOrderSummary();
      case 1: return _buildPaymentMethod();
      case 2: return _buildCardDetails();
      case 3: return _buildProcessing();
      case 4: return _buildSuccess();
      case 5: return _buildFailed();
      default: return const SizedBox.shrink();
    }
  }

  // --- Step 0: Summary ---
  Widget _buildOrderSummary() {
    final amount = widget.packageData['amount'] as int;
    final bonus = widget.packageData['bonus'] as int;
    final price = widget.packageData['price'] as num;
    final isSC = widget.packageData['currency'] == 'syndicate_coins';
    final color = isSC ? AppColors.gold : AppColors.cyan;
    final total = amount + bonus;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ORDER SUMMARY', style: TextStyle(color: AppColors.white50, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.glassBorder)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Currency', style: TextStyle(color: Colors.white, fontSize: 14)),
                    Text('$total', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (bonus > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Includes Bonus', style: TextStyle(color: AppColors.white50, fontSize: 12)),
                      Text('+$bonus', style: const TextStyle(color: AppColors.mintGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
                const Divider(color: AppColors.white10, height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Final Price', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('\$${price.toStringAsFixed(2)}', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          GestureDetector(
            onTap: () => setState(() => _currentStep = 1),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 15)]),
              child: const Center(child: Text('SELECT PAYMENT METHOD', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
            ),
          )
        ],
      ),
    );
  }

  // --- Step 1: Payment Method ---
  Widget _buildPaymentMethod() {
    final methods = [
      {'name': 'Debit/Credit Card', 'icon': Icons.credit_card},
      {'name': 'PayPal', 'icon': Icons.paypal},
      {'name': 'Google Pay', 'icon': Icons.g_mobiledata},
    ];

    final isSC = widget.packageData['currency'] == 'syndicate_coins';
    final color = isSC ? AppColors.gold : AppColors.cyan;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CHOOSE A METHOD', style: TextStyle(color: AppColors.white50, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          ...methods.map((m) {
            final isSelected = _selectedMethod == m['name'];
            return GestureDetector(
              onTap: () => setState(() => _selectedMethod = m['name'] as String),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? color : AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    Icon(m['icon'] as IconData, color: isSelected ? color : AppColors.white50, size: 28),
                    const SizedBox(width: 16),
                    Expanded(child: Text(m['name'] as String, style: TextStyle(color: isSelected ? Colors.white : AppColors.white70, fontSize: 16, fontWeight: FontWeight.bold))),
                    if (isSelected) Icon(Icons.check_circle, color: color),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              if (_selectedMethod == 'Debit/Credit Card') {
                setState(() => _currentStep = 2);
              } else {
                _processPayment();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 15)]),
              child: const Center(child: Text('CONTINUE', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
            ),
          )
        ],
      ),
    );
  }

  // --- Step 2: Card Details ---
  Widget _buildCardDetails() {
    final isSC = widget.packageData['currency'] == 'syndicate_coins';
    final color = isSC ? AppColors.gold : AppColors.cyan;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ENTER CARD DETAILS', style: TextStyle(color: AppColors.white50, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          _buildTextField('Cardholder Name', _nameCtrl),
          _buildTextField('Card Number', _cardCtrl, type: TextInputType.number, maxLength: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Expiry (MM/YY)', _expCtrl, maxLength: 5)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('CVV', _cvvCtrl, isObscure: true, type: TextInputType.number, maxLength: 3)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.lock, color: AppColors.mintGreen, size: 14),
              const SizedBox(width: 8),
              const Expanded(child: Text('Card details are securely encrypted and processed by our payment gateway. We do not store your CVV.', style: TextStyle(color: AppColors.white50, fontSize: 10))),
            ],
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              if (_nameCtrl.text.isEmpty || _cardCtrl.text.isEmpty || _expCtrl.text.isEmpty || _cvvCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all card details'), backgroundColor: AppColors.crimsonRed));
                return;
              }
              _processPayment();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 15)]),
              child: const Center(child: Text('PAY SECURELY', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isObscure = false, TextInputType type = TextInputType.text, int? maxLength}) {
    final isSC = widget.packageData['currency'] == 'syndicate_coins';
    final color = isSC ? AppColors.gold : AppColors.cyan;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: type,
        maxLength: maxLength,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.white50),
          counterText: "",
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.glassBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color)),
        )
      )
    );
  }

  // --- Step 3: Processing ---
  Future<void> _processPayment() async {
    setState(() => _currentStep = 3);

    final transactionId = const Uuid().v4();
    await Future.delayed(const Duration(seconds: 3)); // Simulated gateway delay

    final result = await ref.read(paymentProvider.notifier).processPayment(
      packageId: widget.packageId,
      price: (widget.packageData['price'] as num).toDouble(),
      transactionId: transactionId,
      statusCode: 'SUCCESS',
    );

    if (!mounted) return;

    if (result != null) {
      setState(() => _currentStep = 4);
    } else {
      setState(() {
        _currentStep = 5;
        _failReason = 'Your bank declined the transaction or network failed.';
      });
    }
  }

  Widget _buildProcessing() {
    final isSC = widget.packageData['currency'] == 'syndicate_coins';
    final color = isSC ? AppColors.gold : AppColors.cyan;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: color),
          const SizedBox(height: 24),
          const Text('Processing Payment...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Please do not close the app.', style: TextStyle(color: AppColors.white50, fontSize: 14)),
        ],
      ),
    );
  }

  // --- Step 3: Success ---
  Widget _buildSuccess() {
    final amount = widget.packageData['amount'] as int;
    final bonus = widget.packageData['bonus'] as int;
    final isSC = widget.packageData['currency'] == 'syndicate_coins';
    final color = isSC ? AppColors.gold : AppColors.cyan;
    final total = amount + bonus;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.online.withValues(alpha: 0.1), boxShadow: [BoxShadow(color: AppColors.online.withValues(alpha: 0.3), blurRadius: 40)]),
              child: const Icon(Icons.check_circle, color: AppColors.online, size: 80),
            ),
            const SizedBox(height: 32),
            const Text('PAYMENT SUCCESSFUL!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 16),
            Text('You received $total ${isSC ? 'SC' : 'IP'}', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () {
                context.pop(); // Pop checkout
                context.pop(); // Pop details screen to go back to store
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.glassBorder)),
                child: const Center(child: Text('RETURN TO STORE', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- Step 4: Failed ---
  Widget _buildFailed() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.crimsonRed.withValues(alpha: 0.1), boxShadow: [BoxShadow(color: AppColors.crimsonRed.withValues(alpha: 0.3), blurRadius: 40)]),
              child: const Icon(Icons.error_outline, color: AppColors.crimsonRed, size: 80),
            ),
            const SizedBox(height: 32),
            const Text('PAYMENT FAILED', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 16),
            Text(_failReason, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.white70, fontSize: 14)),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () => setState(() => _currentStep = 1),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(color: AppColors.crimsonRed, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('RETRY PAYMENT', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.glassBorder)),
                child: const Center(child: Text('CANCEL', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
