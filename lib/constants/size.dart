import 'package:flutter/material.dart';
import 'package:get/get.dart';

double kBottomSafea = MediaQuery.of(Get.context!).padding.bottom > 0
    ? MediaQuery.of(Get.context!).padding.bottom
    : 24;
