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
    
    static let uidKey: String = "uid"
    static let titleKey: String = "title"
    static let contentKey: String = "content"
    static let colorKey: String = "color"
    static let impotanceKey: String = "impotance"
    static let selfDestructionDateKey: String = "selfDestructionDate"
    
    init(uid: String? = nil, title: String, content: String, color: UIColor? = nil,
         impotance: Impotance, selfDestructionDate: Date? = nil){
        self.uid = uid ?? UUID().uuidString
        self.title = title
        self.content = content
        self.color = color ?? UIColor.white
        self.impotance = impotance
        self.selfDestructionDate = selfDestructionDate
    }
}
