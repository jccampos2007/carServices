import 'package:flutter/material.dart';

IconData getIconData(String iconName) {
  switch (iconName) {
    case 'oil_change':
      return Icons.oil_barrel;
    case 'tire_rotation':
      return Icons.swap_horiz;
    case 'air_filter':
      return Icons.air;
    case 'brakes':
      return Icons.car_crash;
    case 'coolant':
      return Icons.water_drop;
    default:
      return Icons.settings;
  }
}
