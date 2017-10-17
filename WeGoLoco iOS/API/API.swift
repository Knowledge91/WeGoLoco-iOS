//
//  API.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 15/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import Foundation
import PromiseKit
import AWSS3

class API {
    enum HTTPMethod : String {
        case GET = "GET"
        case POST = "POST"
    }
    
    enum EndPoint : String {
        case Tinpons = "/tinpons"
    }
    
    static func invoke(httpMethod: HTTPMethod, endPoint: EndPoint, queryParameters: [AnyHashable: Any]?, headerParameters: [AnyHashable : Any]?, httpBody: Any?, completion: @escaping (Error?)->()) {
        let client = APIWeGoLocoClient.default()
        
        let request = AWSAPIGatewayRequest(httpMethod: httpMethod.rawValue, urlString: endPoint.rawValue, queryParameters: queryParameters, headerParameters: headerParameters, httpBody: httpBody)
        client.invoke(request).continueWith { task -> Void in
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
    
    // MARK: - Tinpon
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
    
    // MARK: Image upload
    static func uploadImage(image: UIImage, path: String, completion: @escaping (Error?)->()) {
        
        // upload S3 image
        let imageData: NSData = UIImagePNGRepresentation(image)! as NSData
        let transferManager = AWSS3TransferManager.default()
        
        let fileManager = FileManager.default
        let filePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(UUID().uuidString)
        fileManager.createFile(atPath: filePath as String, contents: imageData as Data, attributes: nil)
        let fileUrl = NSURL(fileURLWithPath: filePath)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest?.bucket = "wegoloco"
        uploadRequest?.key = path+".png"
        uploadRequest?.body = fileUrl as URL!
        uploadRequest?.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
            DispatchQueue.main.async(execute: {
                let sent = Float(totalBytesSent)
                let total = Float(totalBytesExpectedToSend)
                //progressView?.progress = sent/total
            })
        }
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        completion(nil)
                        break
                    default:
                        print("Error uploading: \(uploadRequest?.key) Error: \(error)")
                        completion(error)
                    }
                } else {
                    print("Error uploading: \(uploadRequest?.key) Error: \(error)")
                    completion(error)
                }
                return nil
            }

            // SUCCESS: Image uploaded
            // save ImageId to RDS
//            let uploadOutput = task.result
//            print("Upload complete for: \(uploadRequest?.key ?? "")")
            completion(nil)
            return nil
        })
    }
    static func uploadImage(image: UIImage, path: String) -> Promise<Void> {
        return PromiseKit.wrap{ uploadImage(image: image, path: path, completion: $0) }
    }
    
    // MARK: Helper
    
}

