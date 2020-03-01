//
//  LoadNotesDBOperation.swift
//  ios-online-l5-ops-example
//
//  Created by ios_school on 2/27/20.
//  Copyright © 2020 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

class LoadNotesDBOperation: BaseDBOperation {
    var result: [String: Note]?
    
    init(fileNotebook: FileNotebook) {
        super.init(notebook: fileNotebook)
    }
    
    override func main() {
        result = notebook.notes
        finish()
    }
}
