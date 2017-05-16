import Foundation

public extension Networking {

    @discardableResult
    public func get(_ path: String, parameters: Any? = nil, completion: @escaping (_ result: JSONResult) -> Void) -> String {
        let parameterType = parameters != nil ? ParameterType.formURLEncoded : ParameterType.none

        return requestJSON(requestType: .get, path: path, parameterType: parameterType, parameters: parameters, completion: completion)
    }
    
    public func cancelGET(_ path: String) {
        let url = try! self.composedURL(with: path)
        cancelRequest(.data, requestType: .get, url: url)
    }
}

public extension Networking {

    public func imageFromCache(_ path: String, cacheName: String? = nil) -> Image? {
        let object = objectFromCache(for: path, cacheName: cacheName, responseType: .image)

        return object as? Image
    }

//    @discardableResult
//    public func downloadImage(_ path: String, cacheName: String? = nil, completion: @escaping (_ result: ImageResult) -> Void) -> String {
//        return requestImage(path: path, cacheName: cacheName, completion: completion)
//    }

    public func cancelImageDownload(_ path: String) {
        let url = try! self.composedURL(with: path)
        cancelRequest(.data, requestType: .get, url: url)
    }
}
