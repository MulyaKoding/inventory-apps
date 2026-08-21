import 'package:flutter/material.dart';

/// =====================================================================
/// MASTER BARANG SCREEN — REDESIGN (tanpa TabBar)
///
/// Sebelumnya UI pakai TabBar 5 tab yang jadi sempit & sesak di layar HP.
/// Sekarang polanya jadi "dashboard -> halaman detail":
///   1. Layar utama nampilin ringkasan (Total Barang) + menu kartu
///      (Satuan, Pabrik, Merek, Supplier, Buat Barang).
///   2. Tap salah satu kartu -> masuk ke halaman form tersendiri
///      (full screen, ada tombol back), lengkap dengan daftar data
///      yang sudah disimpan supaya user langsung lihat hasilnya.
///
/// Cara pakai (dari HomeScreen):
///
///   Navigator.push(
///     context,
///     MaterialPageRoute(builder: (_) => const MasterBarangScreen()),
///   );
/// =====================================================================

const _kPrimary = Color(0xFF8B5CF6);
const _kPrimaryDark = Color(0xFF7C3AED);
const _kBg = Color(0xFFF8F7FC);

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

// ----------------------------- MAIN SCREEN -------------------------------

class MasterBarangScreen extends StatefulWidget {
  /// Daftar nama toko untuk dropdown "Toko Tujuan". Kosongkan kalau
  /// belum ada toko (akan tampil "Tidak ada toko tersedia" seperti di web).
  final List<String> tokoList;

  const MasterBarangScreen({super.key, this.tokoList = const []});

  @override
  State<MasterBarangScreen> createState() => _MasterBarangScreenState();
}

class _MasterBarangScreenState extends State<MasterBarangScreen> {
  final List<SatuanItem> _satuanList = [];
  final List<PabrikItem> _pabrikList = [];
  final List<MerekItem> _merekList = [];
  final List<SupplierItem> _supplierList = [];
  final List<BarangItem> _barangList = [];

  Future<void> _openScreen(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {}); // refresh counts on the dashboard
  }

  void _openSatuan() => _openScreen(_DetailPage(
        title: 'Satuan Barang',
        child: _SatuanForm(
          items: _satuanList,
          onSaved: (item) => setState(() => _satuanList.add(item)),
          onDelete: (item) => setState(() => _satuanList.remove(item)),
        ),
      ));

  void _openPabrik() => _openScreen(_DetailPage(
        title: 'Pabrik',
        child: _PabrikForm(
          tokoList: widget.tokoList,
          items: _pabrikList,
          onSaved: (item) => setState(() => _pabrikList.add(item)),
          onDelete: (item) => setState(() => _pabrikList.remove(item)),
        ),
      ));

  void _openMerek() => _openScreen(_DetailPage(
        title: 'Merek',
        child: _MerekForm(
          tokoList: widget.tokoList,
          pabrikList: _pabrikList,
          items: _merekList,
          onSaved: (item) => setState(() => _merekList.add(item)),
          onDelete: (item) => setState(() => _merekList.remove(item)),
        ),
      ));

  void _openSupplier() => _openScreen(_DetailPage(
        title: 'Supplier',
        child: _SupplierForm(
          tokoList: widget.tokoList,
          items: _supplierList,
          onSaved: (item) => setState(() => _supplierList.add(item)),
          onDelete: (item) => setState(() => _supplierList.remove(item)),
        ),
      ));

  void _openBuatBarang() => _openScreen(_DetailPage(
        title: 'Buat Barang',
        child: _BuatBarangForm(
          tokoList: widget.tokoList,
          satuanList: _satuanList,
          merekList: _merekList,
          supplierList: _supplierList,
          items: _barangList,
          onSaved: (item) => setState(() => _barangList.add(item)),
          onDelete: (item) => setState(() => _barangList.remove(item)),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Master Barang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _HeroStat(total: _barangList.length),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Satuan',
                  value: _satuanList.length,
                  color: _kPrimaryDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Pabrik',
                  value: _pabrikList.length,
                  color: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Merek',
                  value: _merekList.length,
                  color: const Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Supplier',
                  value: _supplierList.length,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Kelola Data Master',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              _MenuCard(
                icon: Icons.straighten_rounded,
                label: 'Satuan',
                count: _satuanList.length,
                color: _kPrimaryDark,
                onTap: _openSatuan,
              ),
              _MenuCard(
                icon: Icons.factory_outlined,
                label: 'Pabrik',
                count: _pabrikList.length,
                color: const Color(0xFF059669),
                onTap: _openPabrik,
              ),
              _MenuCard(
                icon: Icons.sell_outlined,
                label: 'Merek',
                count: _merekList.length,
                color: const Color(0xFF7C3AED),
                onTap: _openMerek,
              ),
              _MenuCard(
                icon: Icons.local_shipping_outlined,
                label: 'Supplier',
                count: _supplierList.length,
                color: const Color(0xFFD97706),
                onTap: _openSupplier,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Barang',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _PrimaryActionCard(
            icon: Icons.add_box_rounded,
            title: 'Tambah Barang Baru',
            subtitle: 'Buat data barang lengkap dengan satuan, merek, '
                'supplier, harga & stok minimum',
            onTap: _openBuatBarang,
          ),
        ],
      ),
    );
  }
}

