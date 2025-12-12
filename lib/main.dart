import 'package:flutter/material.dart';
import 'package:supabase_1123150124/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://abrcktepwhjxvljdplay.supabase.co';
const supabasekey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFicmNrdGVwd2hqeHZsamRwbGF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU0MjMyOTksImV4cCI6MjA4MDk5OTI5OX0.KM2Nz7zEfnILO9sSV8vSngmj3XNBDPhGOI8UkmD6pHU';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabasekey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    title: 'Supabase Foto Regina safarina', 
    home: MyHomePage(),
    );
  }
}
