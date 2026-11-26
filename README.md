# TAKARKUY Mobile

**TAKARKUY** (Tata Kelola Anggaran dan Resep, Kuy!) adalah aplikasi untuk membantu pengguna merencanakan menu makanan yang sehat, hemat, dan minim limbah makanan. Berbeda dari aplikasi resep konvensional, TAKARKUY memulai perencanaan dari anggaran dan stok bahan yang sudah tersedia, kemudian menyusun rekomendasi menu untuk hari-hari selanjutnya.


**Aplikasi web:** [alfredo-nathaniel-takarkuy.pws.cs.ui.ac.id](https://alfredo-nathaniel-takarkuy.pws.cs.ui.ac.id) 
**Desain:** [Figma](https://www.figma.com/design/EwuNvVKhBjAzQH1OYC6Cs7/Untitled?node-id=0-1&t=b5W2dmy5bpgVoPdF-1)

## Anggota Kelompok

| Nama | NPM |
| --- | --- |
| Alfredo Nathaniel Putra Harsono | 2506656412 |
| Alena Aura Deviyana | 2506656394 |
| Aiko Zahwa | 2506617140 |
| Attar Rais Hakam | 2506656495 |
| Rajendra Akbar Mahdiansyah | 2506596874 |

## Latar Belakang dan Value Proposition

### Visi

TAKARKUY bertujuan mendukung pola konsumsi pangan yang terencana, efisien secara finansial, dan ramah lingkungan. Aplikasi ini ingin membuat pola makan sehat yang terjangkau lebih mudah diakses masyarakat Indonesia tanpa menyisakan bahan makanan yang terbuang.

### Masalah yang Diselesaikan

- **Food waste rumah tangga:** bahan makanan terlupakan, kedaluwarsa, atau membusuk karena pengguna tidak tahu kapan harus mengolahnya.
- **Budget belanja tidak efisien:** pengguna kesulitan membagi anggaran makan harian atau mingguan secara realistis.
- **Nutrisi terabaikan demi hemat:** penghematan sering dilakukan dengan mengorbankan kualitas gizi.
- **Resep kurang fleksibel:** banyak aplikasi resep mengharuskan pengguna membeli bahan baru yang mahal atau tidak sesuai dengan kebiasaan masak lokal.

### Target Pengguna

- Mahasiswa dan anak kos yang membutuhkan menu bergizi dengan anggaran terbatas.
- Keluarga muda yang ingin mengoptimalkan pengeluaran dapur dan isi kulkas.
- Konsumen yang peduli lingkungan dan ingin mengurangi limbah makanan.

### Kenapa Versi Mobile

Belanja, mengecek isi kulkas, dan memasak terjadi jauh dari laptop. Versi mobile membawa fitur TAKARKUY ke tempat kegiatan itu berlangsung: memotret struk langsung di kasir, melihat daftar belanja di pasar, dan mengikuti langkah resep di dapur.

## Daftar Modul dan Pembagian Kerja

Setiap anggota memegang satu modul dari tampilan Flutter sampai endpoint API di proyek Django. Cakupan di bawah adalah rencana versi mobile dan akan diperbarui sesuai progres.

### Modul 1: Landing Page & Smart Budget Meal Planner

**PIC:** Alfredo Nathaniel Putra Harsono

- **Landing page:** layar pertama untuk guest dengan kalkulator budget (total budget, jumlah hari, jumlah orang, 2× atau 3× makan) yang menghitung budget harian per orang dan budget sekali makan.
- **Planner:** pengguna mengisi budget, durasi 1–7 hari, jumlah orang, waktu makan, target gizi, dan bahan yang dihindari. Hasilnya berupa jadwal menu per hari, daftar belanja dengan estimasi harga, total belanja dibanding budget, dan estimasi gizi harian.
- **Rencana Saya:** daftar rencana tersimpan, ganti satu menu, dan memasukkan belanjaan ke Pantry.

**CRUD:** Create membuat dan menyimpan rencana · Read melihat daftar dan detail rencana · Update mengubah judul, tanggal mulai, atau mengganti menu · Delete menghapus rencana.

### Modul 2: Smart Pantry

**PIC:** Rajendra Akbar Mahdiansyah

- **Input bahan:** memotret struk dengan kamera HP atau input manual. Hasil pindai bisa diperiksa dan diedit sebelum disimpan.
- **Virtual Pantry:** daftar stok dengan filter sudah kedaluwarsa, 7 hari ke depan, dan tanggal belum diketahui.
- **Ide menu dari stok:** saran resep dari stok yang belum kedaluwarsa.

**CRUD:** Create menambah bahan · Read melihat stok dan perkiraan kedaluwarsa · Update mengubah jumlah, satuan, lokasi simpan, dan tanggal kedaluwarsa · Delete menghapus bahan.

### Modul 3: User Account & Food Preference

**PIC:** Attar Rais Hakam

- **Autentikasi:** daftar, masuk, dan keluar memakai akun yang sama dengan versi web.
- **Profil:** nama, username, email, dan avatar.
- **Preferensi makanan:** target gizi, waktu makan, jumlah orang, alergi, dan bahan yang dihindari. Data ini menjadi nilai awal Modul 1 dan penyaring resep Modul 4.

**CRUD:** Create mendaftarkan akun · Read melihat akun dan preferensi · Update mengubah profil, kata sandi, dan preferensi · Delete belum termasuk cakupan.

### Modul 4: Recipe Book & Cooking Tracker

**PIC:** Alena Aura Deviyana

- **Recipe book:** cari resep berdasarkan nama atau bahan, dengan filter waktu makan dan favorit. Detail berisi bahan, gizi, estimasi harga, dan cara memasak; takaran menyesuaikan jumlah porsi.
- **Mode memasak:** langkah demi langkah dengan timer, cocok dipakai di dapur.
- **Sudah Masak:** mencatat riwayat masak dan mengurangi stok Pantry, lalu pengguna bisa memberi rating dan ulasan.

**CRUD:** Create menyimpan favorit, catatan, ulasan, dan riwayat masak · Read melihat resep, favorit, dan riwayat · Update mengubah catatan dan ulasan sendiri · Delete menghapus favorit, catatan, dan ulasan sendiri.

### Modul 5: Dashboard, Resep Saya & Market Locator

**PIC:** Aiko Zahwa

- **Dashboard:** layar utama setelah masuk, berisi menu hari ini, jadwal 7 hari ke depan, bahan yang segera digunakan, dan masakan terakhir.
- **Resep Saya:** membuat dan menyimpan resep pribadi (nama, waktu makan, porsi, bahan, langkah, estimasi harga).
- **Market locator:** memakai lokasi HP untuk menampilkan pasar tradisional terdekat.

**CRUD:** Create menambah resep pribadi · Read melihat Dashboard dan Resep Saya · Update mengubah resep pribadi · Delete menghapus resep pribadi.

## Peran Pengguna

| Peran | Hak Akses di Aplikasi Mobile |
| --- | --- |
| Guest | Membuka landing page dan kalkulator budget, serta daftar atau masuk. |
| Registered User | Mengelola rencana menu, daftar belanja, Virtual Pantry, profil dan preferensi, resep favorit, dan Resep Saya; melihat resep dan riwayat masak, mencatat **Sudah Masak**, serta membuka Dashboard dan market locator. |
| Administrator | Tidak memakai aplikasi mobile. Master bahan, harga referensi, dan database resep tetap dikelola lewat Django admin di versi web. |

## Alur Integrasi Aplikasi Mobile dan Web

Aplikasi mobile tidak punya database sendiri. Semua data disimpan di aplikasi web Django yang berjalan di PWS, sehingga akun, rencana, stok, dan resep yang sama terlihat di web maupun di HP.

```text
Aplikasi Flutter  ──(HTTP request)──▶  Django REST Framework (web di PWS)  ──▶  Database
       ▲                                          │
       └──────────────(respons JSON)──────────────┘
```

1. Pengguna masuk di aplikasi mobile memakai akun yang sama dengan versi web. Server membalas sebuah token, dan setiap permintaan berikutnya membawa header `Authorization: Token <token>`.
2. Saat sebuah halaman dibuka atau pengguna menyimpan perubahan, aplikasi mengirim request HTTP ke endpoint API di web.
3. Django REST Framework memeriksa login dan kepemilikan data, membaca atau mengubah database, lalu mengirim balasan dalam format JSON.
4. Aplikasi mengubah JSON tersebut menjadi objek Dart (model) dan menampilkannya di layar.
5. Perubahan dari mobile langsung tersimpan di database yang sama, sehingga ikut terlihat di versi web, begitu juga sebaliknya.

### Daftar Endpoint API

Dokumentasi lengkap yang dibuat otomatis dari kode tersedia di [Swagger](https://alfredo-nathaniel-takarkuy.pws.cs.ui.ac.id/api/docs/) dan [Redoc](https://alfredo-nathaniel-takarkuy.pws.cs.ui.ac.id/api/redoc/). Login memakai token DRF seperti Tutorial 10: `POST /api/auth/login/` membalas `{"status": true, "username": ..., "token": ...}`, lalu aplikasi mengirim `Authorization: Token <token>` di setiap request, dan `POST /api/auth/logout/` mencabut token itu (204). Semua endpoint kecuali login, logout, dan daftar wajib login dan hanya mengembalikan data milik pengguna sendiri. Aksi ubah dan hapus memakai POST ke URL aksi (`.../update/`, `.../delete/`). Body POST berupa JSON. Setiap error berbentuk `{"error": "pesan", "code": "kode"}`, ditambah `fields` untuk error per kolom.

| Modul | Method | Endpoint | Fungsi |
| --- | --- | --- | --- |
| 1 Planner | GET, POST | `/api/planner/plans/` | Daftar rencana; buat rencana (draft) dari budget |
| | GET | `/api/planner/plans/<id>/` | Detail: jadwal, daftar belanja, gizi |
| | POST | `/api/planner/plans/<id>/save/` | Simpan draft atau ubah judul dan tanggal |
| | POST | `/api/planner/plans/<id>/delete/` | Hapus rencana |
| 2 Pantry | GET, POST | `/api/pantry/items/` | Daftar stok (filter kedaluwarsa); tambah bahan |
| | GET | `/api/pantry/items/<id>/` | Detail bahan |
| | POST | `/api/pantry/items/<id>/update/` | Ubah bahan |
| | POST | `/api/pantry/items/<id>/delete/` | Buang bahan |
| | GET | `/api/pantry/items/<id>/movements/` | Riwayat perubahan stok |
| | GET | `/api/pantry/recipes/` | Ide menu dari stok |
| | POST | `/api/pantry/receipt/scan/` | Baca struk belanja |
| 3 Akun | POST | `/api/auth/login/`, `/api/auth/logout/`, `/api/auth/register/` | Masuk (menerbitkan token), keluar (mencabut token), daftar |
| | GET | `/api/auth/profile/` | Profil dan preferensi makanan |
| | POST | `/api/auth/profile/update/`, `/api/auth/preferences/update/`, `/api/auth/password/` | Ubah profil, preferensi, kata sandi |
| 4 Resep | GET | `/api/recipes/`, `/api/recipes/<kode>/` | Cari resep; detail resep |
| | GET, POST | `/api/recipes/favorites/` | Daftar favorit; tambah atau hapus favorit |
| | POST | `/api/recipes/notes/` | Simpan atau hapus catatan pribadi |
| | GET | `/api/recipes/history/` | Riwayat masak |
| | POST | `/api/recipes/cook/preview/`, `/api/recipes/cook/` | Pratinjau pemakaian stok; catat "Sudah Masak" |
| 5 Dashboard | GET | `/api/dashboard/summary/` | Ringkasan Dashboard |
| | GET, POST | `/api/dashboard/recipes/` | Daftar dan buat Resep Saya |
| | GET | `/api/dashboard/recipes/<id>/` | Detail Resep Saya |
| | POST | `/api/dashboard/recipes/<id>/update/`, `/api/dashboard/recipes/<id>/delete/` | Ubah dan hapus Resep Saya |
| | GET | `/api/dashboard/markets/` | Pasar terdekat (`lat` dan `lon`) |

Untuk memastikan semua endpoint hidup, jalankan dari folder proyek web: `python -m scripts.cek_api https://alfredo-nathaniel-takarkuy.pws.cs.ui.ac.id`. Skrip login dengan akunmu (kata sandi diketik saat berjalan), memanggil satu endpoint dari tiap modul, lalu menampilkan status masing-masing.

## Arsitektur dan Panduan Menyambungkan Modul

```text
lib/
  main.dart              akar aplikasi: ApiClient, AuthState (token), tema, router
  app/                   kerangka aplikasi (halaman awal)
  core/
    api/                 ApiConfig (alamat server) dan ApiClient (pintu ke API)
    router/              AppRoutes, go_router, dan transisi halaman
    theme/               AppColors dan AppTheme (sama dengan web)
    utils/               Debouncer dan optimistic()
    widgets/             LeftDrawer, AsyncStateView, showAppSnackBar
  features/<modul>/      satu folder per modul: data/ (model, repository), providers/, screens/, widgets/
test/                    mengikuti struktur lib/
```

Aturan bersama supaya aplikasi terasa satu produk:

- **Warna:** pakai `AppColors` (mis. `AppColors.green`, `AppColors.muted`), bukan `Color(0x...)`. AppBar, tombol, input, kartu, dan SnackBar sudah otomatis mengikuti `AppTheme`.
- **Navigasi:** pindah halaman dengan `context.push(AppRoutes.pantry)`. Rute baru didaftarkan di `lib/core/router/app_router.dart` supaya ikut mendapat transisi bersama.
- **API:** ambil `ApiClient` dengan `context.read<ApiClient>()`, lalu `await api.get('/api/...')` atau `await api.post('/api/...', {...})`. Token login dikirim otomatis. Setiap kegagalan (error server, koneksi putus, jawaban rusak) dilempar sebagai `ApiException` dengan pesan berbahasa Indonesia yang siap ditampilkan.
- **Login:** status masuk ada di `AuthState` (`context.watch<AuthState>().isAuthenticated`). Rute Planner, Pantry, Resep, Dashboard, dan Akun otomatis dialihkan ke halaman Masuk bila belum login; rute baru yang wajib login ditambahkan ke daftar `protected` di `app_router.dart`.
- **State:** simpan data modul di `ChangeNotifier` (Provider) dengan status memuat, berhasil, dan gagal, lalu tampilkan lewat `AsyncStateView` (lengkap dengan tombol "Coba lagi").
- **Interaksi:** pencarian memakai `Debouncer`, hapus atau ubah yang langsung terlihat memakai `optimistic()` dengan tombol "Batal" di `showAppSnackBar`.

Contoh singkat memuat data di sebuah halaman:

```dart
final api = context.read<ApiClient>();
try {
  final rows = await api.get('/api/planner/plans/') as List;
  plans = rows.map((row) => BudgetPlan.fromJson(row)).toList();
} on ApiException catch (error) {
  showAppSnackBar(context, error.message, error: true);
}
```

**Tes tanpa internet:** jalankan aplikasi dengan `MockClient` dari `package:http/testing.dart` sebagai server palsu dan token tes, lalu periksa tampilan dan request yang terjadi.

```dart
final client = MockClient((request) async {
  expect(request.url.path, '/api/planner/plans/');
  expect(request.headers['authorization'], 'Token test-token');
  return http.Response('[]', 200);
});
await tester.pumpWidget(TakarKuyApp(client: client, initialToken: 'test-token'));
```

**Alur kerja tiap anggota:** satu branch per modul (`modul-<nama>`), commit `test:` dulu lalu `feat:`/`fix:`, `flutter analyze` dan `flutter test` hijau sebelum push, lalu pull request ke `main` yang wajib di-review satu anggota lain dan diperiksa CodeRabbit.

## Menjalankan Secara Lokal

**Prasyarat:** Flutter SDK (channel stable, Dart 3.13 atau lebih baru), Git, serta Android Studio dengan emulator Android atau HP Android dengan USB debugging. Google Chrome bisa dipakai untuk mencoba versi web.

```bash
git clone https://github.com/PBPUY-11-C/TAKARKUY-APK.git
cd TAKARKUY-APK

flutter pub get
flutter devices        # cek emulator, HP, atau Chrome yang terdeteksi
flutter run            # jalankan di perangkat yang tersedia
# atau: flutter run -d chrome
```

Cek kode dan jalankan tes dengan `flutter analyze` dan `flutter test`. Untuk membuat APK: `flutter build apk --release` (hasilnya di `build/app/outputs/flutter-apk/`).

Secara bawaan aplikasi memakai server PWS. Untuk mencoba dengan Django di laptop, jalankan server web (`python manage.py runserver`) lalu:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Django sudah mengizinkan Flutter dari `localhost` memanggil `/api/` (CORS), jadi login dan data bisa dicoba langsung di Chrome.