// --------------------------- DETAIL PAGE WRAPPER ------------------------

/// Bungkus semua form jadi halaman tersendiri (bukan tab) supaya
/// tiap kategori terasa lega & fokus, dengan tombol back standar.
class _DetailPage extends StatelessWidget {
  final String title;
  final Widget child;
  const _DetailPage({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: child,
    );
  }
}

// ---------------------------- DASHBOARD WIDGETS --------------------------

class _HeroStat extends StatelessWidget {
  final int total;
  const _HeroStat({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimary, _kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _kPrimaryDark.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL BARANG',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'produk terdaftar di sistem',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count data',
                style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kPrimary, _kPrimaryDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------- SHARED FORM WIDGETS -----------------------------

class _FormScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String saveLabel;
  final Widget? footer;

  const _FormScaffold({
    required this.title,
    required this.child,
    required this.onCancel,
    required this.onSave,
    required this.saveLabel,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                child,
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: onSave,
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(saveLabel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimaryDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 20),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// Daftar data yang sudah tersimpan, ditampilkan di bawah form supaya
/// user langsung dapat feedback visual (bukan cuma snackbar sekilas).
class _EntryListSection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Color color;
  final IconData icon;
  final String Function(T) titleOf;
  final String Function(T) subtitleOf;
  final ValueChanged<T> onDelete;

  const _EntryListSection({
    required this.title,
    required this.items,
    required this.color,
    required this.icon,
    required this.titleOf,
    required this.subtitleOf,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${items.length}',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, color: Colors.grey[300], size: 30),
                const SizedBox(height: 6),
                Text('Belum ada data',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12.5)),
              ],
            ),
          )
        else
          ...items.map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titleOf(e),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        if (subtitleOf(e).isNotEmpty)
                          Text(subtitleOf(e),
                              style: TextStyle(
                                  fontSize: 11.5, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => onDelete(e),
                    icon: const Icon(Icons.delete_outline, size: 19),
                    color: Colors.grey[400],
                    splashRadius: 18,
                  ),
                ],
              ),
            ),
          ),
      ],
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
            fillColor: _kBg,
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
            color: _kBg,
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
                  color: _kBg,
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

// ----------------------------- FORM 1: SATUAN --------------------------

