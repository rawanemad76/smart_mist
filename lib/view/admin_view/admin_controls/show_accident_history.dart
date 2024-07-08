import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mist_app/common_widgets/containers/custom_decoration.dart';
import 'package:mist_app/common_widgets/containers/item_count_helps_container.dart';
import 'package:mist_app/common_widgets/dropdown_list/select_road_drop_down_list.dart';
import 'package:mist_app/common_widgets/images/default_background.dart';
import 'package:mist_app/common_widgets/sizedbox10.dart';
import 'package:mist_app/common_widgets/sizedbox20.dart';
import 'package:mist_app/constants/colors.dart';
import 'package:mist_app/constants/fonts.dart';
import 'package:mist_app/constants/strings.dart';
import 'package:mist_app/model/operations/admin_operations.dart';
import 'package:mist_app/model/operations/data_models/counts_data_model.dart';
import 'package:mist_app/model/operations/data_models/report_data_model.dart';
import 'package:mist_app/my_flutter_app_icons.dart';

class ShowAccidentHistory extends StatelessWidget {
  const ShowAccidentHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const DefaultBackground(),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: FutureBuilder(
                  future: AdminOperations.getReportsForRoad(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final accidents =
                          snapshot.data!.map((e) => _buildAccident(e));
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            child: const Icon(
                              Icons.arrow_back_ios_sharp,
                              size: 15,
                            ),
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox20(),
                          Text(
                            selectedRoad!,
                            style: TextStyle(
                                fontSize: 36, fontFamily: fontFamily2),
                          ),
                          Text(
                            "Accident history",
                            style: TextStyle(
                                fontSize: 26, fontFamily: fontFamily2),
                          ),
                          const SizedBox(height: 20),
                          FutureBuilder<CountsDataModel>(
                            future: AdminOperations.getReportsCountsForRoad(),
                            builder: (BuildContext context,
                                AsyncSnapshot<CountsDataModel> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData) {
                                return const CircularProgressIndicator(
                                  color: ColorManager.primaryColor,
                                );
                              } else {
                                CountsDataModel countsData = snapshot.data!;
                                return ItemsCountHelpsContainer(
                                  name: "Accidents",
                                  totalCount: countsData.all,
                                  resolvedCount: countsData.solvedCount,
                                  unResolvedCount: countsData.notSolvedCount,
                                  iconName: const Icon(MyFlutterApp.road),
                                  iconPressed: const Icon(
                                    MyFlutterApp.group,
                                    size: 0,
                                  ),
                                );
                              }
                            },
                          ),
                          ...accidents,
                        ],
                      );
                    } else {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: ColorManager.primaryColor,
                      ));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildAccident(ReportDataMdoel report) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: CustomDecoration(
        height: 350,
        width: double.infinity,
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                            spreadRadius: 1,

                            //spreadRadius: 10,
                          ),
                        ]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: report.user!.picUrl == null
                          ? Image.asset("assets/images/profile image.jpg")
                          : Image.network(report.user!.picUrl!,
                              fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    '${report.user!.fname} ${report.user!.lname}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                dateFormatter.format(report.time),
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                report.details,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox10(),
              const Text(
                "NID",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                report.user!.nid!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox10(),
              const Text(
                "Email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                report.user!.email!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox10(),
              const Text(
                "Location",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // Text(
              //   'Address here',
              //   style: const TextStyle(fontSize: 16),
              // maxLines: 2,
              //   overflow: TextOverflow.ellipsis,
              // ),

              FutureBuilder(
                future:
                    getAddressFromLocation(report.latitude, report.longitude),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: const TextStyle(fontSize: 16),
                      );
                    } else {
                      return const Text(
                        'error loading location',
                        style: TextStyle(fontSize: 16),
                      );
                    }
                  } else {
                    return const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator());
                  }
                },
              ),
              // Text(
              //   'Longitude: ${report.longitude}',
              //   style: const TextStyle(fontSize: 16),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> getAddressFromLocation(double lat, double long) async {
    LatLng position = LatLng(lat, long);
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      String address =
          "${place.street}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}";

      return address;
    } catch (e) {
      return 'no location shared';
    }
  }
}
