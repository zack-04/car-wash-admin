import 'dart:io';

import 'package:car_wash/common/utils/constants.dart';
import 'package:car_wash/common/widgets/buttonWidget.dart';
import 'package:car_wash/common/widgets/textFieldWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AdminTextField extends StatefulWidget {
  const AdminTextField({super.key});

  @override
  _AdminTextFieldState createState() => _AdminTextFieldState();
}

class _AdminTextFieldState extends State<AdminTextField> {
  final TextEditingController adminController = TextEditingController();
  final TextEditingController phone1Controller = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  File? imageFile;

  Future<void> _pickImage(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppTemplate.bgClr,
          content: Text(
            "Image Uploaded Successfully",
            style: GoogleFonts.inter(
                color: AppTemplate.primaryClr, fontWeight: FontWeight.w400),
          )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppTemplate.bgClr,
          content: Text(
            "Image is Required",
            style: GoogleFonts.inter(
                color: AppTemplate.primaryClr, fontWeight: FontWeight.w400),
          )));
    }
  }

  Future<void> createAdmin(BuildContext context) async {
    if (adminController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTemplate.bgClr,
        content: Text(
          'Please Enter Admin Name',
          style: GoogleFonts.inter(
              color: AppTemplate.primaryClr, fontWeight: FontWeight.w400),
        ),
      ));
      return;
    }
    if (phone1Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTemplate.bgClr,
        content: Text(
          'Please Enter Mobile Number',
          style: GoogleFonts.inter(
              color: AppTemplate.primaryClr, fontWeight: FontWeight.w400),
        ),
      ));
      return;
    }
    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTemplate.bgClr,
        content: Text(
          'Please Enter Password',
          style: GoogleFonts.inter(
              color: AppTemplate.primaryClr, fontWeight: FontWeight.w400),
        ),
      ));
      return;
    }

    var request = http.MultipartRequest('POST',
        Uri.parse('https://wash.sortbe.com/API/Admin/User/Employee-Creation'));
    request.fields.addAll({
      'enc_key': encKey,
      'emp_id': '123',
      'emp_name': adminController.text,
      'phone_1': phone1Controller.text,
      'phone_2': '',
      'password': passwordController.text,
      'role': 'Admin'
    });

    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('emp_photo', imageFile!.path));
    }

    http.StreamedResponse response = await request.send();
    String responseString = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppTemplate.bgClr,
          content: Text(
            'Admin created Successfully',
            style: GoogleFonts.inter(
                color: AppTemplate.primaryClr, fontWeight: FontWeight.w400),
          )));
      // Navigator.pop(context);
      print(responseString);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppTemplate.bgClr,
          content: Text(
            'Admin creation Failed',
            style: GoogleFonts.inter(
                color: AppTemplate.primaryClr, fontWeight: FontWeight.w400),
          )));
      print(response.reasonPhrase);
    }
  }

  @override
  void dispose() {
    adminController.dispose();
    phone1Controller.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Textfieldwidget(
            controller: adminController,
            labelTxt: 'Admin Name',
            labelTxtClr: const Color(0xFF929292),
            enabledBorderClr: const Color(0xFFD4D4D4),
            focusedBorderClr: const Color(0xFFD4D4D4),
          ),
        ),
        SizedBox(height: 30.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Textfieldwidget(
            controller: phone1Controller,
            labelTxt: 'Phone 1',
            labelTxtClr: const Color(0xFF929292),
            enabledBorderClr: const Color(0xFFD4D4D4),
            focusedBorderClr: const Color(0xFFD4D4D4),
          ),
        ),
        SizedBox(height: 30.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Textfieldwidget(
            controller: passwordController,
            labelTxt: 'Password',
            labelTxtClr: const Color(0xFF929292),
            enabledBorderClr: const Color(0xFFD4D4D4),
            focusedBorderClr: const Color(0xFFD4D4D4),
          ),
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Text(
            'Admin Photo',
            style: GoogleFonts.inter(
              color: AppTemplate.textClr,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  _pickImage(context);
                },
                child: Container(
                  width: 120.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: AppTemplate.primaryClr,
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(color: const Color(0xFFCCC3E5)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTemplate.enabledBorderClr,
                        offset: Offset(2.w, 4.h),
                        blurRadius: 4.r,
                      ),
                    ],
                  ),
                  child: imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(5.r),
                          child: Image.file(
                            imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5.r),
                              child: Image.asset(
                                'assets/images/Camera.png',
                                height: 45.w,
                                width: double.infinity,
                              ),
                            ),
                            Text(
                              'Upload Photo',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: const Color(0xFF6750A4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Buttonwidget(
              width: 227.w,
              height: 50.h,
              buttonClr: const Color(0xFf1E3763),
              txt: 'Create',
              textClr: AppTemplate.primaryClr,
              textSz: 18.sp,
              onClick: () async {
                await createAdmin(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}
