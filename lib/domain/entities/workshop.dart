import 'package:flutter/material.dart';

class Workshop {
  const Workshop(this.id, this.name, this.english, this.icon, this.color, this.tagline);

  final String id;
  final String name;
  final String english;
  final IconData icon;
  final Color color;
  final String tagline;
}

const workshops = [
  Workshop('carpentry', 'النجارة', 'Carpentry', Icons.carpenter, Color(0xFF8D5A35), 'خشب يروي قصة بيتك'),
  Workshop('blacksmith', 'الحدادة', 'Blacksmithing', Icons.local_fire_department, Color(0xFF37474F), 'قوة تصنع التفاصيل'),
  Workshop('aluminum', 'الألمنيوم', 'Aluminum', Icons.window, Color(0xFF357A8C), 'دقة وعزل يدومان'),
];
