import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class PrayerData {
  final String locationName;
  final String nextPrayerName;
  final String nextPrayerTimeStr;
  final DateTime targetTime;

  PrayerData({
    required this.locationName,
    required this.nextPrayerName,
    required this.nextPrayerTimeStr,
    required this.targetTime,
  });
}

class PrayerTimeService {
  static Future<PrayerData?> getPrayerData() async {
    try {
      // 1. Cek & Minta Izin Lokasi (Tanpa memblokir jika ditolak)
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        }
      } catch (e) {
        // Abaikan jika pengecekan gagal
      }

      // 2. Ambil Koordinat GPS dengan Timeout 3 detik
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium)
        ).timeout(const Duration(seconds: 3));
      } catch (e) {
        // Jika gagal atau timeout, gunakan fallback (Malang)
        position = null;
      }
      
      double lat = position?.latitude ?? -7.983908;
      double lng = position?.longitude ?? 112.621391;

      // 3. Konversi Koordinat ke Nama Kota
      String cityName = 'Malang';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          cityName = '${place.subAdministrativeArea ?? place.locality ?? place.administrativeArea}';
          cityName = cityName.replaceAll('Kabupaten ', '').replaceAll('Kota ', '');
        }
      } catch (_) {
        // Abaikan jika geocoding gagal, tetap gunakan default
      }

      // 4. Tarik Jadwal Sholat (Aladhan API, Method 20 = Kemenag RI)
      final url = Uri.parse(
        'http://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=20'
      );
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        
        return _calculateNextPrayer(timings, cityName);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static PrayerData _calculateNextPrayer(Map<String, dynamic> timings, String cityName) {
    final now = DateTime.now();
    
    final List<String> prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final List<String> prayerLabels = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
    
    String nextName = 'Subuh';
    String nextTimeStr = timings['Fajr'].toString().substring(0, 5);
    DateTime nextTime = _parseTime(nextTimeStr, now);

    bool found = false;
    for (int i = 0; i < prayerNames.length; i++) {
      String pTimeStr = timings[prayerNames[i]].toString().substring(0, 5);
      DateTime pTime = _parseTime(pTimeStr, now);
      
      if (pTime.isAfter(now)) {
        nextName = prayerLabels[i];
        nextTimeStr = pTimeStr;
        nextTime = pTime;
        found = true;
        break;
      }
    }
    
    // Jika semua sholat hari ini sudah lewat, maka sholat berikutnya adalah Subuh besok
    if (!found) {
      String fajrStr = timings['Fajr'].toString().substring(0, 5);
      nextName = 'Subuh';
      nextTimeStr = fajrStr;
      nextTime = _parseTime(fajrStr, now).add(const Duration(days: 1));
    }
    
    return PrayerData(
      locationName: cityName,
      nextPrayerName: nextName,
      nextPrayerTimeStr: nextTimeStr,
      targetTime: nextTime,
    );
  }

  static DateTime _parseTime(String timeStr, DateTime now) {
    List<String> parts = timeStr.split(':');
    return DateTime(
      now.year, now.month, now.day,
      int.parse(parts[0]), int.parse(parts[1])
    );
  }
}
