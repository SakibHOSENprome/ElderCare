import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/medicine_service.dart';
import '../../models/medicine.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddMedicineScreen extends StatefulWidget {
  final String? elderId;
  const AddMedicineScreen({super.key, this.elderId});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _authService = AuthService();
  final _medicineService = MedicineService();

  String _frequency = 'Daily';
  TimeOfDay _time = TimeOfDay(hour: 8, minute: 0);
  String _repeat = 'Everyday';
  bool _reminder = true;
  bool _saving = false;

  final _frequencies = ['Daily', 'Twice Daily', 'Weekly', 'As Needed'];
  final _repeats = ['Everyday', 'Weekdays', 'Weekends', 'Custom'];

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _dosage.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final uid = widget.elderId ?? _authService.currentAuthUser?.id;
      if (uid == null) throw Exception('You are not logged in.');
      final medicine = Medicine(
        id: '',
        userId: uid,
        name: _name.text.trim(),
        dosage: _dosage.text.trim(),
        frequency: _frequency,
        time: _time.format(context),
        reminder: _reminder,
        status: MedicineStatus.upcoming,
        createdAt: DateTime.now(),
      );
      await _medicineService.add(medicine);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save medicine: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Add Medicine')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            CustomTextField(
              label: 'Medicine Name',
              hint: 'Enter medicine name',
              controller: _name,
              icon: Icons.medication_outlined,
            ),
            CustomTextField(
              label: 'Dosage',
              hint: 'Enter dosage',
              controller: _dosage,
              icon: Icons.science_outlined,
            ),
            Text('Frequency',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            _dropdown(_frequency, _frequencies, (v) => setState(() => _frequency = v!)),
            SizedBox(height: 16),
            Text('Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            InkWell(
              onTap: _pickTime,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: AppColors.grey, size: 20),
                    SizedBox(width: 10),
                    Text(_time.format(context)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Repeat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            _dropdown(_repeat, _repeats, (v) => setState(() => _repeat = v!)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reminder',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Switch(
                  value: _reminder,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _reminder = v),
                ),
              ],
            ),
            SizedBox(height: 24),
            PrimaryButton(label: 'Save Medicine', onPressed: _save, loading: _saving),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
