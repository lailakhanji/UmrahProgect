import 'package:flutter/material.dart';

class GenderSelector extends StatefulWidget {
  final String? initialGender;
  final ValueChanged<String>? onChanged;

  const GenderSelector({super.key, this.initialGender, this.onChanged});

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.initialGender;
  }

  void selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });

    widget.onChanged?.call(gender);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الجنس',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _GenderOption(
                title: 'ذكر',
                selected: selectedGender == 'ذكر',
                onTap: () => selectGender('ذكر'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _GenderOption(
                title: 'أنثى',
                selected: selectedGender == 'أنثى',
                onTap: () => selectGender('أنثى'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF7F0) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF087443)
                  : const Color(0xFFE1E1E1),
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              const Spacer(flex: 5),

              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Colors.black),
              ),

              const Spacer(),

              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF087443)
                        : const Color(0xFF777777),
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF087443),
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
