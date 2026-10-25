# PerpusKu — panduan hasil redesign

Implementasi dimulai dari `main` pada commit
`0e27e1178d5a13b4841a978789cb0801259d4cc8` dan dikerjakan di
`redesign/minimal-dashboard-responsive`.

## Perubahan

- Tema navy, latar terang, border tipis, ukuran tombol dan hierarki teks konsisten.
- Beranda berisi jumlah judul, anggota, reservasi dan reservasi menunggu dari
  Provider asli, serta daftar reservasi terkini dan akses form cepat.
- Sidebar desktop, rail tablet, serta Beranda/Katalog/Reservasi/Lainnya di mobile.
  Anggota, Kategori & Rak dan Keluar tersedia lewat Lainnya.
- Daftar berupa tabel pada desktop dan kartu pada layar kecil; list/grid dan
  pencarian/filter yang sudah ada tetap terhubung ke Provider.
- Form auth menggunakan panel branding di desktop. Form CRUD dibatasi lebarnya;
  field tahun/stok buku menjadi satu kolom di mobile. Detail buku/reservasi
  menampilkan informasi dan aksi yang terkelompok.
- Error reservasi/kategori dapat dicoba ulang. Kegagalan simpan mempertahankan
  input, kegagalan hapus diberi feedback. Provider mencegah operasi tulis ganda
  dan menggabungkan permintaan baca bersamaan.
- Pencarian dan halaman yang pernah dibuka dipertahankan saat navigasi/resize.

Repository, model, schema, RLS dan isi konfigurasi Supabase tidak diubah.
Nama parameter SDK `anonKey` diperbarui ke `publishableKey` dengan nilai
`SUPABASE_ANON_KEY` yang sama. Tidak ada dependency baru atau data contoh dalam
kode produksi. Konstruktor Provider menerima repository opsional untuk tes;
jalur aplikasi tetap membuat repository asli secara default.

## File utama

| File / area | Peran |
|---|---|
| `lib/core/theme/app_theme.dart` | Warna, tipografi, kontrol dan surface |
| `lib/core/widgets/app_layout.dart` | Form/layout, feedback, badge, dialog, toolbar |
| `lib/core/widgets/record_collection.dart` | Tabel/kartu adaptif |
| `lib/features/dashboard/presentation/pages/` | Shell dan overview |
| `lib/features/*/presentation/pages/` | Auth, daftar, form, detail |
| Provider katalog/reservasi/kategori | Request, loading, error, guard simpan |
| `test/*breakpoints_test.dart`, `responsive_layout_test.dart` | Ukuran, navigasi, resize |
| `test/provider_recovery_test.dart` | Gagal fetch/hapus, retry, request bersamaan |

## Menjalankan di komputer sendiri

Repository hasil: https://github.com/gefiranch/perpusku-modern-dashboard

Repository ini adalah fork dari `REMITMID/projekakhirpamp`, dengan riwayat commit
asal dipertahankan agar perubahan dapat digabungkan secara normal.

```bash
git clone https://github.com/gefiranch/perpusku-modern-dashboard.git
cd perpusku-modern-dashboard
flutter pub get
```

Salin `.env.example` menjadi `.env`, isi konfigurasi Supabase, lalu jalankan:

```bash
flutter analyze
flutter test
flutter run -d windows
```

Untuk menggabungkan ke repo teman, baca [MERGING.md](MERGING.md).
Gunakan `.env` Supabase milik proyek
sesuai README sebelum menjalankan aplikasi. `.env` tidak disertakan dalam commit.
Untuk Android, pilih ID perangkat dari `flutter devices`, lalu `flutter run -d ID`.

## Batas verifikasi

Tes UI menggunakan repository palsu hanya di direktori test, tanpa akses jaringan
atau data produksi. Tangkapan layar offline, bila dihasilkan, menampilkan keadaan
kosong untuk memperlihatkan layout; angka nol bukan data Supabase pengguna.

Login/registrasi/logout dan CRUD terhadap Supabase asli memerlukan smoke test
menggunakan konfigurasi proyek. Build Windows memerlukan host Windows dan build
Android memerlukan Android SDK. Hasil pemeriksaan yang benar-benar dijalankan
dicatat dalam `REDESIGN_QA.md`.
