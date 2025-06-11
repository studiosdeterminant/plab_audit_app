import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:surveyapp/data/network_services/network_client/dio_client.dart';
import 'package:surveyapp/cubits/form/form_cubit.dart';
import 'package:surveyapp/cubits/images/images_cubit.dart';
import 'package:surveyapp/cubits/videos/videos_cubit.dart';
import 'package:surveyapp/data/models/page.dart';
import 'package:surveyapp/data/models/question.dart';
import 'package:surveyapp/data/network_services/form.dart';
import 'package:surveyapp/data/repositories/form.dart';
import 'package:surveyapp/helpers/colors.dart';
import 'package:surveyapp/presentation/components/image_pager_view.dart';
import 'package:surveyapp/presentation/components/numeric_layout.dart';
import 'package:surveyapp/presentation/components/one_liner_layout.dart';
import 'package:surveyapp/presentation/components/question_container.dart';
import 'package:surveyapp/presentation/components/single_choice_layout.dart';
import 'package:surveyapp/presentation/components/video_pager_view.dart';

class PageScreen extends StatefulWidget {
  final PageData page;
  final int index;
  final int size;
  final navigationCallback, onLocationFetched;
  final String sid, cycleId;

  const PageScreen({
    Key? key,
    required this.page,
    required this.index,
    required this.size,
    required this.sid,
    required this.cycleId,
    this.navigationCallback,
    this.onLocationFetched,
  }) : super(key: key);

  @override
  _PageScreenState createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  final _formKey = GlobalKey<FormState>();

  bool allQuestionsNotRequired() {
    return widget.page.questions.every((q) {
      if (q is OneLinerQuestion) {
        return !q.isRequired;
      } else if (q is NumericChoiceQuestion) {
        return !q.isRequired;
      } else if (q is SingleChoiceQuestion) {
        return !q.isRequired;
      } else if (q is ImageQuestion) {
        return !q.isRequired;
      } else if (q is VideoQuestion) {
        return !q.isRequired;
      }
      // If the question type doesn't have isRequired, treat as not required
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];

    rows.add(
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.page.title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black),
              ),
            ),
            // Show skip button only for middle pages
            if (widget.index > 0 && widget.index < widget.size - 1)
              ElevatedButton(
                onPressed: () {
                  if (widget.navigationCallback != null) widget.navigationCallback(widget.index + 1);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black),
                child: Text("SKIP"),
              ),
          ],
        ),
      ),
    );

    rows.addAll(
        widget.page.questions.map((e) => getQuestionLayout(e)).toList());

    rows.add(
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: navigationTile(widget.index, widget.size,
            widget.navigationCallback, context, _formKey),
      ),
    );

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        key: Key(widget.page.pid),
        scrollDirection: Axis.vertical,
        child: Column(children: rows),
      ),
    );
  }

