//
//  Feed+CoreDataProperties.swift
//  NewsReader
//
//  Created by Aleksei Chupriienko on 12/15/19.
//  Copyright © 2019 Aleksei Chupriienko. All rights reserved.
//
//

import Foundation
import CoreData


extension Feed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Feed> {
        return NSFetchRequest<Feed>(entityName: "Feed")
    }

    @NSManaged public var feedTitle: String?
    @NSManaged public var feedURL: String?

}
