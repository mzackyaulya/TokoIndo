import 'package:flutter/material.dart';

class TambahVarianProdukPage extends StatefulWidget {
  @override
  _TambahVarianProdukPageState createState() => _TambahVarianProdukPageState();
}

class _TambahVarianProdukPageState extends State<TambahVarianProdukPage> {
  List<Varian> varianList = [];

  void addVarian() {
    setState(() {
      varianList.add(Varian());
    });
  }

  void removeVarian(int index) {
    setState(() {
      varianList.removeAt(index);
    });
  }

  void addPilihan(int varianIndex) {
    setState(() {
      varianList[varianIndex].pilihan.add('');
    });
  }

  void removePilihan(int varianIndex, int pilihanIndex) {
    setState(() {
      varianList[varianIndex].pilihan.removeAt(pilihanIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Varian Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: varianList.length,
                itemBuilder: (context, varianIndex) {
                  final varian = varianList[varianIndex];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama Varian
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Nama Varian (misal: Warna, Ukuran)',
                            ),
                            onChanged: (val) {
                              varian.nama = val;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Daftar Pilihan Varian
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: varian.pilihan.length,
                            itemBuilder: (context, pilihanIndex) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Pilihan ke-${pilihanIndex + 1}',
                                      ),
                                      onChanged: (val) {
                                        varian.pilihan[pilihanIndex] = val;
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => removePilihan(varianIndex, pilihanIndex),
                                  ),
                                ],
                              );
                            },
                          ),

                          // Tombol tambah pilihan varian
                          TextButton.icon(
                            onPressed: () => addPilihan(varianIndex),
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Pilihan'),
                          ),

                          // Tombol hapus varian
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => removeVarian(varianIndex),
                              icon: const Icon(Icons.delete_forever, color: Colors.red),
                              label: const Text('Hapus Varian', style: TextStyle(color: Colors.red)),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Tombol tambah varian baru
            ElevatedButton.icon(
              onPressed: addVarian,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Varian Baru'),
            ),

            const SizedBox(height: 20),

            // Tombol Simpan (contoh print ke console)
            ElevatedButton(
              onPressed: () {
                for (var v in varianList) {
                  print('Varian: ${v.nama}, Pilihan: ${v.pilihan}');
                }
              },
              child: const Text('Simpan Varian (Debug print)'),
            ),
          ],
        ),
      ),
    );
  }
}

class Varian {
  String nama = '';
  List<String> pilihan = [];

  Varian();
}
