import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:surveyapp/data/models/store.dart';
import 'package:surveyapp/data/repositories/store.dart';

part 'stores_state.dart';

class StoresCubit extends Cubit<StoresState> {
  final StoreRepository storeRepository;

  StoresCubit({required this.storeRepository}) : super(StoresInitial());

  void refreshStoresList() {
    fetchStoresList();
  }

  void getStoryList() {
    final currentState = state;
    if (currentState is StoresListLoaded)
      emit(StoresListRefershed(stores: currentState.stores));
    else
      fetchStoresList();
  }

  Future<void> fetchStoresList() async {
    emit(StoresInitial());

    await Future<void>.delayed(const Duration(milliseconds: 50));
    emit(StoresListLoading());
    await Future<void>.delayed(const Duration(milliseconds: 50));
    List<Store> stores = await storeRepository.getStoreList();
    emit(StoresListLoaded(stores: stores));
  }

  /// 🔹 Calls getStoreList again after a new store is added
  Future<void> addStore(Map<String, dynamic> payload) async {
    emit(StoresInitial());
    emit(StoresListLoading());

    final success = await storeRepository.addStore(payload);
    if (success) {
      List<Store> stores = await storeRepository.getStoreList();
      emit(StoresListLoaded(stores: stores));
    } else {
      emit(StoresListLoadError(error: "Failed to add store"));
    }
  }

  void cannotAudit(String sid, String reason, String image) {
    storeRepository.cannotAudit(sid, reason, image);
  }

  // Fetch clients for dropdown
  Future<List<Map<String, dynamic>>> getClients() async {
    return await storeRepository.getClients();
  }

  // Fetch cycles for a clientId
  Future<List<Map<String, dynamic>>> getCycles(String clientId) async {
    return await storeRepository.getCycles(clientId);
  }

}
