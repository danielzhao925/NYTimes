import Foundation
import XCTest

class GETTests: XCTestCase {
    let baseURL = WebServiceContants.baseApiURL

    func testGET() {
        var asynchronous = false
        let networking = Networking(baseURL: baseURL)
        
        let params = ["api-key": WebServiceContants.apiKey,
                      "q": "Singapore",
                      "page": "0"] as [String : Any]
        
        let expectation = self.expectation(description: "testGET")

        networking.get(WebServiceContants.articleSearch, parameters:params ){ _ in
            asynchronous = true
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10.0, handler: nil)

        XCTAssertTrue(asynchronous)
    }

    func testGETWithHeaders() {
        let networking = Networking(baseURL: baseURL)
        let params = ["api-key": WebServiceContants.apiKey,
                      "q": "Singapore",
                      "page": "0"] as [String : Any]
        networking.get(WebServiceContants.articleSearch,parameters:params ) { result in
            switch result {
            case .success(let response):
                let json = response.dictionaryBody
                guard let url = json["url"] as? String else { XCTFail(); return }
                XCTAssertEqual(url, "http://httpbin.org/get")

                let headers = response.headers
                guard let connection = headers["Connection"] as? String else { XCTFail(); return }
                XCTAssertEqual(connection, "keep-alive")
                XCTAssertEqual(headers["Content-Type"] as? String, "application/json")
            case .failure:
                XCTFail()
            }
        }
    }

    func testGETWithInvalidPath() {
        let networking = Networking(baseURL: baseURL)
        networking.get("/invalidpath") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let response):
                XCTAssertEqual(response.error.code, 404)
            }
        }
    }
   
    func testCancelGETWithPath() {
        let expectation = self.expectation(description: "testCancelGET")

        let networking = Networking(baseURL: baseURL)
        networking.isSynchronous = true
        var completed = false
        networking.get("/get") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let response):
                XCTAssertTrue(completed)
                XCTAssertEqual(response.error.code, URLError.cancelled.rawValue)
                expectation.fulfill()
            }
        }

        networking.cancelGET("/get")
        completed = true

        waitForExpectations(timeout: 15.0, handler: nil)
    }

    func testCancelGETWithID() {
        let expectation = self.expectation(description: "testCancelGET")

        let networking = Networking(baseURL: baseURL)
        networking.isSynchronous = true
        let requestID = networking.get("/get") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let response):
                XCTAssertEqual(response.error.code, URLError.cancelled.rawValue)
                expectation.fulfill()
            }
        }

        networking.cancel(requestID)

        waitForExpectations(timeout: 15.0, handler: nil)
    }

    func testStatusCodes() {
        let networking = Networking(baseURL: baseURL)
        let params = ["api-key": WebServiceContants.apiKey,
                      "q": "Singapore",
                      "page": "0"] as [String : Any]
        networking.get(WebServiceContants.articleSearch,parameters:params )  { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.statusCode, 200)
            case .failure:
                XCTFail()
            }
        }

    }

    func testGETWithURLEncodedParameters() {
        let networking = Networking(baseURL: baseURL)
        networking.get("/get", parameters: ["count": 25]) { result in
            switch result {
            case .success(let response):
                let json = response.dictionaryBody
                XCTAssertEqual(json["url"] as? String, "http://httpbin.org/get?count=25")
            case .failure:
                XCTFail()
            }
        }
    }

}
