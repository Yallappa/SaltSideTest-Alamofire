//
//  SSItemDetailsVC.swift
//  SaltSideAssignment
//
//  Created by Yallappa Kuntennavar on 18/10/15.
//  Copyright © 2015 Yallappa. All rights reserved.
//

import UIKit

class SSItemDetailsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderContainer: UIView!
    @IBOutlet weak var tableHeaderImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var itemModel: SSItemModel? = nil
    var headerImageDownloader: SSImageDownloader? = nil
    
    
    // MARK: - View Heirarchy
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Details"
        
        navigationController?.hidesBarsOnSwipe = true
        
        if (itemModel!.image != nil) {
            tableHeaderImageView.image = itemModel!.image
        }
        startHeaderImageDownload()
    }
    
    
    // MARK: - UITableViewDatasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SSItemDetailsTableViewCell") as? SSItemDetailsTableViewCell
        
        switch indexPath.row {
        case 0:
            cell?.titleLabel.text = "Title:"
            cell?.descriptionLabel.text = itemModel?.title
            
        case 1:
            cell?.titleLabel.text = "Description:"
            cell?.descriptionLabel.text = itemModel?.itemDescription
            
        default:
            print("Do Nothing!")
        }
        
        return cell!
    }

    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cellHeight: CGFloat = 100.0//Minimum cell height
        var labelString = ""
        
        switch indexPath.row {
        case 0:
            labelString = (itemModel?.title)!
            
        case 1:
            labelString = (itemModel?.itemDescription)!
            
        default:
            labelString = (itemModel?.title)!
        }
        
        let sizeConstriant = CGSizeMake((tableView.bounds.width - 20.0), CGFloat.infinity)
        let cellFont = UIFont.systemFontOfSize(14.0)
        
        let heightOfString = SSUtility.stringSize(labelString, withSizeConstraint: sizeConstriant, andFont: cellFont).height + 58.0
        if (heightOfString > cellHeight) {
            cellHeight = heightOfString
        }
        
        return cellHeight
    }
    
    
    // MARK: - Download thumb images of products
    
    func startHeaderImageDownload() {
        activityIndicator.startAnimating()
        
        if (headerImageDownloader == nil) {
            self.headerImageDownloader = SSImageDownloader()
            headerImageDownloader?.isThumbImage = false
            headerImageDownloader?.imageLink = (itemModel?.imageLink)!
            
            weak var weakSelf = self
            headerImageDownloader?.starDownload({
                (downloadedImage) -> () in
                
                if let weakerMe = weakSelf {
                    weakerMe.activityIndicator.stopAnimating()
                    weakerMe.tableHeaderImageView.alpha = 0.0
                    weakerMe.tableHeaderImageView.image = downloadedImage
                    
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        weakerMe.tableHeaderImageView.alpha = 1.0
                    })
                }
                
                weakSelf?.headerImageDownloader = nil
            })
        }
    }


    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
