import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/models/duaa_request_model.dart';
import 'duaa_request_bloc/duaa_request_bloc.dart';
import 'duaa_request_bloc/duaa_request_event.dart';
import 'duaa_request_bloc/duaa_request_state.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final Set<String> _completedLocally = {};
  static const Color primaryGreen = Color(0xff186442);

  int selectedTab = 0;

  // =========================
  // Filter
  // =========================

  List<DuaaRequestModel> _filteredRequests(List<DuaaRequestModel> requests) {
    if (selectedTab == 0) {
      return requests;
    }

    if (selectedTab == 1) {
      return requests.where((item) => item.type == 'دعاء').toList();
    }

    return requests.where((item) => item.type == 'وصية').toList();
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<DuaaRequestBloc, DuaaRequestState>(
          listener: (context, state) {
            if (state is DuaaRequestError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<DuaaRequestBloc, DuaaRequestState>(
            builder: (context, state) {
              if (state is DuaaRequestLoading || state is DuaaRequestInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryGreen),
                );
              }

              if (state is DuaaRequestError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 45,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'تعذر تحميل البيانات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'تأكد من اتصالك بالإنترنت ثم حاول مرة أخرى',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 18),

                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<DuaaRequestBloc>().add(
                              GetDuaaRequests(),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is DuaaRequestLoaded) {
                final requests = state.requests;

                return Column(
                  children: [
                    _buildHeader(requests),

                    Expanded(
                      child: requests.isEmpty
                          ? _buildEmptyState()
                          : _buildNotesList(requests),
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  // =========================
  // Header
  // =========================

  Widget _buildHeader(List<DuaaRequestModel> requests) {
    return Directionality(
      textDirection: TextDirection.ltr,

      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),

        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),

                const Text(
                  'ملاحظات',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: primaryGreen,
                  ),
                ),

                const Spacer(),

                const SizedBox(width: 22),
              ],
            ),

            const SizedBox(height: 12),

            if (requests.isEmpty) ...[
              const Text(
                'تتبع الأشياء التي تريد تذكرها أثناء رحلتك',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],

            if (requests.isNotEmpty) ...[
              const SizedBox(height: 18),
              _buildTabs(),
            ],
          ],
        ),
      ),
    );
  }

  // =========================
  // Tabs
  // =========================

  Widget _buildTabs() {
    return Directionality(
      textDirection: TextDirection.rtl,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildTab(title: 'الكل', index: 0),

          const SizedBox(width: 8),

          _buildTab(title: 'دعاء', index: 1),

          const SizedBox(width: 8),

          _buildTab(title: 'وصية', index: 2),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTab({required String title, required int index}) {
    final bool selected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),

        decoration: BoxDecoration(
          color: selected ? primaryGreen : Colors.white,

          borderRadius: BorderRadius.circular(7),

          border: Border.all(
            color: selected ? primaryGreen : const Color(0xffE5EAE7),
          ),
        ),

        child: Text(
          title,

          style: TextStyle(
            fontSize: 11,
            color: selected ? Colors.white : const Color(0xff555555),
          ),
        ),
      ),
    );
  }

  // =========================
  // Empty State
  // =========================

  Widget _buildEmptyState() {
    return Column(
      children: [
        const Spacer(),

        Image.asset(
          'assets/images/duaa_image.png',
          width: 224,
          height: 297,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 25),

        const Text(
          'لا توجد ملاحظات حتى الآن',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),

          child: Text(
            'احفظ الأدعية والوصايا للأشخاص الذين تريد تذكرهم',
            textAlign: TextAlign.center,

            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 25),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: _buildAddButton(),
        ),

        const Spacer(),
      ],
    );
  }

  // =========================
  // Notes List
  // =========================

  Widget _buildNotesList(List<DuaaRequestModel> requests) {
    final list = _filteredRequests(requests);

    return Stack(
      children: [
        if (list.isEmpty)
          const Center(
            child: Text(
              'لا توجد ملاحظات من هذا النوع',

              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 100),

            itemCount: list.length,

            itemBuilder: (context, index) {
              return _buildNoteCard(list[index]);
            },
          ),

        Positioned(left: 20, bottom: 20, child: _buildFloatingButton()),
      ],
    );
  }

  // =========================
  // Note Card
  // =========================

  Widget _buildNoteCard(DuaaRequestModel request) {
    final bool isDuaa = request.type == 'دعاء';

    final String requestId =
        request.id ?? '${request.personName}_${request.message}';

    final bool isCompleted =
        request.isCompleted || _completedLocally.contains(requestId);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(8),

          border: Border.all(color: const Color(0xffDDE5E0)),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Text(
                    request.personName,
                    textAlign: TextAlign.right,

                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    request.message,
                    textAlign: TextAlign.right,

                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: isDuaa
                          ? const Color(0xffD9F5E5)
                          : const Color(0xffffecd2),

                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: Text(
                      request.type,

                      style: TextStyle(
                        fontSize: 12,

                        color: isDuaa
                            ? const Color(0xff20A35A)
                            : const Color(0xffE99B28),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 19),

            GestureDetector(
              onTap: isCompleted
                  ? null
                  : () {
                      setState(() {
                        _completedLocally.add(requestId);
                      });

                      context.read<DuaaRequestBloc>().add(
                        MarkDuaaRequestAsCompleted(requestId),
                      );
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),

                width: 22,
                height: 22,

                decoration: BoxDecoration(
                  color: isCompleted ? primaryGreen : Colors.white,

                  borderRadius: BorderRadius.circular(6),

                  border: Border.all(color: primaryGreen, width: 1.4),
                ),

                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // Floating Button
  // =========================

  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: _showAddNoteSheet,

      child: Container(
        width: 38,
        height: 38,

        decoration: const BoxDecoration(
          color: primaryGreen,
          shape: BoxShape.circle,
        ),

        child: const Icon(Icons.add, color: Colors.white, size: 22),
      ),
    );
  }

  // =========================
  // Add Button
  // =========================

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,

      child: ElevatedButton.icon(
        onPressed: _showAddNoteSheet,

        icon: const Icon(Icons.add, color: Colors.white),

        label: const Text(
          'إضافة ملاحظة',

          style: TextStyle(color: Colors.white, fontSize: 13),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

          elevation: 0,
        ),
      ),
    );
  }

  // =========================================================
  // ADD NOTE BOTTOM SHEET
  // =========================================================

  void _showAddNoteSheet() {
    // نأخذ نفس الـ BLoC الموجود في NotesScreen
    final bloc = context.read<DuaaRequestBloc>();

    final TextEditingController nameController = TextEditingController();

    final TextEditingController messageController = TextEditingController();

    String selectedType = 'دعاء';

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: bloc,

          child: BlocListener<DuaaRequestBloc, DuaaRequestState>(
            listener: (context, state) {
              // نجاح الحفظ
              if (state is DuaaRequestCreated) {
                Navigator.pop(context);
              }

              // خطأ
              if (state is DuaaRequestError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },

            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.7,

                  decoration: const BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),

                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 12,

                        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                      ),

                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // =========================
                            // Drag handle
                            // =========================
                            Container(
                              width: 35,
                              height: 4,

                              decoration: BoxDecoration(
                                color: const Color(0xffD8D8D8),

                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // =========================
                            // Title
                            // =========================
                            Row(
                              children: [
                                const Spacer(),

                                const Text(
                                  'إضافة ملاحظة',

                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const Spacer(),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },

                                  child: const Icon(
                                    Icons.arrow_forward,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // =========================
                            // Type
                            // =========================
                            Container(
                              height: 38,

                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius: BorderRadius.circular(7),

                                border: Border.all(
                                  color: const Color(0xffE3EAE5),
                                ),
                              ),

                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          selectedType = 'وصية';
                                        });
                                      },

                                      child: Container(
                                        alignment: Alignment.center,

                                        decoration: BoxDecoration(
                                          color: selectedType == 'وصية'
                                              ? primaryGreen
                                              : Colors.transparent,

                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                        ),

                                        child: Text(
                                          'وصية',

                                          style: TextStyle(
                                            fontSize: 12,

                                            color: selectedType == 'وصية'
                                                ? Colors.white
                                                : const Color(0xff555555),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          selectedType = 'دعاء';
                                        });
                                      },

                                      child: Container(
                                        alignment: Alignment.center,

                                        decoration: BoxDecoration(
                                          color: selectedType == 'دعاء'
                                              ? primaryGreen
                                              : Colors.transparent,

                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                        ),

                                        child: Text(
                                          'دعاء',

                                          style: TextStyle(
                                            fontSize: 12,

                                            color: selectedType == 'دعاء'
                                                ? Colors.white
                                                : const Color(0xff555555),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // =========================
                            // Name
                            // =========================
                            const Align(
                              alignment: Alignment.centerRight,

                              child: Text(
                                'الاسم',

                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 7),

                            TextField(
                              controller: nameController,

                              textDirection: TextDirection.rtl,

                              textAlign: TextAlign.right,

                              decoration: InputDecoration(
                                hintText: 'أدخل اسم الشخص',

                                hintStyle: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),

                                filled: true,

                                fillColor: Colors.white,

                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),

                                  borderSide: const BorderSide(
                                    color: Color(0xffDDE5E0),
                                  ),
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),

                                  borderSide: const BorderSide(
                                    color: Color(0xffDDE5E0),
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),

                                  borderSide: const BorderSide(
                                    color: primaryGreen,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // =========================
                            // Message
                            // =========================
                            const Align(
                              alignment: Alignment.centerRight,

                              child: Text(
                                'الملاحظة',

                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 7),

                            TextField(
                              controller: messageController,

                              maxLength: 300,

                              minLines: 4,

                              maxLines: 8,

                              textDirection: TextDirection.rtl,

                              textAlign: TextAlign.right,

                              keyboardType: TextInputType.multiline,

                              decoration: InputDecoration(
                                hintText: selectedType == 'دعاء'
                                    ? 'اكتب الدعاء هنا...'
                                    : 'اكتب الوصية هنا...',

                                hintStyle: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),

                                counterStyle: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),

                                filled: true,

                                fillColor: Colors.white,

                                contentPadding: const EdgeInsets.all(12),

                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),

                                  borderSide: const BorderSide(
                                    color: Color(0xffDDE5E0),
                                  ),
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),

                                  borderSide: const BorderSide(
                                    color: Color(0xffDDE5E0),
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),

                                  borderSide: const BorderSide(
                                    color: primaryGreen,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 80),

                            // =========================
                            // Save
                            // =========================
                            SizedBox(
                              width: double.infinity,

                              height: 45,

                              child: ElevatedButton(
                                onPressed: () {
                                  if (nameController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('يرجى إدخال اسم الشخص'),
                                      ),
                                    );
                                    return;
                                  }

                                  if (messageController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('يرجى إدخال الملاحظة'),
                                      ),
                                    );
                                    return;
                                  }

                                  final request = DuaaRequestModel(
                                    personName: nameController.text.trim(),
                                    message: messageController.text.trim(),
                                    type: selectedType,
                                    isCompleted: false,
                                  );

                                  bloc.add(CreateDuaaRequest(request));
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,

                                  elevation: 0,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),

                                child: const Text(
                                  'حفظ',

                                  style: TextStyle(
                                    color: Colors.white,

                                    fontSize: 13,

                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
