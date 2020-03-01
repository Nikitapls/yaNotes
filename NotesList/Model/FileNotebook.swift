import Foundation
import UIKit
import CocoaLumberjack
//import CocoaLumberjack.swift
class FileNotebook {
    
    private(set) var notes: [String: Note] = [String: Note]()
    private lazy var dirPath: URL  = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("caches")
    
    public func add(_ note: Note) {
        if notes[note.uid] != nil {
            DDLogInfo("Note with id \(note.uid) is overwritten")
        } else {
            notes[note.uid] = note
            DDLogInfo("Note with id \(note.uid) is added")
        }
    }
    
    public func remove(with uid: String) {
        notes.removeValue(forKey: uid)
        DDLogInfo("Note with id \(uid) is removed")
    }
    
    public func saveToFile() throws {
        var dictJson = [String: Any]()
        for (uid, value) in notes {
            dictJson[uid] = value.json
        }
        let jsdata = try JSONSerialization.data(withJSONObject: dictJson, options: [])
        FileManager.default.createFile(atPath: dirPath.path, contents: jsdata, attributes: nil)
        DDLogInfo("Notes are saved to file")
    }
    
    public func loadFromFile() throws {
        let jsonData = try Data(contentsOf: dirPath)
        let dictData = try JSONSerialization.jsonObject(with: jsonData, options: [])
        if let dictData = dictData as? Dictionary<String, Dictionary<String,Any>> { // fixed from AnyObject
            var dictInput = [String: Note]()
            for (key, value) in dictData {
                dictInput[key] = Note.parse(json: value)
            }
            self.notes = dictInput
            DDLogInfo("Notes are loaded from file")
        }
    }
    
    public func setUrl(url: URL) {
        self.dirPath = url
    }
    
    public func replaceNotes(notes: [String: Note]) {
        self.notes = notes
    }
}
