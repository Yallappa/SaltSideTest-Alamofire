//
//  SSItemModel+CoreDataProperties.swift
//  SaltSideAssignment
//
//  Created by Yallappa Kuntennavar on 18/10/15.
//  Copyright © 2015 Yallappa. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SSItemModel {

    @NSManaged var imageLink: String?
    @NSManaged var itemDescription: String?
    @NSManaged var title: String?
    @NSManaged var index: NSNumber?

}