Widget navigationTile(
    index, size, navigationCallback, context, GlobalKey<FormState> formKey) {

  if (index == 0 && size == 1) {
    // Only one page, no skip
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                submitForm(context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: cSecondary,
                shadowColor: cDark,
                elevation: 3,
                foregroundColor: cWhite),
            child: BlocBuilder<StoreFormCubit, StoreFormState>(
              builder: (context, state) {
                if (state is FormSubmitting)
                  return CircularProgressIndicator();
                else
                  return Text("SUBMIT FORM");
              },
            ))
      ],
    );
  } else if (index == 0 && size > 1) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                navigationCallback(index + 1);
              } else {
                Fluttertoast.showToast(msg: "Fill All required fields");
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: cSecondary,
                shadowColor: cDark,
                elevation: 3,
                foregroundColor: cWhite),
            child: Text("NEXT")),
      ],
    );
  } else if (index > 0 && index == size - 1) {
    // Last page
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
            onPressed: () => {navigationCallback(index - 1)},
            style: ElevatedButton.styleFrom(
                backgroundColor: cSecondary,
                shadowColor: cDark,
                elevation: 3,
                foregroundColor: cWhite),
            child: Text("PREVIOUS")),
        
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              submitForm(context);
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: cSecondary,
              shadowColor: cDark,
              elevation: 3,
              foregroundColor: cWhite),
          child: BlocBuilder<StoreFormCubit, StoreFormState>(
            builder: (context, state) {
              if (state is FormSubmitting)
                return CircularProgressIndicator();
              else
                return Text("SUBMIT FORM");
            },
          ),
        ),
      ],
    );
  } else {
    // Middle pages
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
            onPressed: () => {navigationCallback(index - 1)},
            style: ElevatedButton.styleFrom(
                backgroundColor: cSecondary,
                shadowColor: cDark,
                elevation: 3,
                foregroundColor: cWhite),
            child: Text("PREVIOUS")),
        ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                navigationCallback(index + 1);
              } else {
                Fluttertoast.showToast(msg: "Fill All required fields");
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: cSecondary,
                shadowColor: cDark,
                elevation: 3,
                foregroundColor: cWhite),
            child: Text("NEXT")),
      ],
    );
  }
}

  void submitForm(context) {
    BlocProvider.of<StoreFormCubit>(context).submitForm();
  }

  Widget getQuestionLayout(qn) {
    // Handle questions with image-type questions
    if (qn is OneLinerQuestion ||
        qn is NumericChoiceQuestion ||
        qn is SingleChoiceQuestion) {
      Widget questionWidget;

      if (qn is OneLinerQuestion) {
        questionWidget = OneLinerQuestionLayout(
          question: qn,
          onChangedListener: (val) => qn.answer = val,
        );
      } else if (qn is NumericChoiceQuestion) {
        questionWidget = NumericQuestionLayout(
          question: qn,
          onChangedListener: (val) => qn.answer = int.parse(val),
        );
      } else {
        questionWidget = SingleChoiceQuestionLayout(
          question: qn,
          onChangedListener: (val) => qn.answer = val,
        );
      }

      if (qn.questionType == "image" && qn.imageData?['id'] != null) {
        return QuestionContainer(
          question: qn.question,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuestionImage(qn.imageData!),
              questionWidget,
            ],
          ),
        );
      }

      return QuestionContainer(question: qn.question, child: questionWidget);
    } else if (qn is ImageQuestion) {
      return BlocProvider(
        create: (context) => ImagesCubit(
            sid: widget.sid,
            cycleId: widget.cycleId,
            question: qn,
            formRepository:
                FormRepository(formNetworkService: FormNetworkService())),
        child: QuestionContainer(
            child: ImagePager(onLocationFetched: widget.onLocationFetched),
            question: qn.question),
      );
    } else if (qn is VideoQuestion) {
      return BlocProvider(
        create: (context) => VideosCubit(
            sid: widget.sid,
            cycleId: widget.cycleId,
            question: qn,
            formRepository:
                FormRepository(formNetworkService: FormNetworkService())),
        child: QuestionContainer(child: VideoPager(), question: qn.question),
      );
    } else
      return SizedBox();
  }

  Widget _buildQuestionImage(Map<String, dynamic> imageData) {
    final String? mediaId = imageData['id'];
    if (mediaId == null || mediaId.isEmpty) return SizedBox();

    Future<String?> fetchSignedUrl(String mediaId) async {
      try {
        final dio = await DioClient.dio;
        final response = await dio.get(
          "/audit/image",
          queryParameters: {"mediaId": mediaId},
        );

        if (response.statusCode == 200 && response.data['data'] != null) {
          return response.data['data']['signedUrl'];
        }
      } catch (e) {
        print("Image fetch error: $e");
      }
      return null;
    }

    return FutureBuilder<String?>(
      future: fetchSignedUrl(mediaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(child: CircularProgressIndicator()),
          );
        if (!snapshot.hasData || snapshot.data == null)
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Failed to load image",
                style: TextStyle(color: Colors.red)),
          );

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Image.network(snapshot.data!, fit: BoxFit.contain),
        );
      },
    );
  }
}
