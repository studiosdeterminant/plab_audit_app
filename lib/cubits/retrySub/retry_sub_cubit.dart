import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyapp/data/models/form.dart';
import 'package:surveyapp/data/models/page.dart';
import 'package:surveyapp/data/models/question.dart';
import 'package:surveyapp/data/repositories/form.dart';
import 'package:surveyapp/data/repositories/stream_state/form_submit_state.dart'
    as se;

part 'retry_sub_state.dart';

class RetrySubCubit extends Cubit<RetrySubState> {
  int formSize = 0;
  final List<SurveyForm> forms = [];
  final FormRepository formRepository;

  RetrySubCubit({required this.formRepository}) : super(RetrySubInitial());

  Future<void> checkForSubmissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    forms.clear();
    for (String key in keys) {
      try {
        String? res = prefs.getString(key);
        SurveyForm form = SurveyForm.fromJson(jsonDecode(res!));
        forms.add(form);
      } catch (e) {
        //kuch nai karna hai.
      }
    }

    formSize = forms.length;
    if (forms.length == 0)
      emit(RetryTaskComplete());
    else
      emit(RetrySubmissionsPresent(forms.length));
  }

  Future<void> retryNextSubmit() async {
    if (forms.length == 0) {
      emit(RetrySubInitial());
    } else {
      SurveyForm form = forms.removeAt(0);
      int images = 0, videos = 0;

      for (PageData page in form.pages) {
        for (Question question in page.questions) {
          if (question is ImageQuestion) images += question.imageList.length;
          if (question is VideoQuestion) videos += question.videoList.length;
        }
      }

      Stream<se.FormSubmitState> stream = formRepository.submitForm(form);
      StreamSubscription<se.FormSubmitState> streamSubscription = stream.listen(
        (event) async {
          if (event is se.FormSubmitting)
            emit(RetryingSubmission(formSize - forms.length, formSize, images,
                videos, "Submitting"));
          else if (event is se.FileUploadError)
            emit(RetryingSubmission(formSize - forms.length, formSize, images,
                videos, event.error));
          else if (event is se.FormSubmitted) {
            emit(FormSubmittedSuccessfully(formSize - forms.length, formSize,
                images, videos, "Submitted", "Form Submitted Successfully"));
          } else if (event is se.FormSubmitError) {
            emit(FormSubmissionError(formSize - forms.length, formSize, images,
                videos, "Error Occurred", event.error));
          }
          await Future.delayed(Duration(milliseconds: 50));
        },
      );

      streamSubscription.onDone(() {
        streamSubscription.cancel();
        retryNextSubmit();
      });
    }
  }
}
