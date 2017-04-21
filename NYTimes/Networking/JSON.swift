

import Foundation

public enum ParsingError: Error {
    case notFound, failed
}

public enum JSON: Equatable {
    case none

    case dictionary([String: Any])

    case array([[String: Any]])

    public var dictionary: [String: Any] {
        get {
            switch self {
            case .dictionary(let value):
                return value
            default:
                return [String: Any]()
            }
        }
    }

    public var array: [[String: Any]] {
        get {
            switch self {
            case .array(let value):
                return value
            default:
                return [[String: Any]]()
            }
        }
    }

    public init(_ dictionary: [String: Any]) {
        self = .dictionary(dictionary)
    }

    public init(_ array: [[String: Any]]) {
        self = .array(array)
    }

    public static func from(_ fileName: String, bundle: Bundle = Bundle.main) throws -> Any? {
        var json: Any?

        guard let url = URL(string: fileName), let filePath = bundle.path(forResource: url.deletingPathExtension().absoluteString, ofType: url.pathExtension) else { throw ParsingError.notFound }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { throw ParsingError.failed }

        json = try data.toJSON()

        return json
    }
}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    return lhs.array.debugDescription == rhs.array.debugDescription && lhs.dictionary.debugDescription == rhs.dictionary.debugDescription
}

extension Data {
    
    public func toJSON() throws -> Any? {
        var json: Any?
        do {
            json = try JSONSerialization.jsonObject(with: self, options: [])
        } catch {
            throw ParsingError.failed
        }

        return json
    }
}
