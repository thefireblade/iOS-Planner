//
//  Task+CoreDataProperties.swift
//  part3
//
//  Created by Jason Huang on 6/21/20.
//  Copyright © 2020 Jason Huang. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var name: String?
    @NSManaged public var classTaskName: String?
    @NSManaged public var date: Date?

}
