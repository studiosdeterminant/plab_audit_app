import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyapp/data/models/form.dart';
import 'package:surveyapp/data/models/page.dart';
import 'package:surveyapp/data/models/question.dart';

@immutable
abstract class FormSubmitState extends Equatable {}

class FormSubmitting extends FormSubmitState {
  final SurveyForm form;

  FormSubmitting({required this.form});

  @override
  List<Object?> get props => [form];
}

class NewFormSubmission extends FormSubmitting {
  NewFormSubmission({required form}) : super(form: form) {
    _updateSharedPrefs();
  }

  _updateSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "${form.sid}||${form.cycle}", jsonEncode(SurveyForm.toJson(form)));
  }
}

class FileUploaded extends FormSubmitState {
  final SurveyForm form;

  FileUploaded({required this.form}) {
    _updateSharedPrefs();
  }

  _updateSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "${form.sid}||${form.cycle}", jsonEncode(SurveyForm.toJson(form)));
  }

  @override
  List<Object?> get props => [form];
}

class FormSubmitted extends FormSubmitState {
  final SurveyForm form;

  FormSubmitted({required this.form}) {
    _updateSharedPrefs();
    _removeFilesFromStore();
  }

  _updateSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("${form.sid}||${form.cycle}");
  }

  _removeFilesFromStore() async {
    for (PageData page in form.pages) {
      for (Question question in page.questions) {
        if (question is ImageQuestion) {
          for (FileData image in question.imageList) {
            try {
              File file = File(image.address);
              await file.delete();
            } catch (e) {}
          }
        }

        if (question is VideoQuestion) {
          for (FileData video in question.videoList) {
            try {
              File file = File(video.address);
              await file.delete();
            } catch (e) {}
          }
        }
      }
    }
  }

  @override
  List<Object?> get props => [form];
}

class FileUploadError extends FormSubmitState {
  final SurveyForm form;
  final String error;

  FileUploadError({required this.form, required this.error}){
    _updateSharedPrefs();
  }

  _updateSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "${form.sid}||${form.cycle}", jsonEncode(SurveyForm.toJson(form)));
  }

  @override
  List<Object?> get props => [form, error];
}

class FormSubmitError extends FormSubmitState {
  final SurveyForm form;
  final String error;

  FormSubmitError({required this.form, required this.error}) {
    _updateSharedPrefs();
  }

  _updateSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "${form.sid}||${form.cycle}", jsonEncode(SurveyForm.toJson(form)));
  }

  @override
  List<Object?> get props => [form, error];
}
