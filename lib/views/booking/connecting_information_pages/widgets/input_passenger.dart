import 'package:flutter/material.dart';

class InputPassenger extends StatefulWidget {
  final String hintText;
  final String text;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool date;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool futureDate;

  const InputPassenger({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.date = false,
    required this.text,
    this.onChanged,
    this.validator,
    this.futureDate = false,
  });

  @override
  State<InputPassenger> createState() => _InputPassengerState();
}

class _InputPassengerState extends State<InputPassenger> {
  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,


      initialDate: widget.futureDate
          ? now
          : DateTime(now.year - 20, now.month, now.day),

      firstDate: widget.futureDate
          ? DateTime(now.year, now.month, now.day)
          : DateTime(1900),

      lastDate: widget.futureDate
          ? DateTime(2100)
          : DateTime(now.year, now.month, now.day),

      locale: const Locale('ar'),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF087443),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {

      final String formattedDate =
          '${pickedDate.year.toString().padLeft(4, '0')}-'
          '${pickedDate.month.toString().padLeft(2, '0')}-'
          '${pickedDate.day.toString().padLeft(2, '0')}';

      widget.controller?.text = formattedDate;

      widget.onChanged?.call(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================================================
        // LABEL
        // =====================================================
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            widget.text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),

        const SizedBox(height: 6),

        // =====================================================
        // INPUT
        // =====================================================
        TextFormField(
          controller: widget.controller,

          validator: widget.validator,

          onChanged: widget.onChanged,

          autovalidateMode: AutovalidateMode.onUserInteraction,

          readOnly: widget.date || widget.readOnly,

          keyboardType: widget.date
              ? TextInputType.datetime
              : widget.keyboardType,

          onTap: widget.date ? _selectDate : widget.onTap,

          style: const TextStyle(fontSize: 14),

          decoration: InputDecoration(
            hintText: widget.hintText,

            hintStyle: const TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),

            filled: true,

            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            // =================================================
            // CALENDAR ICON
            // =================================================
            suffixIcon: widget.date
                ? const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF087443),
                    size: 20,
                  )
                : null,

            // =================================================
            // NORMAL
            // =================================================
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
            ),

            // =================================================
            // FOCUSED
            // =================================================
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF087443),
                width: 1.3,
              ),
            ),

            // =================================================
            // ERROR
            // =================================================
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.3),
            ),

            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              height: 1.2,
            ),

            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
