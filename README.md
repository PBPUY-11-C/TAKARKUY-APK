# TAKARKUY Mobile

**TAKARKUY** (Tata Kelola Anggaran dan Resep, Kuy!) adalah aplikasi untuk membantu pengguna merencanakan menu makanan yang sehat, hemat, dan minim limbah makanan. Berbeda dari aplikasi resep konvensional, TAKARKUY memulai perencanaan dari anggaran dan stok bahan yang sudah tersedia, kemudian menyusun rekomendasi menu untuk hari-hari selanjutnya.

Repositori ini berisi versi mobile (Flutter) dari TAKARKUY. Aplikasi tidak menyimpan data statis: semua data (akun, rencana, stok, resep) diambil dari dan dikirim ke versi web yang berjalan di PWS ([repositori web](https://github.com/PBPUY-11-C/TAKARKUY)).

**Aplikasi web:** [alfredo-nathaniel-takarkuy.pws.cs.ui.ac.id](https://alfredo-nathaniel-takarkuy.pws.cs.ui.ac.id) · **Desain:** [Figma](https://www.figma.com/design/EwuNvVKhBjAzQH1OYC6Cs7/Untitled?node-id=0-1&t=b5W2dmy5bpgVoPdF-1) · **Data & API:** [DATA_API.md](https://github.com/PBPUY-11-C/TAKARKUY/blob/main/DATA_API.md) · **APK:** menyusul

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