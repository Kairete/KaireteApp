import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kairete/features/register/navigator/register_navigator.dart';
import 'package:kairete/features/register/usecase/register_usecase.dart';

import '../../../components/kairete_popup.dart';

class RegisterController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  RegisterNavigator navigator = IRegisterNavigator();
  ResgiterUsecase usecase = IResgiterUsecase();

  var errorName = ''.obs;
  var errorEmail = ''.obs;
  var errorPass = ''.obs;
  var errorDob = ''.obs;

  DateTime? selectedDate;

  void toDatePicker() async {
    final date = await showDatePicker(
        context: Get.context!,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (date != null) {
      selectedDate = date;
      String formattedDate = DateFormat('dd/MM/yyyy').format(date);
      dobController.text = formattedDate;
    }
  }

  void onRegister() async {
    if (validateData()) {
      final body = {
        'username': nameController.text,
        'password': passController.text,
        'email': emailController.text,
        'dob[day]': selectedDate?.day,
        'dob[month]': selectedDate?.month,
        'dob[year]': selectedDate?.year,
      };
      final json = await usecase.register(body: body);
      if (json != null) {
        showKairetePopup(
          onTapDone: () {
            navigator.toLogin();
          },
          content: 'Register successfuly',
        );
      }
    }
  }

  void toLogin() {
    final data = {'email': emailController.text};
    navigator.toLogin(data: data);
  }

  bool validateData() {
    if (nameController.text.isEmpty) {
      errorName.value = 'required';
      return false;
    } else if (passController.text.isEmpty) {
      errorPass.value = 'required';
      return false;
    } else if (emailController.text.isEmpty) {
      errorPass.value = 'required';
      return false;
    } else if (dobController.text.isEmpty) {
      errorPass.value = 'required';
      return false;
    }
    return true;
  }
}
