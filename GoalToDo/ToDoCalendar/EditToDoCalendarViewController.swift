//
//  EditingDiaryViewController.swift
//  WillDiary
//
//  Created by 澤田世那 on 2022/03/31.
//

import UIKit
import RealmSwift

class EditingDiaryViewController: UIViewController, UITextViewDelegate {

    
    var pushDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        diaryDescriptionTextView.delegate = self
        diaryDescriptionTextView.layer.borderColor = UIColor.black.cgColor
        diaryDescriptionTextView.layer.borderWidth = 1.0
        diaryDescriptionTextView.layer.cornerRadius = 10.0
        diaryDescriptionTextView.layer.masksToBounds = true
        
        if let pushDate = pushDate {
            selectDateLabel.text = pushDate
        }
    }

    override func viewWillAppear(_ animated: Bool) { // TODO: 解読
        super.viewWillAppear(animated)

        if let pushDate = pushDate {
            selectDateLabel.text = pushDate
        }
        
        DispatchQueue(label: "background").async { // TODO: 解読
            let realm = try! Realm()

            if let savedDiary = realm.objects(DiaryModel.self).filter("calendarDate == '\(self.pushDate!)'").last {
                    let context = savedDiary.diaryText
                    DispatchQueue.main.async {
                        self.diaryDescriptionTextView.text = context
                    }
            }
        }
    }
    
    @IBOutlet weak var selectDateLabel: UILabel!
    @IBOutlet weak var diaryDescriptionTextView: UITextView!
    
    @IBAction func saveButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "exitFromEditBySaveSegue", sender: nil)
    }
}
