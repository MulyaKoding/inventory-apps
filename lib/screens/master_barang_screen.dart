import 'package:flutter/material.dart';

/// =====================================================================
/// MASTER BARANG SCREEN
/// Rombak UI mengikuti tampilan web (Satuan, Pabrik, Merek, Supplier,
/// Buat Barang) tapi tetap pakai bahasa desain aplikasi Flutter kamu
/// (ungu / putih, bukan dark navy seperti di web).
///
/// Cara pakai (dari HomeScreen, ganti tujuan "Master Barang"):
///
///   Navigator.push(
///     context,
///     MaterialPageRoute(builder: (_) => const MasterBarangScreen()),
///   );
///
/// Kalau kamu sudah punya data toko dari service, tinggal isi
/// parameter `tokoList` supaya dropdown "Toko Tujuan" otomatis terisi.
/// =====================================================================

const _kPrimary = Color(0xFF8B5CF6);
const _kPrimaryDark = Color(0xFF7C3AED);

// ----------------------------- MODELS ------------------------------

class SatuanItem {
  final String kode;
  final String nama;
  final String keterangan;
  SatuanItem({required this.kode, required this.nama, this.keterangan = ''});
}

class PabrikItem {
  final String toko;
  final String kode;
  final String nama;
  final String kota;
  final String telepon;
  final String alamat;
  PabrikItem({
    required this.toko,
    required this.kode,
    required this.nama,
    this.kota = '',
    this.telepon = '',
    this.alamat = '',
  });
}

class MerekItem {
  final String toko;
  final String kode;
  final String nama;
  final String? pabrik;
  MerekItem({
    required this.toko,
    required this.kode,
    required this.nama,
    this.pabrik,
  });
}

class SupplierItem {
  final String toko;
  final String kode;
  final String nama;
  final String kontakPerson;
  final String telepon;
  final String email;
  final String kota;
  final String alamat;
  SupplierItem({
    required this.toko,
    required this.kode,
    required this.nama,
    this.kontakPerson = '',
    this.telepon = '',
    this.email = '',
    this.kota = '',
    this.alamat = '',
  });
}

class BarangItem {
  final String toko;
  final String kodeBarang;
  final String namaBarang;
  final String barcode;
  final String? jenisBarang;
  final String? satuan;
  final String? merek;
  final String? supplierDefault;
  final double hargaBeli;
  final double hargaJual;
  final int stokMinimum;
  final String status;
  BarangItem({
    required this.toko,
    required this.kodeBarang,
    required this.namaBarang,
    this.barcode = '',
    this.jenisBarang,
    this.satuan,
    this.merek,
    this.supplierDefault,
    this.hargaBeli = 0,
    this.hargaJual = 0,
    this.stokMinimum = 0,
    this.status = 'Aktif',
  });
}

// ----------------------------- SCREEN -------------------------------

class MasterBarangScreen extends StatefulWidget {
  /// Daftar nama toko untuk dropdown "Toko Tujuan". Kosongkan kalau
  /// belum ada toko (akan tampil "Tidak ada toko tersedia" seperti di web).
  final List<String> tokoList;

  const MasterBarangScreen({super.key, this.tokoList = const []});

  @override
  State<MasterBarangScreen> createState() => _MasterBarangScreenState();
}

