//
//  LoadNotesBackendOperations.swift
//  ios-online-l5-ops-example
//
//  Created by ios_school on 2/27/20.
//  Copyright © 2020 Dmitry Galimzyanov. All rights reserved.
//

import Foundation

enum LoadNotesBackendResult {
  case success([Note])
  case failure(NetworkError)
}

class LoadNotesBackendOperation: BaseBackendOperation {

    var result: LoadNotesBackendResult?
    
    init(notes: [Note]) {
        super.init()
    }
    
    override func main() {
        result = .failure(.unreachable)
        finish()
    }
}
