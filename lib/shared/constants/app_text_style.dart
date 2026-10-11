import 'package:flutter/material.dart';

abstract class AppTextStyle {
  const AppTextStyle._();

  static const _defaultFont = TextStyle(
    fontWeight: FontWeight.w400,
    overflow: TextOverflow.ellipsis,
    color: Colors.black,
    fontFamily: 'Roboto',
  );

  static final _font10 = _defaultFont.copyWith(fontSize: 10);
  static final _font12 = _defaultFont.copyWith(fontSize: 12);
  static final _font14 = _defaultFont.copyWith(fontSize: 14);
  static final _font16 = _defaultFont.copyWith(fontSize: 16);
  static final _font18 = _defaultFont.copyWith(fontSize: 18);
  static final _font20 = _defaultFont.copyWith(fontSize: 20);
  static final _font24 = _defaultFont.copyWith(fontSize: 24);
  static final _font32 = _defaultFont.copyWith(fontSize: 32);
  static final _font36 = _defaultFont.copyWith(fontSize: 36);

  // 10
  static final font10Re = _font10.copyWith(
    fontWeight: FontWeight.w400,
  );
  static final font10Semi = _font10.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final font10Bo = _font10.copyWith(
    fontWeight: FontWeight.w700,
  );
  static final font10Ex = _font10.copyWith(
    fontWeight: FontWeight.w800,
  );

  // Des
  static final font12Re = _font12.copyWith(
    fontWeight: FontWeight.w400,
  );
  static final font12Semi = _font12.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final font12Bo = _font12.copyWith(
    fontWeight: FontWeight.w700,
  );
  static final font12Ex = _font12.copyWith(
    fontWeight: FontWeight.w800,
  );

  // Det
  static final font14Re = _font14.copyWith(
    fontWeight: FontWeight.w400,
  );
  static final font14Semi = _font14.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final font14Bo = _font14.copyWith(
    fontWeight: FontWeight.w700,
  );
  static final font14Ex = _font14.copyWith(
    fontWeight: FontWeight.w800,
  );

  // Body
  static final font16Re = _font16.copyWith(
    fontWeight: FontWeight.w400,
  );
  static final font16Semi = _font16.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final font16Bo = _font16.copyWith(
    fontWeight: FontWeight.w700,
  );
  static final font16Ex = _font16.copyWith(
    fontWeight: FontWeight.w800,
  );

  // Sub
  static final font18Re = _font18.copyWith(
    fontWeight: FontWeight.w400,
  );
  static final font18Semi = _font18.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final font18Bo = _font18.copyWith(
    fontWeight: FontWeight.w700,
  );
  static final font18Ex = _font18.copyWith(
    fontWeight: FontWeight.w800,
  );

  // Heading0
  static final font20Re = _font20.copyWith(
    fontWeight: FontWeight.w400,
  );
  static final font20Semi = _font20.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final font20Bo = _font20.copyWith(
    fontWeight: FontWeight.w700,
  );
  static final font20Ex = _font20.copyWith(
    fontWeight: FontWeight.w800,
  );

  // Heading1
  static final font24Re = _font24.copyWith(
    fontWeight: FontWeight.w400,
  );
  static final font24Semi = _font24.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final font24Bo = _font24.copyWith(
    fontWeight: FontWeight.w700,
  );
  static final font24Ex = _font24.copyWith(
    fontWeight: FontWeight.w800,
  );

  // Heading2
  static final font32Re = _font32.copyWith(
    fontWeight: FontWeight.w400,
  );
  static final font32Semi = _font32.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final font32Bo = _font32.copyWith(
    fontWeight: FontWeight.w700,
  );
  static final font32Ex = _font32.copyWith(
    fontWeight: FontWeight.w800,
  );

  // Heading3
  static final font36Re = _font36.copyWith(
    fontWeight: FontWeight.w400,
  );
  static final font36Semi = _font36.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final font36Bo = _font36.copyWith(
    fontWeight: FontWeight.w700,
  );
  static final font36Ex = _font36.copyWith(
    fontWeight: FontWeight.w800,
  );
}
