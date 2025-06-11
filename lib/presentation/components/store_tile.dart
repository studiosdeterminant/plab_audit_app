import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyapp/data/models/store.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:maps_launcher/maps_launcher.dart';

import 'cannot_audit_dialog.dart';

class StoreTile extends StatelessWidget {
  final onSelect;
  final cannotAudit;
  final Store store;

  const StoreTile(
      {Key? key, required this.store, required this.onSelect, this.cannotAudit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: cPrimary.withAlpha(100),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    runSpacing: 5,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: cPrimary,
                        ),
                        child: Text(
                          store.storeCode,
                          style: TextStyle(color: cWhite),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        margin: EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: cSecondary,
                        ),
                        child: Text(
                          store.area,
                          style: TextStyle(
                            color: cWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    store.name,
                    maxLines: 5,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 15),
                  InkWell(
                    onTap: () => {MapsLauncher.launchQuery(store.address)},
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: cDark,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Text(
                            store.address,
                            maxLines: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: cPrimary,
                        ),
                        child:
                            (store.longitude != 0 && store.latitude != 0)
                                ? Row(
                                    children: [
                                      Text(
                                        "Directions : ",
                                        style: TextStyle(
                                          color: cWhite,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      InkWell(
                                        onTap: () => {
                                          MapsLauncher.launchCoordinates(
                                            store.latitude,
                                            store.longitude,
                                            store.name,
                                          )
                                        },
                                        child: Icon(
                                          Icons.directions,
                                          color: cWhite,
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    width: 10,
                                  ),
                      ),

                      // FutureBuilder(
                      //   future: SharedPreferences.getInstance(),
                      //   builder: (BuildContext context,
                      //       AsyncSnapshot<SharedPreferences> snapshot) {
                      //     if (snapshot.hasData) {
                      //       String? res = snapshot.data!
                      //           .getString("${store.sid}||${store.cycle}");
                      //       if (res != null && res.isNotEmpty) {
                      //         return Container(
                      //           padding: EdgeInsets.all(5),
                      //           decoration: BoxDecoration(
                      //             color: Colors.redAccent,
                      //             borderRadius: BorderRadius.circular(30),
                      //           ),
                      //           child: Text("RETRY"),
                      //         );
                      //       }
                      //     }
                      //     return SizedBox();
                      //   },
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: cPrimary,
            ),
            child: !store.isSubmitted
                ? Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_outlined),
                        color: cWhite,
                        iconSize: 20,
                        onPressed: () => {onSelect(store.sid)},
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      IconButton(
                        icon: const Icon(Icons.error_rounded),
                        color: cWhite,
                        iconSize: 20,
                        onPressed: () {
                          _asyncInputDialog(context, cannotAudit);
                        },
                      )
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.done),
                    iconSize: 20,
                    color: cWhite,
                    onPressed: () => {
                      Fluttertoast.showToast(
                          msg: "Completed Already",
                          gravity: ToastGravity.BOTTOM)
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Future<SharedPreferences> _getSharedPrefs() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs;
  // }

  void _asyncInputDialog(BuildContext context, cannotAudit) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return CannotAuditDialog(cannotAudit: cannotAudit);
      },
    );
  }
}
