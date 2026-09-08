import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../caregiver/find_caregiver_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await _authService.fetchProfile();
    if (mounted) setState(() => _user = user);
  }

  bool get _isCaregiver => _user?.role == UserRole.caregiver;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: _user == null ? null : _openEditSheet,
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.secondary,
                    child: Icon(Icons.person, color: AppColors.white, size: 44),
                  ),
                  SizedBox(height: 12),
                  Text(_user?.fullName ?? '',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text(
                    _isCaregiver
                        ? (_user?.caregiverRelation ?? 'Caregiver')
                        : '${_user?.age ?? '--'} Years • ${_user?.gender ?? '--'}',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: _isCaregiver
                      ? [
                          _infoRow('Experience', _user?.experience ?? '--'),
                          Divider(),
                          _infoRow('Relation / Care Type', _user?.caregiverRelation ?? '--'),
                          Divider(),
                          _infoRow('Remuneration', _user?.remuneration ?? '--'),
                          Divider(),
                          _infoRow('Phone Number', _user?.phone ?? '--'),
                          Divider(),
                          _infoRow('Email', _user?.email ?? '--'),
                        ]
                      : [
                          _infoRow('Blood Group', _user?.bloodGroup ?? '--'),
                          Divider(),
                          _infoRow('Medical Condition', _user?.medicalCondition ?? '--'),
                          Divider(),
                          _infoRow('Phone Number', _user?.phone ?? '--'),
                          Divider(),
                          _infoRow('Email', _user?.email ?? '--'),
                        ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isCaregiver) ...[
              _menuTile(Icons.settings_outlined, 'Settings',
                  () => Navigator.of(context).pushNamed(AppRoutes.settings)),
            ] else ...[
              _menuTile(Icons.favorite_border, 'Find a Caregiver',
                  () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FindCaregiverScreen()))),
              _menuTile(Icons.people_outline, 'Emergency Contacts',
                  () => Navigator.of(context).pushNamed(AppRoutes.emergencyContacts)),
              _menuTile(Icons.insights_outlined, 'Health Analytics',
                  () => Navigator.of(context).pushNamed(AppRoutes.healthAnalytics)),
              _menuTile(Icons.favorite_outline, 'Health Records',
                  () => Navigator.of(context).pushNamed(AppRoutes.healthRecords)),
              _menuTile(Icons.settings_outlined, 'Settings',
                  () => Navigator.of(context).pushNamed(AppRoutes.settings)),
            ],
            _menuTile(Icons.logout, 'Logout', () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            }, color: AppColors.danger),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.grey)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(label, style: TextStyle(color: color)),
        trailing: Icon(Icons.chevron_right, color: AppColors.grey),
        onTap: onTap,
      ),
    );
  }

  void _openEditSheet() {
    final user = _user!;
    if (_isCaregiver) {
      _openCaregiverEditSheet(user);
    } else {
      _openElderEditSheet(user);
    }
  }

  void _openCaregiverEditSheet(AppUser user) {
    final experience = TextEditingController(text: user.experience ?? '');
    final relation = TextEditingController(text: user.caregiverRelation ?? '');
    final remuneration = TextEditingController(text: user.remuneration ?? '');
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Caregiver Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 16),
                CustomTextField(
                  label: 'Experience',
                  hint: 'e.g. 3 years',
                  controller: experience,
                  icon: Icons.work_history_outlined,
                ),
                CustomTextField(
                  label: 'Relation / Care Type',
                  hint: 'e.g. Home Nurse, Companion, Physiotherapist',
                  controller: relation,
                  icon: Icons.family_restroom,
                ),
                CustomTextField(
                  label: 'Remuneration',
                  hint: 'e.g. ৳15,000/month',
                  controller: remuneration,
                  icon: Icons.payments_outlined,
                ),
                SizedBox(height: 8),
                PrimaryButton(
                  label: 'Save',
                  loading: saving,
                  onPressed: () async {
                    setModalState(() => saving = true);
                    try {
                      final updated = user.copyWith(
                        experience:
                            experience.text.trim().isEmpty ? null : experience.text.trim(),
                        caregiverRelation:
                            relation.text.trim().isEmpty ? null : relation.text.trim(),
                        remuneration:
                            remuneration.text.trim().isEmpty ? null : remuneration.text.trim(),
                      );
                      await _authService.updateProfile(updated);
                      if (mounted) Navigator.pop(context);
                      _load();
                    } catch (e) {
                      setModalState(() => saving = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Could not save: $e'),
                              backgroundColor: AppColors.danger),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openElderEditSheet(AppUser user) {
    final age = TextEditingController(text: user.age?.toString() ?? '');
    String? bloodGroup = user.bloodGroup;
    final medicalCondition = TextEditingController(text: user.medicalCondition ?? '');
    bool saving = false;
    const bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Health Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 16),
                CustomTextField(
                  label: 'Age',
                  hint: 'e.g. 68',
                  controller: age,
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                ),
                Text('Blood Group',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: bloodGroup != null && bloodGroups.contains(bloodGroup)
                          ? bloodGroup
                          : null,
                      hint: Text('Select blood group'),
                      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
                      items: bloodGroups
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setModalState(() => bloodGroup = v),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                CustomTextField(
                  label: 'Medical Condition',
                  hint: 'e.g. Hypertension, Diabetes',
                  controller: medicalCondition,
                  icon: Icons.medical_information_outlined,
                ),
                SizedBox(height: 8),
                PrimaryButton(
                  label: 'Save',
                  loading: saving,
                  onPressed: () async {
                    setModalState(() => saving = true);
                    try {
                      final updated = user.copyWith(
                        age: int.tryParse(age.text.trim()),
                        bloodGroup: bloodGroup,
                        medicalCondition: medicalCondition.text.trim().isEmpty
                            ? null
                            : medicalCondition.text.trim(),
                      );
                      await _authService.updateProfile(updated);
                      if (mounted) Navigator.pop(context);
                      _load();
                    } catch (e) {
                      setModalState(() => saving = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Could not save: $e'),
                              backgroundColor: AppColors.danger),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
