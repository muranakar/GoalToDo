//
//  PushDateTableViewCell.swift
//  GoalToDo
//
//  Created by 村中令 on 2022/04/16.
//

import UIKit

class PushDateTableViewCell: UITableViewCell {
    @IBOutlet weak private var pushDateLabel: UILabel!

    func configure(labelText: String) {
        pushDateLabel.text = labelText
    }
}
