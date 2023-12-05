import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'database_helper.dart';
import 'floors.dart';

class House extends StatefulWidget {
  const House({Key? key}) : super(key: key);

  @override
  State<House> createState() => _HouseState();
}

class _HouseState extends State<House> {
  List<String> itemList = [];
  late TextEditingController _buildingNameController;
  late TextEditingController _floorCountController;

  @override
  void initState() {
    super.initState();
    _buildingNameController = TextEditingController();
    _floorCountController = TextEditingController();
    _loadBuildings();
  }

  Future<void> _loadBuildings() async {
    List<Map<String, dynamic>> buildings =
        await DatabaseHelper.instance.getAllBuildings();
    setState(() {
      itemList = buildings.map((building) {
        String name = building['name'];
        if (name.isEmpty) {
          return 'writed name';
        } else {
          return name;
        }
      }).toList();
    });
  }

  Future<void> _deleteBuilding(String buildingName) async {
    await DatabaseHelper.instance.deleteBuilding(buildingName);
    _loadBuildings();
  }

  Future<void> _showInputDialog(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.black),
            ),
            contentPadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.maxFinite,
                  height: 50,
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          'Add House',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 4,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.close,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                _DialogItem(
                  textEditingController: _buildingNameController,
                  title: 'Name',
                ),
                const SizedBox(height: 16),
                _DialogItem(
                  textEditingController: _floorCountController,
                  isCountField: true,
                  title: 'Floors count',
                ),
              ],
            ),
            actions: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 29.0, right: 21, bottom: 10),
                child: GeneralButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    setState(() {
                      itemList.add(
                          'writed name ${_floorCountController.text} floor(s)');
                    });

                    await DatabaseHelper.instance.insertBuilding({
                      'name': _buildingNameController.text,
                      'floors': _floorCountController.text,
                    });

                    _buildingNameController.clear();
                    _floorCountController.clear();
                    _loadBuildings();
                  },
                  title: 'Add',
                  buttomWidth: 98,
                  buttomHeight: 24,
                  fontSize: 14,
                  backgroundColor: const Color.fromRGBO(230, 230, 230, 1),
                ),
              )
            ],
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(230, 230, 230, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(230, 230, 230, 1),
        leading: const SizedBox.shrink(),
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 66.0, vertical: 28),
        child: ListView.separated(
          itemCount: itemList.length + 1,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 20),
          itemBuilder: (context, index) {
            if (index == 0) {
              return GeneralButton(
                onPressed: () => _showInputDialog(context),
                title: 'Add house',
                isAdittionalButton: true,
              );
            }

            return GestureDetector(
              onTap: () async {
                List<Map<String, dynamic>> buildings =
                    await DatabaseHelper.instance.getAllBuildings();

                Map<String, dynamic> selectedBuilding = buildings[index - 1];
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Floors(
                        buildingName: selectedBuilding['name'],
                        floorCount: selectedBuilding['floors'],
                      ),
                    ),
                  );
                }
              },
              child: Slidable(
                key: UniqueKey(),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  dismissible: DismissiblePane(onDismissed: () {
                    _deleteBuilding(itemList[index - 1]);
                  }),
                  children: [
                    SlidableAction(
                      onPressed: (doNothing) {},
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 9.0, top: 11, bottom: 10),
                        child: Text(
                          'House',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 36,
                        height: 36,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 12.0, bottom: 9, right: 40),
                        child: Text(itemList[index - 1],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GeneralButton extends StatelessWidget {
  const GeneralButton({
    required this.onPressed,
    required this.title,
    this.isAdittionalButton = false,
    this.buttomWidth,
    this.buttomHeight,
    this.fontSize,
    this.backgroundColor,
    super.key,
  });

  final bool isAdittionalButton;
  final String title;
  final VoidCallback onPressed;
  final double? buttomWidth;
  final double? buttomHeight;
  final double? fontSize;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(buttomWidth ?? 0, buttomHeight ?? 40),
        minimumSize: Size.zero,
        padding: EdgeInsets.only(right: isAdittionalButton ? 22 : 0),
        backgroundColor:
            backgroundColor ?? const Color.fromRGBO(255, 255, 255, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: fontSize ?? 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (isAdittionalButton)
            const Icon(
              Icons.add,
              color: Colors.black,
              size: 35,
            ),
        ],
      ),
    );
  }
}

class _DialogItem extends StatelessWidget {
  const _DialogItem({
    required this.textEditingController,
    required this.title,
    this.isCountField = false,
  });

  final TextEditingController textEditingController;
  final String title;
  final bool isCountField;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Flexible(
            child: SizedBox(
              width: isCountField ? 37 : null,
              child: TextField(
                keyboardType: isCountField ? TextInputType.number : null,
                controller: textEditingController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(2),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Color.fromRGBO(231, 230, 230, 1),
                  isDense: true,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
