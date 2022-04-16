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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var detailedItemLabel: UILabel!
    
}
