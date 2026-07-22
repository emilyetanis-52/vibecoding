import Foundation

enum TailorServiceError: LocalizedError {
    case invalidServerURL
    case server(String)
    case network(Error)
    case decoding

    var errorDescription: String? {
        switch self {
        case .invalidServerURL:
            return "The server URL in Settings isn't valid."
        case .server(let message):
            return message
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .decoding:
            return "The server sent back something unexpected."
        }
    }
}

struct TailorRequestBody: Encodable {
    let resumeText: String
    let jobDescription: String
}

struct ExtractResumeResponseBody: Decodable {
    let resumeText: String
}

struct TailorErrorBody: Decodable {
    let error: String
}

enum TailorService {
    static func extractResume(
        fileData: Data,
        filename: String,
        mimeType: String,
        settings: AppSettings
    ) async throws -> String {
        guard let baseURL = settings.serverURL else {
            throw TailorServiceError.invalidServerURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: baseURL.appendingPathComponent("v1/extract-resume"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(settings.sharedSecret)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"resume\"; filename=\"\(filename)\"\r\n"
                .data(using: .utf8)!
        )
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let responseBody: ExtractResumeResponseBody = try await send(request)
        return responseBody.resumeText
    }

    static func tailorResume(
        resumeText: String,
        jobDescription: String,
        settings: AppSettings
    ) async throws -> TailorResult {
        guard let baseURL = settings.serverURL else {
            throw TailorServiceError.invalidServerURL
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("v1/tailor"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(settings.sharedSecret)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(
            TailorRequestBody(resumeText: resumeText, jobDescription: jobDescription)
        )

        return try await send(request)
    }

    private static func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw TailorServiceError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TailorServiceError.decoding
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            if let errorBody = try? JSONDecoder().decode(TailorErrorBody.self, from: data) {
                throw TailorServiceError.server(errorBody.error)
            }
            throw TailorServiceError.server("Server returned status \(httpResponse.statusCode).")
        }

        guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            throw TailorServiceError.decoding
        }

        return decoded
    }
}
