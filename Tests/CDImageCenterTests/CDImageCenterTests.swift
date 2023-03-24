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
        let op = ImageloaderOperation(keyType: .url(address: "https://img.littlefox.co.kr/static/contents/series/FS0076/featured.jpg?1637110453"))
        op.setCompleted(completedCallback: { image, error in
            ex.fulfill()
            XCTAssertNotNil(image, error?.localizedDescription ?? "unknowned named")
        })

        self.imageloadOperationQueue?.addOperation(op)
        
        wait(for: [ex], timeout: 4)
    }
    
    func testOperationFactory(){
        let ex = self.expectation(description: "testOperationFactory")
        let op = ImageOperationFactory.url(address: "https://img.littlefox.co.kr/static/contents/series/FS0076/featured.jpg?1637110453").operation
        op.setCompleted(completedCallback: { image, error in
            ex.fulfill()
            XCTAssertNotNil(image, error?.localizedDescription ?? "unknowned named")
        })

        self.imageloadOperationQueue?.addOperation(op)
        
        wait(for: [ex], timeout: 4)
    }
}
