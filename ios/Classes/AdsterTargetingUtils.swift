import Foundation

/// Converts Flutter's single- and multi-value targeting into the native SDK format.
enum AdsterTargetingUtils {
    static func customTargetingValues(from value: Any?) -> [String: [String]]? {
        guard let targeting = value as? [String: Any] else { return nil }
        return targeting.compactMapValues { value in
            if let string = value as? String {
                return [string]
            }
            return value as? [String]
        }
    }
}
