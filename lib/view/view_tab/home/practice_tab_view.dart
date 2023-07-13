import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/view_cell/practice/practice_history_cell.dart';
import 'package:migii_sat/view/view_cell/practice/practice_preparation_cell.dart';
import 'package:migii_sat/view/view_dialog/user_premium_dialog.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../model/home/home_screen_item.dart';
import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../view_cell/practice/practice_banner_top_1_cell.dart';
import '../../view_cell/practice/practice_banner_top_2_cell.dart';
import '../../view_cell/practice/practice_training_cell.dart';

// ignore: must_be_immutable
class PracticeTabView extends BasePage {
  Function(String tab) selectTabListener;

  PracticeTabView(this.selectTabListener, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PracticeTabView> {
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    Utils.trackerScreen("HomeScreen - Practice");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme(
          ColorHelper.colorBackgroundDay, ColorHelper.colorBackgroundNight),
      child: Stack(
        children: [
          if (Utils.isPortrait(context))
            Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  "bg_bottom_practice".withImage(),
                  width: double.infinity,
                  fit: BoxFit.contain,
                )),
          viewContainer(),
        ],
      ),
    );
  }

  Widget viewContainer() {
    final isPremium =
        context.select((AppProvider provider) => provider.isPremium);

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(children: [
        Container(
            width: double.infinity,
            height: preferenceHelper.appBarHeight +
                preferenceHelper.paddingInsetsTop,
            padding: EdgeInsets.only(top: preferenceHelper.paddingInsetsTop),
            decoration: BoxDecoration(
                color: ColorHelper.colorPrimary,
                boxShadow: kElevationToShadow[3]),
            child: Stack(children: [
              if (isPremium)
                GestureDetector(
                  onTap: () {
                    UserPremiumDialog.show(context);
                  },
                  child: Container(
                    width: preferenceHelper.appBarHeight,
                    height: double.infinity,
                    color: Colors.transparent,
                    padding: EdgeInsets.all(
                        preferenceHelper.appBarHeight / 2 - 11.0.dp()),
                    child: SvgPicture.asset(
                      "ic_premium_select".withIcon(),
                      color: Colors.white,
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  appLocalized().practice,
                  style:
                      UIFont.fontAppBold(18.0.sp(), ColorHelper.colorTextNight),
                ),
              )
            ])),
        Expanded(child: listViewItem())
      ]),
    );
  }

  Widget listViewItem() {
    return ScrollablePositionedList.builder(
        key: const PageStorageKey("PracticeTabView"),
        padding: EdgeInsets.only(top: 6.0.dp(), bottom: 24.0.dp()),
        itemScrollController: _itemScrollController,
        itemCount: 5,
        itemBuilder: (context, index) {
          return getItem(index);
        },
        shrinkWrap: true);
  }

  Widget getItem(int index) {
    switch (index) {
      case 0:
        return PracticeBannerTop1Cell(widget.selectTabListener);
      case 1:
        return PracticeTrainingCell(widget.selectTabListener);
      case 2:
        return PracticePreparationCell(context, widget.selectTabListener)
            .init();
      case 3:
        return PracticeBannerTop2Cell(widget.selectTabListener);
      case 4:
        return PracticeHistoryCell(_clickStartNow);
      default:
        return const Text("other");
    }
  }

  _clickStartNow(int type) {
    switch (type) {
      case 0:
        _itemScrollController.scrollTo(
            index: 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.linearToEaseOut);
        break;
      case 1:
        widget.selectTabListener(HomeScreenItem.routeExam);
        break;
    }
  }
}
