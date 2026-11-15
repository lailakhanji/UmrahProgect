import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../profile_bloc/profile_bloc.dart';

class EditPassportBottomSheet extends StatefulWidget {
  final String currentPassportNumber;
  final DateTime? currentExpiryDate;

  const EditPassportBottomSheet({
    super.key,
    required this.currentPassportNumber,
    required this.currentExpiryDate,
  });

  @override
  State<EditPassportBottomSheet> createState() =>
      _EditPassportBottomSheetState();
}

class _EditPassportBottomSheetState extends State<EditPassportBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _passportController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _passportController.text = widget.currentPassportNumber;

    _selectedDate = widget.currentExpiryDate;

    if (_selectedDate != null) {
      _dateController.text = _formatDate(_selectedDate!);
    }
  }

  // نفس تنسيق الـ Auth
  String _formatDate(DateTime date) {
    return "${date.year}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  // اختيار تاريخ انتهاء الجواز
  // مطابق للـ Auth
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    // إذا كان التاريخ الحالي موجودًا وصالحًا نستخدمه
    // وإلا نستخدم بعد سنة من اليوم
    DateTime initialDate = _selectedDate ?? now.add(const Duration(days: 365));

    // التأكد أن initialDate ليس قبل اليوم
    final today = DateTime(now.year, now.month, now.day);

    if (initialDate.isBefore(today)) {
      initialDate = now.add(const Duration(days: 365));
    }

    // التأكد أن initialDate لا يتجاوز الحد الأعلى
    final maxDate = DateTime(now.year + 20);

    if (initialDate.isAfter(maxDate)) {
      initialDate = maxDate;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,

      // نفس Auth
      initialDate: initialDate,

      // لا نسمح بتاريخ منتهي
      firstDate: now,

      // نفس Auth
      lastDate: DateTime(now.year + 20),

      // يبدأ باختيار السنة
      initialDatePickerMode: DatePickerMode.year,

      // عربي
      locale: const Locale('ar', 'AE'),

      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(148, 200, 177, 1),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromRGBO(148, 200, 177, 1),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;

        // نفس تنسيق Auth
        _dateController.text = _formatDate(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 10,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الخط العلوي
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // العنوان
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'تعديل البيانات',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF186442),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 30),

              // ==============================
              // رقم جواز السفر
              // ==============================
              const Text(
                'رقم جواز السفر',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _passportController,
                textAlign: TextAlign.right,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال رقم جواز السفر';
                  }

                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'p12345678',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==============================
              // تاريخ انتهاء جواز السفر
              // ==============================
              const Text(
                'تاريخ انتهاء صلاحية جواز السفر',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _dateController,

                // المستخدم لا يكتب التاريخ يدويًا
                readOnly: true,

                // فتح الـ DatePicker
                onTap: () => _selectDate(context),

                textAlign: TextAlign.right,

                // نفس فكرة validator الموجودة في Auth
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال تاريخ انتهاء الجواز';
                  }

                  final expiryDate = DateTime.tryParse(value);

                  if (expiryDate == null) {
                    return 'تاريخ انتهاء الجواز غير صالح';
                  }

                  final today = DateTime.now();

                  final todayOnly = DateTime(
                    today.year,
                    today.month,
                    today.day,
                  );

                  final expiryOnly = DateTime(
                    expiryDate.year,
                    expiryDate.month,
                    expiryDate.day,
                  );

                  if (expiryOnly.isBefore(todayOnly)) {
                    return 'تاريخ انتهاء الجواز منتهي';
                  }

                  return null;
                },

                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  hintStyle: TextStyle(color: Colors.grey.shade400),

                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.black,
                    ),
                  ),

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ==============================
              // زر الحفظ
              // ==============================
              BlocConsumer<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if (state is ProfileUpdateSuccess) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث بيانات جواز السفر بنجاح'),
                        backgroundColor: Color(0xFF186442),
                      ),
                    );
                  } else if (state is ProfileFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },

                builder: (context, state) {
                  final isUpdating = state is ProfileUpdating;

                  return SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isUpdating
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                if (_selectedDate == null) {
                                  return;
                                }

                                context.read<ProfileBloc>().add(
                                  UpdatePassportEvent(
                                    passportNumber: _passportController.text
                                        .trim(),

                                    passportExpiryDate: _selectedDate!,
                                  ),
                                );
                              }
                            },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF186442),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),

                      child: isUpdating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'حفظ التغييرات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passportController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
