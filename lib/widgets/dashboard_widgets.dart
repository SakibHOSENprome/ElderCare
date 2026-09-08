import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/medicine.dart';

/// Small colored stat card used on Dashboard & Health Analytics
/// e.g. BP 120/80, Sugar 98, Weight 65kg, Pulse 72bpm
class VitalStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color background;
  final Color valueColor;

  const VitalStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.background,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.dark)),
          SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: valueColor)),
          Text(unit, style: TextStyle(fontSize: 11, color: AppColors.grey)),
        ],
      ),
    );
  }
}

/// Green-tinted summary tile e.g. "Today's Medicines 3/3 Scheduled"
class SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const SummaryTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            SizedBox(height: 10),
            Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 12, color: AppColors.dark)),
          ],
        ),
      ),
    );
  }
}

/// A medicine row used on the Medicines list screen.
class MedicineTile extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onMore;

  const MedicineTile({super.key, required this.medicine, this.onMore});

  Color get _pillColor {
    switch (medicine.status) {
      case MedicineStatus.taken:
        return AppColors.accentGreen;
      case MedicineStatus.pending:
        return AppColors.warning;
      case MedicineStatus.upcoming:
        return AppColors.primary;
    }
  }

  String get _pillLabel {
    switch (medicine.status) {
      case MedicineStatus.taken:
        return 'Taken';
      case MedicineStatus.pending:
        return 'Pending';
      case MedicineStatus.upcoming:
        return 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.medication_rounded, color: AppColors.primary),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medicine.name,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('${medicine.dosage} • ${medicine.time} • ${medicine.frequency}',
                      style: TextStyle(fontSize: 12, color: AppColors.grey)),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _pillColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_pillLabel,
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600, color: _pillColor)),
                ),
                if (onMore != null)
                  IconButton(
                    icon: Icon(Icons.more_vert, size: 18, color: AppColors.grey),
                    onPressed: onMore,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
