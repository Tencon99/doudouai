import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:doudouai/utils/color.dart';

SpanNodeGeneratorWithTag inlineCodeGenerator =
    SpanNodeGeneratorWithTag(tag: _code, generator: (e, config, visitor) => InlineCodeNode(e.attributes, e.textContent, config));

const _code = 'code';

class InlineCodeNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;
  final MarkdownConfig config;
  InlineCodeNode(this.attributes, this.textContent, this.config);

  @override
  InlineSpan build() {
    return WidgetSpan(
      child: Builder(
        builder: (context) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
          decoration: BoxDecoration(
            color: AppColors.getThemeColor(
              context,
              lightColor: AppColors.grey[200],
              darkColor: AppColors.grey[800],
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            textContent,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: config.p.textStyle.fontSize,
              color: config.p.textStyle.color ?? AppColors.getThemeTextColor(context),
            ),
          ),
        ),
      ),
    );
  }
}
