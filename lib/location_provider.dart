import 'package:flutter/material.dart';
import 'models/location.dart';

class LocationProvider extends ChangeNotifier {
  PlaceLocation _location;

  LocationProvider({required PlaceLocation initialLocation}) : _location = initialLocation;

  PlaceLocation get location => _location;

  void updateLocation(PlaceLocation newLocation) {
    _location = newLocation;
    notifyListeners(); // Notify listeners that the data has changed
  }
}