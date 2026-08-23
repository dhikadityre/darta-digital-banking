import XCTest
@testable import PackageData

final class TokenManagerTests: XCTestCase {
    private var fakeStorage: FakeTokenStorage!
    private var sut: TokenManager!
    
    override func setUp() {
        super.setUp()
        fakeStorage = FakeTokenStorage()
        sut = TokenManager(storage: fakeStorage)
    }
    
    override func tearDown() {
        sut = nil
        fakeStorage = nil
        super.tearDown()
    }
    
    func test_token_getsAndSetsAccessToken() {
        XCTAssertNil(sut.token)
        
        sut.token = "test-token"
        XCTAssertEqual(sut.token, "test-token")
        XCTAssertEqual(fakeStorage.accessToken, "test-token")
        
        sut.token = nil
        XCTAssertEqual(sut.token, "")
        XCTAssertEqual(fakeStorage.accessToken, "")
    }
    
    func test_accessToken_getsAndSetsAccessToken() {
        XCTAssertNil(sut.accessToken)
        
        sut.accessToken = "test-token"
        XCTAssertEqual(sut.accessToken, "test-token")
        XCTAssertEqual(fakeStorage.accessToken, "test-token")
        
        sut.accessToken = nil
        XCTAssertEqual(sut.accessToken, "")
        XCTAssertEqual(fakeStorage.accessToken, "")
    }
    
    func test_refreshToken_getsAndSetsRefreshToken() {
        XCTAssertNil(sut.refreshToken)
        
        sut.refreshToken = "refresh-token"
        XCTAssertEqual(sut.refreshToken, "refresh-token")
        XCTAssertEqual(fakeStorage.refreshToken, "refresh-token")
        
        sut.refreshToken = nil
        XCTAssertEqual(sut.refreshToken, "")
        XCTAssertEqual(fakeStorage.refreshToken, "")
    }
    
    func test_clear_clearsStorage() {
        fakeStorage.accessToken = "token"
        fakeStorage.refreshToken = "refresh"
        
        sut.clear()
        
        XCTAssertNil(fakeStorage.accessToken)
        XCTAssertNil(fakeStorage.refreshToken)
    }
}
