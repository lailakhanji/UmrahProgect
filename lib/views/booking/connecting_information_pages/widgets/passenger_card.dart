import 'package:flutter/material.dart';

import 'gender_selector.dart';
import 'input_passenger.dart';

class PassengerCard extends StatefulWidget {
  final String passengerNumber;
  final bool isChild;
  final VoidCallback? onBack;
  final String? selectedCityId;

  final Function({
  required String name,
  required String birthDate,
  required String passportNumber,
  required String passportExpiryDate,
  required String gender,
  String? relationship,
  })? onDataChanged;

  const PassengerCard({
    super.key,
    required this.passengerNumber,
    required this.isChild,
    this.onBack,
    this.selectedCityId,
    this.onDataChanged,
  });

  @override
  State<PassengerCard> createState() => PassengerCardState();
}

class PassengerCardState extends State<PassengerCard>
    with AutomaticKeepAliveClientMixin<PassengerCard> {
  final nameController = TextEditingController();
  final birthDateController = TextEditingController();
  final passportController = TextEditingController();
  final passportExpiryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? selectedGender;
  String? selectedCityId;

  String? selectedRelationship;

  String travelType = 'مع محرم';

  String? mahramRelation;

  String? genderError;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    selectedCityId = widget.selectedCityId;
  }

  @override
  void dispose() {
    nameController.dispose();
    birthDateController.dispose();
    passportController.dispose();
    passportExpiryController.dispose();

    super.dispose();
  }

  // =========================================================
  // GET PASSENGER DATA
  // =========================================================

  Map<String, dynamic> getPassengerData() {
    return {
      'name': nameController.text.trim(),
      'passportNumber': passportController.text.trim(),
      'birthDate': birthDateController.text.trim(),
      'passportExpiryDate':
      passportExpiryController.text.trim(),
      'gender': selectedGender,
      'relationship': mahramRelation,
    };
  }

  // =========================================================
  // SEND DATA
  // =========================================================

  void _sendData() {
    widget.onDataChanged?.call(
      name: nameController.text.trim(),
      birthDate: birthDateController.text.trim(),
      passportNumber: passportController.text.trim(),
      passportExpiryDate:
      passportExpiryController.text.trim(),
      gender: selectedGender ?? '',
      relationship: mahramRelation,
    );
  }

  // =========================================================
  // VALIDATE FORM
  // =========================================================

  bool validateForm() {
    final formValid =
        _formKey.currentState?.validate() ?? false;

    bool genderValid = true;
    bool relationshipValid = true;

    // =====================================================
    // GENDER مطلوب للجميع
    // =====================================================

    if (selectedGender == null ||
        selectedGender!.isEmpty) {
      setState(() {
        genderError = 'يرجى اختيار الجنس';
      });

      genderValid = false;
    }

    // =====================================================
    // العلاقة مطلوبة للطفل
    // =====================================================

    if (widget.isChild) {
      if (mahramRelation == null ||
          mahramRelation!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى اختيار صلة ولي الأمر',
            ),
          ),
        );

        relationshipValid = false;
      }
    }

    // =====================================================
    // العلاقة مطلوبة للأنثى البالغة مع محرم
    // =====================================================

    if (!widget.isChild &&
        selectedGender == 'أنثى' &&
        travelType == 'مع محرم') {
      if (mahramRelation == null ||
          mahramRelation!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى اختيار صفة المحرم',
            ),
          ),
        );

        relationshipValid = false;
      }
    }

    return formValid &&
        genderValid &&
        relationshipValid;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // =================================================
            // TITLE
            // =================================================

            Column(
              children: [
                SizedBox(
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          widget.isChild
                              ? 'الطفل المسافر ${widget.passengerNumber}'
                              : 'البالغ المسافر ${widget.passengerNumber}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      if (widget.onBack != null)
                        Positioned(
                          right: 0,
                          child: IconButton(
                            onPressed: widget.onBack,
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // =================================================
                // CHILD WARNING
                // =================================================

                if (widget.isChild) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      border: Border.all(
                        color: const Color(0xFFFEF3C7),
                      ),
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_rounded,
                          color: Color(0xFFD97706),
                          size: 22,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ربط الطفل بولي أمر',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.bold,
                                  color:
                                  Color(0xFF1F2937),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'يجب ان يسافر الطفل مع ولي أمره',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(
                                    0xFF4B5563,
                                  ).withValues(alpha: 0.9),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =================================================
                  // CHILD RELATIONSHIP
                  // =================================================

                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'صفة ولي الأمر',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  DropdownButtonFormField<String>(
                    initialValue: mahramRelation,

                    hint: const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'اختر صفة ولي الأمر المسافر مع الطفل',
                        style: TextStyle(
                          color: Color(0xFF9B9B9B),
                          fontSize: 13,
                        ),
                      ),
                    ),

                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(8),
                        borderSide:
                        const BorderSide(
                          color:
                          Color.fromRGBO(
                            0,
                            0,
                            0,
                            0.4,
                          ),
                          width: 0.3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(8),
                        borderSide:
                        const BorderSide(
                          color: Colors.teal,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),

                    items: const [
                      'أب',
                      'أم',
                      'أخ',
                      'أخت',
                      'ابن',
                      'ابنة',
                    ]
                        .map(
                          (label) =>
                          DropdownMenuItem<String>(
                            value: label,
                            child: Align(
                              alignment:
                              Alignment.centerRight,
                              child: Text(label),
                            ),
                          ),
                    )
                        .toList(),

                    onChanged: (value) {
                      setState(() {
                        mahramRelation = value;
                      });

                      _sendData();
                    },
                  ),
                ],
              ],
            ),

            // =================================================
            // FORM
            // =================================================

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // =================================================
                    // NAME
                    // =================================================

                    InputPassenger(
                      text: 'الاسم الكامل',
                      hintText:
                      'ادخل اسمك بالكامل كما في جواز السفر',
                      controller: nameController,
                      onChanged: (_) => _sendData(),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'يرجى إدخال الاسم الكامل';
                        }

                        if (value.trim().length < 3) {
                          return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // =================================================
                    // BIRTH DATE
                    // =================================================

                    InputPassenger(
                      text: 'تاريخ الميلاد',
                      hintText: 'اختر تاريخ الميلاد',
                      controller: birthDateController,
                      date: true,
                      futureDate: false,
                      onChanged: (_) => _sendData(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى اختيار تاريخ الميلاد';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // =================================================
                    // GENDER
                    // الآن يظهر للطفل والبالغ
                    // =================================================

                    GenderSelector(
                      initialGender: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                          genderError = null;

                          // إذا كان ذكر، نمسح صلة المحرم
                          if (value != 'أنثى') {
                            mahramRelation = null;
                            travelType = 'مع محرم';
                          }
                        });

                        _sendData();
                      },
                    ),

                    if (genderError != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 10,
                          top: 6,
                        ),
                        child: Text(
                          genderError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),
                      ),

                    // =================================================
                    // FEMALE TRAVEL TYPE
                    // فقط للبالغة
                    // =================================================

                    if (!widget.isChild &&
                        selectedGender == 'أنثى') ...[
                      Container(
                        margin:
                        const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        padding:
                        const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red.shade300,
                            width: 1.2,
                          ),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: [
                            const Align(
                              alignment:
                              Alignment.centerRight,
                              child: Text(
                                'تحديد كيفية السفر',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            RadioGroup<String>(
                              groupValue: travelType,
                              onChanged: (value) {
                                setState(() {
                                  travelType = value!;

                                  if (travelType ==
                                      'مع مجموعة نساء') {
                                    mahramRelation = null;
                                  }
                                });

                                _sendData();
                              },
                              child: Column(
                                children: [
                                  RadioListTile<String>(
                                    title: const Align(
                                      alignment:
                                      Alignment.centerRight,
                                      child: Text(
                                        'مع محرم',
                                      ),
                                    ),
                                    value: 'مع محرم',
                                    activeColor:
                                    Colors.teal,
                                  ),

                                  RadioListTile<String>(
                                    title: const Align(
                                      alignment:
                                      Alignment.centerRight,
                                      child: Text(
                                        'مع مجموعة نساء',
                                      ),
                                    ),
                                    value: 'مع مجموعة نساء',
                                    activeColor:
                                    Colors.teal,
                                  ),
                                ],
                              ),
                            ),

                            if (travelType ==
                                'مع محرم') ...[
                              const SizedBox(height: 12),

                              const Align(
                                alignment:
                                Alignment.centerRight,
                                child: Text(
                                  'صفة المحرم',
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              DropdownButtonFormField<String>(
                                initialValue:
                                mahramRelation,

                                hint: const Align(
                                  alignment:
                                  Alignment.centerRight,
                                  child: Text(
                                    'اختر صفة المحرم',
                                  ),
                                ),

                                decoration:
                                InputDecoration(
                                  border:
                                  OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(8),
                                  ),
                                  contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),

                                items: const [
                                  'أب',
                                  'أخ',
                                  'زوج',
                                ]
                                    .map(
                                      (label) =>
                                      DropdownMenuItem<
                                          String>(
                                        value: label,
                                        child: Align(
                                          alignment:
                                          Alignment
                                              .centerRight,
                                          child:
                                          Text(label),
                                        ),
                                      ),
                                )
                                    .toList(),

                                onChanged: (value) {
                                  setState(() {
                                    mahramRelation =
                                        value;
                                  });

                                  _sendData();
                                },
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],

                    // =================================================
                    // PASSPORT NUMBER
                    // =================================================
SizedBox(height: 12,),
                    InputPassenger(
                      text: 'رقم جواز السفر',
                      hintText: 'أدخل رقم جواز السفر',
                      controller: passportController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _sendData(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى إدخال رقم جواز السفر';
                        }

                        if (value.trim().length < 5) {
                          return 'رقم جواز السفر غير صحيح';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // =================================================
                    // PASSPORT EXPIRY
                    // =================================================

                    InputPassenger(
                      text: 'صلاحية جواز السفر',
                      hintText: 'اختر تاريخ انتهاء جواز السفر',
                      controller: passportExpiryController,
                      date: true,
                      futureDate: true,
                      onChanged: (_) => _sendData(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'يرجى اختيار تاريخ انتهاء جواز السفر';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}