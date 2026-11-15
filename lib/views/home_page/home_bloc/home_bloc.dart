import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umrahapp/views/home_page/data/category_model.dart';
import 'package:umrahapp/views/home_page/data/home_api_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState()) {
    on<GetHomeCategories>(getCategories);
  }

  Future<void> getCategories(
      GetHomeCategories event,
      Emitter<HomeState> emit,
      ) async {
    // إذا ما عنا بيانات سابقة → هذا أول تحميل
    if (state is! SuccessCategoryState) {
      emit(LoadingCategoryState());
    }

    final res = await HomeApiService().getCategories();

    res.fold(
          (l) {
        emit(FailedCategoryState(errorMessage: l, ));
      },
          (r) {
        emit(SuccessCategoryState(data: r));
      },
    );
  }
}