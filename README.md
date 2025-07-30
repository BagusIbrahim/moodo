# Moodo
Aplikasi to-do list modern yang dirancang untuk membantu Anda mengelola tugas harian dengan antarmuka yang bersih, intuitif, dan fungsional.

## Fitur Utama
✅ Manajemen Tugas (CRUD) - Tambah, lihat, edit, dan hapus tugas dengan mudah.

📅 Kalender Interaktif - Navigasi dan filter tugas berdasarkan tanggal dengan tampilan kalender yang responsif.

🔔 Notifikasi Pengingat - Dapatkan pengingat untuk setiap tugas sebelum tenggat waktu.

🔍 Penyortiran & Pencarian - Urutkan tugas berdasarkan waktu atau prioritas, dan temukan tugas dengan cepat.

🎨 Personalisasi Tema - Pilih antara mode terang (light mode) dan gelap (dark mode).

🖼️ Dokumentasi Foto - Lampirkan gambar dari galeri ke setiap tugas sebagai dokumentasi visual.

📦 Penyimpanan Lokal - Semua data disimpan secara lokal di perangkat menggunakan Hive untuk akses yang cepat dan offline.


## Teknologi yang Digunakan
Framework: Flutter - Framework UI modern dari Google untuk membangun aplikasi mobile, web, dan desktop dari satu basis kode.

Bahasa: Dart - Bahasa pemrograman yang dioptimalkan untuk membangun antarmuka pengguna yang cepat di berbagai platform.

Database Lokal: hive & hive_flutter - Database NoSQL yang sangat cepat dan ringan, ideal untuk penyimpanan data di perangkat secara offline.

Manajemen State: provider - Pendekatan sederhana dan efisien untuk mengelola state aplikasi, digunakan di sini untuk fungsionalitas tema.

Notifikasi: flutter_local_notifications - Plugin untuk menampilkan notifikasi lokal yang dapat dijadwalkan, berfungsi sebagai pengingat tugas.

### UI & Paket Pendukung
google_fonts - Memungkinkan akses mudah ke ribuan font dari Google Fonts untuk memperkaya tipografi aplikasi.

intl - Digunakan untuk internasionalisasi dan lokalisasi, terutama untuk memformat tanggal dan waktu ke dalam format bahasa Indonesia.

table_calendar - Widget kalender yang sangat dapat dikustomisasi dan fungsional untuk menampilkan dan memilih tanggal.

image_picker - Plugin untuk mengambil gambar dari galeri atau kamera perangkat.

timezone - Diperlukan oleh flutter_local_notifications untuk menangani penjadwalan notifikasi secara akurat berdasarkan zona waktu perangkat.

## Petunjuk Instalasi
Untuk menjalankan proyek ini secara lokal, ikuti langkah-langkah berikut:


Prasyarat
Pastikan Anda telah menginstal Flutter SDK.
Siapkan emulator (Android/iOS) atau hubungkan perangkat fisik.


Clone Repositori
```
git clone https://github.com/BagusIbrahim/moodo.git
```

```
cd moodo
```


Instal Dependensi
```
flutter pub get
```

Jalankan Build Runner
Perintah ini diperlukan untuk menghasilkan file adapter untuk Hive.

```
flutter pub run build_runner build --delete-conflicting-outputs
```

Jalankan Aplikasi
```
flutter run
```
## Struktur Proyek

```
lib
├── models # Berisi model data (todo.dart)
├── screens # Berisi semua file UI aplikasi
├── services # Berisi logika bisnis (hive, notifikasi, tema)
└── main.dart # Titik masuk aplikasi dan konfigurasi global
```

## Tim Pengembang
Proyek ini dikembangkan secara kolaboratif oleh:

Bagus Ibrahim - Frontend / UI/UX Lead

M Ramdani Yumansyah - Backend / Logic Lead

Muhammad Ustman Muzakki - Project Manager & QA
