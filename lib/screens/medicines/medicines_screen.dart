import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/medicine_service.dart';
import '../../models/medicine.dart';
import '../../widgets/dashboard_widgets.dart';
import 'add_medicine_screen.dart';

class MedicinesScreen extends StatefulWidget {
  final String? elderId;
  final String? elderName;
  const MedicinesScreen({super.key, this.elderId, this.elderName});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final _authService = AuthService();
  final _medicineService = MedicineService();
  final _search = TextEditingController();

  List<Medicine> _all = [];
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
        _all = await _medicineService.fetchAll(uid);
      }
    } catch (e) {
      _error = 'Could not load medicines: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Medicine> get _filtered {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((m) => m.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text(widget.elderName != null ? "${widget.elderName}'s Medicines" : 'Medicines')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddMedicineScreen(elderId: widget.elderId)));
          _load();
        },
        child: Icon(Icons.add, color: AppColors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search medicines',
                  prefixIcon: Icon(Icons.search, color: AppColors.grey),
                ),
              ),
              SizedBox(height: 18),
              if (_loading)
                Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (_error != null)
                Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
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
              else if (_filtered.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text('No medicines added yet.', style: TextStyle(color: AppColors.grey)),
                  ),
                )
              else
                ..._filtered.map((m) => MedicineTile(
                      medicine: m,
                      onMore: () => _showActions(m),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  void _showActions(Medicine m) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.check_circle_outline, color: AppColors.accentGreen),
              title: Text('Mark as Taken'),
              onTap: () async {
                await _medicineService.updateStatus(m.id, MedicineStatus.taken);
                if (mounted) Navigator.pop(context);
                _load();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.danger),
              title: Text('Delete Medicine'),
              onTap: () async {
                await _medicineService.delete(m.id);
                if (mounted) Navigator.pop(context);
                _load();
              },
            ),
          ],
        ),
      ),
    );
  }
}
