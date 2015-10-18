//
//  SSItemModel.swift
//  SaltSideAssignment
//
//  Created by Yallappa Kuntennavar on 18/10/15.
//  Copyright © 2015 Yallappa. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class SSItemModel: NSManagedObject, SSImageDownloaderDelegate {
    var image : UIImage? = nil
    
    // Insert code here to add functionality to your managed object subclass
    func addItem(parseDict: Dictionary<String, AnyObject>, forIndex orderIndex: Int) {
        if let imageURLStringValue = parseDict["image"] as? String {
            self.imageLink = imageURLStringValue
        }
        if let itemDescriptionValue = parseDict["description"] as? String {
            self.itemDescription = itemDescriptionValue
        }
        if let titleValue = parseDict["title"] as? String {
            self.title = titleValue
        }
        self.index = orderIndex
    }
    
    
    func imageDownloader(imageDownloader: SSImageDownloader, didDownloadImage image: UIImage) {
        self.image = image
    }
}
