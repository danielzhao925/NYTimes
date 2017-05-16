import Foundation
import XCTest

class NetworkingTests: XCTestCase {
    let baseApiURL = WebServiceContants.baseApiURL
    let baseWebURL = WebServiceContants.baseWebURL

    func testURLForPath() {
        let networking = Networking(baseURL: baseApiURL)
        let url = try! networking.composedURL(with: WebServiceContants.articleSearch)
        XCTAssertEqual(url.absoluteString, "https://api.nytimes.com/svc/search/v2/articlesearch.json")
    }

    func testDestinationURL() {
        let networking = Networking(baseURL: baseWebURL)
        let path = "images/2017/03/03/arts/03APPRENTICE/03APPRENTICE-thumbStandard-v2.jpg"
        guard let destinationURL = try? networking.destinationURL(for: path) else { XCTFail(); return }
        XCTAssertEqual(destinationURL.lastPathComponent, "https:--www.nytimes.com-images-2017-03-03-arts-03APPRENTICE-03APPRENTICE-thumbStandard-v2.jpg")
    }

    func testDestinationURLWithSpecialCharactersInPath() {
        let networking = Networking(baseURL: baseWebURL)
        let path = "/h�sttur.jpg"
        guard let destinationURL = try? networking.destinationURL(for: path) else { XCTFail(); return }
        XCTAssertEqual(destinationURL.lastPathComponent, "https:--www.nytimes.com--h%EF%BF%BDsttur.jpg")
    }

    func testDestinationURLWithSpecialCharactersInCacheName() {
        let networking = Networking(baseURL: baseWebURL)
        let path = "/the-url-doesnt-really-matter"
        guard let destinationURL = try? networking.destinationURL(for: path, cacheName: "h�sttur.jpg-25-03/small") else { XCTFail(); return }
        XCTAssertEqual(destinationURL.lastPathComponent, "h%EF%BF%BDsttur.jpg-25-03-small")
    }

    func testDestinationURLCache() {
        let networking = Networking(baseURL: baseWebURL)
        let path = "/image/png"
        let cacheName = "png/png"
        guard let destinationURL = try? networking.destinationURL(for: path, cacheName: cacheName) else { XCTFail(); return }
        XCTAssertEqual(destinationURL.lastPathComponent, "png-png")
    }

    func testStatusCodeType() {
        XCTAssertEqual((URLError.cancelled.rawValue).statusCodeType, Networking.StatusCodeType.cancelled)
        XCTAssertEqual(99.statusCodeType, Networking.StatusCodeType.unknown)
        XCTAssertEqual(100.statusCodeType, Networking.StatusCodeType.informational)
        XCTAssertEqual(199.statusCodeType, Networking.StatusCodeType.informational)
        XCTAssertEqual(200.statusCodeType, Networking.StatusCodeType.successful)
        XCTAssertEqual(299.statusCodeType, Networking.StatusCodeType.successful)
        XCTAssertEqual(600.statusCodeType, Networking.StatusCodeType.unknown)
    }


    func testCancelWithRequestID() {
        let expectation = self.expectation(description: "testCancelAllRequests")
        let networking = Networking(baseURL: baseApiURL)
        networking.isSynchronous = true
        var cancelledGET = false

        let requestID = networking.get("/get") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let response):
                cancelledGET = response.error.code == URLError.cancelled.rawValue
                XCTAssertTrue(cancelledGET)

                if cancelledGET {
                    expectation.fulfill()
                }
            }
        }

        networking.cancel(requestID)

        waitForExpectations(timeout: 15.0, handler: nil)
    }

    func testCancelRequestsReturnInMainThread() {
        let expectation = self.expectation(description: "testCancelRequestsReturnInMainThread")
        let networking = Networking(baseURL: baseApiURL)
        networking.isSynchronous = true
        
        let params = ["api-key": WebServiceContants.apiKey,
                      "q": "Singapore",
                      "page": "0"] as [String : Any]
        
        networking.get(WebServiceContants.articleSearch,parameters:params ) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let response):
                XCTAssertFalse(Thread.isMainThread)
                XCTAssertEqual(response.error.code, URLError.cancelled.rawValue)
                expectation.fulfill()
            }
        }
        networking.cancelAllRequests()
        waitForExpectations(timeout: 15.0, handler: nil)
    }
}
