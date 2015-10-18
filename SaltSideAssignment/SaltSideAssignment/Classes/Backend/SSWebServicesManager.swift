//
//  SSWebServicesManager.swift
//  SaltSideAssignment
//
//  Created by Yallappa Kuntennavar on 18/10/15.
//  Copyright © 2015 Yallappa. All rights reserved.
//

import UIKit
import Alamofire

class SSWebServicesManager: NSObject {
    
    class var sharedInstance: SSWebServicesManager {
        struct Static {
            static var instance: SSWebServicesManager? = nil
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = SSWebServicesManager()
        }
        
        return Static.instance!
    }
    
    
    // MARK: - Helpers
    
    func getError(message: String, withErrorCode errorCode: Int) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: message]
        let serverError = NSError(domain: "HTError", code: errorCode, userInfo: userInfo)
        
        return serverError
    }
    
    
    func fetchItems(completionHandler:(error: NSError?, status: Bool) -> ()) {
        let urlString = kItemsListURL
        
        let manager = Manager.sharedInstance
        manager.request(.GET, urlString, parameters: nil).responseJSON {
            (_, _, result) -> Void in
            
            switch result {
            case .Success(let data):
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let itemsArray = data as? Array<Dictionary<String, AnyObject>> {
                        var index = 0
                        
                        let coreDataController = SSCoreDataController.sharedInstance
                        coreDataController.deleteAllItemModels()
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            () -> Void in
                            
                            for item in itemsArray {
                                coreDataController.addItem(item, forIndex: index)
                                index++
                            }
                            
                            coreDataController.saveContext(coreDataController.backgroundContext!)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                completionHandler(error: nil, status: true)
                            })
                        })
                    }
                })
                
                
            case .Failure(let data, _):
                var errorString = "Unknown error occured"
                
                if let data = data {
                    errorString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
                }
                let errorObj = self.getError(errorString, withErrorCode: 999)
                
                completionHandler(error: errorObj, status: false)
            }
        }
    }
}
