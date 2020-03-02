import Foundation
import UIKit
extension Note {
    private static func checkJsonFields(json: [String: Any]) -> Bool {
        if let dict = json as? [String: String] {
            let keys: Set = [Note.colorKey, Note.contentKey, Note.creationDateKey, Note.selfDestructionDateKey, Note.titleKey, Note.uidKey]
            for (key, _) in dict {
                if !keys.contains(key) {
                    return false
                }
            }
            return true
        }
        return false
    }
    static func parse(json: [String: Any]) -> Note? {//функция для разбора json
        guard checkJsonFields(json: json) else {
            return nil
        }
        var uid: String?
        var title: String?
        var content: String?
        var color: UIColor?
        var impotance: Impotance?
        var selfDestructionDate: Date?
        var creationDate: Date?
        if let dict = json as? [String: String] {
            uid = dict[Note.uidKey]
            title = dict[Note.titleKey]
            content = dict[Note.contentKey]
            if let colorHex = dict[Note.colorKey], let colorValue = UIColor.hexStringToUIColor(hex: colorHex) {
                color = colorValue
            }
            if let value = dict[Note.impotanceKey], let impotanceValue = Impotance.init(rawValue: value) {
                impotance = impotanceValue
            }
            if let value = dict[Note.selfDestructionDateKey], let timeValue = TimeInterval(value) {
            selfDestructionDate = Date(timeIntervalSince1970: timeValue)
            }
            if let value = dict[Note.creationDateKey], let timeValue = TimeInterval(value) {
            creationDate = Date(timeIntervalSince1970: timeValue)
            }
        }
        guard let creationDateValue = creationDate else { return nil }
        if let titleStr = title, let contentStr = content {
            return Note(uid: uid, title: titleStr, content: contentStr, color: color, impotance: impotance ?? Impotance.usual , selfDestructionDate: selfDestructionDate, creationDate: creationDateValue)
        }
        return nil
    }

    var json: [String: Any] {
        var dict = [String: Any]()
        dict[Note.titleKey] = title
        dict[Note.contentKey] = content
        dict[Note.uidKey] = uid
       
        if color != UIColor.white, let colorHex = color.toHex() {
            dict[Note.colorKey] = colorHex
        }
        if impotance != Impotance.usual {
            dict[Note.impotanceKey] = impotance.rawValue
        }
        
        if let selfDestructionDate = selfDestructionDate {
            dict[Note.selfDestructionDateKey] = String(selfDestructionDate.timeIntervalSince1970)
        }
        dict[Note.creationDateKey] = String(creationDate.timeIntervalSince1970)
        return dict
    }
}
extension Note: Equatable {
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.color == rhs.color && lhs.content == rhs.content && lhs.impotance == rhs.impotance
            && lhs.selfDestructionDate == rhs.selfDestructionDate && lhs.title == rhs.title
            && lhs.uid == rhs.uid && lhs.creationDate == rhs.creationDate
    }
}
extension UIColor {
    
    func toHex() -> String? {
        /* if color.components return data in [white: ,alpha: ] format */
        if let components = cgColor.components, components.count == 2 {
            return String(format: "%02lX%02lX%02lX", lroundf(Float(components[0]) * 255), lroundf(Float(components[0]) * 255), lroundf(Float(components[0]) * 255))
        } else if let components = cgColor.components {
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
        return nil
      }
    
    static func hexStringToUIColor (hex: String) -> UIColor? {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()// очищает с двух сторон от кода пробелы и \n
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            return nil
        }
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
