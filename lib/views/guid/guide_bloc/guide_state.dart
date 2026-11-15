part of 'guide_bloc.dart';


abstract class GuideState {}

class GuideInitial extends GuideState {}

class GuideLoading extends GuideState {}

class GuideSuccess extends GuideState {
  final List<GuideModel> guides;

  GuideSuccess(this.guides);
}

class GuideFailure extends GuideState {
  final String message;

  GuideFailure(this.message);
}