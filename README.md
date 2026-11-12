# Mandiri Mobile — Flutter Demo

Aplikasi prototype edukasi dengan tampilan mobile banking bergaya biru-kuning. Bukan aplikasi resmi Bank Mandiri.

## Jalankan
Persyaratan: Flutter SDK dan Android Studio/VS Code sudah terpasang.

```bash
flutter doctor
flutter pub get
flutter run
```

Untuk menjalankan di browser:
```bash
flutter run -d chrome
```

## Akun demo
- Email: `demo@mandiri.test`
- Password: `123456`

Bisa juga membuat akun dari halaman Daftar. Akun dan transaksi hanya tersimpan sementara selama aplikasi berjalan; data akan kembali ke kondisi awal setelah aplikasi ditutup.

## Fitur yang dapat dicoba
- Login dan registrasi lokal (validasi input)
- Dashboard dan saldo contoh (tombol sembunyikan saldo)
- Transfer simulasi: saldo berkurang dan transaksi masuk ke riwayat
- QRIS simulasi: nominal pembayaran dan transaksi tercatat
- Riwayat transaksi
- Profil dan logout

## Tentang Firebase
Project ini sengaja dibuat tanpa dependency Firebase agar dapat langsung dijalankan tanpa file konfigurasi. Firebase belum diaktifkan dan tidak ada data yang dikirim ke server.
Untuk menghubungkan Firebase pada project Firebase milik Anda:
1. Install Firebase CLI dan FlutterFire CLI.
2. Dari folder project jalankan `flutterfire configure`.
3. Pilih project Firebase Anda.
4. Tambahkan package `firebase_core`, `firebase_auth`, dan `cloud_firestore`.
5. Inisialisasi Firebase pada `main()` memakai `DefaultFirebaseOptions.currentPlatform`.
6. Ganti penyimpanan lokal `DemoStore` dengan Firebase Authentication dan Cloud Firestore, lalu atur Firestore Security Rules.

Jangan memasukkan token, password rekening, PIN, atau data nasabah asli ke prototype. Integrasi pembayaran/perbankan sungguhan memerlukan API resmi dan persetujuan penyedia layanan.
