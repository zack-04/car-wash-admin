import 'dart:io';

import 'package:car_wash/common/utils/constants.dart';
import 'package:car_wash/common/widgets/buttonWidget.dart';
import 'package:car_wash/common/widgets/header.dart';
import 'package:car_wash/common/widgets/textFieldWidget.dart';
import 'package:car_wash/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as perm_handler;

class EditCustomer extends ConsumerStatefulWidget {
  const EditCustomer({super.key});

  @override
  _EditCustomerState createState() => _EditCustomerState();
}

class _EditCustomerState extends ConsumerState<EditCustomer> {
  final TextEditingController customerController =
      TextEditingController(text: 'Abinanthan');
  TextEditingController mobileController =
      TextEditingController(text: "9826355263");
  final List<TextEditingController> carModelNameControllers = [
    TextEditingController(text: 'Verna'),
  ];
  final List<TextEditingController> carNoControllers = [
    TextEditingController(text: 'TN 45 Ak 3658'),
  ];
  final ScrollController _scrollController = ScrollController();
  File? imageFile;
  double lat = 0.0;
  double long = 0.0;
  @override
  void initState() {
    super.initState();
    carModelNameControllers.add(TextEditingController());
    carNoControllers.add(TextEditingController());
  }

  void _addNewCard() {
    carModelNameControllers.add(TextEditingController());
    carNoControllers.add(TextEditingController());
    ref.read(customerCardProvider.notifier).addCard();
    _scrollToBottom();
  }

