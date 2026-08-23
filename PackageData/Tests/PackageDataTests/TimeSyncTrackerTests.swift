import XCTest
@testable import PackageData

/// `TimeSyncTrackerTests` bertujuan untuk memvalidasi mekanisme sinkronisasi waktu antara Client (iOS) dan Server.
///
/// Latar Belakang:
/// Jam lokal pada perangkat iOS pengguna bisa saja tidak akurat (misal: dimundurkan/dimajukan secara manual).
/// `TimeSyncTracker` melacak perbedaan ini dengan menghitung offset:
///
///     timeOffset = ServerTime - ClientLocalTime
///
/// Karena jam berjalan terus setiap milidetik saat tes dieksekusi, pengujian menggunakan nilai statis murni akan
/// menghasilkan tes yang tidak stabil (flaky). Untuk mengatasinya, kita menggunakan perhitungan estimasi interval waktu.
final class TimeSyncTrackerTests: XCTestCase {
    private var sut: TimeSyncTracker!
    
    override func setUp() {
        super.setUp()
        sut = TimeSyncTracker.shared
    }
    
    func test_syncTime_withStandardFormat_setsOffset() {
        // Given: Tanggal server simulasi dalam format standar HTTP RFC 1123
        let serverDateString = "Sun, 23 Aug 2026 07:00:00 GMT"
        
        // Sebelum melakukan sinkronisasi, kita catat waktu client terlebih dahulu
        let clientBefore = Date()
        
        // When: Jalankan sinkronisasi waktu
        sut.syncTime(withServerDateString: serverDateString)
        
        // Setelah sinkronisasi selesai, kita catat lagi waktu client saat ini
        let clientAfter = Date()
        let offset = sut.timeOffset
        
        // Then: Hitung secara manual untuk mencocokkan hasil offset
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let serverDate = formatter.date(from: serverDateString)!
        
        // Karena waktu berjalan selama proses eksekusi kode di atas (meskipun hanya sekian milidetik),
        // kita mengestimasi waktu client saat eksekusi sinkronisasi terjadi dengan mengambil nilai rata-rata (mid-point):
        //
        //     clientDateEstimate = (clientBefore + clientAfter) / 2
        //
        let clientDateEstimate = (clientBefore.timeIntervalSince1970 + clientAfter.timeIntervalSince1970) / 2.0
        let expectedOffset = serverDate.timeIntervalSince1970 - clientDateEstimate
        
        // Kita gunakan asersi dengan parameter `accuracy: 1.0` (toleransi 1 detik) untuk mentoleransi fluktuasi
        // waktu yang sangat kecil akibat antrean CPU saat menjalankan tes.
        XCTAssertEqual(offset, expectedOffset, accuracy: 1.0)
    }
    
    func test_syncTime_withFallbackFormat_setsOffset() {
        // Given: Tanggal server simulasi tanpa zona waktu GMT (Format Fallback)
        let serverDateString = "Sun, 23 Aug 2026 07:00:00"
        let clientBefore = Date()
        
        // When: Jalankan sinkronisasi
        sut.syncTime(withServerDateString: serverDateString)
        
        let clientAfter = Date()
        let offset = sut.timeOffset
        
        // Then: Verifikasi menggunakan format fallback
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let serverDate = formatter.date(from: serverDateString)!
        
        // Sama seperti format standar, gunakan rata-rata waktu sebelum & sesudah untuk mendapatkan estimasi yang akurat
        let clientDateEstimate = (clientBefore.timeIntervalSince1970 + clientAfter.timeIntervalSince1970) / 2.0
        let expectedOffset = serverDate.timeIntervalSince1970 - clientDateEstimate
        
        XCTAssertEqual(offset, expectedOffset, accuracy: 1.0)
    }
    
    func test_syncTime_withInvalidFormat_doesNotChangeOffset() {
        // Given: Sinkronisasi awal dengan format valid untuk menetapkan baseline offset
        let baselineDateString = "Sun, 23 Aug 2026 07:00:00 GMT"
        sut.syncTime(withServerDateString: baselineDateString)
        let baselineOffset = sut.timeOffset
        
        // When: Mencoba sinkronisasi menggunakan string tanggal tidak valid
        sut.syncTime(withServerDateString: "Invalid Date String")
        
        // Then: Tracker tidak boleh merusak data offset yang sudah stabil sebelumnya
        XCTAssertEqual(sut.timeOffset, baselineOffset)
    }
    
    func test_serverTimeNow_returnsSynchronizedTime() {
        // Given: Sinkronisasikan dengan tanggal tertentu
        let serverDateString = "Sun, 23 Aug 2026 07:00:00 GMT"
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let expectedServerDate = formatter.date(from: serverDateString)!
        
        sut.syncTime(withServerDateString: serverDateString)
        
        // When: Ambil waktu server tersinkronisasi saat ini
        let serverTime = sut.serverTimeNow()
        
        // Then: Karena serverTimeNow() dihitung dengan rumus `Date() + timeOffset`,
        // jika dipanggil sesaat setelah syncTime(), ia harus menghasilkan nilai yang sangat dekat (toleransi 0.5 detik)
        // dengan tanggal server simulasi semula.
        XCTAssertEqual(serverTime.timeIntervalSince1970, expectedServerDate.timeIntervalSince1970, accuracy: 0.5)
    }
}

