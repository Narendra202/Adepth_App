
import 'package:location/location.dart';
import 'package:location_platform_interface/location_platform_interface.dart';

class LocationService{


  Future getLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }

  bool isLatLngValid(latitude, longitude) {
    const double minLatitude = -90.0;
    const double maxLatitude = 90.0;
    const double minLongitude = -180.0;
    const double maxLongitude = 180.0;

    if (latitude < minLatitude ||
        latitude > maxLatitude ||
        longitude < minLongitude ||
        longitude > maxLongitude) {
      return false;
    }

    return true;
  }
}