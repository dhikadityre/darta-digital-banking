# TapCash iOS Application (SwiftUI)

Client iOS Native untuk aplikasi **TapCash**. Aplikasi ini mengintegrasikan authentication pengguna, simulasi saldo & batas penarikan, pembuatan tiket penarikan QR berkode server-signed, serta mode Cashier untuk memindai dan mencairkan kode QR secara real-time.

---

## 📱 Fitur Utama

- **Customer Mode**:
  - Simulasi saldo & batas penarikan harian/per transaksi via endpoint `/api/accounts/{email}/limits`.
  - Penghitung mundur aktif & penyegaran otomatis kode QR sebelum kedaluwarsa.
- **Cashier Mode**:
  - Pemindaian kode QR menggunakan kamera fisik (`AVCaptureMetadataOutput`) untuk proses pencairan dana instan melalui `/api/withdrawals/dispense`.
  - Penanganan izin kamera secara kontekstual dengan fallback navigasi ke Settings.
- **In-App Debugger**:
  - Terintegrasi dengan `DebugSwift` untuk memantau performa, log network, dan configuration environment langsung di dalam aplikasi.

---

## 🛠️ System Requirements

| Requirement | Minimum Version | Description |
| :--- | :--- | :--- |
| **Operating System** | macOS Sequoia (atau kompatibel) | Dibutuhkan untuk menjalankan Xcode terbaru |
| **Xcode Version** | `16.2+` | Dibutuhkan dukungan Swift 6.2 compiler |
| **Swift Version** | `6.2` | Mengaktifkan strict concurrency checks |
| **iOS Deployment Target** | `iOS 16.0+` | Menggunakan fitur SwiftUI & NavigationStack modern |
| **Physical Device** | Dibutuhkan untuk Cashier Mode | Simulator Xcode tidak memiliki kamera fisik |

---

## 📐 Architecture Overview

Project ini menerapkan prinsip **Clean Architecture & SOLID** yang ter-decouple secara ketat menggunakan **Modular Local Swift Package Manager (SPM)**:

```
ios/
├── TapCash/                         # Main Target (Presentation & UI Layer)
│   ├── App/                         # TapCashApp entry point & Lifecycle Coordinator
│   ├── Presentation/                # SwiftUI Views, ViewModels, & Router Coordinator
│   ├── Utilities/                   # Helpers & Extensions
│   └── XCConfig/                    # [NEW/LOCAL] Berkas configuration build target (.xcconfig)
│
├── CoreDomain/                      # Local SPM Package (Domain Layer)
│   ├── Sources/CoreDomain/          # Business Logic Inti: Entities, Use Cases, & Repository Contracts
│   └── Tests/CoreDomainTests/       # Unit Test khusus Business Logic murni (Cepat, Tanpa Simulator)
│
└── PackageData/                     # Local SPM Package (Data Layer)
    ├── Sources/PackageData/         # Infrastruktur: API Client, DTOs, Mappers, & Concrete Repositories
    └── Tests/PackageDataTests/      # Unit Test integration data & parsing (Cepat, Tanpa Simulator)
```

---

## 📦 Dependency & Library yang Digunakan

Project membagi dependency menjadi dua kategori utama:

