//
//  SSRootItemsListVC.swift
//  SaltSideAssignment
//
//  Created by Yallappa Kuntennavar on 17/10/15.
//  Copyright © 2015 Yallappa. All rights reserved.
//

import UIKit
import CoreData

class SSRootItemsListVC: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var refreshControl = UIRefreshControl()
    var fetchingItems = false
    var justRefreshedData = false
    
    var itemsArray: Array<SSItemModel>? = nil
    var imageDownloadsInProgress: Dictionary<String, SSImageDownloader> = [:]
    let managedObjectContext = SSCoreDataController.sharedInstance.managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let itemsFetchRequest = NSFetchRequest(entityName: "SSItemModel")
        itemsFetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        itemsFetchRequest.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest:itemsFetchRequest, managedObjectContext:self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        return frc
        }()
    
    
    // MARK: - View Heirarchy
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Home"
        
        fetchItems()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.tintColor = UIColor(red: 241.0/255, green: 148.0/255, blue: 0.0/255, alpha: 1.0)
        refreshControl.addTarget(self, action: "fetchItems", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
    }
    
    
    func updateUI() {
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("An error occurred")
        }
    }
    
    
    // MARK: - Fetch Items
    
    func fetchItems() {
        if fetchingItems {
            return
        }
        
        cleanUp()
        
        self.fetchingItems = true
        activityIndicator.startAnimating()
        SSWebServicesManager.sharedInstance.fetchItems {
            (error, status) -> () in
            
            self.fetchingItems = false
            self.justRefreshedData = true
            
            self.refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
            
            if error != nil {
                let errorDescription = error!.localizedDescription + "\nStill you can browse in offline"
                SSUtility.showAlertWithTitle("Error!", alertMessage: errorDescription, dismissButtonsTitle: "OK", inController: self)
                
                self.updateUI()
            }else {
                
                self.updateUI()
            }
        }
    }
    
    
    // MARK: - UITableViewDatasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int = 0
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            count = currentSection.numberOfObjects
        }
        
        return count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SSRootItemTableViewCell") as? SSRootItemTableViewCell
        
        let itemObject = fetchedResultsController.objectAtIndexPath(indexPath) as? SSItemModel
        cell?.titleLabel.text = itemObject!.title
        
        cell!.itemImageView.image = nil
        if (itemObject!.image != nil) {
            cell!.itemImageView.image = itemObject!.image
        }
        else {
            let scale = UIScreen.mainScreen().scale
            var thumbImageSize = cell!.itemImageView.bounds.size
            thumbImageSize.height = thumbImageSize.height * scale
            thumbImageSize.width = thumbImageSize.width * scale
            startImageDownloadFor(indexPath, withSize: thumbImageSize)
        }
        
        return cell!
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cellHeight: CGFloat = 80.0//Minimum cell height
        
        let itemObject = fetchedResultsController.objectAtIndexPath(indexPath) as? SSItemModel
        let sizeConstriant = CGSizeMake((tableView.bounds.width - 98.0), CGFloat.infinity)
        let cellFont = UIFont.systemFontOfSize(14.0)
        
        let heightOfString = SSUtility.stringSize(itemObject!.title!, withSizeConstraint: sizeConstriant, andFont: cellFont).height + 12.0
        if (heightOfString > cellHeight) {
            cellHeight = heightOfString
        }
        
        return cellHeight
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if fetchingItems {
            return
        }
        
        let itemModel = fetchedResultsController.objectAtIndexPath(indexPath) as? SSItemModel
        let itemDetailsVC = storyboard?.instantiateViewControllerWithIdentifier("SSItemDetailsVC") as? SSItemDetailsVC
        itemDetailsVC!.itemModel = itemModel
        
        navigationController?.pushViewController(itemDetailsVC!, animated: true)
    }
    
    
    // MARK: - Download thumb images of products
    
    func startImageDownloadFor(indexPath: NSIndexPath, withSize size: CGSize) {
        let itemObject = fetchedResultsController.objectAtIndexPath(indexPath) as? SSItemModel
        
        let imageLink = itemObject!.imageLink
        var imageDownloader = imageDownloadsInProgress[imageLink!]
        
        if (imageDownloader == nil) {
            imageDownloader = SSImageDownloader()
            imageDownloader?.imageLink = imageLink!
            imageDownloader?.isThumbImage = true
            imageDownloader?.thumbImageSize = size
            imageDownloader?.delegate = itemObject
            
            imageDownloadsInProgress[itemObject!.imageLink!] = imageDownloader
            weak var weakSelf = self
            
            imageDownloader?.starDownload({
                (downloadedImage) -> () in
                
                if let weakerMe = weakSelf {
                    if let tableCell = weakerMe.tableView.cellForRowAtIndexPath(indexPath) as? SSRootItemTableViewCell {
                        tableCell.itemImageView.alpha = 0.0
                        tableCell.itemImageView.image = itemObject!.image
                        
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            tableCell.itemImageView.alpha = 1.0
                        })
                    }else {
                        if weakerMe.justRefreshedData {
                           weakerMe.justRefreshedData = false
                            weakerMe.tableView.reloadData()
                        }
                    }
                    
                    self.imageDownloadsInProgress[itemObject!.imageLink!] = nil
                }
            })
        }
    }
    
    
    // MARK: - Cleanup
    
    func cleanUp() {
        for (_, imageDownloader) in imageDownloadsInProgress {
            imageDownloader.stopDownload()
        }
        imageDownloadsInProgress.removeAll(keepCapacity: false)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
