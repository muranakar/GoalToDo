//
//  ToDoListXibTableViewCell.swift
//  WillDiary
//
//  Created by 澤田世那 on 2022/04/03.
//

import UIKit

class ToDoListXibTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBOutlet weak private var checkImageView: UIImageView!
    @IBOutlet weak private var detailedItemLabel: UILabel!

    func configureCell(
        checkImage: UIImage?,
        uncheckImage: UIImage?,
        todoItem: ToDoItem
    ) {
        checkImageView.image = todoItem.isCheck ? checkImage : uncheckImage
        detailedItemLabel.text = todoItem.toDoText
    }
}
