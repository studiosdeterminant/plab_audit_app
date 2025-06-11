part of 'retry_sub_cubit.dart';

abstract class RetrySubState extends Equatable {
  const RetrySubState();
}

class RetrySubInitial extends RetrySubState {
  @override
  List<Object> get props => [];
}

class RetrySubmissionsPresent extends RetrySubState {

  final int submissions;
  RetrySubmissionsPresent(this.submissions);

  @override
  List<Object> get props => [];

}

class RetryingSubmission extends RetrySubState {
  final int index;
  final int all;
  final int images;
  final int videos;
  final String status;

  const RetryingSubmission(this.index, this.all, this.images, this.videos, this.status);

  @override
  List<Object> get props => [index, all, images, videos, status];
}

class FormSubmittedSuccessfully extends RetryingSubmission {

  final String msg;
  const FormSubmittedSuccessfully(int index, int all, int images, int videos, status, this.msg): super(index, all, images, videos, status);

  @override
  List<Object> get props => [msg];
}

class FormSubmissionError extends RetryingSubmission {

  final String error;
  const FormSubmissionError(int index, int all, int images, int videos, status, this.error): super(index, all, images, videos, status);

  @override
  List<Object> get props => [error];
}

class RetryTaskComplete extends RetrySubState {

  @override
  List<Object> get props => [];
}
