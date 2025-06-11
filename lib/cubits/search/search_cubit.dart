import 'package:bloc/bloc.dart';
import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:surveyapp/data/models/search.dart';
import 'package:surveyapp/data/models/store.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:surveyapp/presentation/screens/search_filter_dialog.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  late SearchData searchData;
  late Set<ActivatedFilter> activatedfilter = Set();

  SearchCubit({required List<Store> stores})
      : super(StoresLoading(activatedfilter: Set())) {
    searchData = SearchData();
    searchData.stores = stores;
    _initSearchState();
  }

  void getCurrentState() async {
    final currentState = state;
    if(currentState is StoresLoading)
      emit(StoresLoading(activatedfilter: activatedfilter));
    else
      emit(StoresUpdated(searchData: searchData, activatedfilter: activatedfilter));
  }

  _initSearchState() async {
    Set<String> locationSet = Set();
    Set<String> areaSet = Set();
    Set<String> pincodeSet = Set();

    for(Store store in searchData.stores){
      if (store.location.isNotEmpty) locationSet.add(store.location);
      if (store.area.isNotEmpty) areaSet.add(store.area);
      if (store.pincode.isNotEmpty) pincodeSet.add(store.pincode);
    };

    searchData.areas = areaSet.toList(growable: false);
    searchData.locations = locationSet.toList(growable: false);
    searchData.pincodes = pincodeSet.toList(growable: false);
    searchData.searchOutput = searchData.stores;

    emit(
        StoresUpdated(searchData: searchData, activatedfilter: activatedfilter));
  }

  void openFilterDialog(
      context, ActivatedFilter filter) async {
    switch (filter) {
      case ActivatedFilter.LOCATION:
        FilterListDialog.display<String>(
          context,
          listData: searchData.locations,
          selectedListData: searchData.selectedLocations,
          choiceChipLabel: (location) => location,
          validateSelectedItem: (list, val) => list!.contains(val),
          hideHeader: true,
          hideSearchField: true,
          hideSelectedTextCount: true,
          borderRadius: 10,
          backgroundColor: cPrimary,
          onItemSearch: (list, item) {
            return true;
          },
          //controlContainerDecoration: BoxDecoration(
          //  color: cDark,
          //  borderRadius: BorderRadius.circular(5.0),
          // ),
          // buttonRadius: 5,
          //controlButtonTextStyle: TextStyle(
          //  color: cWhite,
          // ),
          // applyButonTextBackgroundColor: cSecondary,
          onApplyButtonClick: (List<String>? list) {
            _onApplyButtonClicked(
                list, ActivatedFilter.LOCATION, context);
          },
        );
        break;
      case ActivatedFilter.AREA:
        FilterListDialog.display<String>(
          context,
          listData: searchData.areas,
          selectedListData: searchData.selectedAreas,
          choiceChipLabel: (area) => area,
          validateSelectedItem: (list, val) => list!.contains(val),
          hideHeader: true,
          hideSearchField: true,
          hideSelectedTextCount: true,
          borderRadius: 10,
          backgroundColor: cPrimary,
          onItemSearch: (list, item) {
            return true;
          },
        //  controlContainerDecoration: BoxDecoration(
        //    color: cDark,
        //    borderRadius: BorderRadius.circular(5.0),
        //  ),
        //  buttonRadius: 5,
        //  controlButtonTextStyle: TextStyle(
        //    color: cWhite,
        //  ),
        //  applyButonTextBackgroundColor: cSecondary,
          onApplyButtonClick: (List<String>? list) {
            _onApplyButtonClicked(list, ActivatedFilter.AREA, context);
          },
        );
        break;
      case ActivatedFilter.PINCODE:
        FilterListDialog.display<String>(
          context,
          listData: searchData.pincodes,
          selectedListData: searchData.selectedPincodes,
          choiceChipLabel: (pincode) => pincode,
          validateSelectedItem: (list, val) => list!.contains(val),
          hideHeader: true,
          hideSearchField: true,
          hideSelectedTextCount: true,
          borderRadius: 10,
          backgroundColor: cPrimary,
          onItemSearch: (list, item) {
            return true;
          },
          //controlContainerDecoration: BoxDecoration(
          //  color: cDark,
          //  borderRadius: BorderRadius.circular(5.0),
          //),
          // buttonRadius: 5,
          // controlButtonTextStyle: TextStyle(
          //  color: cWhite,
          // ),
          // applyButonTextBackgroundColor: cSecondary,
          onApplyButtonClick: (List<String>? list) {
            _onApplyButtonClicked(
                list, ActivatedFilter.PINCODE, context);
          },
        );
        break;
      default:
        emit(StoresUpdated(
          searchData: searchData,
          activatedfilter: activatedfilter,
        ));
        break;
    }
  }

  void _onApplyButtonClicked(List<String>? list, ActivatedFilter filter,
      BuildContext context) {

    Navigator.pop(context);

    switch (filter) {
      case ActivatedFilter.LOCATION:
        searchData.selectedLocations = list!;
        break;
      case ActivatedFilter.AREA:
        searchData.selectedAreas = list!;

        break;
      case ActivatedFilter.PINCODE:
        searchData.selectedPincodes = list!;
        break;
      case ActivatedFilter.NONE:
        break;
    }

    if (searchData.selectedLocations.length == 0 ||
        searchData.selectedLocations.length ==
            searchData.locations.length)
      activatedfilter.remove(ActivatedFilter.LOCATION);
    else
      activatedfilter.add(ActivatedFilter.LOCATION);

    if (searchData.selectedAreas.length == 0 ||
        searchData.selectedAreas.length ==
            searchData.areas.length)
      activatedfilter.remove(ActivatedFilter.AREA);
    else
      activatedfilter.add(ActivatedFilter.AREA);

    if (searchData.selectedPincodes.length == 0 ||
        searchData.selectedPincodes.length ==
            searchData.pincodes.length)
      activatedfilter.remove(ActivatedFilter.PINCODE);
    else
      activatedfilter.add(ActivatedFilter.PINCODE);

    emit(StoresLoading(activatedfilter: activatedfilter));

    List<Store> stores = searchData.stores.where((store) {
      if (activatedfilter.contains(ActivatedFilter.LOCATION) &&
          !searchData.selectedLocations.contains(store.location)) return false;

      if (activatedfilter.contains(ActivatedFilter.AREA) &&
          !searchData.selectedAreas.contains(store.area)) return false;

      if (activatedfilter.contains(ActivatedFilter.PINCODE) &&
          !searchData.selectedPincodes.contains(store.pincode)) return false;

      return true;
    }).toList();

    searchData.searchOutput = stores;

    emit(
        StoresUpdated(searchData: searchData, activatedfilter: activatedfilter)
    );
  }

  void searchStore(searchText) async {
    emit(StoresLoading(activatedfilter: activatedfilter));

    String val = searchText.toLowerCase();
    List<Store> temp = searchData.stores
        .where(
            (store) =>
              store.location.toLowerCase().contains(val) ||
              store.pincode.toLowerCase().contains(val) ||
              store.area.toLowerCase().contains(val) ||
              store.name.toLowerCase().contains(val) ||
              store.storeCode.toLowerCase().contains(val) ||
              store.address.toLowerCase().contains(val)
          ).toList();

    searchData.searchOutput = temp;
    emit(
        StoresUpdated(searchData: searchData, activatedfilter: activatedfilter)
    );
  }
}
