import Foundation

extension Networking {

    func objectFromCache(for path: String, cacheName: String?, responseType: ResponseType) -> Any? {
        guard let destinationURL = try? destinationURL(for: path, cacheName: cacheName) else { fatalError("Couldn't get destination URL for path: \(path) and cacheName: \(String(describing: cacheName))") }

        if let object = cache.object(forKey: destinationURL.absoluteString as AnyObject) {
            return object
        } else if FileManager.default.exists(at: destinationURL) {
            var returnedObject: Any?

            let object = destinationURL.getData()
            if responseType == .image {
                returnedObject = Image(data: object)
            } else {
                returnedObject = object
            }
            if let returnedObject = returnedObject {
                cache.setObject(returnedObject as AnyObject, forKey: destinationURL.absoluteString as AnyObject)
            }

            return returnedObject
        } else {
            return nil
        }
    }

    func requestJSON(requestType: RequestType, path: String, parameterType: ParameterType?, parameters: Any?, completion: @escaping (_ result: JSONResult) -> Void) -> String {
        return request(requestType, path: path, parameterType: parameterType, parameters: parameters, responseType: .json) { deserialized, response, error in
            completion(JSONResult(body: deserialized, response: response, error: error))
        }
    }

    func requestImage(path: String, completion: @escaping (_ result: ImageResult) -> Void) -> String {
        return request(.get, path: path, parameterType: nil, parameters: nil, responseType: .image) { deserialized, response, error in
            completion(ImageResult(body: deserialized, response: response, error: error))
        }
    }

    func request(_ requestType: RequestType, path: String, parameterType: ParameterType?, parameters: Any?, responseType: ResponseType, completion: @escaping (_ response: Any?, _ response: HTTPURLResponse, _ error: NSError?) -> Void) -> String {
       
        if responseType == .json {
            return handleJSONRequest(requestType, path: path, parameterType: parameterType, parameters: parameters, responseType: responseType, completion: completion)
        }
        else{
            return handleImageRequest(requestType, path: path, parameterType: parameterType, parameters: parameters, responseType: responseType, completion: completion)
        }
        
    }

   
    func handleJSONRequest(_ requestType: RequestType, path: String, parameterType: ParameterType?, parameters: Any?, responseType: ResponseType, completion: @escaping (_ response: Any?, _ response: HTTPURLResponse, _ error: NSError?) -> Void) -> String {
        return dataRequest(requestType, path: path, parameterType: parameterType, parameters: parameters, responseType: responseType) { data, response, error in
            var returnedError = error
            var returnedResponse: Any?
            if let data = data, data.count > 0 {
                do {
                    returnedResponse = try JSONSerialization.jsonObject(with: data, options: [])
                } catch let JSONParsingError as NSError {
                    if returnedError == nil {
                        returnedError = JSONParsingError
                    }
                }
            }
             (DispatchQueue.main).async { completion(returnedResponse, response, returnedError) }
        }
    }

    func handleImageRequest(_ requestType: RequestType, path: String, parameterType: ParameterType?, parameters: Any?, responseType: ResponseType, completion: @escaping (_ response: Any?, _ response: HTTPURLResponse, _ error: NSError?) -> Void) -> String {
        let object = objectFromCache(for: path, cacheName: "image", responseType: responseType)
        if let object = object {
            let requestID = UUID().uuidString
            let url = try! self.composedURL(with: path)
            let response = HTTPURLResponse(url: url, statusCode: 200)
            completion(object, response, nil)
            return requestID
        } else {
            return dataRequest(requestType, path: path, parameterType: parameterType, parameters: parameters, responseType: responseType) { data, response, error in

                var returnedResponse: Any?
                if let data = data, data.count > 0 {
                    guard let destinationURL = try? self.destinationURL(for: path) else { fatalError("Couldn't get destination URL for path: \(path) and cacheName: \(String(describing: ""))") }
                    _ = try? data.write(to: destinationURL, options: [.atomic])
                    switch responseType {
                    case .data:
                        self.cache.setObject(data as AnyObject, forKey: destinationURL.absoluteString as AnyObject)
                        returnedResponse = data
                    case .image:
                        if let image = Image(data: data) {
                            self.cache.setObject(image, forKey: destinationURL.absoluteString as AnyObject)
                            returnedResponse = image
                        }
                    default:
                        fatalError("Response Type is different than Data and Image")
                    }
                }
                
                completion(returnedResponse, response, error)

            }
        }
    }

    func cancelRequest(_ sessionTaskType: SessionTaskType, requestType: RequestType, url: URL) {
        let semaphore = DispatchSemaphore(value: 0)
        session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            var sessionTasks = [URLSessionTask]()
            switch sessionTaskType {
            case .data:
                sessionTasks = dataTasks
            case .download:
                sessionTasks = downloadTasks
            case .upload:
                sessionTasks = uploadTasks
            }

            for sessionTask in sessionTasks {
                if sessionTask.originalRequest?.httpMethod == requestType.rawValue && sessionTask.originalRequest?.url?.absoluteString == url.absoluteString {
                    sessionTask.cancel()
                    break
                }
            }

            semaphore.signal()
        }

