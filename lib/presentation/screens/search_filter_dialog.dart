import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surveyapp/cubits/search/search_cubit.dart';
import 'package:surveyapp/cubits/stores/stores_cubit.dart';
import 'package:surveyapp/data/models/search.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:surveyapp/helpers/strings.dart';
import 'package:surveyapp/presentation/components/Filter.dart';
import 'package:surveyapp/presentation/components/store_tile.dart';

enum ActivatedFilter { LOCATION, AREA, PINCODE, NONE }

class SearchFilter extends StatefulWidget {
  SearchFilter({Key? key}) : super(key: key);

  @override
  _SearchFilterState createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocListener<SearchCubit, SearchState>(
      listener: (context, state) {
        // TODO: implement listener}
      },
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              // child: Text("Search Stores", style: TextStyle(color: cWhite)),
              child: TextField(
                maxLines: 1,
                cursorColor: cWhite,
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                style: TextStyle(color: cWhite),
                decoration: InputDecoration(
                  hintText: "Search Stores ...",
                  hintStyle: TextStyle(color: cWhiteSecondary),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          backgroundColor: cSecondary,
          elevation: 1,
          actions: [
            InkWell(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                BlocProvider.of<SearchCubit>(context).searchStore(searchText);
              },
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.search,
                  color: cWhite,
                ),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: size.width,
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: cPrimary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Filters"),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Filter(
                                filterName: "LOCATION",
                                isActivated: state.activatedfilter
                                    .contains(ActivatedFilter.LOCATION),
                                onTap: () {
                                  BlocProvider.of<SearchCubit>(context)
                                      .openFilterDialog(
                                    context,
                                    ActivatedFilter.LOCATION,
                                  );
                                }),
                            Filter(
                                filterName: "AREA",
                                isActivated: state.activatedfilter
                                    .contains(ActivatedFilter.AREA),
                                onTap: () {
                                  BlocProvider.of<SearchCubit>(context)
                                      .openFilterDialog(
                                          context, ActivatedFilter.AREA);
                                }),
                            Filter(
                                filterName: "PINCODE",
                                isActivated: state.activatedfilter
                                    .contains(ActivatedFilter.PINCODE),
                                onTap: () {
                                  BlocProvider.of<SearchCubit>(context)
                                      .openFilterDialog(
                                          context, ActivatedFilter.PINCODE);
                                }),
                          ],
                        )
                      ],
                    );
                  },
                ),
              ),
              BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is StoresLoading)
                    return Container(
                      margin: EdgeInsets.only(top: 10),
                      child: CircularProgressIndicator(color: cPrimary),
                    );
                  if (state is StoresUpdated) {
                    return _showList(context, state.searchData);
                  }
                  return SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showList(context, SearchData data) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: data.searchOutput.length,
        itemBuilder: (context, index) {
          final store = data.searchOutput[index];
          return StoreTile(
              store: store,
              onSelect: (sid) => {
                    Navigator.pushNamed(context, FORM_ROUTE, arguments: {
                      "storeId": sid,
                      "storeName": store.name
                    }).then(
                      (value) => {
                        if (value != null && (value is bool))
                          {
                            store.isSubmitted = value,
                            BlocProvider.of<SearchCubit>(context)
                                .getCurrentState(),
                          },
                      },
                    )
                  },
              cannotAudit:
                  ({required String reason, required String image}) => {
                        BlocProvider.of<StoresCubit>(context)
                            .cannotAudit(store.sid, reason, image)
                      });
        });
  }
}
