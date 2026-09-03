import 'package:flutter/material.dart';

class RideOption {
  final String name;
  final String description;
  final String eta;
  final String price;
  final IconData icon;

  const RideOption({
    required this.name,
    required this.description,
    required this.eta,
    required this.price,
    required this.icon,
  });
}

/// Fixed ride types + fares. Edit freely — no API involved.
const List<RideOption> rideOptions = [
  RideOption(
    name: 'Bike',
    description: 'Quick & affordable',
    eta: '3 min',
    price: '₹49',
    icon: Icons.two_wheeler,
  ),
  RideOption(
    name: 'Auto',
    description: 'Fits up to 3',
    eta: '5 min',
    price: '₹89',
    icon: Icons.electric_rickshaw,
  ),
  RideOption(
    name: 'Cab Mini',
    description: 'AC, fits up to 4',
    eta: '7 min',
    price: '₹149',
    icon: Icons.directions_car,
  ),
  RideOption(
    name: 'Cab Prime',
    description: 'Premium sedan',
    eta: '8 min',
    price: '₹229',
    icon: Icons.local_taxi,
  ),
];
