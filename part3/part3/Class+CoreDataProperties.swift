//
//  Class+CoreDataProperties.swift
//  part3
//
//  Created by Jason Huang on 6/21/20.
//  Copyright © 2020 Jason Huang. All rights reserved.
//
//

import Foundation
import CoreData


extension Class {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Class> {
        return NSFetchRequest<Class>(entityName: "Class")
    }

    @NSManaged public var name: String?

}
