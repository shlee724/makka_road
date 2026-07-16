import 'package:flutter/material.dart';

// 100만 이상: 진한 빨강 / 10만 이상: 진한 주황 / 그 미만: 검정.
Color viewCountColor(int viewCount) {
  if (viewCount >= 1000000) return Colors.red[700]!;
  if (viewCount >= 100000) return Colors.orange[900]!;
  return Colors.black;
}

String viewCountLabel(int viewCount) {
  if (viewCount >= 10000) {
    return '조회수 ${viewCount ~/ 10000}만회';
  }
  return '조회수 ${_withThousandsComma(viewCount)}회';
}

String _withThousandsComma(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    if (i != 0 && remaining % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
