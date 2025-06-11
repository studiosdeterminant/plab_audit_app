import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:surveyapp/cubits/retrySub/retry_sub_cubit.dart';
import 'package:surveyapp/cubits/user/user_cubit.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:surveyapp/helpers/strings.dart';
import 'package:surveyapp/cubits/stores/stores_cubit.dart';
import 'package:surveyapp/data/models/store.dart';
import 'package:surveyapp/presentation/components/retry_all_submission.dart';
import 'package:surveyapp/presentation/components/store_tile.dart';
import 'package:surveyapp/presentation/screens/add_store_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  List<Store> storeList = [];

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<StoresCubit>(context).getStoryList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Stores",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          InkWell(
            onTap: () async {
              final success = await Navigator.pushNamed(context, ADD_STORE_ROUTE);
              if (success != null && success == true) {
                BlocProvider.of<StoresCubit>(context).getStoryList();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(Icons.add),
            ),
          ),
          InkWell(
              onTap: () => {
                    Navigator.pushNamed(context, SEARCH_DIALOG,
                            arguments: storeList)
                        .then((value) => {
                              BlocProvider.of<StoresCubit>(context)
                                  .getStoryList(),
                              if (BlocProvider.of<RetrySubCubit>(context).state
                                      is RetryTaskComplete ||
                                  BlocProvider.of<RetrySubCubit>(context).state
                                      is RetrySubmissionsPresent)
                                {
                                  BlocProvider.of<RetrySubCubit>(context)
                                      .checkForSubmissions(),
                                }
                            },
                    ),
                  },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.search),
              )),
          InkWell(
            onTap: () {
              BlocProvider.of<StoresCubit>(context).refreshStoresList();
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(Icons.settings_backup_restore),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (_) => <PopupMenuItem<String>>[
              PopupMenuItem(
                child: InkWell(
                  onTap: () async {
                    BlocProvider.of<UserCubit>(context).logoutUser();
                    SystemNavigator.pop();
                  },
                  child: Text("Logout"),
                ),
              ),
            ],
          ),
        ],
        elevation: 1,
        backgroundColor: cPrimary,
      ),
      body:
          SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RetryAllSubmission(),
                  BlocListener<StoresCubit, StoresState>(
                    listener: (context, state) {
                      if (state is StoresListLoadError) {
                        Fluttertoast.showToast(
                            msg: "Error Occured while Loading the Stores",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM);
                      }
                    },
                    child: BlocBuilder<StoresCubit, StoresState>(
                      builder: (context, state) {
                        if (state is StoresInitial) {
                          storeList = state.stores;
                        }

                        if (state is StoresListLoaded) {
                          storeList = state.stores;
                        }
                        List<Widget> widgets = storeList
                            .map<Widget>(
                              (e) => StoreTile(
                                store: e,
                                onSelect: (sid) => {
                                  Navigator.pushNamed(context, FORM_ROUTE,
                                      arguments: {
                                        "storeId": sid,
                                        "storeName": e.name
                                      }).then(
                                    (value) => {
                                      if (value != null && (value is bool))
                                        {
                                          e.isSubmitted = value,
                                          BlocProvider.of<StoresCubit>(context)
                                              .getStoryList()
                                        },
                                      if (BlocProvider.of<RetrySubCubit>(context)
                                              .state is RetryTaskComplete ||
                                          BlocProvider.of<RetrySubCubit>(context)
                                              .state is RetrySubmissionsPresent)
                                        {
                                          BlocProvider.of<RetrySubCubit>(context)
                                              .checkForSubmissions(),
                                        }
                                    },
                                  )
                                },
                                cannotAudit: (
                                        {
                                        required String reason,
                                        required String image}) =>
                                    {
                                  BlocProvider.of<StoresCubit>(context)
                                      .cannotAudit(e.sid, reason, image)
                                },
                              ),
                            )
                            .toList();

                        if (state is StoresListLoading) {
                          widgets.add(_loadingTile(context));
                        }

                        if (widgets.isEmpty && state is StoresListLoaded) {
                          return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                "No stores found",
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widgets.length,
                          itemBuilder: (context, index) {
                            return widgets[index];
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _loadingTile(context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.all(10.0),
      width: size.width,
      child: Center(
        child: CircularProgressIndicator(
          color: cSecondary,
        ),
      ),
    );
  }
}
