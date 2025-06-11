import 'package:bloc/bloc.dart';
import 'package:surveyapp/data/models/question.dart';
import 'package:surveyapp/data/repositories/form.dart';
import 'package:surveyapp/helpers/strings.dart';

part 'images_state.dart';

class ImagesCubit extends Cubit<ImagesState> {
  final FormRepository formRepository;
  final String cycleId, sid;

  ImagesCubit({required ImageQuestion question, required this.formRepository, required this.cycleId, required this.sid})
      : super(ImagesInitial(question));

  void deleteImage({required int imageIndex}) {
    state.question.imageList.removeAt(imageIndex);
    emit(ImageListUpdated(state.question));
  }

  void addImage(String address) {
    state.question.imageList.add(FileData(address: address));
    emit(ImageListUpdated(state.question));
  }

  void cannotTakeImage({required String? reason }) {

    if(reason != null) {
      formRepository.cannotUploadFile(cycleId: cycleId, sid: sid, qid: state.question.qid, reason: reason);
    }

    state.question.reason = reason;
    emit(ImageListUpdated(state.question));
  }
}
