//
//  AddListViewController.swift
//  WillDiary
//
//  Created by 澤田世那 on 2022/03/31.
//

import UIKit

class AddListViewController: UIViewController {

    enum Mode {
        case add
        case edit
    }
    var mode = Mode.add
    var toDoText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if mode == .edit {
            detailedItemTextField.text = toDoText
        }
    }
    @IBOutlet weak var detailedItemTextField: UITextField!
    
    @IBAction private func saveButtonAction(_ sender: Any) {
        if mode == .add {
            let identifier = "exitFromAddBySaveSegue"
            performSegue(withIdentifier: identifier, sender: sender)
        } else {
            let identifier = "exitFromEditBySaveSegue"
            performSegue(withIdentifier: identifier, sender: sender)
        }
    }

    @IBAction private func cancelButtonAction(_ sender: Any) {
        if mode == .add {
            let identifier = "exitFromAddByCancelSegue"
            performSegue(withIdentifier: identifier, sender: sender)
        } else {
            let identifier = "exitFromEditByCancelSegue"
            performSegue(withIdentifier: identifier, sender: sender)
        }
    }
}
