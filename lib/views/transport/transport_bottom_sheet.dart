import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umrahapp/views/transport/data/transport_model.dart';
import 'package:umrahapp/views/transport/transport_bloc/transport_bloc.dart';
import 'package:umrahapp/views/transport/widget/transport_info_card.dart';

class TransportBottomSheet extends StatefulWidget {
  final String transportId;

  const TransportBottomSheet({super.key, required this.transportId});

  @override
  State<TransportBottomSheet> createState() => _TransportBottomSheetState();
}

class _TransportBottomSheetState extends State<TransportBottomSheet> {
  @override
  void initState() {
    super.initState();

    context.read<TransportBloc>().add(GetTransportsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final double desiredHeight = MediaQuery.of(context).size.height * 0.7;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: desiredHeight,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

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
            const SizedBox(height: 15),

            // شريط العنوان وزر الإغلاق
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'تفاصيل المواصلات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF186442),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 15),


            Expanded(
              child: BlocBuilder<TransportBloc, TransportState>(
                builder: (context, state) {

                  if (state is LoadingTransportState) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF186442),
                      ),
                    );
                  }


                  if (state is SuccessTransportState) {
                    if (state.Transports.isEmpty) {
                      return const Center(
                        child: Text("لا توجد رحلات مواصلات متاحة حالياً"),
                      );
                    }

                    final matches = state.Transports.where((e) {
                      return e.id.toString().trim().toLowerCase() ==
                          widget.transportId.toString().trim().toLowerCase();
                    });

                    final TransportModel selectedTransport;

                    if (matches.isEmpty) {

                      selectedTransport = state.Transports.first;
                    } else {
                      selectedTransport = matches.first;
                    }


                    return SingleChildScrollView(
                      child: TransportCard(transports: selectedTransport),
                    );
                  }

                  if (state is FailedTransportState) {
                    return Center(
                      child: Text(
                        state.errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    );
                  }


                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF186442)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
