import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as htmlDom;
import 'package:html/parser.dart' show parse;
import 'package:ttsbuiltmobile/data/utility/job_detail_note.dart';
import 'package:ttsbuiltmobile/logic/blocs/simpro_connection_bloc.dart';
import 'package:ttsbuiltmobile/logic/states/simpro_connection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../logic/blocs/job_listing_bloc.dart';
import '../../logic/blocs/user_bloc.dart';
import '../../logic/states/connection_available.dart';
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
                var document = parse(thisJob["details"]["Notes"]);
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
                          color: borderColor),
                          borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
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
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        child:TextField(
                          controller: textController,
                          style: defaultTextStyle,
                          onEditingComplete: () => saveNewNote(context)
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
                              Padding(
                                  padding: new EdgeInsets.all(6.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: c2,
                                          border: Border.all(
                                            color: c2,
                                          ),
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                      width: size.width - 40,
                                      child: Padding(
                                          padding: new EdgeInsets.all(4.0),
                                          child: Row(children: <Widget>[
                                            Image.asset(
                                                'assets/images/territory-trade-services-icon.png'),
                                            Spacer(),
                                            Padding(
                                                padding: EdgeInsets.all(7.0),
                                                child: Container(
                                                    constraints: BoxConstraints(
                                                      maxWidth: size.width - 130,
                                                    ),
                                                    child: SingleChildScrollView(
                                                        scrollDirection:
                                                        Axis.horizontal,
                                                        child: Text(
                                                            thisJob["details"]["Site"]
                                                            ["Name"],
                                                            style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 30))))),
                                            Spacer(),
                                          ])))),
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

  void saveNewNote(BuildContext context)  {
    String currentText = textController!.text;
    if(currentText.isNotEmpty && currentText.trim().length > 0){
      UserBloc user = BlocProvider.of<UserBloc>(context);
      UserState userState = user.state;
      JobDetailNote firstNote = JobDetailNote(userState.name + (DateFormat("dd/MM/yyyy").format(DateTime.now()) + " - Work Note"), JobDetailStyle.strong);
      JobDetailNote secondNote = JobDetailNote(currentText, JobDetailStyle.normal);
      List<JobDetailNote> notesToAdd = [firstNote, secondNote];
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
          thisStyle = TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18
          );
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

TextStyle defaultTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 18
);