# Hasil pemeriksaan PerpusKu

Tanggal: 26 Oktober 2026. Baseline `0e27e1178d5a13b4841a978789cb0801259d4cc8`.
Lingkungan: Linux; Flutter 3.47.8 stable, Dart 3.13.7.

| Pemeriksaan | Hasil |
|---|---|
| Resolusi dependency dari lockfile | Berhasil; pubspec dan lockfile tidak berubah |
| `dart format` untuk 25 file Dart yang diubah/ditambahkan | Lolos, 0 perubahan format tersisa |
| `dart analyze` | No issues found |
| `flutter analyze --no-pub` | Lolos, No issues found |
| `flutter test --no-pub` | **145 tes lolos**, termasuk seluruh tes lama |
| Screenshot overview mobile dan desktop | Render widget aktual diperiksa secara visual; data kosong dari repository tes |
| `git diff --check` | Lolos |
| Build Windows / Android | Tidak dijalankan; host Windows dan Android SDK tidak tersedia |
| Smoke test terhadap Supabase asli | Belum diverifikasi; kredensial proyek tidak tersedia |

Tes memakai repository palsu hanya di direktori `test/`. Tidak ada data palsu atau
statistik hardcoded dalam aplikasi produksi. Tidak ada permintaan ke Supabase asli
selama tes. Inisialisasi auth tes memakai penyimpanan memori tanpa plugin platform.

## Cakupan responsif dan interaksi

Lebar 320, 360, 390, 430, 600, 768, 900, 1024, 1280, 1440 dan 1920 logical pixels,
dengan skala teks 1,0 serta 1,3:

- Semua modul dapat dibuka melalui bottom navigation/menu Lainnya, rail dan sidebar.
- Form buku, reservasi dan kategori tidak menunjukkan overflow pada bagian atas
  maupun setelah di-scroll ke field bawah.
- Tabel/kartu dan tombol aksi dapat ditampilkan dan digunakan.
- Input anggota bertahan saat resize; pencarian katalog bertahan saat perpindahan
  modul dan perubahan mobile ke desktop.
- AuthLayout mempertahankan state field ketika panel branding muncul/hilang.
- Error fetch reservasi/kategori dapat dicoba ulang; error delete dilepas dengan
  state simpan kembali normal; permintaan baca reservasi bersamaan digabungkan.
- Tes anggota yang sudah ada tetap memeriksa validasi, normalisasi, duplicate,
  create/update/delete, pembatalan, kegagalan akses/koneksi dan aksi ganda.
- Tes katalog yang sudah ada tetap memeriksa model serta validasi dan prefill form.

Dua masalah sidebar yang ditemukan oleh tes (lapisan Material dan overflow logo)
telah diperbaiki sebelum pengujian akhir. Perubahan ikon panah setelah pemeriksaan
visual diverifikasi kembali melalui tes render overview.

Screenshot merupakan keadaan kosong offline, bukan data perpustakaan pengguna:

- [Desktop](screenshots/desktop_overview.png)
- [Mobile](screenshots/mobile_overview.png)

Source, tes dan screenshot disertakan dalam fork `gefiranch/perpusku-modern-dashboard`.
Repository asal tetap terpisah; penggabungan dilakukan melalui review/PR.

## Pemeriksaan lanjutan di lingkungan proyek

Jalankan dengan `.env` yang sudah dimiliki, lalu periksa login, registrasi, logout,
CRUD keempat modul, pencarian/filter, list/grid dan tanggal reservasi pada perangkat
Windows/Android. Uji keyboard virtual dan koneksi terputus pada perangkat asli.
Ini diperlukan sebelum menyatakan integrasi database dan build platform terverifikasi.