1. **Modular Local Package (Swift Package Manager)**:
   - [CoreDomain](file:///Users/dhikadityre/Documents/Project/MediatamaIdTech/BSN/POC/ios/CoreDomain) - Berisi Entity, UseCase, dan Protokol abstraksi.
   - [PackageData](file:///Users/dhikadityre/Documents/Project/MediatamaIdTech/BSN/POC/ios/PackageData) - Berisi implementasi repositori, REST API client, DTO, dan pemetaan data.
2. **Third-Party Package (Remote SPM)**:
   - [DebugSwift](https://github.com/DebugSwift/DebugSwift) (`1.18.0`) - Toolkit debugging dalam aplikasi untuk inspeksi HTTP request, performa UI, dan CoreData/File logs.

---

## ⚙️ Panduan Setup Configuration (`XCConfig`)

Untuk alasan keamanan data sensitif dan kredensial API, seluruh berkas configuration `.xcconfig` dimasukkan ke dalam `.gitignore` dan **TIDAK** disimpan ke dalam repositori Git.

### Langkah-langkah Setup:

1. **Dapatkan File Kredensial**:
   - Pastikan Anda telah memiliki berkas `XCConfig.zip` (jika belum punya, silakan hubungi/minta ke **Lead Developer**).
2. **Penempatan Berkas**:
   - Salin dan letakkan berkas `XCConfig.zip` di dalam folder `TapCash/` (sejajar dengan file `TapCash.xcodeproj`).
   - *Lokasi target*: `ios/TapCash/XCConfig.zip`
3. **Jalankan Script Instalasi**:
   - Buka Terminal di root direktori project, lalu jalankan script setup berikut:
     ```bash
     chmod +x TapCash/script/setup_xcconfig.sh
     ./TapCash/script/setup_xcconfig.sh
     ```
   - *Apa yang dilakukan script ini?*
     - Mengekstrak berkas `XCConfig.zip` ke folder target `TapCash/XCConfig/`.
     - Melakukan backup jika folder target sudah ada sebelumnya.
     - Membersihkan cache Xcode build & Derived Data secara lokal.
     - Melakukan sinkronisasi serta resolve Package Dependencies project.
4. **Verifikasi Penempatan File**:
   Setelah script berhasil dijalankan, pastikan folder `TapCash/XCConfig/` telah terisi berkas configuration berikut:
   - `Base.xcconfig` - Configuration dasar project.
   - `Development.xcconfig` - Kredensial & URL API dev.
   - `Staging.xcconfig` - Configuration server staging.
   - `UAT.xcconfig` - Configuration server testing UAT.
   - `Production.xcconfig` - Configuration server production.

---

## 🚀 Build Schemes & Environments

Project ini memiliki beberapa scheme target yang disesuaikan dengan siklus rilis dan kebutuhan pengujian:

- **`TapCash-Development`**: Menghubungkan aplikasi ke server dev.
- **`TapCash-Staging`**: Digunakan untuk pengujian integration internal di environment staging.
- **`TapCash-UAT`**: Digunakan untuk pengujian penerimaan pengguna (User Acceptance Testing) dengan data yang menyerupai production.
- **`TapCash-Production`**: Configuration final untuk distribusi App Store dengan proteksi keamanan maksimum.
- **`TapCashPresentationTest`**: Scheme khusus untuk menjalankan pengujian UI & Presentation Layer di simulator.

> [!TIP]
> Saat berpindah scheme di Xcode, pastikan scheme yang dipilih sesuai dengan target server API yang dituju agar pengujian data berjalan lancar.

---

## 🧪 Running Unit Tests

Untuk mempercepat proses pengembangan dan integration CI/CD (Jenkins), unit test dalam project ini dirancang agar dapat dieksekusi secara efisien:

### 1. Unit Test Standalone di Environment macOS (Sangat Cepat ⚡)
Unit test untuk module CoreDomain dan PackageData tidak memerlukan simulator iOS sehingga dapat dieksekusi langsung secara native menggunakan Swift compiler di mesin Mac Anda. Hal ini memangkas waktu start-up simulator secara signifikan.

Pengujian ini dapat dijalankan melalui dua cara:

#### A. Menggunakan Xcode Scheme
Buka project di Xcode, lalu pilih dan jalankan target scheme berikut:
- **`CoreDomain`**: Scheme untuk menjalankan unit test khusus Business Logic di module CoreDomain.
- **`PackageData`**: Scheme untuk menjalankan unit test integration data di module PackageData.
*(Pilih scheme lalu tekan shortcut `Cmd + U` untuk mengeksekusi test).*

#### B. Menggunakan Swift CLI (Terminal / Jenkins)
Eksekusi pengujian langsung menggunakan command line dari direktori module masing-masing:
- **CoreDomain**:
  ```bash
  cd CoreDomain && swift test
  ```
    *(Atau jalankan menggunakan scheme `CoreDomain` di Xcode)*

- **PackageData**:
  ```bash
  cd PackageData && swift test
  ```
    *(Atau jalankan menggunakan scheme `PackageData` di Xcode)*

### 2. Unit Test Presentation & UI (Menggunakan Simulator iOS)
Untuk menguji UI Component dan Presentation Flow, gunakan scheme `TapCashPresentationTest` yang akan dijalankan di Simulator iOS.
- **Melalui Xcode**: Pilih scheme `TapCashPresentationTest` -> tekan `Cmd + U`.
- **Melalui Terminal / Jenkins**: Jalankan runner script terpadu:
  ```bash
  ./TapCash/script/run_tests.sh
  ```
  *(Script ini akan mendeteksi simulator iPhone yang kompatibel secara otomatis dan mengeksekusi test target).*

---

## 🔑 Kredensial Uji Coba (Demo Credentials)

Untuk masuk ke dalam aplikasi di lingkungan pengujian, gunakan akun berikut:
* **Username**: `alex@tapcash.demo`
* **Password**: `cash1234`

*Catatan: Seluruh data saldo, mutasi, dan penarikan yang tertera merupakan data simulasi.*
