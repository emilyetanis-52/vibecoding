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

struct TailorResponseBody: Decodable {
    let tailoredResume: String
}

struct TailorErrorBody: Decodable {
    let error: String
}

enum TailorService {
    static func tailorResume(
        resumeText: String,
        jobDescription: String,
        settings: AppSettings
    ) async throws -> String {
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

        guard let body = try? JSONDecoder().decode(TailorResponseBody.self, from: data) else {
            throw TailorServiceError.decoding
        }

        return body.tailoredResume
    }
}
