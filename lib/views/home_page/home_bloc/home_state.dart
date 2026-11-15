part of 'home_bloc.dart';

class HomeState {}

class InitCategoryState extends HomeState{}
class LoadingCategoryState extends HomeState{}
class FailedCategoryState extends HomeState{
  final String errorMessage;

  FailedCategoryState({required this.errorMessage,});
}
class SuccessCategoryState extends HomeState{
  final List<CategoryModel> data;
  List filteredData = [];
  String selectedCategory = 'الكل';
  SuccessCategoryState({required this.data});
}
