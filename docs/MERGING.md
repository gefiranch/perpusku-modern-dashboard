# Menggabungkan redesign ke repo kelompok

Fork hasil redesign: https://github.com/gefiranch/perpusku-modern-dashboard
Repo asal: https://github.com/REMITMID/projekakhirpamp

Riwayat commit asal dipertahankan. Penggabungan tidak memerlukan
`--allow-unrelated-histories`.

## Pilihan 1 — pull request di GitHub

1. Buka fork hasil redesign.
2. Klik **Contribute**, lalu **Open pull request**.
3. Pastikan base repository `REMITMID/projekakhirpamp`, base branch `main`,
   head repository `gefiranch/perpusku-modern-dashboard`, compare branch `main`.
4. Tinjau tab **Files changed**, lalu buat pull request.
5. Anggota kelompok meninjau perubahan dan melakukan merge setelah disetujui.

## Pilihan 2 — merge di clone repo teman

Jalankan di folder clone repo kelompok yang sedang berada pada branch `main`
yang sudah diperbarui. Simpan pekerjaan lokal terlebih dahulu.

```bash
git remote add redesign https://github.com/gefiranch/perpusku-modern-dashboard.git
git fetch redesign
git switch -c review/perpusku-redesign
git merge redesign/main
flutter pub get
flutter analyze
flutter test
git push -u origin review/perpusku-redesign
```

Jika remote bernama `redesign` sudah ada dan menunjuk fork ini, lewati perintah
`git remote add`. Bila muncul konflik, selesaikan file yang ditandai, kemudian
`git add` file tersebut dan `git commit`. Jika belum ingin menyelesaikan konflik,
`git merge --abort` membatalkan proses merge yang sedang berlangsung.

Setelah branch review berhasil di-push, buat PR dari `review/perpusku-redesign`
ke `main` di repo kelompok. Periksa login, CRUD dan konfigurasi Supabase asli
sebelum kelompok melakukan merge.

## Konfigurasi lokal

`.env` tidak ada di repository. Salin `.env.example` menjadi `.env`, lalu isi
nilai Supabase proyek kelompok. File konfigurasi lokal ini tetap diabaikan Git.
