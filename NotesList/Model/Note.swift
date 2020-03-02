import UIKit
import Foundation

enum Impotance : String {
    case unimpotant = "unimpotant"
    case usual = "usual"
    case impotant = "impotant"
}

struct Note {
    
    let uid: String
    let title: String
    let content: String
    let color: UIColor
    let impotance: Impotance
    let selfDestructionDate: Date?
    let creationDate: Date
    
    static let uidKey: String = "uid"
    static let titleKey: String = "title"
    static let contentKey: String = "content"
    static let colorKey: String = "color"
    static let impotanceKey: String = "impotance"
    static let selfDestructionDateKey: String = "selfDestructionDate"
    static let creationDateKey: String  = "creationDate"
    
    init(uid: String? = nil, title: String, content: String, color: UIColor? = nil,
         impotance: Impotance, selfDestructionDate: Date? = nil){
        self.uid = uid ?? UUID().uuidString
        self.title = title
        self.content = content
        self.color = color ?? UIColor.white
        self.impotance = impotance
        self.selfDestructionDate = selfDestructionDate
        self.creationDate = Date()
    }
    
    init(uid: String? = nil, title: String, content: String, color: UIColor? = nil,
                 impotance: Impotance, selfDestructionDate: Date? = nil, creationDate: Date){
        self.uid = uid ?? UUID().uuidString
        self.title = title
        self.content = content
        self.color = color ?? UIColor.white
        self.impotance = impotance
        self.selfDestructionDate = selfDestructionDate
        self.creationDate = creationDate
    }
}
