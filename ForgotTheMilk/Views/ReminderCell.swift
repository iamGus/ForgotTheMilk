//
//  ReminderCell.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 28/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placemarkLabel: UILabel!
    
    
    static let reuseIdentifier = "ReminderCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with viewModel: ReminderCellViewModel) {
        titleLabel.text = viewModel.title
        placemarkLabel.text = viewModel.placeMark ?? "Temp placework"
    }

}
