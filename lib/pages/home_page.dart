import 'package:flutter/foundation.dart';
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

    // pilih gambar
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
        final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final filePath = 'uploads/$fileName';
        if (kIsWeb) {
            final bytes = await picked.readAsBytes();
            await supabase.storage
            .from('bucket_images')
            .uploadBinary(filePath, bytes,
            fileOptions: const FileOptions(
                contentType: 'image/jpeg',
            )
            );
        }else {
            final file = File(picked.path);
            await supabase.storage.from('bucket_images').upload(filePath, file);
        }

      // ambil URL public
      final publicUrl = supabase.storage
          .from('bucket_images')
          .getPublicUrl(filePath);

      setState(() {
        _publicImageUrl = publicUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload gagal: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload ke Public Bucket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress upload
            if (_isUploading) const LinearProgressIndicator(),

            const SizedBox(height: 16),

            //Button untuk pilih image
            ElevatedButton(
              onPressed: _isUploading ? null : _pickAndUploadToPublicBucket,
              child: const Text('Pilih & Upload Gambar'),
            ),

            //Menampilkan image yang di upload
            const SizedBox(height: 24),
            if (_publicImageUrl != null) ...[
              const Text('Gambar dari Public URL:'),
              const SizedBox(height: 8),
              Expanded(
                child: Image.network(_publicImageUrl!),
              ),
              const SizedBox(height: 8),
              SelectableText(
                _publicImageUrl!,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
