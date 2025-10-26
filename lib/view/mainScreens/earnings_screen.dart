import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/model/earning.dart';
import '../widgets/my_appbar.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String selectedPeriod = 'Month'; // Day, Week, Month, Year
  List<Earning> earnings = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() {
      isLoading = true;
    });

    try {
      switch (selectedPeriod) {
        case 'Day':
          earnings = await earningsViewModel.getEarningsForToday();
          break;
        case 'Week':
          earnings = await earningsViewModel.getEarningsForCurrentWeek();
          break;
        case 'Month':
          earnings = await earningsViewModel.getEarningsForCurrentMonth();
          break;
        case 'Year':
          earnings = await earningsViewModel.getEarningsForCurrentYear();
          break;
      }
    } catch (e) {
      print('Error loading earnings: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        titleMsg: 'My Earnings',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Total Earnings Display
            StreamBuilder<DocumentSnapshot>(
              stream: earningsViewModel.getSellerEarnings(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                  double totalWithTax = (data['totalEarningsWithTax'] ?? 0.0).toDouble();
                  double totalWithoutTax = (data['totalEarningsWithoutTax'] ?? 0.0).toDouble();
                  
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withAlpha(73),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Earnings',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withAlpha(229),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${totalWithoutTax.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Including Tax: \$${totalWithTax.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(208),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),

            // Period Selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['Day', 'Week', 'Month', 'Year'].map((period) {
                  bool isSelected = selectedPeriod == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPeriod = period;
                        });
                        _loadEarnings();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          period,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Chart Section
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : earnings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No earnings data for $selectedPeriod',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    List<FlSpot> spots = [];
    List<String> labels = [];
    
    switch (selectedPeriod) {
      case 'Day':
        spots = _buildDailySpots();
        labels = _buildDailyLabels();
        break;
      case 'Week':
        spots = _buildWeeklySpots();
        labels = _buildWeeklyLabels();
        break;
      case 'Month':
        spots = _buildMonthlySpots();
        labels = _buildMonthlyLabels();
        break;
      case 'Year':
        spots = _buildYearlySpots();
        labels = _buildYearlyLabels();
        break;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(21),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Earnings for $selectedPeriod',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < labels.length) {
                          return Text(
                            labels[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.orange.withAlpha(21),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _buildDailySpots() {
    Map<int, double> dailyEarnings = {};
    
    for (var earning in earnings) {
      if (earning.completedAt != null) {
        DateTime date = earning.completedAt!.toDate();
        int hour = date.hour;
        dailyEarnings[hour] = (dailyEarnings[hour] ?? 0) + (earning.amountWithoutTax ?? 0);
      }
    }
    
    return dailyEarnings.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  List<String> _buildDailyLabels() {
    return List.generate(24, (index) => '${index}:00');
  }

  List<FlSpot> _buildWeeklySpots() {
    Map<int, double> weeklyEarnings = {};
    
    for (var earning in earnings) {
      if (earning.completedAt != null) {
        DateTime date = earning.completedAt!.toDate();
        int dayOfWeek = date.weekday;
        weeklyEarnings[dayOfWeek] = (weeklyEarnings[dayOfWeek] ?? 0) + (earning.amountWithoutTax ?? 0);
      }
    }
    
    return weeklyEarnings.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  List<String> _buildWeeklyLabels() {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }

  List<FlSpot> _buildMonthlySpots() {
    Map<int, double> monthlyEarnings = {};
    
    for (var earning in earnings) {
      if (earning.completedAt != null) {
        DateTime date = earning.completedAt!.toDate();
        int day = date.day;
        monthlyEarnings[day] = (monthlyEarnings[day] ?? 0) + (earning.amountWithoutTax ?? 0);
      }
    }
    
    return monthlyEarnings.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  List<String> _buildMonthlyLabels() {
    return List.generate(31, (index) => '${index + 1}');
  }

  List<FlSpot> _buildYearlySpots() {
    Map<int, double> yearlyEarnings = {};
    
    for (var earning in earnings) {
      if (earning.completedAt != null) {
        DateTime date = earning.completedAt!.toDate();
        int month = date.month;
        yearlyEarnings[month] = (yearlyEarnings[month] ?? 0) + (earning.amountWithoutTax ?? 0);
      }
    }
    
    return yearlyEarnings.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  List<String> _buildYearlyLabels() {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  }
}
