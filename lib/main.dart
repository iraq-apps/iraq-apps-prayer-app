 import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مواقيت الصلاة',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const PrayerTimesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  PrayerTimes? prayerTimes;
  String location = 'جاري تحديد الموقع...';

  @override
  void initState() {
    super.initState();
    _getPrayerTimes();
  }

  Future<void> _getPrayerTimes() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      final myCoordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      final prayerTimes = PrayerTimes.today(myCoordinates, params);

      setState(() {
        this.prayerTimes = prayerTimes;
        location = '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      });
    } catch (e) {
      setState(() {
        location = 'بغداد - افتراضي';
      });
      final coordinates = Coordinates(33.3152, 44.3661); // بغداد
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      setState(() {
        prayerTimes = PrayerTimes.today(coordinates, params);
      });
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat('hh:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('مواقيت الصلاة', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: prayerTimes == null
         ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green[50]!, Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.green),
                        title: Text(location),
                        subtitle: Text(DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now())),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPrayerTile('الفجر', prayerTimes!.fajr, Icons.nightlight),
                    _buildPrayerTile('الشروق', prayerTimes!.sunrise, Icons.wb_sunny),
                    _buildPrayerTile('الظهر', prayerTimes!.dhuhr, Icons.light_mode),
                    _buildPrayerTile('العصر', prayerTimes!.asr, Icons.wb_twilight),
                    _buildPrayerTile('المغرب', prayerTimes!.maghrib, Icons.nights_stay),
                    _buildPrayerTile('العشاء', prayerTimes!.isha, Icons.dark_mode),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getPrayerTimes,
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.green[700],
      ),
    );
  }
 Widget _buildPrayerTile(String name, DateTime time, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700], size: 30),
        title: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        trailing: Text(
          _formatTime(time),
          style: TextStyle(fontSize: 22, color: Colors.green[800], fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
