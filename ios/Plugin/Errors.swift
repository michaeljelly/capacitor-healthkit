enum HKSampleError: Error {
    case sleepRequestFailed
    case workoutRequestFailed
    case quantityRequestFailed
    case sampleTypeFailed
    case deniedDataAccessFailed

    var outputMessage: String {
        switch self {
        case .sleepRequestFailed:
            return "sleepRequestFailed"
        case .workoutRequestFailed:
            return "workoutRequestFailed"
        case .quantityRequestFailed:
            return "quantityRequestFailed"
        case .sampleTypeFailed:
            return "sampleTypeFailed"
        case .deniedDataAccessFailed:
            return "deniedDataAccessFailed"
        }
    }
}

struct RequestError: Error {

    var title: String?
    var code: Int
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }

    private var _description: String

    init(title: String?, description: String, code: Int) {
        self.title = title ?? "RequestError"
        self._description = description
        self.code = code
    }
}

struct AccessError: Error {
    var title: String?
    var errorDescription: String? { return _description }
    
    private var _description: String
    
    init(title: String?, description: String) {
        self.title = title ?? "AccessTokenError"
        self._description = description
    }
}