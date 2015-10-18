//
//  SSUtility.swift
//  SaltSideAssignment
//
//  Created by Yallappa Kuntennavar on 18/10/15.
//  Copyright © 2015 Yallappa. All rights reserved.
//

import UIKit

class SSUtility: NSObject {
    
    class func showAlertWithTitle(title: String?, alertMessage message: String?, dismissButtonsTitle dismissTitle: String?, inController controller: UIViewController?) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okayAction: UIAlertAction = UIAlertAction(title: dismissTitle!, style: .Default, handler: nil)
        alertController.addAction(okayAction)
        
        if let cntrl = controller {
            cntrl.presentViewController(alertController, animated: true, completion: nil)
        }else {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    class func stringSize(string: String, withSizeConstraint constraint: CGSize, andFont font: UIFont) -> (CGSize) {
        let keyLabelText = NSString(string: string)
        let sizeOfString = keyLabelText.boundingRectWithSize(constraint, options: .UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil).size
        
        return sizeOfString
    }
}
