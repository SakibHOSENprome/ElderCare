import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/caregiver_service.dart';
import 'caregiver_dashboard_screen.dart';

/// Caregiver-side screen: every elder currently assigned to this caregiver.
/// Tapping an elder opens their info (medicines, next appointment, latest
/// vitals) via [CaregiverDashboardScreen].
class MyEldersScreen extends StatefulWidget {
  const MyEldersScreen({super.key});

  @override
  State<MyEldersScreen> createState() => _MyEldersScreenState();
}

class _MyEldersScreenState extends State<MyEldersScreen> {
  final _authService = AuthService();
  final _caregiverService = CaregiverService();

  List<AppUser> _elders = [];
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
      final uid = _authService.currentAuthUser?.id;
      if (uid == null) {
        _error = 'You are not logged in.';
      } else {
        _elders = await _caregiverService.fetchAssignedElders(uid);
      }
    } catch (e) {
      _error = 'Could not load your elders: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('My Elders')),
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
                    child: _elders.isEmpty
                        ? ListView(children: [
                            Padding(
                              padding: EdgeInsets.only(top: 60),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                      "No elders have assigned you yet. Once an elder assigns "
                                      "you as their caregiver from their app, they'll show up here.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.grey)),
                                ),
                              ),
                            )
                          ])
                        : ListView.builder(
                            padding: EdgeInsets.all(20),
                            itemCount: _elders.length,
                            itemBuilder: (context, i) => _elderCard(_elders[i]),
                          ),
                  ),
      ),
    );
  }

  Widget _elderCard(AppUser elder) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.secondary,
          child: Icon(Icons.person, color: AppColors.white),
        ),
        title: Text(elder.fullName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(
          '${elder.age ?? '--'} Years${elder.bloodGroup != null ? ' • ${elder.bloodGroup}' : ''}',
          style: TextStyle(color: AppColors.grey, fontSize: 13),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.grey),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CaregiverDashboardScreen(elderId: elder.id)),
        ),
      ),
    );
  }
}
