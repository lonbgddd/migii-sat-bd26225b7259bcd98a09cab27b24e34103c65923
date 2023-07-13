import 'package:flutter/material.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/view_custom/item_setting_download.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../model/home/training_section_json_object.dart';
import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';

class DownloadManage extends BasePage {
  DownloadManage({super.key, this.onTap});

  Function()? onTap;

  @override
  BasePageState<DownloadManage> createState() => _DownloadManageState();
}

class _DownloadManageState extends BasePageState<DownloadManage> {
  late String _languageApp;
  late bool _isNightMode;

  @override
  Widget build(BuildContext context) {
    _languageApp =
        context.select((AppProvider provider) => provider.languageApp);
    _isNightMode =
        context.select((AppProvider provider) => provider.isNightMode);

    // if (sectionsList.isNullOrEmpty) {
    //   return const SizedBox(width: double.infinity, height: 0);
    // }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          context.select((AppProvider bloc) => bloc.isDownload) != 0
              ? Stack(
                  fit: StackFit.loose,
                  alignment: AlignmentDirectional.center,
                  children: [
                    const CircularProgressIndicator(
                        color: ColorHelper.colorYellow),
                    Text(context.select(
                        (AppProvider bloc) => bloc.isDownload.toString()))
                  ],
                )
              : const SizedBox(),
          SizedBox(
            width: 20.0.dp(),
          )
        ],
        backgroundColor: ColorHelper.colorPrimary,
        title: Text(appLocalized().download_manage),
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.only(left: 10.0.dp(), right: 10.0.dp(), top: 20.0.dp()),
        physics: const ScrollPhysics(),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final section in sectionsList!) ...{_trainingView(section)}
        ]),
      ),
    );
  }

  Widget _trainingView(TrainingSectionJSONObject sectionItem) {
    final kinds = sectionItem.kinds;
    return SizedBox(
      width: double.infinity,
      child: Wrap(spacing: 0, runSpacing: 0, children: [
        for (final kind in kinds!) ...[
          ItemDownLoad(
            kind,
          )
        ]
      ]),
    );
  }
}
