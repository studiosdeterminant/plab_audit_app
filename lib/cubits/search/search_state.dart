part of 'search_cubit.dart';

@immutable
abstract class SearchState {
  final Set<ActivatedFilter> activatedfilter;
  SearchState({required this.activatedfilter});
}

class StoresLoading extends SearchState{
  StoresLoading({required Set<ActivatedFilter> activatedfilter}): super(activatedfilter: activatedfilter);
}

class StoresUpdated extends SearchState {
  final SearchData searchData;
  StoresUpdated({required this.searchData, required Set<ActivatedFilter> activatedfilter}): super(activatedfilter: activatedfilter);
}

