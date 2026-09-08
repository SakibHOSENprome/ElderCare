import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../services/auth_service.dart';
import '../../services/medicine_service.dart';
import '../../models/app_user.dart';
import '../../models/medicine.dart';
import '../../widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _medicineService = MedicineService();

  AppUser? _user;
  List<Medicine> _medicines = [];
  bool _loading = true;
  String? _error;

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
      final user = await _authService.fetchProfile();
      final uid = _authService.currentAuthUser?.id;
      final meds = uid != null ? await _medicineService.fetchAll(uid) : <Medicine>[];
      setState(() {
        _user = user;
        _medicines = meds;
      });
    } catch (e) {
      setState(() => _error = 'Could not load your dashboard: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _takenCount => _medicines.where((m) => m.status == MedicineStatus.taken).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello ${_user?.fullName.split(' ').first ?? ''} 👋',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.dark)),
                      Text('Good Morning', style: TextStyle(color: AppColors.grey)),
                    ],
                  ),
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.surface, shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cardBorder)),
                        child: Icon(Icons.notifications_outlined, color: AppColors.dark),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                              color: AppColors.danger, shape: BoxShape.circle),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.5,
                children: [
                  SummaryTile(
                    title: "Today's Medicines\n$_takenCount/${_medicines.length} Scheduled",
                    value: '${_medicines.length}',
                    icon: Icons.medication_rounded,
                    color: AppColors.primary,
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.medicines),
                  ),
                  SummaryTile(
                    title: 'Upcoming Appointment',
                    value: 'Next',
                    icon: Icons.event_available_rounded,
                    color: AppColors.accentGreen,
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.appointments),
                  ),
                  SummaryTile(
                    title: 'Health Summary\nView your latest health overview',
                    value: '❤',
                    icon: Icons.favorite_rounded,
                    color: AppColors.danger,
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.healthAnalytics),
                  ),
                  SummaryTile(
                    title: 'Emergency SOS\nGet help instantly',
                    value: 'SOS',
                    icon: Icons.sos_rounded,
                    color: AppColors.danger,
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.sos),
                  ),
                ],
              ),
              SizedBox(height: 28),
              Text('Recent Activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 12),
              if (_loading)
                Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ))
              else if (_error != null)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
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
              else if (_medicines.isEmpty)
                Text('No recent activity yet.', style: TextStyle(color: AppColors.grey))
              else
                ..._medicines.take(3).map((m) => MedicineTile(medicine: m)),
            ],
          ),
        ),
      ),
    );
  }
}
