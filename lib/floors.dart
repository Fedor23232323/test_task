import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Floors extends StatefulWidget {
  final String buildingName;
  final int floorCount;

  const Floors({
    required this.buildingName,
    required this.floorCount,
    Key? key,
  }) : super(key: key);

  @override
  State<Floors> createState() => _FloorsState();
}

class _FloorsState extends State<Floors> {
  List<String> floorList = [];
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  int currentFloor = 1;
  int selectedFloorIndex = -1;


  @override
  void initState() {
    super.initState();
    _loadFloors();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  Future<void> _loadFloors() async {
    List<String> floors =
        List.generate(widget.floorCount, (index) => (index + 1).toString());

    setState(() {
      floorList = floors;
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    await _createNotificationChannelForAndroid();
  }

  Future<void> _createNotificationChannelForAndroid() async {
    AndroidNotificationChannel androidNotificationChannel =
        const AndroidNotificationChannel(
      'channel_id',
      'Default Notification Channel Name',
      'Default Notification Channel Description',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  Future<void> _showNotification(String floor) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'channel_id',
      'Default Notification Channel Name',
      'Default Notification Channel Description',
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notification Title',
      'You have reached floor $floor',
      platformChannelSpecifics,
    );
  }

  Future<void> _simulateElevatorMovement(int destinationFloor) async {
    while (currentFloor != destinationFloor) {
      await Future.delayed(const Duration(seconds: 3));

      await _showNotification(currentFloor.toString());
      _showSnackBar('Arrived at floor $currentFloor');
      setState(() {
        if (currentFloor < destinationFloor) {
          currentFloor++;
        } else {
          currentFloor--;
        }
      });
    }

    await _showNotification(destinationFloor.toString());
    _showSnackBar('Arrived at floor $destinationFloor');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(230, 230, 230, 1),
        leading: const SizedBox.shrink(),
        toolbarHeight: 90,
        flexibleSpace: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 35.0, top: 100),
              child: Text(
                'Floors ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Divider(
                color: Colors.black,
                thickness: 1,
              ),
            )
          ],
        ),
        elevation: 0,
      ),
      body: ColoredBox(
        color: const Color.fromRGBO(230, 230, 230, 1),
        child: Stack(
          children: [
            ListView.builder(
              itemCount: floorList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 66, vertical: 15),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        selectedFloorIndex = index;
                      });

                      int destinationFloor = int.parse(floorList[index]);
                      await _simulateElevatorMovement(destinationFloor);
                    },
                    child: Container(
                      height: 40,
                      width: 228,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black),
                        color: currentFloor == int.parse(floorList[index])
                            ? Color.fromRGBO(59, 134, 66, 1)
                            : selectedFloorIndex == index
                            ? Color.fromRGBO(202, 195, 22, 1)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Floor ${floorList[index]}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            Positioned(
              left: 21,
              bottom: 0,
              child: Container(
                color: const Color.fromRGBO(230, 230, 230, 1),
                width: double.maxFinite,
                padding: const EdgeInsets.only(top: 10, bottom: 22),
                child: const Text(
                  'desinged by ...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
