import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/app_user.dart';
import '../../models/caregiver_assignment.dart';
import '../../services/auth_service.dart';
import '../../services/caregiver_service.dart';

/// Elder-side screen: browse every registered caregiver (name, experience,
/// relation/care type, remuneration) and assign one or more of them.
class FindCaregiverScreen extends StatefulWidget {
  const FindCaregiverScreen({super.key});

  @override
  State<FindCaregiverScreen> createState() => _FindCaregiverScreenState();
}

class _FindCaregiverScreenState extends State<FindCaregiverScreen> {
  final _authService = AuthService();
  final _caregiverService = CaregiverService();

  List<AppUser> _caregivers = [];
  Map<String, CaregiverAssignment> _assignments = {};
  bool _loading = true;
  String? _error;
  final Set<String> _busy = {};

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
        _caregivers = await _caregiverService.fetchAllCaregivers();
        _assignments = await _caregiverService.fetchAssignmentsForElder(uid);
      }
    } catch (e) {
      _error = 'Could not load caregivers: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleAssign(AppUser caregiver) async {
    final uid = _authService.currentAuthUser?.id;
    if (uid == null) return;
    setState(() => _busy.add(caregiver.id));
    try {
      final existing = _assignments[caregiver.id];
      if (existing != null) {
        await _caregiverService.unassignCaregiver(existing.id);
      } else {
        await _caregiverService.assignCaregiver(elderId: uid, caregiverId: caregiver.id);
      }
      _assignments = await _caregiverService.fetchAssignmentsForElder(uid);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update assignment: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(caregiver.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Find a Caregiver')),
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
                    child: _caregivers.isEmpty
                        ? ListView(children: [
                            Padding(
                              padding: EdgeInsets.only(top: 60),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                      'No caregivers are registered yet. Check back later.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.grey)),
                                ),
                              ),
                            )
                          ])
                        : ListView.builder(
                            padding: EdgeInsets.all(20),
                            itemCount: _caregivers.length,
                            itemBuilder: (context, i) => _caregiverCard(_caregivers[i]),
                          ),
                  ),
      ),
    );
  }

  Widget _caregiverCard(AppUser c) {
    final assigned = _assignments.containsKey(c.id);
    final busy = _busy.contains(c.id);
    return Card(
      margin: EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: assigned ? AppColors.primary : AppColors.cardBorder,
            width: assigned ? 1.5 : 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.person, color: AppColors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.fullName,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      if (c.caregiverRelation != null && c.caregiverRelation!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(c.caregiverRelation!,
                              style: TextStyle(fontSize: 13, color: AppColors.primary)),
                        ),
                    ],
                  ),
                ),
                if (assigned)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Assigned',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _detailChip(Icons.work_history_outlined, 'Experience',
                      c.experience ?? '--'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _detailChip(Icons.payments_outlined, 'Remuneration',
                      c.remuneration ?? '--'),
                ),
              ],
            ),
            SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: assigned
                  ? OutlinedButton(
                      onPressed: busy ? null : () => _toggleAssign(c),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.danger),
                        foregroundColor: AppColors.danger,
                      ),
                      child: busy
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.danger))
                          : Text('Unassign'),
                    )
                  : ElevatedButton(
                      onPressed: busy ? null : () => _toggleAssign(c),
                      child: busy
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.white))
                          : Text('Assign as My Caregiver'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.grey),
              SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 11, color: AppColors.grey)),
            ],
          ),
          SizedBox(height: 3),
          Text(value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
