import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../../../core/constants/app_colors.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey      = GlobalKey<FormState>();
  final _descCtrl     = TextEditingController();
  final _montantCtrl  = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _descCtrl.dispose();
    _montantCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context:      context,
      initialDate:  _selectedDate,
      firstDate:    DateTime(2020),
      lastDate:     DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final success = await ref.read(transactionProvider.notifier).addTransaction(
      description: _descCtrl.text.trim(),
      montant:     double.parse(_montantCtrl.text.trim()),
      date:        dateStr,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('success_add')),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(transactionProvider).error ?? 'Erreur'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(transactionProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(tr('add_transaction'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Icône IA
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tr('ai_auto_category'),
                        style: TextStyle(
                          color:    AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Description
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText:  tr('description'),
                  prefixIcon: const Icon(Icons.edit_outlined),
                  hintText:   'Ex: McDonald\'s, Taxi, Cinéma...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary, width: 2,
                    ),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? tr('error_required') : null,
              ),
              const SizedBox(height: 16),

              // ── Montant
              TextFormField(
                controller:  _montantCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText:  tr('amount'),
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: 'DT',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary, width: 2,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return tr('error_required');
                  if (double.tryParse(v) == null) return tr('error_amount');
                  if (double.parse(v) <= 0) return tr('error_amount');
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Date picker
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border:       Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('date'),
                            style: TextStyle(
                              color: Colors.grey[600], fontSize: 12,
                            ),
                          ),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize:   15,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Bouton Ajouter
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          width:  20,
                          height: 20,
                          child:  CircularProgressIndicator(
                            color:       Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    isLoading ? tr('ai_classifying') : tr('add'),
                    style: const TextStyle(
                      fontSize:   16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}