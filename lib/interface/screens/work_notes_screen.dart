import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as htmlDom;
import 'package:html/parser.dart' show parse;
import 'package:ttsbuiltmobile/data/repositories/simpro_repository.dart';
import 'package:ttsbuiltmobile/data/utility/job_detail_note.dart';
import 'package:ttsbuiltmobile/logic/blocs/simpro_connection_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/simpro_connection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../logic/blocs/job_listing_bloc.dart';
import '../../logic/blocs/user_bloc.dart';
import '../../logic/states/connection_available.dart';
import '../../logic/states/job_listing_event.dart';
import '../../logic/states/job_listing_state.dart';
import '../../logic/states/user_state.dart';
import '../components/global.dart';
import 'package:intl/intl.dart';

class WorkNotesScreen extends StatelessWidget {

  final int companyId;
  final int jobId;

  int startOfEdit = -1;
  int endOfEdit = -1;

  String defaultTextCaptureValue = 'Enter new note here';

  WorkNotesScreen(this.companyId, this.jobId);
  TextEditingController? textController;
  String? updatedText;
  @override
  Widget build(BuildContext context) {
    textController = TextEditingController(text: defaultTextCaptureValue);
    textController!.addListener(_processEdit);
    return BlocBuilder<SimproConnectionBloc, SimproConnectionState>(
        builder: (context, connectionState) {
          final Size size = MediaQuery.of(context).size;
          double borderWidth = 4;
          Color borderColor;
          switch (connectionState.available) {
            case ConnectionAvailable.attempting:
              {
                borderColor = Colors.amber;
              }
              break;
            case ConnectionAvailable.idle:
              {
                borderColor = Colors.grey;
              }
              break;
            case ConnectionAvailable.yes:
              {
                borderColor = Colors.lightGreenAccent;
              }
              break;
            case ConnectionAvailable.no:
              {
                borderColor = Colors.red;
              }
          }
          ScheduleRepository scheduleRepo = RepositoryProvider.of<ScheduleRepository>(context);
          return BlocBuilder<JobListingBloc, JobListingState>(
              builder: (context, jobListingState) {
                Map<String,dynamic> thisJob = jobListingState.jobs[jobId.toString()];
                htmlDom.Document document = parse(thisJob["details"]["Notes"]);
                List<TextNode> startVal = [];
                List<TextNode> workNoteText = getNodeText(startVal, document);
                htmlDom.NodeList documentNodes = document.firstChild!.nodes[1].nodes;
                if(documentNodes[0].nodes.length > 1) documentNodes = documentNodes[0].nodes;
                List<Widget> workNotes = [];
                for(TextNode node in workNoteText) {
                    workNotes.add(
                      Container(
                        width: size.width,
                        padding: new EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                          width: 1,
                          color: c2),
                          borderRadius: BorderRadius.all(Radius.circular(2))
                        ),
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 7),
                        child:Text(node.text,
                        style: node.style
                      ))
                    );
                    workNotes.add(SizedBox(height: 1));
                }

                workNotes.add(
                    Container(
                        width: size.width,
                        padding: new EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                            color:c4,
                            border: Border.all(
                                width: 1,
                                color: borderColor),
                            borderRadius: BorderRadius.all(Radius.circular(2))
                        ),
                        child:TextField(
                          controller: textController,
                          style: defaultTextStyle,
                          onEditingComplete: () => saveNewNote(context, document)
                        ))
                );

                return SafeArea(
                    child: Scaffold(
                        body: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(
                                  width: borderWidth, color: borderColor),
                            ),
                            width: size.width - 2 * borderWidth,
                            height: size.height - 2 * borderWidth,
                            child: Column(children: <Widget>[
                              getJobHeader(size, thisJob["details"]["Site"]["Name"]),
                              Expanded(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                        padding: EdgeInsets.all(7.0),
                                        child: Focus(
                                        child:Column(
                                          children: workNotes
                                        ),
                                        )),
                                  ))
                            ]))));
              }
          );
        });
  }

  void _processEdit(){
    String currentText = textController!.text;
    if(currentText.startsWith(defaultTextCaptureValue)){
      textController!.text = currentText.substring(defaultTextCaptureValue.length);
    }
  }

  void saveNewNote(BuildContext context, htmlDom.Document document)  async{
    String currentText = textController!.text;
    if(currentText == defaultTextCaptureValue) return;
    if(currentText.isNotEmpty && currentText.trim().length > 0){
      UserBloc user = BlocProvider.of<UserBloc>(context);
      UserState userState = user.state;
      JobDetailNote firstNote = JobDetailNote(userState.name + " (" + (DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now()) + ") - Work Note"), JobDetailStyle.strong);
      JobDetailNote secondNote = JobDetailNote(currentText, JobDetailStyle.normal);
      List<JobDetailNote> notesToAdd = [firstNote, secondNote];
      SimproRepository simproRep = RepositoryProvider.of<SimproRepository>(context);
      await simproRep.appendJobDetailNotes(jobId, notesToAdd);
      JobListingBloc listingBloc = BlocProvider.of<JobListingBloc>(context);
      String existingNotes = document.outerHtml;
      //String prefix <html><head></head><body> and suffix <div>&nbsp;</div></body></html>
      if(existingNotes.startsWith("<html><head></head><body>")){
        existingNotes = existingNotes.substring(25);
      }else{
        debugPrint(existingNotes);
      }

      if(existingNotes.endsWith("<div>&nbsp;</div></body></html>")){
        existingNotes = existingNotes.substring(0, existingNotes.length - 31);
      }else{
        debugPrint(existingNotes);
      }
      StringBuffer updatedNotesBuffer = StringBuffer(existingNotes);
      for (JobDetailNote thisNote in notesToAdd) {
        updatedNotesBuffer.write(thisNote.getJobDetailToAppend());
      }
      Map<String, dynamic> jobUpdateSkeleton = {};
      jobUpdateSkeleton[jobId.toString()] = {};
      jobUpdateSkeleton[jobId.toString()]["details"] = {};
      jobUpdateSkeleton[jobId.toString()]["details"]["Notes"] = updatedNotesBuffer.toString();
      JobListingState updateState = JobListingState(jobUpdateSkeleton);
      UpdateListedJobs updateEvent = UpdateListedJobs(updateState);
      listingBloc.add(updateEvent);
      textController!.text = defaultTextCaptureValue;
      FocusScope.of(context).unfocus();
    }
  }

}

class TextNode{
  String text;
  TextStyle style;
  TextNode(this.text, this.style);
}

List<TextNode> getNodeText(List<TextNode> nodes, htmlDom.Node node){
  for(var thisNode in node.nodes){
    if(thisNode.runtimeType.toString() == "Text"){
      String textToDisplay = thisNode.text!;
      if(textToDisplay.trim().length > 0) {
        TextStyle thisStyle;
        if (getElementLocalName(node as htmlDom.Element) == "strong") {
          thisStyle = defaultTextStyle.copyWith(fontWeight: FontWeight.bold);
        } else {
          thisStyle = defaultTextStyle;
        }
        nodes.add(TextNode(textToDisplay.trim(), thisStyle));
      }
    }else if(thisNode.nodes.length > 0){
      nodes = getNodeText(nodes, thisNode);
    }
  }
  return nodes;
}

String getElementLocalName(htmlDom.Element element){
  return element.localName!;
}
