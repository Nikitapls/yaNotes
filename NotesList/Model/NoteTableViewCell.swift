//
//  NoteTableViewCell.swift
//  NotesList
//
//  Created by ios_school on 2/19/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var colorField: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
