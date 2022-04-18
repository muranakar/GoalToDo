//
//  ToDoItemTableViewCell.swift
//  GoalToDo
//
//  Created by 村中令 on 2022/04/16.
//

import UIKit

class ToDoItemTableViewCell: UITableViewCell {
    @IBOutlet weak private var toDoItemLabel: UILabel!

    func configure(labelText: String) {
        toDoItemLabel.text = labelText
    }
}
