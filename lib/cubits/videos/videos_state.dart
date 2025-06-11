part of 'videos_cubit.dart';

abstract class VideosState {
  final VideoQuestion question;
  const VideosState(this.question);
}

class VideosInitial extends VideosState {
  VideosInitial(VideoQuestion question) : super(question);
}

class VideoListUpdated extends VideosState {
  VideoListUpdated(VideoQuestion question) : super(question);
}
