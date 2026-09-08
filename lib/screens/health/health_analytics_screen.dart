import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../services/auth_service.dart';
import '../../services/health_service.dart';
import '../../models/health_record.dart';
import '../../widgets/dashboard_widgets.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

enum _Metric { bp, sugar, weight, pulse }

class HealthAnalyticsScreen extends StatefulWidget {
  const HealthAnalyticsScreen({super.key});

  @override
  State<HealthAnalyticsScreen> createState() => _HealthAnalyticsScreenState();
}

class _HealthAnalyticsScreenState extends State<HealthAnalyticsScreen> {
  final _authService = AuthService();
  final _healthService = HealthService();

  List<HealthRecord> _records = [];
  bool _loading = true;
  String? _error;
  _Metric _metric = _Metric.bp;

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
        _records = await _healthService.fetchAll(uid, limit: 14);
      }
    } catch (e) {
      _error = 'Could not load health analytics: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double? _valueFor(HealthRecord r) {
    switch (_metric) {
      case _Metric.bp:
        return r.bpSystolic?.toDouble();
      case _Metric.sugar:
        return r.sugar?.toDouble();
      case _Metric.weight:
        return r.weight;
      case _Metric.pulse:
        return r.pulse?.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final latest = _records.isNotEmpty ? _records.first : null;
    final chartRecords = _records.reversed.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Health Analytics'),
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.healthRecords),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _openAddSheet,
        child: Icon(Icons.add, color: AppColors.white),
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
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        VitalStatCard(
                          label: 'BP',
                          value: latest?.bpDisplay ?? '--',
                          unit: 'mmHg',
                          background: AppColors.bpCard,
                          valueColor: AppColors.danger,
                        ),
                        VitalStatCard(
                          label: 'Sugar',
                          value: '${latest?.sugar ?? '--'}',
                          unit: 'mg/dL',
                          background: AppColors.sugarCard,
                          valueColor: Color(0xFF8B5CF6),
                        ),
                        VitalStatCard(
                          label: 'Weight',
                          value: '${latest?.weight ?? '--'}',
                          unit: 'kg',
                          background: AppColors.weightCard,
                          valueColor: Color(0xFF2563EB),
                        ),
                        VitalStatCard(
                          label: 'Pulse',
                          value: '${latest?.pulse ?? '--'}',
                          unit: 'bpm',
                          background: AppColors.pulseCard,
                          valueColor: Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        _metricChip('BP', _Metric.bp),
                        SizedBox(width: 8),
                        _metricChip('Sugar', _Metric.sugar),
                        SizedBox(width: 8),
                        _metricChip('Weight', _Metric.weight),
                        SizedBox(width: 8),
                        _metricChip('Pulse', _Metric.pulse),
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: chartRecords.isEmpty
                          ? Center(
                              child: Text('No data yet. Add your first reading.',
                                  style: TextStyle(color: AppColors.grey)))
                          : LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: [
                                      for (int i = 0; i < chartRecords.length; i++)
                                        if (_valueFor(chartRecords[i]) != null)
                                          FlSpot(i.toDouble(), _valueFor(chartRecords[i])!)
                                    ],
                                    isCurved: true,
                                    color: AppColors.primary,
                                    barWidth: 3,
                                    dotData: FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                        show: true, color: AppColors.primary.withOpacity(0.1)),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _metricChip(String label, _Metric metric) {
    final selected = _metric == metric;
    return GestureDetector(
      onTap: () => setState(() => _metric = metric),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.lightGrey),
        ),
        child: Text(label,
            style: TextStyle(color: selected ? AppColors.white : AppColors.dark, fontSize: 13)),
      ),
    );
  }

  void _openAddSheet() {
    final systolic = TextEditingController();
    final diastolic = TextEditingController();
    final sugar = TextEditingController();
    final weight = TextEditingController();
    final pulse = TextEditingController();
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
                Text('Add Health Reading',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: CustomTextField(
                          label: 'Systolic',
                          hint: '120',
                          controller: systolic,
                          icon: Icons.favorite_outline,
                          keyboardType: TextInputType.number)),
                  SizedBox(width: 12),
                  Expanded(
                      child: CustomTextField(
                          label: 'Diastolic',
                          hint: '80',
                          controller: diastolic,
                          icon: Icons.favorite_outline,
                          keyboardType: TextInputType.number)),
                ]),
                CustomTextField(
                    label: 'Sugar (mg/dL)',
                    hint: '98',
                    controller: sugar,
                    icon: Icons.water_drop_outlined,
                    keyboardType: TextInputType.number),
                CustomTextField(
                    label: 'Weight (kg)',
                    hint: '65',
                    controller: weight,
                    icon: Icons.monitor_weight_outlined,
                    keyboardType: TextInputType.number),
                CustomTextField(
                    label: 'Pulse (bpm)',
                    hint: '72',
                    controller: pulse,
                    icon: Icons.timeline,
                    keyboardType: TextInputType.number),
                SizedBox(height: 8),
                PrimaryButton(
                  label: 'Save Reading',
                  loading: saving,
                  onPressed: () async {
                    setModalState(() => saving = true);
                    try {
                      final uid = _authService.currentAuthUser?.id;
                      if (uid == null) throw Exception('You are not logged in.');
                      await _healthService.add(HealthRecord(
                        id: '',
                        userId: uid,
                        recordedAt: DateTime.now(),
                        bpSystolic: int.tryParse(systolic.text),
                        bpDiastolic: int.tryParse(diastolic.text),
                        sugar: int.tryParse(sugar.text),
                        weight: double.tryParse(weight.text),
                        pulse: int.tryParse(pulse.text),
                      ));
                      if (mounted) Navigator.pop(context);
                      _load();
                    } catch (e) {
                      setModalState(() => saving = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Could not save reading: $e'),
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
