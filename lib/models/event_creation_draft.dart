import 'package:flutter/material.dart';

class EventCreationDraft {
  const EventCreationDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.capacity,
    required this.isOnline,
    required this.address,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.price,
    required this.isFree,
  });

  final String title;
  final String description;
  final String category;
  final int capacity;
  final bool isOnline;
  final String? address;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay startTime;
  final double price;
  final bool isFree;

  String get formattedStartDate {
    final day = startDate.day.toString().padLeft(2, '0');
    final month = startDate.month.toString().padLeft(2, '0');
    return '$day/$month/${startDate.year}';
  }
}