class _SatuanForm extends StatefulWidget {
  final List<SatuanItem> items;
  final ValueChanged<SatuanItem> onSaved;
  final ValueChanged<SatuanItem> onDelete;
  const _SatuanForm(
      {required this.items, required this.onSaved, required this.onDelete});

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
    setState(() {});
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
      footer: _EntryListSection<SatuanItem>(
        title: 'Daftar Satuan',
        items: widget.items,
        color: _kPrimaryDark,
        icon: Icons.straighten_rounded,
        titleOf: (e) => '${e.nama} (${e.kode})',
        subtitleOf: (e) => e.keterangan,
        onDelete: (e) => setState(() => widget.onDelete(e)),
      ),
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

// ----------------------------- FORM 2: PABRIK ---------------------------

class _PabrikForm extends StatefulWidget {
  final List<String> tokoList;
  final List<PabrikItem> items;
  final ValueChanged<PabrikItem> onSaved;
  final ValueChanged<PabrikItem> onDelete;
  const _PabrikForm({
    required this.tokoList,
    required this.items,
    required this.onSaved,
    required this.onDelete,
  });

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
    setState(() {});
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
      footer: _EntryListSection<PabrikItem>(
        title: 'Daftar Pabrik',
        items: widget.items,
        color: const Color(0xFF059669),
        icon: Icons.factory_outlined,
        titleOf: (e) => e.nama.isNotEmpty ? '${e.nama} (${e.kode})' : e.kode,
        subtitleOf: (e) =>
            [e.kota, e.telepon].where((s) => s.isNotEmpty).join(' • '),
        onDelete: (e) => setState(() => widget.onDelete(e)),
      ),
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

// ----------------------------- FORM 3: MEREK ----------------------------

class _MerekForm extends StatefulWidget {
  final List<String> tokoList;
  final List<PabrikItem> pabrikList;
  final List<MerekItem> items;
  final ValueChanged<MerekItem> onSaved;
  final ValueChanged<MerekItem> onDelete;
  const _MerekForm({
    required this.tokoList,
    required this.pabrikList,
    required this.items,
    required this.onSaved,
    required this.onDelete,
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
    setState(() {});
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
      footer: _EntryListSection<MerekItem>(
        title: 'Daftar Merek',
        items: widget.items,
        color: const Color(0xFF7C3AED),
        icon: Icons.sell_outlined,
        titleOf: (e) => e.nama.isNotEmpty ? '${e.nama} (${e.kode})' : e.kode,
        subtitleOf: (e) => e.pabrik ?? '',
        onDelete: (e) => setState(() => widget.onDelete(e)),
      ),
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
                    content: Text('Buka menu Pabrik untuk menambah data baru')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------- FORM 4: SUPPLIER ---------------------------

class _SupplierForm extends StatefulWidget {
  final List<String> tokoList;
  final List<SupplierItem> items;
  final ValueChanged<SupplierItem> onSaved;
  final ValueChanged<SupplierItem> onDelete;
  const _SupplierForm({
    required this.tokoList,
    required this.items,
    required this.onSaved,
    required this.onDelete,
  });

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
    setState(() {});
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
      footer: _EntryListSection<SupplierItem>(
        title: 'Daftar Supplier',
        items: widget.items,
        color: const Color(0xFFD97706),
        icon: Icons.local_shipping_outlined,
        titleOf: (e) => '${e.nama} (${e.kode})',
        subtitleOf: (e) =>
            [e.kontakPerson, e.telepon].where((s) => s.isNotEmpty).join(' • '),
        onDelete: (e) => setState(() => widget.onDelete(e)),
      ),
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

// --------------------------- FORM 5: BUAT BARANG --------------------------

class _BuatBarangForm extends StatefulWidget {
  final List<String> tokoList;
  final List<SatuanItem> satuanList;
  final List<MerekItem> merekList;
  final List<SupplierItem> supplierList;
  final List<BarangItem> items;
  final ValueChanged<BarangItem> onSaved;
  final ValueChanged<BarangItem> onDelete;

  const _BuatBarangForm({
    required this.tokoList,
    required this.satuanList,
    required this.merekList,
    required this.supplierList,
    required this.items,
    required this.onSaved,
    required this.onDelete,
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
    setState(() {});
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
      footer: _EntryListSection<BarangItem>(
        title: 'Daftar Barang',
        items: widget.items,
        color: _kPrimaryDark,
        icon: Icons.inventory_2_outlined,
        titleOf: (e) => '${e.namaBarang} (${e.kodeBarang})',
        subtitleOf: (e) => [
          if (e.satuan != null) e.satuan!,
          if (e.merek != null) e.merek!,
          'Rp ${e.hargaJual.toStringAsFixed(0)}',
        ].join(' • '),
        onDelete: (e) => setState(() => widget.onDelete(e)),
      ),
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
                            Text('Buka menu Satuan untuk menambah data baru')),
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
                            Text('Buka menu Merek untuk menambah data baru')),
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
                  content: Text('Buka menu Supplier untuk menambah data baru')),
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
