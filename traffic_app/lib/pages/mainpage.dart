import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/drawer.dart';
import '../pages/zoombuttons_plugin_option.dart';
import '../pages/current_location.dart';

class MainPage extends StatefulWidget {
  static const String route = 'polyline';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  // late Position _currentPosition;
  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;

  Set<Marker> markers = {};

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var markers = <Marker>[
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(9.032902334542289, 38.76340274677532),
        builder: (ctx) => Container(
            child: Icon(Icons.gps_fixed_outlined, color: Colors.green)),
      ),
      Marker(
          width: 80.0,
          height: 80.0,
          rotate: true,
          point: LatLng(9.040441993521377, 38.76207682720006),
          builder: (ctx) => Container(
                child: Icon(Icons.pin_drop, color: Colors.red),
              ),
          anchorPos: AnchorPos.align(AnchorAlign.center)),
    ];

    var points = <LatLng>[
      LatLng(9.032902334542289, 38.76340274677532),
      LatLng(9.040441993521377, 38.76207682720006),
    ];

    return Scaffold(
      // appBar: AppBar(title: Text('Traffic App')),
      drawer: buildDrawer(context, MainPage.route),
      floatingActionButton: CurrentLocation(mapController: mapController),
      body: Stack(
        children: <Widget>[
          Flexible(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: LatLng(9.032902334542289, 38.56340274677532),
                zoom: 15.0,
                plugins: [
                  ZoomButtonsPlugin(),
                ],
              ),
              nonRotatedLayers: [
                ZoomButtonsPluginOption(
                  minZoom: 2,
                  maxZoom: 30,
                  mini: true,
                  padding: 10,
                  alignment: Alignment.centerLeft,
                )
              ],
              layers: [
                TileLayerOptions(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c']),
                PolylineLayerOptions(
                  polylines: [
                    Polyline(
                        points: points, strokeWidth: 4.0, color: Colors.blue),
                  ],
                ),
                MarkerLayerOptions(markers: markers)
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 15,
            left: 15,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Places',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Start',
                              hint: 'Choose starting point',
                              prefixIcon: Icon(Icons.looks_one),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.my_location),
                                onPressed: () {
                                  startAddressController.text = _currentAddress;
                                  _startAddress = _currentAddress;
                                },
                              ),
                              controller: startAddressController,
                              focusNode: startAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _startAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Destination',
                              hint: 'Choose destination',
                              prefixIcon: Icon(Icons.looks_two),
                              controller: destinationAddressController,
                              focusNode: desrinationAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _destinationAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          Visibility(
                            visible: _placeDistance == null ? false : true,
                            child: Text(
                              'DISTANCE: $_placeDistance km',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: (_startAddress != '' &&
                                    _destinationAddress != '')
                                ? () async {
                                    print("succesfully here");
                                    startAddressFocusNode.unfocus();
                                    desrinationAddressFocusNode.unfocus();
                                    // setState(() {
                                    //   if (markers.isNotEmpty) markers.clear();
                                    //   if (polylines.isNotEmpty) polylines.clear();
                                    //   if (polylineCoordinates.isNotEmpty)
                                    //     polylineCoordinates.clear();
                                    //   _placeDistance = null;
                                    // });

                                    // _calculateDistance().then((isCalculated) {
                                    //   if (isCalculated) {
                                    //     ScaffoldMessenger.of(context)
                                    //         .showSnackBar(
                                    //       SnackBar(
                                    //         content: Text(
                                    //             'Distance Calculated Sucessfully'),
                                    //       ),
                                    //     );
                                    //   } else {
                                    //     ScaffoldMessenger.of(context)
                                    //         .showSnackBar(
                                    //       SnackBar(
                                    //         content: Text(
                                    //             'Error Calculating Distance'),
                                    //       ),
                                    //     );
                                    //   }
                                    // });
                                  }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Show Route'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // child: Container(
            //   color: Colors.white,
            //   child: Row(
            //     children: <Widget>[
            //       Builder(
            //           builder: (context) => // Ensure Scaffold is in context
            //               IconButton(
            //                   icon: Icon(Icons.menu),
            //                   onPressed: () =>
            //                       Scaffold.of(context).openDrawer())),
            //       Expanded(
            //         child: TextField(
            //           cursorColor: Colors.black,
            //           keyboardType: TextInputType.text,
            //           textInputAction: TextInputAction.go,
            //           decoration: InputDecoration(
            //               border: InputBorder.none,
            //               contentPadding: EdgeInsets.symmetric(horizontal: 15),
            //               hintText: "Search..."),
            //         ),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.only(right: 8.0),
            //         child: CircleAvatar(
            //           backgroundColor: Colors.deepPurple,
            //           child: Text('RD'),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}
