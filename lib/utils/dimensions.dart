// lib/utils/dimension.dart

import 'package:flutter/material.dart';

/// App-wide dimensions and spacing constants
class Dimens {
  // ---------- SPACING ----------
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space18 = 18.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space36 = 36.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;
  static const double space72 = 72.0;
  static const double space80 = 80.0;
  static const double space96 = 96.0;

  // ---------- PADDING (EDGE INSETS) ----------
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: space16);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: space16);
  static const EdgeInsets paddingAll = EdgeInsets.all(space16);
  static const EdgeInsets paddingSmall = EdgeInsets.all(space8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(space16);
  static const EdgeInsets paddingLarge = EdgeInsets.all(space24);

  static const EdgeInsets paddingLeft = EdgeInsets.only(left: space16);
  static const EdgeInsets paddingRight = EdgeInsets.only(right: space16);
  static const EdgeInsets paddingTop = EdgeInsets.only(top: space16);
  static const EdgeInsets paddingBottom = EdgeInsets.only(bottom: space16);

  // ---------- MARGIN ----------
  static const EdgeInsets marginHorizontal = EdgeInsets.symmetric(horizontal: space16);
  static const EdgeInsets marginVertical = EdgeInsets.symmetric(vertical: space16);
  static const EdgeInsets marginAll = EdgeInsets.all(space16);
  static const EdgeInsets marginSmall = EdgeInsets.all(space8);
  static const EdgeInsets marginMedium = EdgeInsets.all(space16);
  static const EdgeInsets marginLarge = EdgeInsets.all(space24);

  // ---------- BORDER RADIUS ----------
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 100.0;

  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(radiusXL));
  static const BorderRadius borderRadiusXXL = BorderRadius.all(Radius.circular(radiusXXL));
  static const BorderRadius borderRadiusCircular = BorderRadius.all(Radius.circular(radiusCircular));

  // ---------- BUTTON ----------
  static const double buttonHeight = 48.0;
  static const double buttonMinWidth = 200.0;
  static const double buttonElevation = 2.0;
  static const double buttonBorderRadius = radiusLarge;

  // ---------- TEXT FIELD ----------
  static const double textFieldHeight = 48.0;
  static const double textFieldBorderRadius = radiusLarge;
  static const double textFieldContentPaddingHorizontal = space16;
  static const double textFieldContentPaddingVertical = space14;

  // ---------- ICON ----------
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeXXL = 48.0;

  // ---------- IMAGE / AVATAR ----------
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double avatarSizeXL = 96.0;

  // ---------- CARD ----------
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = radiusMedium;
  static const EdgeInsets cardPadding = EdgeInsets.all(space12);

  // ---------- DIVIDER ----------
  static const double dividerThickness = 1.0;

  // ---------- APP BAR ----------
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;

  // ---------- BOTTOM NAVIGATION ----------
  static const double bottomNavBarHeight = 60.0;

  // ---------- DIALOG ----------
  static const double dialogBorderRadius = radiusLarge;
  static const EdgeInsets dialogPadding = EdgeInsets.all(space24);

  // ---------- SCREEN PADDING (DEFAULT) ----------
  static const EdgeInsets screenPadding = EdgeInsets.all(space16);

  // ---------- FONT SIZES ----------
  static const double fontCaption = 12.0;
  static const double fontSmall = 14.0;
  static const double fontBody = 16.0;
  static const double fontSubhead = 18.0;
  static const double fontTitle = 20.0;
  static const double fontHeadline = 24.0;
  static const double fontDisplay = 32.0;

  // ---------- RESPONSIVE BREAKPOINTS ----------
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // ---------- RESPONSIVE HELPER ----------
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;
}