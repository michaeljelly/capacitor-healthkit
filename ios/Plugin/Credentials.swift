//
//  Credentials.swift
//  HealthSync
//
//  Created by Oscar King on 23/03/2022.
//

import Foundation
import Alamofire
import JWTDecode

struct RefreshResponse: Decodable {
    let access_token: String
}

class JWTCredentials {
    private var accessToken: JWT
    private let refreshToken: String
    private let refreshURL: String
    
    init(accessToken: String, refreshToken: String) {
        self.accessToken = try! decode(jwt: accessToken)
        self.refreshToken = refreshToken
        
        self.refreshURL = "https://flask-server-rya4g2ukoq-ez.a.run.app/api/v1/user/refresh/"
        
    }
    
    func refresh(_ callback: @escaping (String?, Error?) -> Void) -> Void {
        if !accessToken.expired {
            return
        } else {
            self.prepareRequest(callback)
        }
    }
    
    func prepareRequest(_ callback: @escaping (String?, Error?) -> Void) {
        let headers: HTTPHeaders = [.authorization(bearerToken: refreshToken)]

        AF.request(refreshURL, method: .post, headers: headers).responseDecodable(of: RefreshResponse.self) { (response) in
            switch response.result {
                case .success:
                    // Successful result, return it in a callback.
                    debugPrint("Refreshed access token")
                    self.accessToken = try! decode(jwt: response.value!.access_token)
                    callback(response.value?.access_token, nil)
                case .failure:
                    // In case it failed, return a nil as an error indicator.
                    debugPrint(response)
                    callback(nil, RequestError(title: "Refresh Failure", description: "Could not refresh the access token.", code: 1))
                }
        }
    }
    
    func getAccessToken(_ callback: @escaping (String?, Error?) -> Void) -> Void {
        let d = Date()
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd H:mm:ss.SSSS"

        debugPrint(df.string(from: d))
        debugPrint("Access token expired: \(accessToken.expired) at \(df.string(from: d))")
        if accessToken.expired {
            refresh(callback)
        } else {
            callback(accessToken.string, nil)
        }
    }
    
    func storeRefresh(refreshToken: String) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: refreshToken, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: "refresh")
        } catch {
            print("Unable to store new refreshToken")
        }
    }

    func retrieveRefresh() -> String? {
        guard let data = UserDefaults.standard.data(forKey: "refresh") else { return nil }
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSString.self, from: data) as String?
        } catch {
            print("Unable to retrieve refreshToken")
            return nil
        }
    }
}
