//
//  EditingDiaryViewController.swift
//  WillDiary
//
//  Created by 澤田世那 on 2022/03/31.
//

import UIKit
import RealmSwift

class EditToDoCalendarViewController: UIViewController, UITextViewDelegate {
    var pushDateString: String?
    private var pushedDate: Date
    private let repository = RealmRepository()
    private var toDoItems: [ToDoList.ToDoItem] {
        repository.loadToDoItems(date: pushedDate)
    }
    @IBOutlet weak private var selectDateLabel: UILabel!
    @IBOutlet weak private var toDoItemTextField: UITextField!
    // TODO: TODOリストに変更
    // TODO: 編集データ保存　Repository
    required init?(coder: NSCoder, pushDate: Date) {
        self.pushedDate = pushDate
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let pushDate = pushDateString {
            selectDateLabel.text = pushDate
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let pushDate = pushDateString {
            selectDateLabel.text = pushDate
        }
        DispatchQueue(label: "background").async {
            let realm = try! Realm()
            if let savedDiary = realm.objects(DiaryModel.self).filter("calendarDate == '\(self.pushDateString)'").last {
                    let context = savedDiary.diaryText
            }
        }
    }

    @IBAction func editToDoItems(_ sender: Any) {
        toDoItems.append(contentsOf: )
        let toDoItem = ToDoList.ToDoItem(toDoText: toDoItemTextField.text!, isCheck: false, createdAt: Date())
        repository.appendToDoList(toDoList: <#T##ToDoList#>)
        toDoItemTextField.text!
        performSegue(withIdentifier: "backToToDoCalendarViewControllerWithSegue", sender: nil)
    }


}
