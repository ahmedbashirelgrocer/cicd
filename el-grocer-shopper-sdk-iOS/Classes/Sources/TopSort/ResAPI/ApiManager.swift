//
//  File.swift
//  Adyen
//
//  Created by Sarmad Abbas on 17/02/2023.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case requestFailed(statusCode: Int, message: String?)
    case decodingFailed
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class ApiManager {
    
    typealias CompletionHandler<T: Codable> = (Swift.Result<T, APIError>) -> Void
    
    func request<T: Codable>(_ url: String,
                             method: HttpMethod,
                             queryParameters: [String: String]? = nil,
                             requestBody: [String: Any]? = nil,
                             headers: [String: String]? = nil,
                             completion: @escaping CompletionHandler<T>) {
        
        guard let url = URL(string: url) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        if let queryParams = queryParameters {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = method.rawValue
        
        
        do {
            if let params = requestBody {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            }
        } catch let error {
            print(error.localizedDescription)
            completion(.failure(APIError.invalidRequest))
        }
        
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    
                    if let error = error as? NSError {
                        completion(.failure(.requestFailed(statusCode: error.code,
                                                           message: error.localizedDescription)))
                    } else {
                        completion(.failure(.invalidResponse))
                    }
                    
                    return
                }
                
                guard (200...299) ~= httpResponse.statusCode else {
                    
                    let statusCode = httpResponse.statusCode
                    
                    if let error = error as? NSError {
                        completion(.failure(.requestFailed(statusCode: statusCode,
                                                           message: error.localizedDescription)))
                    } else {
                        completion(.failure(.requestFailed(statusCode: statusCode, message: nil)))
                    }
                    
                    return
                }
                
                guard var data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                do {
                    
                    if data.count == 0 {
                        data = "{\"status\":\"success\"}".data(using: .utf8) ?? Data()
                    }
                    
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                } catch let error {
                    print(error.localizedDescription)
                    completion(.failure(.decodingFailed))
                }
            }
        }.resume()
    }
    
}
