//
//  TestDocuments+CoreDataProperties.swift
//  InductionApp
//
//  Created by Ben Altschuler on 6/24/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//
//

import Foundation
import CoreData


extension TestDocuments {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestDocuments> {
        return NSFetchRequest<TestDocuments>(entityName: "TestDocuments")
    }

    @NSManaged public var originalPDF: Data?
    @NSManaged public var originalJSON: Data?
    @NSManaged public var resultJSON: Data?
    @NSManaged public var resultPDF: Data?
    @NSManaged public var name: String?

}
