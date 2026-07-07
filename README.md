
# Smart TV Remote CLI 

 alat antarmuka baris perintah (CLI) yang sepenuhnya nyata, berfungsi penuh, dan aman secara tipe (type-safe), yang ditulis menggunakan Haskell untuk menemukan dan mengendalikan Smart TV (Android TV, Samsung Tizen, dan LG WebOS) melalui jaringan Wi-Fi lokal.


Developed by **Mr.Rm19** ([github.com/Rm19x](https://github.com/Rm19x)).

---

##  Fitur 

Aplikasi ini mengimplementasikan 15 fitur esensial pilihan yang berkomunikasi langsung dengan perangkat TV Anda melalui socket jaringan lokal (TCP, UDP, dan WebSockets):

1. **Auto-Discovery :** Mencari semua Smart TV yang menyala di jaringan Wi-Fi rumah secara otomatis menggunakan protokol SSDP/UDP.
2. **Manual Pairing:** Mendukung koneksi manual menggunakan IP Address jika TV dikonfigurasi tersembunyi atau fitur broadcast diblokir oleh router.
3. **Interactive Mode:** Mengubah terminal laptop menjadi remote interaktif. Menangkap ketukan keyboard secara *real-time* (W/A/S/D) untuk mengontrol TV tanpa perlu menekan Enter.
4. **Volume Control :** Kendali penuh untuk menaikkan volume (`volup`), menurunkan volume (`voldown`), dan membisukan suara (`mute`).
5. **Standard Navigation:** Akses tombol navigasi dasar: Atas, Bawah, Kiri, Kanan, OK/Select, Back, dan Home.
6. **App Shortcuts :** Pintasan cepat untuk meluncurkan aplikasi populer seperti YouTube, Netflix, Spotify, dan Prime Video menggunakan ID aplikasi resmi TV.
7. **Power Toggle:** Mematikan atau menyalakan TV dari mode standby langsung melalui baris perintah.
8. **Channel Switching :** Berpindah saluran TV (Channel Up / Channel Down) secara instan.
9. **Media Control Panel :** Tombol kontrol media standar untuk memutar konten (Play, Pause, Stop).
10. **Auto Timer :** Mengatur pewaktu otomatis di latar belakang untuk mematikan TV setelah durasi tertentu.
11. **Notification Management :** Mengirim pesan teks kustom dari terminal laptop untuk dimunculkan sebagai *pop-up toast* resmi di layar TV (khusus WebOS).
12. **Auto Token Authentication :** Menyimpan token akses keamanan setelah pemasangan pertama ke dalam berkas konfigurasi lokal (~/.config/tv-remote-cli/config.json). Anda tidak perlu menekan tombol "Izinkan/Allow" di layar TV berulang kali.
13. **Panic Button :** Memutus semua koneksi socket yang menggantung dan mereset status jaringan remote secara darurat jika terjadi kemacetan komunikasi.
14. **Reboot TV :** Mengirim perintah sistem tingkat rendah (seperti ADB reboot pada Android TV) untuk memaksa TV melakukan *restart system*.
15. **Alias Command :** Membuat nama panggilan singkat untuk perintah yang panjang (contoh: cukup ketik nama alias `yt` untuk menyalakan TV dan otomatis membuka YouTube).

---

## cara pakai nya seperti ini

###  Persiapan pada Android TV (Wajib)
Agar Android TV Anda menerima perintah dari jaringan lokal:
* Buka **Pengaturan** -> **Setelan Perangkat** -> **Tentang**.
* Klik menu **Build (Nomor Bentukan)** sebanyak **7 kali** sampai muncul pesan pengembang.
* Kembali ke menu sebelumnya, buka **Opsi Pengembang**.
* Aktifkan **Debugging USB** dan **Debugging Nirkabel (Wireless Debugging / ADB over Wi-Fi)**.

### Instalasi Haskell Compiler
Pastikan komputer Anda sudah terpasang Haskell compiler (`GHC`) dan manajer paket (`Cabal`) melalui [GHCup](https://www.haskell.org/ghcup/):

```bash
Buka PowerShell (cari di Start Menu, lalu klik kanan dan pilih Run as Administrator).

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; try { Invoke-Command -ScriptBlock ([ScriptBlock]::Create((Invoke-WebRequest https://www.haskell.org/ghcup/sh/bootstrap-haskell.ps1 -UseBasicParsing))) -ArgumentList $true } catch { Write-Error $_ }
```
## Jika Kamu Menggunakan Linux atau macOS
```
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

Ikuti petunjuk di layar terminal. Sama seperti di Windows, cukup tekan Enter untuk menyetujui semua pilihan rekomendasi standar.

Setelah instalasi selesai, muat ulang konfigurasi terminalmu dengan perintah:

source ~/.bashrc
```
## Verifikasi instalasi di terminal Anda
```
ghc --version
cabal --version
cabal update
cabal build
```

## Gunakan perintah :
```
 cabal run tv-remote -- [perintah] untuk mengoperasikan alat ini
 cabal run tv-remote -- scan
 cabal run tv-remote -- connect -i 192.168.1.50 -t android
 cabal run tv-remote -- send -i [IP_TV] -t [TIPE_TV] [PERINTAH]
 cabal run tv-remote -- send -i 192.168.1.50 -t android power
 cabal run tv-remote -- send -i 192.168.1.15 -t tizen volup
 cabal run tv-remote -- send -i 192.168.1.50 -t android reboot
 cabal run tv-remote -- send -i 192.168.1.20 -t webos toast "Halo dari Mr.Rm19!"
 cabal run tv-remote -- alias -n nonton -g "send -i 192.168.1.50 -t android power"
 ```

 #### script oleh Mr.Rm19. Berkas ini dilindungi hak cipta. Anda diizinkan untuk memodifikasi dan membagikannya kembali di bawah ketentuan Lisensi MIT.
