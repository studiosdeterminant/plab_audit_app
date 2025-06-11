import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:surveyapp/cubits/form/form_cubit.dart';
import 'package:surveyapp/presentation/screens/form_submit_screen.dart';
import 'package:surveyapp/presentation/screens/page_screen.dart';

class FormScreen extends StatelessWidget {
  final String sid;
  final String storeName;

  const FormScreen({Key? key, required this.sid, required this.storeName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<StoreFormCubit>(context).getForm(sid);

    return Scaffold(
      appBar: AppBar(
        title: Text(storeName),
        backgroundColor: cSecondary,
      ),
      body: BlocListener<StoreFormCubit, StoreFormState>(
        listener: (context, state) {
          if (state is FormSubmitted) {
            Fluttertoast.showToast(
                msg: "Form Submitted successfully",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM);

            Navigator.pop(context, true);
          } else if (state is FormSubmissionError) {
            BlocProvider.of<StoreFormCubit>(context)
                .changeFormPage(to: state.form.pages.length - 1);
            _asyncInputDialog(
                context,
                state.error,
                () => BlocProvider.of<StoreFormCubit>(context).submitForm(),
                () => Navigator.pop(context, false));
          } else if (state is FileUploadError) {
            Fluttertoast.showToast(
                msg: state.error,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM);
          }
        },
        child: BlocBuilder<StoreFormCubit, StoreFormState>(
          builder: (context, state) {
            if (state is FormInitial || state is FormDetailsLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: cSecondary,
                ),
              );
            } else if (state is FormSubmitting) {
              return FormSubmitScreen(form: state.form);
            } else if (state is FormLoadError) {
              return Center(
                child: Text(
                  state.error,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      wordSpacing: 4),
                ),
              );
            } else if (state is LoadFormPage) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: PageScreen(
                  page: state.form.pages[state.pos],
                  index: state.pos,
                  size: state.form.pages.length,
                  sid: state.form.sid!,
                  cycleId: state.form.cycle,
                  navigationCallback: (to) => {
                    BlocProvider.of<StoreFormCubit>(context)
                        .changeFormPage(to: to),
                  },
                  onLocationFetched: ({latitude, longitude}) {
                    state.form.storeCoordinates['latitude'] = latitude;
                    state.form.storeCoordinates['longitude'] = longitude;
                  },
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  void _asyncInputDialog(BuildContext context, error, onRetry, onCancel) async {
    String reason = '';
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Retry Submitting !!'),
          content: Container(margin: EdgeInsets.all(5), child: Text(error)),
          actions: [
            ElevatedButton(
              child: Text('Retry'),
              onPressed: () {
                onRetry();
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                onCancel();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
