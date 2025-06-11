import 'package:bloc/bloc.dart';
import 'package:surveyapp/data/models/question.dart';
import 'package:surveyapp/data/repositories/form.dart';
import 'package:surveyapp/helpers/strings.dart';

part 'videos_state.dart';

class VideosCubit extends Cubit<VideosState> {
  final FormRepository formRepository;
  final String sid, cycleId;
  VideosCubit({required VideoQuestion question, required this.formRepository, required this.sid, required this.cycleId}) : super(VideosInitial(question));

  void deleteVideo({required int videoIndex}) {
    state.question.videoList.removeAt(videoIndex);

    emit(VideoListUpdated(state.question));
  }

  void addVideo(String address) {
    state.question.videoList.add(FileData(address: address));

    emit(VideoListUpdated(state.question));
  }

  void cannotTakeVideo({required String? reason }) {

    if(reason != null) {
      formRepository.cannotUploadFile(cycleId: cycleId, sid: sid, qid: state.question.qid, reason: reason);
    }

    state.question.reason = reason;
    emit(VideoListUpdated(state.question));
  }
}
