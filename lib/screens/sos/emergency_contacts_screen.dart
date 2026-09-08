import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/emergency_service.dart';
import '../../models/emergency_contact.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EmergencyContactsScreen extends StatefulWidget {
  final String? elderId;
  final String? elderName;
  const EmergencyContactsScreen({super.key, this.elderId, this.elderName});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final _authService = AuthService();
  final _emergencyService = EmergencyService();
  List<EmergencyContact> _contacts = [];
  bool _loading = true;
  String? _error;

  String? get _uid => widget.elderId ?? _authService.currentAuthUser?.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uid = _uid;
      if (uid == null) {
        _error = 'You are not logged in.';
      } else {
        _contacts = await _emergencyService.fetchContacts(uid);
      }
    } catch (e) {
      _error = 'Could not load contacts: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _deleteContact(EmergencyContact c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${c.name}?'),
        content: Text('This contact will no longer be called or messaged during an SOS alert.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _emergencyService.deleteContact(c.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.elderName != null
            ? "${widget.elderName}'s Emergency Contacts"
            : 'Emergency Contacts'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _openAddSheet),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.danger)),
                          SizedBox(height: 12),
                          TextButton(onPressed: _load, child: Text('Retry')),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    Card(
                      color: AppColors.danger.withOpacity(0.08),
                      child: ListTile(
                        leading: Icon(Icons.local_hospital, color: AppColors.danger),
                        title: Text('Call Ambulance',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.danger)),
                        subtitle: Text('999'),
                        onTap: () => _call('999'),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_contacts.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                            'No emergency contacts added yet. Tap + to add someone who should '
                            'be called and texted when you press SOS.',
                            style: TextStyle(color: AppColors.grey)),
                      )
                    else
                      ..._contacts.map((c) => Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.secondary,
                                    child: Icon(Icons.person, color: AppColors.white),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.name,
                                            style: TextStyle(fontWeight: FontWeight.w600)),
                                        SizedBox(height: 2),
                                        Text('${c.relation} • ${c.phone}',
                                            style: TextStyle(
                                                fontSize: 13, color: AppColors.grey)),
                                        if (c.email != null && c.email!.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 2),
                                            child: Text(c.email!,
                                                style: TextStyle(
                                                    fontSize: 12, color: AppColors.grey)),
                                          ),
                                        if (c.address != null && c.address!.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 2),
                                            child: Text(c.address!,
                                                style: TextStyle(
                                                    fontSize: 12, color: AppColors.grey)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.call, color: AppColors.primary),
                                    onPressed: () => _call(c.phone),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: AppColors.grey),
                                    onPressed: () => _deleteContact(c),
                                  ),
                                ],
                              ),
                            ),
                          )),
                  ],
                ),
              ),
      ),
    );
  }

  void _openAddSheet() {
    final name = TextEditingController();
    final relation = TextEditingController();
    final phone = TextEditingController();
    final email = TextEditingController();
    final address = TextEditingController();
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
                Text('Add Emergency Contact',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 16),
                CustomTextField(
                    label: "Contact's Name", hint: 'Full name', controller: name, icon: Icons.person_outline),
                CustomTextField(
                    label: 'Relation with Elder',
                    hint: 'Mother, Brother, Doctor...',
                    controller: relation,
                    icon: Icons.family_restroom),
                CustomTextField(
                    label: 'Phone Number',
                    hint: '01XXX-XXXXXX',
                    controller: phone,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                CustomTextField(
                    label: 'Email',
                    hint: 'name@example.com',
                    controller: email,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                CustomTextField(
                    label: 'Address',
                    hint: 'House, Road, City',
                    controller: address,
                    icon: Icons.location_on_outlined),
                SizedBox(height: 8),
                PrimaryButton(
                  label: 'Save Contact',
                  loading: saving,
                  onPressed: () async {
                    if (name.text.trim().isEmpty || phone.text.trim().isEmpty) return;
                    setModalState(() => saving = true);
                    try {
                      final uid = _uid;
                      if (uid == null) throw Exception('You are not logged in.');
                      await _emergencyService.addContact(EmergencyContact(
                        id: '',
                        userId: uid,
                        name: name.text.trim(),
                        relation: relation.text.trim(),
                        phone: phone.text.trim(),
                        email: email.text.trim().isEmpty ? null : email.text.trim(),
                        address: address.text.trim().isEmpty ? null : address.text.trim(),
                      ));
                      if (mounted) Navigator.pop(context);
                      _load();
                    } catch (e) {
                      setModalState(() => saving = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Could not save contact: $e'),
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
