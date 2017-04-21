import Foundation

public extension Int {

    /// Categorizes a status code.
    ///
    /// - Returns: The NetworkingStatusCodeType of the status code.
    var statusCodeType: Networking.StatusCodeType {
        switch self {
        case URLError.cancelled.rawValue:
            return .cancelled
        case 100 ..< 200:
            return .informational
        case 200 ..< 300:
            return .successful
        case 300 ..< 400:
            return .redirection
        case 400 ..< 500:
            return .clientError
        case 500 ..< 600:
            return .serverError
        default:
            return .unknown
        }
    }
}

open class Networking {
    static let domain = "nytimes.com"

    struct FakeRequest {
        let response: Any?
        let responseType: ResponseType
        let statusCode: Int
    }

    public enum ConfigurationType {
        case `default`, ephemeral, background

        var sessionConfiguration: URLSessionConfiguration {
            switch self {
            case .default:
                return URLSessionConfiguration.default
            case .ephemeral:
                return URLSessionConfiguration.ephemeral
            case .background:
                return URLSessionConfiguration.background(withIdentifier: "NetworkingBackgroundConfiguration")
            }
        }
    }

    enum RequestType: String {
        case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
    }

    enum SessionTaskType: String {
        case data, upload, download
    }

    public enum ParameterType {
        case none, json, formURLEncoded, multipartFormData, custom(String)

        func contentType(_ boundary: String) -> String? {
            switch self {
            case .none:
                return nil
            case .json:
                return "application/json"
            case .formURLEncoded:
                return "application/x-www-form-urlencoded"
            case .multipartFormData:
                return "multipart/form-data; boundary=\(boundary)"
            case .custom(let value):
                return value
            }
        }
    }

    enum ResponseType {
        case json
        case data
        case image

        var accept: String? {
            switch self {
            case .json:
                return "application/json"
            default:
                return nil
            }
        }
    }

    public enum StatusCodeType {
        case informational, successful, redirection, clientError, serverError, cancelled, unknown
    }

    fileprivate let baseURL: String
    fileprivate var configurationType: ConfigurationType
    var cache: NSCache<AnyObject, AnyObject>

    public var isSynchronous = false

    public var disableErrorLogging = false

    let boundary = String(format: "danqiang.networking.%08x%08x", arc4random(), arc4random())

    lazy var session: URLSession = {
        var configuration = self.configurationType.sessionConfiguration
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil

        return URLSession(configuration: configuration)
    }()

    public init(baseURL: String, configurationType: ConfigurationType = .default, cache: NSCache<AnyObject, AnyObject>? = nil) {
        self.baseURL = baseURL
        self.configurationType = configurationType
        self.cache = cache ?? NSCache()
    }

    public var headerFields: [String: String]?

    public func composedURL(with path: String) throws -> URL {
        let encodedPath = path.encodeUTF8() ?? path
        guard let url = URL(string: baseURL + encodedPath) else {
            throw NSError(domain: Networking.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't create a url using baseURL: \(baseURL) and encodedPath: \(encodedPath)"])
        }
        return url
    }

    public func destinationURL(for path: String, cacheName: String? = nil) throws -> URL {
        let normalizedCacheName = cacheName?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var resourcesPath: String
        if let normalizedCacheName = normalizedCacheName {
            resourcesPath = normalizedCacheName
        } else {
            let url = try self.composedURL(with: path)
            resourcesPath = url.absoluteString
        }

        let normalizedResourcesPath = resourcesPath.replacingOccurrences(of: "/", with: "-")
        let folderPath = Networking.domain
        let finalPath = "\(folderPath)/\(normalizedResourcesPath)"

        if let url = URL(string: finalPath) {
            let directory = FileManager.SearchPathDirectory.cachesDirectory
            if let cachesURL = FileManager.default.urls(for: directory, in: .userDomainMask).first {
                try (cachesURL as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
                let folderURL = cachesURL.appendingPathComponent(URL(string: folderPath)!.absoluteString)

                if FileManager.default.exists(at: folderURL) == false {
                    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
                }

                let destinationURL = cachesURL.appendingPathComponent(url.absoluteString)

                return destinationURL
            } else {
                throw NSError(domain: Networking.domain, code: 9999, userInfo: [NSLocalizedDescriptionKey: "Couldn't normalize url"])
            }
        } else {
            throw NSError(domain: Networking.domain, code: 9999, userInfo: [NSLocalizedDescriptionKey: "Couldn't create a url using replacedPath: \(finalPath)"])
        }
    }

//    public static func splitBaseURLAndRelativePath(for path: String) -> (baseURL: String, relativePath: String) {
//        guard let encodedPath = path.encodeUTF8() else { fatalError("Couldn't encode path to UTF8: \(path)") }
//        guard let url = URL(string: encodedPath) else { fatalError("Path \(encodedPath) can't be converted to url") }
//        guard let baseURLWithDash = URL(string: "/", relativeTo: url)?.absoluteURL.absoluteString else { fatalError("Can't find absolute url of url: \(url)") }
//        let index = baseURLWithDash.index(before: baseURLWithDash.endIndex)
//        let baseURL = baseURLWithDash.substring(to: index)
//        let relativePath = path.replacingOccurrences(of: baseURL, with: "")
//
//        return (baseURL, relativePath)
//    }

    public func cancel(_ requestID: String) {
        let semaphore = DispatchSemaphore(value: 0)
        session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            var tasks = [URLSessionTask]()
            tasks.append(contentsOf: dataTasks as [URLSessionTask])
            tasks.append(contentsOf: uploadTasks as [URLSessionTask])
            tasks.append(contentsOf: downloadTasks as [URLSessionTask])

            for task in tasks {
                if task.taskDescription == requestID {
                    task.cancel()
                    break
                }
            }

            semaphore.signal()
        }

        _ = semaphore.wait(timeout: DispatchTime.now() + 60.0)
    }

    /// Cancels all the current requests.
    public func cancelAllRequests() {
        let semaphore = DispatchSemaphore(value: 0)
        session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            for sessionTask in dataTasks {
                sessionTask.cancel()
            }
            for sessionTask in downloadTasks {
                sessionTask.cancel()
            }
            for sessionTask in uploadTasks {
                sessionTask.cancel()
            }

            semaphore.signal()
        }

        _ = semaphore.wait(timeout: DispatchTime.now() + 60.0)
    }

    /// Deletes the downloaded/cached files.
    public static func deleteCachedFiles() {
        let directory = FileManager.SearchPathDirectory.cachesDirectory
        if let cachesURL = FileManager.default.urls(for: directory, in: .userDomainMask).first {
            let folderURL = cachesURL.appendingPathComponent(URL(string: Networking.domain)!.absoluteString)

            if FileManager.default.exists(at: folderURL) {
                _ = try? FileManager.default.remove(at: folderURL)
            }
        }
    }

    /// Removes the stored credentials and cached data.
    public func reset() {
        cache.removeAllObjects()
        headerFields = nil

        Networking.deleteCachedFiles()
    }
}
