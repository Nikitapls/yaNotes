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
        colorField.layer.borderWidth = 1
        colorField.layer.borderColor = UIColor.gray.cgColor
        colorField.layer.cornerRadius = 5
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
