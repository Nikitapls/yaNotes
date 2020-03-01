//
//  LoadNotesOperation.swift
//  ios-online-l5-ops-example
//
//  Created by ios_school on 2/28/20.
//  Copyright © 2020 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

class LoadNotesOperation: AsyncOperation {

    private let notebook: FileNotebook
    private let loadFromDB: LoadNotesDBOperation
    private var loadFromBackend: LoadNotesBackendOperation

    private(set) var notes: [Note]?

    init(notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        self.notebook = notebook

        loadFromDB = LoadNotesDBOperation(fileNotebook: notebook)
        loadFromBackend = LoadNotesBackendOperation(notes: Array(notebook.notes.values))

        super.init()
        
        loadFromBackend.completionBlock = { [weak self] in
            guard let self = self else { return }
            switch self.loadFromBackend.result! {
            case .success(let notes):
                self.notes = notes
                self.finish()
            case .failure:
                dbQueue.addOperation(self.loadFromDB)
            }
        }
        loadFromDB.completionBlock = { [weak self] in
            guard let self = self else { return }
            self.notes = self.loadFromDB.result
            self.finish()
        }
    }

    override func main() {
        backendQueue.addOperation(loadFromBackend)
    }
}
