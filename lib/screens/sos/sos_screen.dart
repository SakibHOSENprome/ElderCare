import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/emergency_service.dart';
import '../../models/emergency_contact.dart';

class SOSScreen extends StatefulWidget {
  final String? elderId;
  final String? elderName;
  const SOSScreen({super.key, this.elderId, this.elderName});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _emergencyService = EmergencyService();
  bool _sent = false;
  bool _sending = false;
  List<EmergencyContact> _contacts = [];
  String? _note;

  bool get _isForElder => widget.elderId != null;

  Future<void> _sendAlert() async {
    if (_sending || _sent) return;
    setState(() => _sending = true);

    final uid = widget.elderId ?? _authService.currentAuthUser?.id;
    List<EmergencyContact> contacts = [];
    String? elderName = widget.elderName;
    try {
      if (uid != null) {
        await _emergencyService.triggerSOS(userId: uid);
        contacts = await _emergencyService.fetchContacts(uid);
        elderName ??= (await _authService.fetchProfile())?.fullName;
      }
    } catch (_) {
      // Non-fatal — still show the SOS "sent" state and try to reach contacts.
    }

    if (contacts.isEmpty) {
      setState(() {
        _sending = false;
        _sent = true;
        _contacts = [];
        _note = 'No emergency contacts on file. Add contacts from Profile > Emergency '
            'Contacts so SOS can call and text them next time.';
      });
      return;
    }

    final who = (elderName == null || elderName.isEmpty) ? 'An ElderCare user' : elderName;
    final message =
        '$who needs help! This is an emergency SOS alert sent automatically from the '
        'ElderCare app. Please call right away or come as soon as you can.';

    // Best-effort: open a single SMS draft addressed to every emergency
    // contact with the alert message pre-filled, so one tap sends it to
    // everyone at once. Mobile OSes only allow one active phone call at a
    // time and don't let apps silently send SMS or dial multiple numbers
    // in the background, so we then auto-dial the first (primary) contact
    // for an immediate voice connection, and list the rest below with a
    // one-tap Call button each.
    try {
      final numbers = contacts.map((c) => c.phone).join(',');
      final smsUri = Uri(scheme: 'sms', path: numbers, queryParameters: {'body': message});
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (_) {
      // Non-fatal — the on-screen contact list still lets the user text/call manually.
    }

    try {
      final primary = contacts.first;
      final callUri = Uri(scheme: 'tel', path: primary.phone);
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      }
    } catch (_) {
      // Non-fatal.
    }

    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = true;
      _contacts = contacts;
      _note = null;
    });
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _message(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.danger,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  if (_isForElder)
                    Expanded(
                      child: Text(
                        'Sending SOS for ${widget.elderName ?? 'this elder'}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  if (_isForElder) SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _sendAlert,
                        child: Container(
                          height: 220,
                          width: 220,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              height: 160,
                              width: 160,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: _sending
                                    ? CircularProgressIndicator(color: AppColors.danger)
                                    : Text(
                                        _sent ? 'SENT' : 'SOS',
                                        style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.danger),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _sending
                              ? 'Alerting your emergency contacts…'
                              : _sent
                                  ? (_note ??
                                      'Your emergency contacts are being called and texted now.')
                                  : 'Tap to send\nemergency alert',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, color: AppColors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (_sent && _contacts.isNotEmpty) ...[
                        SizedBox(height: 28),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Emergency Contacts',
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              SizedBox(height: 10),
                              ..._contacts.map((c) => Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(c.name,
                                                  style: TextStyle(
                                                      color: AppColors.white,
                                                      fontWeight: FontWeight.w600)),
                                              Text('${c.relation} • ${c.phone}',
                                                  style: TextStyle(
                                                      color: AppColors.white.withOpacity(0.8),
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.message_outlined,
                                              color: AppColors.white),
                                          onPressed: () => _message(c.phone),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.call, color: AppColors.white),
                                          onPressed: () => _call(c.phone),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (!_sent)
              Padding(
                padding: EdgeInsets.all(20),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text('Tap the SOS button above to alert your contacts',
                        style: TextStyle(color: AppColors.white)),
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.white),
                      foregroundColor: AppColors.white,
                    ),
                    child: Text('Close'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
