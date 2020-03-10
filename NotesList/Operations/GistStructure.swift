//
//  GistStructure.swift
//  NotesList
//
//  Created by ios_school on 3/7/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Foundation
struct GistLoad: Codable {
    let files: [String: GistFileLoad]
}

struct GistFileLoad: Codable {
    let content: String
}

struct GistDownload: Codable {
    let gistId: String
    let files: [String: GistFileDownload]
    enum CodingKeys: String, CodingKey {
        case gistId = "id"
        case files = "files"
    }
}

struct GistFileDownload: Codable {
    let rawUrl: String
    enum CodingKeys: String, CodingKey {
       case rawUrl = "raw_url"
    }
}