  void _removeCard(int index) {
    if (carModelNameControllers.length > 1) {
      carModelNameControllers[index].dispose();
      carNoControllers[index].dispose();
      carModelNameControllers.removeAt(index);
      carNoControllers.removeAt(index);
      ref.read(customerCardProvider.notifier).removeCard(index);
      _scrollUp();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppTemplate.bgClr,
          content: Text(
            "At least one car must be present",
            style: GoogleFonts.inter(
                color: AppTemplate.primaryClr, fontWeight: FontWeight.w400),
          )));
    }
  }

  // @override
  // void dispose() {
  //   _scrollController.dispose();
  //   carModelNameControllers.forEach((controller) => controller.dispose());
  //   carNoControllers.forEach((controller) => controller.dispose());
  //   super.dispose();
  // }

  // Future<void> creatCustomer() async {
  //   if (lat == null || long == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content:
  //             Text("Please fetch the location before creating the customer")));
  //     return;
  //   }

  //   List<Map<String, dynamic>> carInfoList = [];
  //   for (int i = 0; i < carModelNameControllers.length; i++) {
  //     carInfoList.add({
  //       'model_name': carModelNameControllers[i].text,
  //       'vehicle_no': carNoControllers[i].text,
  //       'lat': lat.toString(),
  //       'long': long.toString(),
  //     });
  //   }

  //   var request = http.MultipartRequest('POST',
  //       Uri.parse('https://wash.sortbe.com/API/Admin/Client/Client-Creation'));
  //   request.fields.addAll({
  //     'enc_key': encKey,
  //     'emp_id': '123',
  //     'client_name': customerController.text,
  //     'mobile': mobileController.text,
  //     'car_info': carInfoList.toString(),
  //   });

  //   http.StreamedResponse response = await request.send();

  //   if (response.statusCode == 200) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text("Employee Account Created Successfully")));
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollUp() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.pixels - 150.h,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  Future<void> _requestPermissions() async {
    var status = await perm_handler.Permission.locationWhenInUse.status;
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      if (await perm_handler.Permission.locationWhenInUse.request().isGranted) {
        print('Location permission granted');
      } else {
        print('Location permission denied');
      }
    } else if (status.isGranted) {
      print('Location permission already granted');
    }
  }

  Future<void> _getLocation(BuildContext context) async {
    bool serviceEnabled;
    perm_handler.PermissionStatus permissionGranted;
    Position position;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      if (!await Geolocator.isLocationServiceEnabled()) {
        return;
      }
    }

    permissionGranted = await perm_handler.Permission.locationWhenInUse.status;
    if (permissionGranted == perm_handler.PermissionStatus.denied) {
      permissionGranted =
          await perm_handler.Permission.locationWhenInUse.request();
      if (permissionGranted != perm_handler.PermissionStatus.granted) {
        _showPermissionDeniedDialog(context);
        return;
      }
    }

    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    ref.read(locationProvider.notifier).updateLocation(position);
    print(
        'Current location: Lat: ${position.latitude}, Long: ${position.longitude}');
    setState(() {
      lat = position.latitude;
      long = position.longitude;
    });

    _showLocationDialog(context, position.latitude, position.longitude);
  }

  void _showLocationDialog(
      BuildContext context, double latitude, double longitude) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Location Retrieved',
            style: GoogleFonts.inter(
                color: AppTemplate.textClr,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Your Live location is stored.',
            style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppTemplate.textClr,
                fontWeight: FontWeight.w500),
          ),
          // Text('Lat: $latitude, Long: $longitude'),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFf1E3763)),
                child: Text(
                  'OK',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Location Permission Required',
            style: GoogleFonts.inter(
                color: AppTemplate.textClr,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Please grant location permission to use this feature.',
            style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppTemplate.textClr,
                fontWeight: FontWeight.w500),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFf1E3763)),
              child: Text(
                'OK',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    print('_pickImage called');
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      print('Picked image path: ${pickedFile.path}');
      setState(() {
        imageFile = file;
      });
    } else {
      print('No image picked');
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerCards = ref.watch(customerCardProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTemplate.primaryClr,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(txt: 'Create Customer'),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Text(
                'Customer Creation',
                style: GoogleFonts.inter(
                  color: AppTemplate.textClr,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Textfieldwidget(
                controller: customerController,
                labelTxt: 'Customer Name',
                labelTxtClr: const Color(0xFF929292),
                enabledBorderClr: const Color(0xFFD4D4D4),
                focusedBorderClr: const Color(0xFFD4D4D4),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Textfieldwidget(
                controller: mobileController,
                labelTxt: 'Mobile Number',
                labelTxtClr: const Color(0xFF929292),
                enabledBorderClr: const Color(0xFFD4D4D4),
                focusedBorderClr: const Color(0xFFD4D4D4),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Text(
                'Car Listing',
                style: GoogleFonts.inter(
                  color: AppTemplate.textClr,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: customerCards.isEmpty ? 1 : customerCards.length + 1,
                itemBuilder: (context, index) {
                  print('Building CreateCustomerCard widget at index $index');
                  return Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.w, vertical: 10.h),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTemplate.primaryClr,
                              borderRadius: BorderRadius.circular(5.r),
                              border:
                                  Border.all(color: const Color(0xFFD4D4D4)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4D4D4),
                                  blurRadius: 4.r,
                                  spreadRadius: 2.r,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25.w, vertical: 25.h),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Textfieldwidget(
                                    controller: carModelNameControllers[index],
                                    labelTxt: 'Car Model',
                                    labelTxtClr: const Color(0xFF929292),
                                    enabledBorderClr: const Color(0xFFD4D4D4),
                                    focusedBorderClr: const Color(0xFFD4D4D4),
                                  ),
                                  SizedBox(height: 25.h),
                                  Textfieldwidget(
                                    controller: carNoControllers[index],
                                    labelTxt: 'Vehicle No',
                                    labelTxtClr: const Color(0xFF929292),
                                    enabledBorderClr: const Color(0xFFD4D4D4),
                                    focusedBorderClr: const Color(0xFFD4D4D4),
                                  ),
                                  SizedBox(height: 25.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () => _pickImage(context),
                                        child: Container(
                                          width: 120.w,
                                          height: 80.h,
                                          decoration: BoxDecoration(
                                            color: AppTemplate.primaryClr,
                                            borderRadius:
                                                BorderRadius.circular(5.r),
                                            border: Border.all(
                                              color: const Color(0xFFCCC3E5),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTemplate
                                                    .enabledBorderClr,
                                                offset: Offset(2.w, 4.h),
                                                blurRadius: 4.r,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              imageFile != null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.r),
                                                      child: Image.file(
                                                        imageFile!,
                                                        height: 78.h,
                                                        width: 120.w,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : Image.asset(
                                                      'assets/images/bmw.jpeg',
                                                      height: 78.h,
                                                      // width: 120.w,
                                                      fit: BoxFit.cover,
                                                    ),
                                              // if (imageFile == null)
                                              //   Text(
                                              //     'Car Picture',
                                              //     style: GoogleFonts.inter(
                                              //       fontSize: 12.sp,
                                              //       color:
                                              //           const Color(0xFF6750A4),
                                              //       fontWeight: FontWeight.w600,
                                              //     ),
                                              //   ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              await _requestPermissions();
                                              await _getLocation(context);
                                            },
                                            child: Container(
                                              height: 80.h,
                                              width: 120.w,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppTemplate
                                                        .enabledBorderClr,
                                                    offset: Offset(2.w, 4.h),
                                                    blurRadius: 4.r,
                                                    spreadRadius: 2.r,
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5.r),
                                                child: const Image(
                                                  image: AssetImage(
                                                      'assets/images/map.jpeg'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 20.h,
                                            left: 37.w,
                                            child: Image(
                                              image: const AssetImage(
                                                  'assets/images/Map pin.png'),
                                              height: 45.w,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (index != 0)
                        Positioned(
                          right: 10.w,
                          top: -5.h,
                          child: GestureDetector(
                            onTap: () => _removeCard(index),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTemplate.enabledBorderClr,
                                    offset: Offset(0.w, 4.h),
                                    blurRadius: 4.r,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: AppTemplate.primaryClr,
                                radius: 15.r,
                                child: SvgPicture.asset(
                                    'assets/svg/red_close.svg'),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 69.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(
                        color: const Color(0xFf1E3763),
                        width: 1.5.w,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: const Color(0xFf1E3763),
                        size: 40.w,
                      ),
                      onPressed: _addNewCard,
                    ),
                  ),
                  Buttonwidget(
                    width: 227.w,
                    height: 50.h,
                    buttonClr: const Color(0xFf1E3763),
                    txt: 'Update',
                    textClr: AppTemplate.primaryClr,
                    textSz: 18.sp,
                    onClick: () async {
                      // await creatCustomer();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
