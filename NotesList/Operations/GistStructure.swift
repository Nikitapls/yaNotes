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

struct GistDownload: Codable {
    let files: [String: GistFileDownload]
}

struct GistFileDownload: Codable {
    let rawUrl: String
    let gistId: String
    enum CodingKeys: String, CodingKey {
        case gistId = "id"
        case rawUrl = "raw_url"
    }
}

struct GistFileLoad: Codable {
    let content: String
}