        _ = semaphore.wait(timeout: DispatchTime.now() + 60.0)
    }

    func logError(parameterType: ParameterType?, parameters: Any? = nil, data: Data?, request: URLRequest?, response: URLResponse?, error: NSError?) {
        if disableErrorLogging { return }
        guard let error = error else { return }

        debugPrint("========== Networking Error ==========")

        let isCancelled = error.code == NSURLErrorCancelled
        if isCancelled {
            if let request = request, let url = request.url {
                debugPrint("Cancelled request: \(url.absoluteString)")
            }
        } else {
            debugPrint("*** Request ***")

            debugPrint("Error \(error.code): \(error.description)")

            if let request = request, let url = request.url {
                debugPrint("URL: \(url.absoluteString)")
            }

            if let headers = request?.allHTTPHeaderFields {
                debugPrint("Headers: \(headers)")
            }

            if let parameterType = parameterType, let parameters = parameters {
                switch parameterType {
                case .json:
                    do {
                        let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                        let string = String(data: data, encoding: .utf8)
                        if let string = string {
                            debugPrint("Parameters: \(string)")
                        }
                    } catch let error as NSError {
                        debugPrint("Failed pretty printing parameters: \(parameters), error: \(error)")
                        debugPrint(" ")
                    }
                case .formURLEncoded:
                    guard let parametersDictionary = parameters as? [String: Any] else { fatalError("Couldn't cast parameters as dictionary: \(parameters)") }
                    do {
                        let formattedParameters = try parametersDictionary.urlEncodedString()
                        debugPrint("Parameters: \(formattedParameters)")
                    } catch let error as NSError {
                        debugPrint("Failed parsing Parameters: \(parametersDictionary) — \(error)")
                    }
                default: break
                }
            }

            if let data = data, let stringData = String(data: data, encoding: .utf8) {
                print("Data: \(stringData)")
            }

            if let response = response as? HTTPURLResponse {
                debugPrint("*** Response ***")

                debugPrint("Headers: \(response.allHeaderFields)")

                debugPrint("Status code: \(response.statusCode) — \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))")
            }
        }
        debugPrint("================= ~ ==================")
    }
    
    func dataRequest(_ requestType: RequestType, path: String, parameterType: ParameterType?, parameters: Any?, responseType: ResponseType, completion: @escaping (_ response: Data?, _ response: HTTPURLResponse, _ error: NSError?) -> Void) -> String {
        let requestID = UUID().uuidString
//        
        var request = URLRequest(url: try! composedURL(with: path), cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
//        request.httpBody
        if let headerFields = headerFields {
            for (headerField, headerValue) in headerFields {
                request.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        
//        var request = URLRequest(url: try! composedURL(with: path), requestType: requestType, path: path, parameterType: parameterType, responseType: responseType, boundary: nil, headerFields: headerFields)
        
//        DispatchQueue.main.async {
            NetworkActivityIndicator.sharedIndicator.visible = true
//        }
        
        var serializingError: NSError?
        if let parameterType = parameterType {
            switch parameterType {
            case .none: break
            case .json:
                if let parameters = parameters {
                    do {
                        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                    } catch let error as NSError {
                        serializingError = error
                    }
                }
            case .formURLEncoded:
                guard let parametersDictionary = parameters as? [String: Any] else { fatalError("Couldn't convert parameters to a dictionary: \(String(describing: parameters))") }
                do {
                    let formattedParameters = try parametersDictionary.urlEncodedString()
                    switch requestType {
                    case .get, .delete:
                        let urlEncodedPath: String
                        if path.contains("?") {
                            if let lastCharacter = path.characters.last, lastCharacter == "?" {
                                urlEncodedPath = path + formattedParameters
                            } else {
                                urlEncodedPath = path + "&" + formattedParameters
                            }
                        } else {
                            urlEncodedPath = path + "?" + formattedParameters
                        }
                        request.url = try! composedURL(with: urlEncodedPath)
                    case .post, .put:
                        request.httpBody = formattedParameters.data(using: .utf8)
                    }
                } catch let error as NSError {
                    serializingError = error
                }
            }
        
        if let serializingError = serializingError {
            let url = try! self.composedURL(with: path)
            let response = HTTPURLResponse(url: url, statusCode: serializingError.code)
            completion(nil, response, serializingError)
        } else {
            var connectionError: Error?
//            let semaphore = DispatchSemaphore(value: 0)
            var returnedResponse: URLResponse?
            var returnedData: Data?
            
            let session = self.session.dataTask(with: request) { data, response, error in
                returnedResponse = response
                connectionError = error
                returnedData = data
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        if let data = data, data.count > 0 {
                            returnedData = data
                        }
                    } else {
                        var errorCode = httpResponse.statusCode
                        if let error = error as NSError? {
                            if error.code == URLError.cancelled.rawValue {
                                errorCode = error.code
                            }
                        }
                        
                        connectionError = NSError(domain: "", code: errorCode, userInfo: [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)])
                    }
                }
                
//                DispatchQueue.main.async {
                    NetworkActivityIndicator.sharedIndicator.visible = false
//                }
                
                self.logError(parameterType: parameterType, parameters: parameters, data: returnedData, request: request, response: returnedResponse, error: connectionError as NSError?)
//                if let error = connectionError as NSError?, error.code == 403 || error.code == 401 {
//                    unauthorizedRequestCallback()
//                } else {
                    if let response = returnedResponse as? HTTPURLResponse {
                        completion(returnedData, response, connectionError as NSError?)
                    } else {
                        let url = try! self.composedURL(with: path)
                        let errorCode = (connectionError as NSError?)?.code ?? 200
                        let response = HTTPURLResponse(url: url, statusCode: errorCode)
                        completion(returnedData, response, connectionError as NSError?)
                    }
                
//                }
                
                
                
            }
            
            session.taskDescription = requestID
            session.resume()
            }
            
            
        }
        
        return requestID
            
    }

}
