//
//  SSRootItemTableViewCell.swift
//  SaltSideAssignment
//
//  Created by Yallappa Kuntennavar on 18/10/15.
//  Copyright © 2015 Yallappa. All rights reserved.
//

import UIKit

class SSRootItemTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var layer = containerView.layer
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        layer.masksToBounds = false
        layer.cornerRadius = 4.0
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 1
        
        
        layer = itemImageView.layer
        layer.masksToBounds = true
//        layer.shouldRasterize = true
//        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        layer.cornerRadius = 4.0
        layer.borderColor = UIColor(red: 26.0 / 255, green: 196.0 / 255, blue: 251.0 / 255, alpha: 1.0).CGColor
        layer.borderWidth = 1.0
    }

}
