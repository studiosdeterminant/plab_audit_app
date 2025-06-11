part of 'images_cubit.dart';

abstract class ImagesState {
  final ImageQuestion question;
  const ImagesState(this.question);
}

class ImagesInitial extends ImagesState {
  ImagesInitial(ImageQuestion question) : super(question);
}

class ImageListUpdated extends ImagesState {
  ImageListUpdated(ImageQuestion question) : super(question);
}
