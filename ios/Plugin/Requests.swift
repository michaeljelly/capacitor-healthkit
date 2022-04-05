//
//  Requests.swift
//  HealthSync
//
//  Created by Oscar King on 23/03/2022.
//

import Foundation
import Alamofire
import Gzip

typealias PostRequestCallback = (_ success: Bool, _ error: Error?) -> Void


class RequestsHandler {
    private let url: String
    private let credentials: JWTCredentials
    private let queue = DispatchQueue(label: "Requests")
    private let semaphore = DispatchSemaphore(value: 1)

    
    init(url: String, accessToken: String, refreshToken: String) {
        self.url = url
        self.credentials = JWTCredentials(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    func push(sampleTypeIdentifier: String, output: Output, completion: @escaping PostRequestCallback) {
        if output.countReturn != 0 {
            self.queue.async {
                self.semaphore.wait()
                self.credentials.getAccessToken { [weak self] (accessToken, error) in
                    guard let strongSelf = self else { return completion(false, nil) }
                    guard let accessToken = accessToken else { return completion(false, nil) }

                    if error != nil {
                        completion(false, error)
                    }
                                        
                    strongSelf.prepareRequest([sampleTypeIdentifier: output], accessToken, completion)
                }
            }
        } else {
            completion(true, nil)
        }
    }
    
    func prepareRequest(_ samples: [String: Output], _ accessToken: String, _ completion: @escaping PostRequestCallback) {
        let d = Date()
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd H:mm:ss.SSSS"
        
        debugPrint("Sending request for \(samples.keys) at \(df.string(from: d)) in thread \(Thread.current)")
        let headers: HTTPHeaders = [.authorization(bearerToken: accessToken), .contentType("application/json")]
        guard let body = try? JSONEncoder().encode(samples).gzipped().base64EncodedData() else {
            return
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(body, withName: "data", mimeType: "application/json")
        }, to: url, headers: headers)
            .responseString { [weak self] (response) in
                debugPrint(String(describing: response.response?.statusCode))
                guard let strongSelf = self else { return completion (false, nil) }
                strongSelf.semaphore.signal()
                switch response.result {
                    case .success:
                        guard let res = response.response else {
                            debugPrint(response)
                            return completion(false, RequestError(title: "Upload Failure", description: "Could not succesfully upload new data", code: 1))
                        }
                        switch res.statusCode {
                            case 202:
                                fallthrough
                            case 201:
                                // Successful result, return it in a callback.
                                debugPrint("Posted: \(String(describing: samples))")
                                completion(true, nil)
                            default:
                                debugPrint(response)
                                completion(false, RequestError(title: "Upload Failure", description: "Could not succesfully upload new data", code: 1))
                        }
                    case .failure:
                        // In case it failed, return a nil as an error indicator.
                        debugPrint(response)
                        completion(false, RequestError(title: "Upload Failure", description: "Could not succesfully upload new data", code: 1))
                    }
                }
    }
}
