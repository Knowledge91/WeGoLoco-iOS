//
//  API.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 15/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import Foundation
import PromiseKit

class API {
    static var client = APIWeGoLocoClient.default()
    
    enum HTTPMethod : String {
        case GET = "GET"
        case POST = "POST"
    }
    
    enum EndPoint : String {
        case Tinpons = "/tinpons"
    }
    
    static func invoke(httpMethod: HTTPMethod, endPoint: EndPoint, queryParameters: [AnyHashable: Any]?, headerParameters: [AnyHashable : Any]?, httpBody: Any?, completion: @escaping (Error?)->()) {
        let request = AWSAPIGatewayRequest(httpMethod: httpMethod.rawValue, urlString: endPoint.rawValue, queryParameters: queryParameters, headerParameters: headerParameters, httpBody: httpBody)
        self.client.invoke(request).continueWith { task -> Void in
            if let error = task.error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    static func invoke(httpMethod: HTTPMethod, endPoint: EndPoint, queryParameters: [AnyHashable: Any]?, headerParameters: [AnyHashable : Any]?, httpBody: Any?) -> Promise<Void> {
        return PromiseKit.wrap{ invoke(httpMethod: httpMethod, endPoint: endPoint, queryParameters: queryParameters, headerParameters: headerParameters, httpBody: httpBody, completion: $0) }
    }
    
    //  Tinpon
    static func createTinpon(tinpon: Tinpon, completion: @escaping (Error?)->()) {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try jsonEncoder.encode(tinpon)
            //let jsonString = String(data: jsonData, encoding: .utf8)
            let body = jsonData
            firstly {
                self.invoke(httpMethod: .POST, endPoint: .Tinpons, queryParameters: nil, headerParameters: nil, httpBody: body)
                }.then {
                    completion(nil)
                }.catch { error -> () in
                    completion(error)
            }
        }
        catch {
            
        }
    }
    static func createTinpon(tinpon: Tinpon) -> Promise<Void> {
        return PromiseKit.wrap{ createTinpon(tinpon: tinpon, completion: $0) }
    }
}

