//
//  SSImageDownloader.swift
//  SaltSideAssignment
//
//  Created by Yallappa Kuntennavar on 18/10/15.
//  Copyright © 2015 Yallappa. All rights reserved.
//

import UIKit

@objc protocol SSImageDownloaderDelegate {
    optional func imageDownloader(imageDownloader: SSImageDownloader, didDownloadImage image: UIImage)
}

class SSImageDownloader: NSObject {
    
    var imageLink: String? = nil
    var downloadedData: NSMutableData? = nil
    var urlSessionDataTask: NSURLSessionDataTask? = nil
    var isThumbImage = true
    var thumbImageSize = CGSizeMake(60.0, 60.0)
    
    weak var delegate: SSImageDownloaderDelegate?
    
    
    func starDownload(completionHandler: (downloadedImage: UIImage?) ->()) {
        if let image = SSFileCacheManager.sharedInstance.cacheObjectForKey(imageLink!) as? UIImage {
            
            if self.isThumbImage {
                let thumbImage = getCroppedImageFor(image, withSize: thumbImageSize)
                delegate?.imageDownloader!(self, didDownloadImage: thumbImage)
                
            }else {
                delegate?.imageDownloader!(self, didDownloadImage: image)
            }
            
            completionHandler(downloadedImage: image)
            
        }else {
            weak var weakSelf = self
            
            self.downloadedData = NSMutableData(capacity: 1)
            let urlRequest = NSURLRequest(URL: NSURL(string: imageLink!)!)
            
            let session = NSURLSession.sharedSession()
            self.urlSessionDataTask = session.dataTaskWithRequest(urlRequest, completionHandler: {
                (data, _, error) -> Void in
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    
                    if weakSelf!.isThumbImage {
                        let thumbImage = weakSelf!.getCroppedImageFor(image!, withSize: weakSelf!.thumbImageSize)
                        weakSelf!.delegate?.imageDownloader!(self, didDownloadImage: thumbImage)
                        
                    }else {
                        weakSelf!.delegate?.imageDownloader!(self, didDownloadImage: image!)
                    }
                    
                    SSFileCacheManager.sharedInstance.cacheObject(image!, forKey: weakSelf!.imageLink!)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(downloadedImage: image!)
                    })
                    
                }else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(downloadedImage: nil)
                    })
                }
            })
            urlSessionDataTask!.resume()
        }
    }

    
    func stopDownload() {
        urlSessionDataTask?.cancel()
    }
    
    
    func getCroppedImageFor(image: UIImage, withSize size: CGSize) -> (UIImage) {
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        return thumbImage
    }
}