class _MasterBarangScreenState extends State<MasterBarangScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<SatuanItem> _satuanList = [];
  final List<PabrikItem> _pabrikList = [];
  final List<MerekItem> _merekList = [];
  final List<SupplierItem> _supplierList = [];
  final List<BarangItem> _barangList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Master Barang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _StatsRow(
              satuan: _satuanList.length,
              pabrik: _pabrikList.length,
              merek: _merekList.length,
              supplier: _supplierList.length,
              totalBarang: _barangList.length,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: _kPrimaryDark,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: _kPrimaryDark,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Satuan'),
                Tab(text: 'Pabrik'),
                Tab(text: 'Merek'),
                Tab(text: 'Supplier'),
                Tab(text: 'Buat Barang'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SatuanForm(onSaved: (item) {
                  setState(() => _satuanList.add(item));
                  _snack('Satuan berhasil disimpan');
                }),
                _PabrikForm(
                  tokoList: widget.tokoList,
                  onSaved: (item) {
                    setState(() => _pabrikList.add(item));
                    _snack('Pabrik berhasil disimpan');
                  },
                ),
                _MerekForm(
                  tokoList: widget.tokoList,
                  pabrikList: _pabrikList,
                  onSaved: (item) {
                    setState(() => _merekList.add(item));
                    _snack('Merek berhasil disimpan');
                  },
                ),
                _SupplierForm(
                  tokoList: widget.tokoList,
                  onSaved: (item) {
                    setState(() => _supplierList.add(item));
                    _snack('Supplier berhasil disimpan');
                  },
                ),
                _BuatBarangForm(
                  tokoList: widget.tokoList,
                  satuanList: _satuanList,
                  merekList: _merekList,
                  supplierList: _supplierList,
                  onSaved: (item) {
                    setState(() => _barangList.add(item));
                    _snack('Barang berhasil disimpan');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------- STATS ROW -------------------------------

class _StatsRow extends StatelessWidget {
  final int satuan;
  final int pabrik;
  final int merek;
  final int supplier;
  final int totalBarang;

  const _StatsRow({
    required this.satuan,
    required this.pabrik,
    required this.merek,
    required this.supplier,
    required this.totalBarang,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('SATUAN', satuan, _kPrimaryDark),
      ('PABRIK', pabrik, const Color(0xFF059669)),
      ('MEREK', merek, const Color(0xFF7C3AED)),
      ('SUPPLIER', supplier, const Color(0xFFD97706)),
      ('TOTAL BARANG', totalBarang, const Color(0xFF059669)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        return GridView.count(
          crossAxisCount: isNarrow ? 2 : 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: isNarrow ? 1.6 : 1.3,
          children: items
              .map((e) => _StatCard(label: e.$1, value: e.$2, color: e.$3))
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(top: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------- SHARED WIDGETS -----------------------------

class _FormScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String saveLabel;

  const _FormScaffold({
    required this.title,
    required this.child,
    required this.onCancel,
    required this.onSave,
    required this.saveLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(onPressed: onCancel, child: const Text('Batal')),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.check, size: 18),
                label: Text(saveLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryDark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool required;
  final TextInputType? keyboardType;
  final int maxLines;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.required = false,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 0.4,
            ),
            children: required
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kPrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _TokoTujuanField extends StatelessWidget {
  final List<String> tokoList;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _TokoTujuanField({
    required this.tokoList,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasToko = tokoList.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.storefront_outlined,
                size: 16, color: _kPrimaryDark),
            const SizedBox(width: 6),
            Text.rich(
              TextSpan(
                text: 'Toko Tujuan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[700],
                ),
                children: const [
                  TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasToko ? Colors.grey.shade300 : Colors.red.shade200,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text(
                hasToko ? 'Pilih toko' : 'Tidak ada toko tersedia',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              items: tokoList
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: hasToko ? onChanged : null,
            ),
          ),
        ),
        if (!hasToko)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Pilih toko terlebih dahulu',
              style: TextStyle(color: Colors.red, fontSize: 11),
            ),
          ),
      ],
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final String placeholder;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final VoidCallback? onAdd;

  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey[600],
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    isExpanded: true,
                    value: value,
                    hint: Text(
                      placeholder,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    items: items
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(itemLabel(e)),
                            ))
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
            if (onAdd != null) ...[
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onAdd,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  side: const BorderSide(color: _kPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(Icons.add, color: _kPrimaryDark, size: 18),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: _kPrimaryDark,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ----------------------------- TAB 1: SATUAN --------------------------

class _SatuanForm extends StatefulWidget {
  final ValueChanged<SatuanItem> onSaved;
  const _SatuanForm({required this.onSaved});

  @override
  State<_SatuanForm> createState() => _SatuanFormState();
}

class _SatuanFormState extends State<_SatuanForm> {
  final _kode = TextEditingController();
  final _nama = TextEditingController();
  final _keterangan = TextEditingController();

  void _clear() {
    _kode.clear();
    _nama.clear();
    _keterangan.clear();
  }

  void _save() {
    if (_kode.text.trim().isEmpty || _nama.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode dan Nama Satuan wajib diisi')),
      );
      return;
    }
    widget.onSaved(SatuanItem(
      kode: _kode.text.trim(),
      nama: _nama.text.trim(),
      keterangan: _keterangan.text.trim(),
    ));
    _clear();
  }

  @override
  void dispose() {
    _kode.dispose();
    _nama.dispose();
    _keterangan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormScaffold(
      title: 'Tambah Satuan Barang',
      onCancel: _clear,
      onSave: _save,
      saveLabel: 'Simpan Satuan',
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Kode Satuan',
                  controller: _kode,
                  hint: 'Contoh: PCS, BOX, BTL',
                  required: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledField(
                  label: 'Nama Satuan',
                  controller: _nama,
                  hint: 'Contoh: Pieces, Box, Botol',
                  required: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LabeledField(
            label: 'Keterangan',
            controller: _keterangan,
            hint: 'Deskripsi tambahan (opsional)',
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

// ----------------------------- TAB 2: PABRIK ---------------------------

class _PabrikForm extends StatefulWidget {
  final List<String> tokoList;
  final ValueChanged<PabrikItem> onSaved;
  const _PabrikForm({required this.tokoList, required this.onSaved});

  @override
  State<_PabrikForm> createState() => _PabrikFormState();
}

class _PabrikFormState extends State<_PabrikForm> {
  String? _toko;
  final _kode = TextEditingController();
  final _nama = TextEditingController();
  final _kota = TextEditingController();
  final _telepon = TextEditingController();
  final _alamat = TextEditingController();

  void _clear() {
    setState(() => _toko = null);
    _kode.clear();
    _nama.clear();
    _kota.clear();
    _telepon.clear();
    _alamat.clear();
  }

  void _save() {
    if (_toko == null || _kode.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Toko Tujuan dan Kode Pabrik wajib diisi')),
      );
      return;
    }
    widget.onSaved(PabrikItem(
      toko: _toko!,
      kode: _kode.text.trim(),
      nama: _nama.text.trim(),
      kota: _kota.text.trim(),
      telepon: _telepon.text.trim(),
      alamat: _alamat.text.trim(),
    ));
    _clear();
  }

  @override
  void dispose() {
    _kode.dispose();
    _nama.dispose();
    _kota.dispose();
    _telepon.dispose();
    _alamat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormScaffold(
      title: 'Tambah Pabrik',
      onCancel: _clear,
      onSave: _save,
      saveLabel: 'Simpan Pabrik',
      child: Column(
        children: [
          _TokoTujuanField(
            tokoList: widget.tokoList,
            value: _toko,
            onChanged: (v) => setState(() => _toko = v),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Kode Pabrik',
                  controller: _kode,
                  hint: 'Contoh: KF, GSK',
                  required: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledField(
                  label: 'Nama Pabrik',
                  controller: _nama,
                  hint: 'Nama perusahaan pabrik',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Kota',
                  controller: _kota,
                  hint: 'Kota pabrik',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledField(
                  label: 'No. Telepon',
                  controller: _telepon,
                  hint: '+62...',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LabeledField(
            label: 'Alamat',
            controller: _alamat,
            hint: 'Alamat lengkap pabrik',
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

// ----------------------------- TAB 3: MEREK ----------------------------

class _MerekForm extends StatefulWidget {
  final List<String> tokoList;
  final List<PabrikItem> pabrikList;
  final ValueChanged<MerekItem> onSaved;
  const _MerekForm({
    required this.tokoList,
    required this.pabrikList,
    required this.onSaved,
  });

  @override
  State<_MerekForm> createState() => _MerekFormState();
}

class _MerekFormState extends State<_MerekForm> {
  String? _toko;
  String? _pabrik;
  final _kode = TextEditingController();
  final _nama = TextEditingController();

  void _clear() {
    setState(() {
      _toko = null;
      _pabrik = null;
    });
    _kode.clear();
    _nama.clear();
  }

  void _save() {
    if (_toko == null || _kode.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toko Tujuan dan Kode Merek wajib diisi')),
      );
      return;
    }
    widget.onSaved(MerekItem(
      toko: _toko!,
      kode: _kode.text.trim(),
      nama: _nama.text.trim(),
      pabrik: _pabrik,
    ));
    _clear();
  }

  @override
  void dispose() {
    _kode.dispose();
    _nama.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormScaffold(
      title: 'Tambah Merek',
      onCancel: _clear,
      onSave: _save,
      saveLabel: 'Simpan Merek',
      child: Column(
        children: [
          _TokoTujuanField(
            tokoList: widget.tokoList,
            value: _toko,
            onChanged: (v) => setState(() => _toko = v),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Kode Merek',
                  controller: _kode,
                  hint: 'Contoh: PAR, AMX',
                  required: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledField(
                  label: 'Nama Merek',
                  controller: _nama,
                  hint: 'Nama merek produk',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LabeledDropdown<String>(
            label: 'Pabrik',
            value: _pabrik,
            placeholder: '— Pilih Pabrik —',
            items: widget.pabrikList.map((p) => p.nama).toList(),
            itemLabel: (e) => e,
            onChanged: (v) => setState(() => _pabrik = v),
            onAdd: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Buka tab Pabrik untuk menambah data baru')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------- TAB 4: SUPPLIER ---------------------------

class _SupplierForm extends StatefulWidget {
  final List<String> tokoList;
  final ValueChanged<SupplierItem> onSaved;
  const _SupplierForm({required this.tokoList, required this.onSaved});

  @override
  State<_SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<_SupplierForm> {
  String? _toko;
  final _kode = TextEditingController();
  final _nama = TextEditingController();
  final _kontak = TextEditingController();
  final _telepon = TextEditingController();
  final _email = TextEditingController();
  final _kota = TextEditingController();
  final _alamat = TextEditingController();

  void _clear() {
    setState(() => _toko = null);
    _kode.clear();
    _nama.clear();
    _kontak.clear();
    _telepon.clear();
    _email.clear();
    _kota.clear();
    _alamat.clear();
  }

  void _save() {
    if (_toko == null ||
        _kode.text.trim().isEmpty ||
        _nama.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toko Tujuan, Kode, dan Nama Supplier wajib diisi'),
        ),
      );
      return;
    }
    widget.onSaved(SupplierItem(
      toko: _toko!,
      kode: _kode.text.trim(),
      nama: _nama.text.trim(),
      kontakPerson: _kontak.text.trim(),
      telepon: _telepon.text.trim(),
      email: _email.text.trim(),
      kota: _kota.text.trim(),
      alamat: _alamat.text.trim(),
    ));
    _clear();
  }

  @override
  void dispose() {
    _kode.dispose();
    _nama.dispose();
    _kontak.dispose();
    _telepon.dispose();
    _email.dispose();
    _kota.dispose();
    _alamat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormScaffold(
      title: 'Tambah Supplier',
      onCancel: _clear,
      onSave: _save,
      saveLabel: 'Simpan Supplier',
      child: Column(
        children: [
          _TokoTujuanField(
            tokoList: widget.tokoList,
            value: _toko,
            onChanged: (v) => setState(() => _toko = v),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Kode Supplier',
                  controller: _kode,
                  hint: 'Contoh: SUP001',
                  required: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledField(
                  label: 'Nama Supplier',
                  controller: _nama,
                  hint: 'Nama perusahaan supplier',
                  required: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Kontak Person',
                  controller: _kontak,
                  hint: 'Nama PIC',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledField(
                  label: 'No. Telepon',
                  controller: _telepon,
                  hint: '+62...',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Email',
                  controller: _email,
                  hint: 'email@supplier.com',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledField(
                  label: 'Kota',
                  controller: _kota,
                  hint: 'Kota',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LabeledField(
            label: 'Alamat',
            controller: _alamat,
            hint: 'Alamat lengkap supplier',
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

// --------------------------- TAB 5: BUAT BARANG --------------------------

class _BuatBarangForm extends StatefulWidget {
  final List<String> tokoList;
  final List<SatuanItem> satuanList;
  final List<MerekItem> merekList;
  final List<SupplierItem> supplierList;
  final ValueChanged<BarangItem> onSaved;

  const _BuatBarangForm({
    required this.tokoList,
    required this.satuanList,
    required this.merekList,
    required this.supplierList,
    required this.onSaved,
  });

  @override
  State<_BuatBarangForm> createState() => _BuatBarangFormState();
}

class _BuatBarangFormState extends State<_BuatBarangForm> {
  String? _toko;
  final _kodeBarang = TextEditingController();
  final _namaBarang = TextEditingController();
  final _barcode = TextEditingController();
  String? _jenisBarang;

  String? _satuan;
  String? _merek;
  String? _supplier;

  final _hargaBeli = TextEditingController();
  final _hargaJual = TextEditingController();
  final _stokMinimum = TextEditingController();
  String _status = 'Aktif';

  static const _jenisOptions = [
    'Obat',
    'Alat Kesehatan',
    'Kosmetik',
    'Lainnya'
  ];

  void _clear() {
    setState(() {
      _toko = null;
      _jenisBarang = null;
      _satuan = null;
      _merek = null;
      _supplier = null;
      _status = 'Aktif';
    });
    _kodeBarang.clear();
    _namaBarang.clear();
    _barcode.clear();
    _hargaBeli.clear();
    _hargaJual.clear();
    _stokMinimum.clear();
  }

  void _save() {
    if (_toko == null ||
        _kodeBarang.text.trim().isEmpty ||
        _namaBarang.text.trim().isEmpty ||
        _satuan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Toko Tujuan, Kode Barang, Nama Barang, dan Satuan wajib diisi'),
        ),
      );
      return;
    }
    widget.onSaved(BarangItem(
      toko: _toko!,
      kodeBarang: _kodeBarang.text.trim(),
      namaBarang: _namaBarang.text.trim(),
      barcode: _barcode.text.trim(),
      jenisBarang: _jenisBarang,
      satuan: _satuan,
      merek: _merek,
      supplierDefault: _supplier,
      hargaBeli: double.tryParse(_hargaBeli.text.trim()) ?? 0,
      hargaJual: double.tryParse(_hargaJual.text.trim()) ?? 0,
      stokMinimum: int.tryParse(_stokMinimum.text.trim()) ?? 0,
      status: _status,
    ));
    _clear();
  }

  @override
  void dispose() {
    _kodeBarang.dispose();
    _namaBarang.dispose();
    _barcode.dispose();
    _hargaBeli.dispose();
    _hargaJual.dispose();
    _stokMinimum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormScaffold(
      title: 'Tambah Barang',
      onCancel: _clear,
      onSave: _save,
      saveLabel: 'Simpan Barang',
      child: Column(
        children: [
          _TokoTujuanField(
            tokoList: widget.tokoList,
            value: _toko,
            onChanged: (v) => setState(() => _toko = v),
          ),
          const _SectionHeader('Identitas Barang'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Kode Barang',
                  controller: _kodeBarang,
                  hint: 'Auto / Manual',
                  required: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledField(
                  label: 'Nama Barang',
                  controller: _namaBarang,
                  hint: 'Nama lengkap barang',
                  required: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Barcode',
                  controller: _barcode,
                  hint: 'Scan atau ketik barcode',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledDropdown<String>(
                  label: 'Jenis Barang',
                  value: _jenisBarang,
                  placeholder: '— Pilih Jenis —',
                  items: _jenisOptions,
                  itemLabel: (e) => e,
                  onChanged: (v) => setState(() => _jenisBarang = v),
                ),
              ),
            ],
          ),
          const _SectionHeader('Referensi'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledDropdown<String>(
                  label: 'Satuan *',
                  value: _satuan,
                  placeholder: '— Pilih Satuan —',
                  items: widget.satuanList.map((s) => s.nama).toList(),
                  itemLabel: (e) => e,
                  onChanged: (v) => setState(() => _satuan = v),
                  onAdd: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Buka tab Satuan untuk menambah data baru')),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledDropdown<String>(
                  label: 'Merek',
                  value: _merek,
                  placeholder: '— Pilih Merek —',
                  items: widget.merekList.map((m) => m.nama).toList(),
                  itemLabel: (e) => e,
                  onChanged: (v) => setState(() => _merek = v),
                  onAdd: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Buka tab Merek untuk menambah data baru')),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _LabeledDropdown<String>(
            label: 'Supplier Default',
            value: _supplier,
            placeholder: '— Pilih Supplier —',
            items: widget.supplierList.map((s) => s.nama).toList(),
            itemLabel: (e) => e,
            onChanged: (v) => setState(() => _supplier = v),
            onAdd: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Buka tab Supplier untuk menambah data baru')),
            ),
          ),
          const _SectionHeader('Harga & Stok'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Harga Beli (Rp)',
                  controller: _hargaBeli,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledField(
                  label: 'Harga Jual (Rp)',
                  controller: _hargaJual,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Stok Minimum',
                  controller: _stokMinimum,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledDropdown<String>(
                  label: 'Status',
                  value: _status,
                  placeholder: 'Aktif',
                  items: const ['Aktif', 'Nonaktif'],
                  itemLabel: (e) => e,
                  onChanged: (v) => setState(() => _status = v ?? 'Aktif'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
