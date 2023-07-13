import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/hive_helper.dart';
import 'package:migii_sat/viewmodel/helper/provider/app_provider.dart';
import 'package:provider/provider.dart';

import '../../model/home/training_section_json_object.dart';
import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/dio/dio_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';

class ItemDownLoad extends BasePage {
  const ItemDownLoad(this.kindItem, {super.key});

  final TrainingSectionKind kindItem;

  @override
  BasePageState<ItemDownLoad> createState() => _ItemDownLoadState();
}

class _ItemDownLoadState extends BasePageState<ItemDownLoad> {
  final widthItem = (preferenceHelper.widthScreen - 20.0.dp()) / 1;
  final isListIdKind = [];
  StateDownload stateDownload = StateDownload.normal;

  getDataAndSave() async {
    try {
      setState(() {
        stateDownload = StateDownload.loading;
      });
      context.read<AppProvider>().setIcriDownload();

      final data = await DioHelper().getToSaveQuestion(isListIdKind);
      await HiveHelper.putData(isListIdKind.toString(), jsonEncode(data));
      context.read<AppProvider>().setDecDownload();
      setState(() {
        stateDownload = StateDownload.delete;
      });
    } catch (e) {
      setState(() {
        stateDownload = StateDownload.err;
      });
      context.read<AppProvider>().setDecDownload();
      throw Exception(e);
    }
  }

  deleteData() {
    setState(() {
      HiveHelper.deleteData("$isListIdKind");
      stateDownload = StateDownload.normal;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (TrainingSectionTheme lisKind in widget.kindItem.themes ?? []) {
      for (String idKind in lisKind.idKindList ?? []) {
        isListIdKind.add(idKind);
      }
    }
    log(isListIdKind.toString());
    final data = HiveHelper.getData("$isListIdKind");
    if (data != null) {
      stateDownload = StateDownload.delete;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0.dp(),
      margin: EdgeInsets.all(6.0.dp()),
      color: stateDownload == StateDownload.delete
          ? Colors.white60
          : theme(ColorHelper.colorBackgroundChildDay,
              ColorHelper.colorBackgroundChildNight),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0.dp())),
      child: SizedBox(
        width: widthItem - 12.0.dp(),
        height: (widthItem - 50.0.dp()) / 4,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SvgPicture.asset(
                (widget.kindItem.icon ?? "").withIcon(),
                width: (widthItem - 30.0.dp()) / 6,
                height: (widthItem - 30.0.dp()) / 6,
              ),
            ),
            Expanded(
                flex: 2,
                child: Text(
                  widget.kindItem.name ?? "",
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 16),
                )),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (stateDownload == StateDownload.loading)
                    const CircularProgressIndicator(),
                  if (stateDownload == StateDownload.delete)
                    IconButton(
                        onPressed: () {
                          deleteData();
                        },
                        icon: const Icon(Icons.delete_forever)),
                  if (stateDownload == StateDownload.normal)
                    TextButton(
                        onPressed: () async {
                          getDataAndSave();
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            elevation: 2,
                            backgroundColor: ColorHelper.colorPrimary),
                        child: const Text(
                          'Tải xuống',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        )),
                  if (stateDownload == StateDownload.err) const Text('Err'),
                ],
              ),
            ),
            SizedBox(
              width: (widthItem - 140.dp()) / 10,
            )
          ],
        ),
      ),
    );
  }
}

enum StateDownload { loading, normal, delete, err }
