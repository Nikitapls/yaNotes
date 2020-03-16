//
//  NoteEntity+CoreDataProperties.swift
//  
//
//  Created by ios_school on 3/16/20.
//
//

import Foundation
import CoreData


extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }

    @NSManaged public var color: String?
    @NSManaged public var content: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var importance: String?
    @NSManaged public var selfDestructionDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var uid: String?

}
