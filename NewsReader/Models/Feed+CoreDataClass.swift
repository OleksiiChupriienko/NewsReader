//
//  Feed+CoreDataClass.swift
//  NewsReader
//
//  Created by Aleksei Chupriienko on 12/15/19.
//  Copyright © 2019 Aleksei Chupriienko. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Feed)
public class Feed: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "Feed"), insertInto: CoreDataManager.instance.managedObjectContext)
    }
}
