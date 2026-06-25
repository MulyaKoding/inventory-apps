# Inventory Marketplace

Aplikasi manajemen inventory produk untuk multi-marketplace, dibangun dengan Flutter dan MongoDB.

## Fitur

- Dashboard ringkasan statistik inventory (total produk, stok habis, nilai stok, jumlah marketplace aktif)
- Daftar produk dengan pencarian (nama/SKU) dan filter status stok
- Status stok otomatis: Aktif, Rendah, Habis
- Label marketplace per produk (Shopee, Tokopedia, dll)
- Paginasi daftar produk

## Tech Stack

- **Framework**: Flutter
- **Database**: MongoDB Atlas (lewat package [`mongo_dart`](https://pub.dev/packages/mongo_dart))
- **Environment config**: [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv)

## Catatan Platform

Koneksi `mongo_dart` ke MongoDB membutuhkan akses socket TCP langsung, yang **tidak didukung di Flutter Web** (Chrome/Edge/browser apapun) karena batasan keamanan browser. Jalankan aplikasi ini di salah satu target berikut:

- ✅ Android
- ✅ iOS
- ✅ Windows Desktop (butuh Visual Studio dengan workload "Desktop development with C++")
- ✅ macOS / Linux Desktop
- ❌ Web (Chrome/Edge) — tidak didukung untuk koneksi database langsung

## Setup

1. Clone repository ini
   ```bash
   git clone https://github.com/MulyaKoding/inventory-apps.git
   cd inventory-apps
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Buat file `.env` di root project (sejajar `pubspec.yaml`), isi dengan connection string MongoDB Anda sendiri:
   ```
   DATABASE_URL=mongodb+srv://<username>:<password>@<cluster-url>/<database>?retryWrites=true&w=majority
   ```
   
   Lihat `.env.example` sebagai referensi format. **Jangan pernah commit file `.env`** — sudah di-ignore lewat `.gitignore`.

4. Jalankan aplikasi (pilih target non-web)
   ```bash
   flutter run
   ```

## Struktur Project

```
lib/
  models/         # Product, Marketplace, InventoryStats
  screens/        # HomeScreen, InventoryScreen
  services/       # MongoDBService, InventoryService
  utils/          # constants, theme
  widgets/        # custom reusable widgets
  main.dart
```

## Lisensi

Project pribadi — belum ditentukan lisensinya.