import XCTest
@testable import CDImageCenter

final class CDImageCenterTests: XCTestCase {
    
    var imageloadOperationQueue: OperationQueue?
    
    override func setUpWithError() throws {
        self.imageloadOperationQueue = OperationQueue()
        self.imageloadOperationQueue?.maxConcurrentOperationCount = 1
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testLoadImage() throws {

        let ex = self.expectation(description: "testLoadImage")
        let op = ImageloaderOperation(keyType: .url(address: "")) { image, error in
            
        }
    }
}
