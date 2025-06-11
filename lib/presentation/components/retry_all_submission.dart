import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:surveyapp/cubits/retrySub/retry_sub_cubit.dart';
import 'package:surveyapp/helpers/colors.dart';

class RetryAllSubmission extends StatelessWidget {
  const RetryAllSubmission({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocListener<RetrySubCubit, RetrySubState>(
      listener: (context, state) {
        if (state is FormSubmittedSuccessfully) {
          Fluttertoast.showToast(msg: state.msg, gravity: ToastGravity.BOTTOM);
        } else if (state is FormSubmissionError) {
          Fluttertoast.showToast(
              msg: state.error, gravity: ToastGravity.BOTTOM);
        }
      },
      child: BlocBuilder<RetrySubCubit, RetrySubState>(
        builder: (context, state) {
          if (state is RetrySubInitial) {
            BlocProvider.of<RetrySubCubit>(context).checkForSubmissions();
            return Container();
          } else if (state is RetryTaskComplete) {
            return Container(
              width: size.width,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.done_outline_outlined,
                    size: 20,
                    color: Colors.green,
                  ),
                  Text(
                    "    No failed Submissions  !!",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is RetrySubmissionsPresent) {
            return Container(
              width: size.width,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Retry ${state.submissions} Submissions"),
                  InkWell(
                    onTap: () {
                      BlocProvider.of<RetrySubCubit>(context).retryNextSubmit();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.amber,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            size: 15,
                            color: cDark,
                          ),
                          Text(
                            "  Retry All",
                            style: TextStyle(color: cDark),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            RetryingSubmission currentState = state as RetryingSubmission;
            return Container(
              width: size.width,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Retry Submissions"),
                      InkWell(
                        onTap: () {
                          BlocProvider.of<RetrySubCubit>(context)
                              .retryNextSubmit();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.amber,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_outlined,
                                size: 15,
                                color: cDark,
                              ),
                              Text(
                                "  Retry All",
                                style: TextStyle(color: cDark),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Submitting ${currentState.index} of ${currentState.all}",
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "${currentState.images} images, ${currentState.videos} videos",
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
