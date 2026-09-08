import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Help & Support')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Card(
              color: AppColors.primary.withOpacity(0.08),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: AppColors.primary, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About ElderCare',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text(
                            'ElderCare helps elders and their caregivers stay on top of '
                            'medicines, appointments, health records and emergencies — all '
                            'in one simple, easy-to-read app.',
                            style: TextStyle(fontSize: 13, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('What you can do in the app',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            _featureTile(
              Icons.home_rounded,
              'Home / Dashboard',
              "Your daily snapshot — today's medicines, upcoming appointments and quick "
                  'access to every part of the app in one place.',
            ),
            _featureTile(
              Icons.medication_rounded,
              'Medicines',
              'Keep a list of medicines with dosage, frequency, time and repeat schedule, '
                  'and turn reminders on so nothing is missed.',
            ),
            _featureTile(
              Icons.calendar_today_rounded,
              'Appointments',
              'Save upcoming doctor visits with date, time and location. Once an '
                  "appointment's date has passed it automatically moves to the Past tab, "
                  'where you can attach a prescription link for that visit.',
            ),
            _featureTile(
              Icons.favorite_outline,
              'Health Records & Analytics',
              'Log vitals like blood pressure, sugar, weight and pulse, and view trends '
                  'over time to spot changes early.',
            ),
            _featureTile(
              Icons.sos_rounded,
              'Emergency SOS',
              'One tap on the red SOS button alerts every saved emergency contact — it '
                  'opens a text message pre-filled to all of them and calls your primary '
                  'contact right away, with one-tap call/text buttons for everyone else.',
            ),
            _featureTile(
              Icons.people_outline,
              'Emergency Contacts',
              "Add the people who should be reached in an emergency, with each contact's "
                  'relation, phone number, email and address.',
            ),
            _featureTile(
              Icons.person_outline,
              'Profile',
              'View and edit personal health details — age, blood group and medical '
                  'condition — alongside your contact information.',
            ),
            _featureTile(
              Icons.groups_outlined,
              'Caregiver Mode',
              "If you're a caregiver, switch into an elder's dashboard to check in on "
                  'their medicines, appointments and health at a glance.',
            ),
            _featureTile(
              Icons.settings_outlined,
              'Settings',
              'Turn Dark Mode and notifications on or off, and adjust text size for '
                  'easier reading from here.',
            ),
            SizedBox(height: 20),
            Text('Need more help?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'If something in the app isn\u2019t working the way you expect, ask your '
                  'caregiver or a family member for help, or reach out to whoever set up '
                  'this app for you.',
                  style: TextStyle(fontSize: 13, color: AppColors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureTile(IconData icon, String title, String description) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  SizedBox(height: 4),
                  Text(description,
                      style: TextStyle(fontSize: 12.5, color: AppColors.grey, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
