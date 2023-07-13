import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HighlightText extends StatelessWidget {
  String text;
  TextStyle? style;
  List<SpanItem>? spanList;
  TextStyle? spanStyle;
  TextAlign textAlign;

  HighlightText(
      {this.text = "",
      this.style,
      this.spanList,
      this.spanStyle,
      this.textAlign = TextAlign.start,
      super.key});

  @override
  Widget build(BuildContext context) {
    var separatorList = [text];
    if (spanList != null && spanList!.isNotEmpty) {
      for (final spanItem in spanList!) {
        for (var i = 0; i < separatorList.length; i++) {
          if (separatorList[i].contains("(((")) continue;
          if (separatorList[i].contains(spanItem.text)) {
            separatorList[i] = separatorList[i]
                .replaceFirst(spanItem.text, "(((${spanItem.text})))");
            break;
          }
        }

        List<String> newSeparatorList = [];
        for (final separatorItem in separatorList) {
          if (!separatorItem.contains("(((")) {
            newSeparatorList.add(separatorItem);
            continue;
          }

          var text = separatorItem;
          var index1 = separatorItem.indexOf("(((");

          if (index1 > 0) {
            newSeparatorList.add(text.substring(0, index1));
            text = text.substring(index1);
          }

          var index2 = text.indexOf(")))") + 3;
          if (index2 < text.length) {
            newSeparatorList.add(text.substring(0, index2));
            text = text.substring(index2);
          } else {
            newSeparatorList.add(text);
            text = "";
          }

          if (text.isNotEmpty) newSeparatorList.add(text);
        }
        separatorList = newSeparatorList;
      }
    }

    List<SpanItem> spanItems = [];
    for (final separatorItem in separatorList) {
      if (!separatorItem.contains("(((")) {
        spanItems.add(SpanItem(text: separatorItem, isDefault: true));
        continue;
      }
      final textReplace =
          separatorItem.replaceFirst("(((", "").replaceFirst(")))", "");

      if (spanList != null && spanList!.isNotEmpty) {
        for (final spanItem in spanList!) {
          if (spanItem.text == textReplace) {
            spanItems.add(spanItem);
            break;
          }
        }
      }
    }

    return RichText(
        textAlign: textAlign,
        text: TextSpan(style: style, children: [
          for (final spanItem in spanItems) ...[
            if (spanItem.isDefault) ...[
              TextSpan(text: spanItem.text)
            ] else ...[
              TextSpan(
                  text: spanItem.text,
                  style: spanStyle,
                  recognizer: spanItem.onTap != null
                      ? (TapGestureRecognizer()
                        ..onTap = () {
                          spanItem.onTap!();
                        })
                      : null)
            ]
          ]
        ]));
  }
}

class SpanItem {
  String text;
  VoidCallback? onTap;
  bool isDefault;

  SpanItem({this.text = "", this.onTap, this.isDefault = false});
}
