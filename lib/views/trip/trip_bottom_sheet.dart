import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umrahapp/views/trip/packages/info_card.dart';
import 'package:umrahapp/views/trip/packages/trip_card.dart';
import 'package:umrahapp/views/trip/trip_bloc/trip_bloc.dart';

import 'data/trip_model.dart';

class TripBottomSheet extends StatelessWidget {
  final String packageId;

  const TripBottomSheet({super.key, required this.packageId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Container(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: SingleChildScrollView(
              child: Container(
                child: BlocBuilder<TripBloc, TripState>(
                  builder: (context, state) {
                    if (state is LoadingTripState) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is SuccessTripState) {
                      final matches = state.trips.where(
                        (e) => e.id == packageId,
                      );

                      if (matches.isEmpty) {
                        return const Center(
                          child: Text("لم يتم العثور على الرحلة"),
                        );
                      }

                      final trip = matches.first;

                      return TripCard(package: trip);
                    }

                    if (state is FailedTripState) {
                      return Text(state.errorMessage);
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
