import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyapp/data/models/form.dart';
import 'package:surveyapp/data/repositories/form.dart';
import 'package:surveyapp/data/repositories/stream_state/form_submit_state.dart'
    as se;

part 'form_state.dart';

class StoreFormCubit extends Cubit<StoreFormState> {
  final FormRepository formRepository;

  StoreFormCubit({required this.formRepository}) : super(FormInitial());

  Future<void> getForm(sid) async {
    final currentState = state;
    if (currentState is FormLoaded) {
      emit(LoadFormPage(form: currentState.form, pos: 0));
    } else {
      emit(FormDetailsLoading());
      var form = await formRepository.getFormDetails(sid);
      await Future.delayed(Duration(milliseconds: 50));

      if (form is SurveyForm) {

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String storedState = prefs.getString("$sid||${form.cycle}") ?? "";

        if(storedState.isNotEmpty){
          form = SurveyForm.fromJson(jsonDecode(storedState));
          emit(FormSubmissionError(form: form, error: "Submit form"));
          await Future.delayed(Duration(milliseconds: 50));
        }

        emit(FormLoaded(form: form));
        await Future.delayed(Duration(milliseconds: 50));
        emit(LoadFormPage(pos: 0, form: form));
      } else {
        emit(FormLoadError(error: form['error']));
      }
    }
  }

  void changeFormPage({required int to}) async {
    final currentState = state;
    if (currentState is FormLoaded) {
      emit(LoadFormPage(form: currentState.form, pos: to));
    }
  }

  // Future<void> submitForm() async {
  //   final currentState = state;
  //   if (currentState is FormLoaded) {
  //     print(currentState.form);
  //     emit(FormSubmitting(form: currentState.form));
  //     Map res = await formRepository.submitForm(currentState.form);
  //     Future.delayed(Duration(milliseconds: 50));
  //
  //     if (res['success']) {
  //       emit(FormSubmitted(form: currentState.form));
  //     } else {
  //       emit(FormSubmissionError(form: currentState.form, error: res['error']));
  //       Future.delayed(Duration(milliseconds: 50));
  //       emit(LoadFormPage(form: currentState.form, pos: currentState.form.pages.length -1));
  //     }
  //   }
  // }

  Future<void> submitForm() async {
    final currentState = state;
    if (currentState is FormLoaded) {
      emit(FormSubmitting(form: currentState.form));
      Stream<se.FormSubmitState> stream =
          formRepository.submitForm(currentState.form);
      StreamSubscription<se.FormSubmitState> streamSubscription = stream.listen(
        (event) async {
          if (event is se.FormSubmitting)
            emit(FormSubmitting(form: event.form));
          else if(event is se.FileUploaded)
            emit(FileUploadSuccess(form: event.form));
          else if (event is se.FileUploadError)
            emit(FileUploadError(form: event.form, error: event.error));
          else if (event is se.FormSubmitted)
            emit(FormSubmitted(form: event.form));
          else if (event is se.FormSubmitError) {
            emit(FormSubmissionError(form: event.form, error: event.error));
          }
          await Future.delayed(Duration(milliseconds: 50));
        },
      );

      streamSubscription.onDone(() {
        streamSubscription.cancel();
      });
    }
  }
}
