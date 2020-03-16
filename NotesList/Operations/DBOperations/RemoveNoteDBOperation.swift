//
//  RemoveNoteDBOperation.swift
//  ios-online-l5-ops-example
//
//  Created by ios_school on 2/28/20.
//  Copyright © 2020 Dmitry Galimzyanov. All rights reserved.
//

import Foundation
import CoreData
class RemoveNoteDBOperation: BaseDBOperation {
    
    private var note: Note
    
    init(note: Note,fileNotebook: FileNotebook, context: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.note = note
        super.init(notebook: fileNotebook, context: context, backgroundContext: backgroundContext)
    }
    
    override func main() {
        notebook.remove(with: note.uid)
        do {
            try notebook.saveToFile()
        } catch {
            print("saveToFileError: \(error.localizedDescription)")
        }
        finish()
    }

}
