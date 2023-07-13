import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';

Widget latexText(List<LatexItem> latexList, TextStyle style) {
  return Text.rich(
    TextSpan(
      children: [
        for (final latexItem in latexList) ...{
          latexItem.isLatex
              ? WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child:
                  latexItem.text.contains("{cases}")
                      ? Math.tex(
                          latexItem.text
                              .substring(1, latexItem.text.length - 1).replaceAll("\n", "\\\\"),
                          textStyle: style,
                        )
                      :
                  latexBreak(
                          latexItem.text
                              .substring(1, latexItem.text.length - 1),
                          style,
                        ),
                )
              : (latexItem.text.contains(RegExp("<.*?>"))
                  ? WidgetSpan(
                      child: Html(
                      data:
                          "<span>${latexItem.text.replaceAll("\n", "<br>").addDomainInText()}</span>",
                      style: {
                        "span": UIFont.htmlFontApp(
                            style.fontSize ?? 1, style.color ?? Colors.white)
                      },
                    ))
                  : TextSpan(
                      text: latexItem.text.clearLatex,
                      style: style,
                    ))
        }
      ],
    ),
  );
}

Widget latexBreak(String text, TextStyle style) {
  final longEq = Math.tex(text, textStyle: style);
  final breakResult = longEq.texBreak();
  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: breakResult.parts,
  );
}

class LatexItem {
  String text;
  bool isLatex;

  LatexItem(this.text, {this.isLatex = false});
}
