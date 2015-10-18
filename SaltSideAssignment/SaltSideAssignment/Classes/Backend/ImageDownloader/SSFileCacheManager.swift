//
//  SSFileCacheManager.swift
//  SaltSideAssignment
//
//  Created by Yallappa Kuntennavar on 18/10/15.
//  Copyright © 2015 Yallappa. All rights reserved.
//

import UIKit

class SSFileCacheManager: NSObject {
    
    let fpCacheDirectory = "SSFileCacheManager"
    var cacheMemory = NSCache()
    
    
    override init() {
        super.init()
        cacheMemory.countLimit = 20
    }
    
    
    class var sharedInstance: SSFileCacheManager {
        struct Static {
            static var instance: SSFileCacheManager? = nil
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = SSFileCacheManager()
        }
        
        return Static.instance!
    }
    
    
    func cacheObject(object: AnyObject, forKey key: String) {
        cacheMemory.setObject(object, forKey: key)
    }
    
    
    func cacheObjectForKey(key: String) -> AnyObject? {
        if let fileObject = cacheMemory.objectForKey(key) {
            return fileObject
        }
        
        return nil
    }
}
