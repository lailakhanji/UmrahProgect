import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/guide_model.dart';
import '../data/guide_api_service.dart';

part 'guide_event.dart';
part 'guide_state.dart';

class GuideBloc extends Bloc<GuideEvent, GuideState> {
  final GuideApiService guideApiService;

  GuideBloc({
    required this.guideApiService,
  }) : super(GuideInitial()) {
    on<GetGuidesEvent>(_getGuides);
  }
  Future<void> _getGuides(
      GetGuidesEvent event,
      Emitter<GuideState> emit,
      ) async {
    if (state is! GuideSuccess) {
      emit(GuideLoading());
    }

    try {
      final response = await guideApiService.getGuides();

      final List data = response.data;

      final guides = data
          .map(
            (json) => GuideModel.fromJson(json),
      )
          .toList();

      guides.sort(
            (a, b) => a.orderIndex.compareTo(b.orderIndex),
      );

      emit(GuideSuccess(guides));
    } catch (e) {
      emit(
        GuideFailure(
          'تعذر تحميل دليل العمرة',
        ),
      );
    }
  }}