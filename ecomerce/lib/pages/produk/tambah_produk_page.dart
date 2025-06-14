import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Varian {
  String nama;
  List<String> pilihan;
  Varian({required this.nama, required this.pilihan});
}

class TambahProdukPage extends StatefulWidget {
  final String storeId;

  const TambahProdukPage({required this.storeId, Key? key}) : super(key: key);

  @override
  _TambahProdukPageState createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  String? _selectedCategory;
  List<String> categories = ['Elektronik', 'Fashion', 'Makanan', 'Kecantikan'];

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;

  List<Varian> varianList = [];

  // Controller untuk input varian baru
  final _varianNameController = TextEditingController();
  final _varianPilihanController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    final cloudName = 'dz94rjzyz'; // ganti sesuai akun cloudinary kamu
    final uploadPreset = 'flutter_unsigned_preset'; // ganti sesuai preset kamu

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    var request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = jsonDecode(respStr);
      return jsonResp['secure_url'];
    } else {
      print('Upload gagal, status: ${response.statusCode}');
      return null;
    }
  }

  void _addVarian() {
    String nama = _varianNameController.text.trim();
    String pilihanText = _varianPilihanController.text.trim();

    if (nama.isEmpty || pilihanText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama varian dan pilihan harus diisi')),
      );
      return;
    }

    // Cek kalau nama varian sudah ada di list
    bool alreadyExists = varianList.any((v) => v.nama.toLowerCase() == nama.toLowerCase());
    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Varian dengan nama "$nama" sudah ada')),
      );
      return;
    }

    List<String> pilihan = pilihanText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (pilihan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan minimal satu pilihan varian')),
      );
      return;
    }

    setState(() {
      varianList.add(Varian(nama: nama, pilihan: pilihan));
      _varianNameController.clear();
      _varianPilihanController.clear();
    });
  }

  Future<void> saveProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama, Harga, Stok, dan Kategori wajib diisi')),
      );
      return;
    }

    int? price = int.tryParse(_priceController.text.trim());
    int? stock = int.tryParse(_stockController.text.trim());

    if (price == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga dan Stok harus berupa angka')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String? imageUrl;
    if (_pickedImage != null) {
      imageUrl = await uploadImageToCloudinary(_pickedImage!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengupload gambar')),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'storeId': widget.storeId,
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'price': price,
        'stock': stock,
        'variants': varianList
            .map((v) => {
          'nama': v.nama,
          'pilihan': v.pilihan,
        })
            .toList(),
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan produk: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _varianNameController.dispose();
    _varianPilihanController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Foto Produk
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                  image: _pickedImage != null
                      ? DecorationImage(image: FileImage(_pickedImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _pickedImage == null
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Ketuk untuk pilih foto produk', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Nama Produk
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi Produk
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Produk',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Kategori Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
            const SizedBox(height: 16),

            // Harga Produk
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Harga Produk',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Stok Produk
            TextField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Stok Produk',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Input tambah varian baru
            Text(
              'Tambah Varian Baru',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _varianNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Varian (contoh: Warna, Ukuran)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _varianPilihanController,
              decoration: const InputDecoration(
                labelText: 'Pilihan Varian (pisahkan dengan koma, contoh: Merah, Biru, Hijau)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addVarian,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
              ),
              child: const Text(
                  'Tambah Varian',
                style: TextStyle( fontWeight: FontWeight.bold , color: Colors.black),
              ),
            ),
            const SizedBox(height: 24),

            // Tampilkan daftar varian yang sudah dibuat
            if (varianList.isNotEmpty) ...[
              Text(
                'Daftar Varian',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...varianList.map((v) => ListTile(
                title: Text(v.nama),
                subtitle: Text(v.pilihan.join(', ')),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      varianList.remove(v);
                    });
                  },
                ),
              )),
              const SizedBox(height: 24),
            ],

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Produk', style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
