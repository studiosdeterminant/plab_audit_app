part of 'stores_cubit.dart';

@immutable
abstract class StoresState  {}

class StoresInitial extends StoresState {
  final List<Store> stores = [];
  // @override
  // List<Object?> get props => [stores];
}

class StoresListLoading extends StoresState {
  // @override
  // List<Object?> get props => [];
}

class StoresListLoaded extends StoresState {
  final List<Store> stores;

  StoresListLoaded({required this.stores});

  // @override
  // List<Object?> get props => [stores];
}

class StoresListRefershed extends StoresListLoaded {
  StoresListRefershed({required stores}) : super(stores: stores);
}

class StoresListLoadError extends StoresState {
  final String error;

  StoresListLoadError({required this.error});

  // @override
  // List<Object?> get props => [error];
}
