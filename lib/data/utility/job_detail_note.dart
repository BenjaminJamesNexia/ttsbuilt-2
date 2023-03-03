class JobDetailNote {
  String text;
  JobDetailStyle style;

  JobDetailNote(this.text, this.style);

  String getJobDetailToAppend() {
    switch (style) {
      case JobDetailStyle.normal:
        {
          return "<div style=\"font-size: 10pt;\">" + text + "</div>";
        }
      case JobDetailStyle.strong:
        {
          return "<div style=\"font-size: 10pt;\"><strong>" +
              text +
              "</strong></div>";
        }
      default:
        {
          return "<div style=\"font-size: 10pt;\">" + text + "</div>";
        }
    }
  }
}

enum JobDetailStyle { strong, normal }
