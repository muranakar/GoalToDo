//
//  EditingTimerViewController.swift
//  WillDiary
//
//  Created by 澤田世那 on 2022/03/31.
//

import UIKit

class EditingTimerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var dyingDatePicker: UIDatePicker!

    @IBAction func decisionButtonAciton(_ sender: Any) {
        
    performSegue(withIdentifier: "exitFromEditByBackSegue", sender: nil)
    }
}
