import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _publicImageUrl;
  bool _isUploading = false;

  Future<void> _pickAndUploadToPublicBucket() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final filePath = 'uploads/$fileName';
      final file = File(picked.path);

      // Upload ke bucket
      await supabase.storage.from('kampushub-images').upload(filePath, file);

      // Ambil URL public
      final publicUrl =
          supabase.storage.from('kampushub-images').getPublicUrl(filePath);

      setState(() => _publicImageUrl = publicUrl);
    } catch (e) {
      debugPrint('Error upload: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Gambar')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _pickAndUploadToPublicBucket,
                    child: const Text("Upload ke Supabase"),
                  ),

            const SizedBox(height: 20),

            if (_publicImageUrl != null)
              Image.network(
                _publicImageUrl!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }
}
