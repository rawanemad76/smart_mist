import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mist_app/common_widgets/dropdown_list/select_road_drop_down_list.dart';
import 'package:mist_app/common_widgets/images/custom_images.dart';
import 'package:mist_app/common_widgets/images/default_background.dart';
import 'package:mist_app/common_widgets/loading.dart';
import 'package:mist_app/common_widgets/main_body.dart';
import 'package:mist_app/constants/sizes.dart';
import 'package:mist_app/location/map_shared_page.dart';
import 'package:mist_app/model/operations/user_operation.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  Widget build(BuildContext context) {
    // AdminOperations.addRoad(RoadDataModel.empty('cairo'));
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const DefaultBackground(),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                child: FutureBuilder(
                  future: UserOperations.getRoad(selectedRoadId!),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(snapshot.error.toString())));
                      return Container();
                    } else {
                      if (snapshot.hasData) {
                        return MainBody(
                          isOpen: snapshot.data!.isOpen,
                          notification: snapshot.data!.notification,
                          currentRoad: selectedRoad ?? "current road",
                          maxSpeed: snapshot.data!.maxSpeed.toString(),
                          recommendSpeed: snapshot.data!.recSpeed.toString(),
                          // accident
                          reports: snapshot.data!.reports,
                          // accidentImage: '',
                          onTapReport: (long, lat) {
                            if (long != 0 && lat != 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapShared(
                                    initialLocation: LatLng(lat, long),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('No location shared yet.')));
                            }
                          },

                          onTapNotification: () {},
                        );
                      } else {
                        return const Loading();
                      }
                    }
                  },
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        backgroundColor: Colors.white.withOpacity(0.2),
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Image(
          image: AssetImage(
            arrowBackImage,
          ),
          width: 75,
          height: 75,
        ),
      ),
    );
  }


}
