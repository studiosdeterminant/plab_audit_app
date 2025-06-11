part of 'form_cubit.dart';

abstract class StoreFormState extends Equatable {
  const StoreFormState();
}

class FormInitial extends StoreFormState {
  @override
  List<Object> get props => [];
}

class FormDetailsLoading extends StoreFormState {
  @override
  List<Object> get props => [];
}

class FormLoadError extends StoreFormState {
  final String error;

  const FormLoadError({required this.error});

  @override
  List<Object> get props => [error];
}

class FormLoaded extends StoreFormState {
  final SurveyForm form;

  const FormLoaded({required this.form});

  @override
  List<Object> get props => [form];
}

class LoadFormPage extends FormLoaded {
  final int pos;

  const LoadFormPage({required SurveyForm form, required this.pos})
      : super(form: form);

  @override
  List<Object> get props => [pos];
}

class FormSubmitting extends FormLoaded {
  FormSubmitting({required SurveyForm form}) : super(form: form);
}

class FileUploadSuccess extends FormSubmitting {
  FileUploadSuccess({required SurveyForm form}) : super(form: form);
}

class FileUploadError extends FormSubmitting {
  final String error;
  FileUploadError({required SurveyForm form, required this.error}) : super(form: form);

  @override
  List<Object> get props => [error];
}

class FormSubmitted extends FormLoaded {
  FormSubmitted({required SurveyForm form}) : super(form: form);
}

class FormSubmissionError extends FormLoaded {
  final String error;

  FormSubmissionError({required SurveyForm form, required this.error})
      : super(form: form);

  @override
  List<Object> get props => [ error];
}
