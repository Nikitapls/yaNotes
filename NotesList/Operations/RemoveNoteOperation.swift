//
//  RemoveNoteOperation.swift
//  ios-online-l5-ops-example
//
//  Created by ios_school on 2/28/20.
//  Copyright © 2020 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

class RemoveNoteOperation: AsyncOperation {
    private let note: Note
    private let notebook: FileNotebook
    private var removeFromDb: RemoveNoteDBOperation
    private var removeFromBackend: SaveNotesBackendOperation
    
    private(set) var result: Bool? = false
    
    init(note: Note,
    notebook: FileNotebook,
    backendQueue: OperationQueue,
    dbQueue: OperationQueue) {
        
        self.notebook = notebook
        self.note = note
        
        removeFromDb = RemoveNoteDBOperation(note: note, fileNotebook: notebook)
        removeFromBackend = SaveNotesBackendOperation(notes: Array(notebook.notes.values))
        super.init()
        
        removeFromBackend.completionBlock = { [weak self] in
            guard let self = self else { return }
            switch self.removeFromBackend.result! {
            case .success:
                    self.result = true
            case .failure(.unreachable):
                    self.result = false
            }
            dbQueue.addOperation(self.removeFromDb)
        }
        
        removeFromDb.completionBlock = { [weak self] in
        guard let self = self else { return }
            self.finish()
        }
    }
    
    override func main() {
        backendQueue.addOperation(removeFromBackend)
    }
}
