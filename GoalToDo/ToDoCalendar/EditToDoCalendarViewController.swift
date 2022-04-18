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
    private var toDoList: ToDoList?
    private var toDoItems: [ToDoItem]
    @IBOutlet weak private var selectDateLabel: UILabel!
    @IBOutlet weak private var toDoItemTextField: UITextField!
    // TODO: TODOリストに変更
    // TODO: 編集データ保存　Repository
    required init?(coder: NSCoder, pushDate: Date) {
        self.pushedDate = pushDate
        self.toDoList = repository.loadToDoList(date: pushDate)
        if let toDoList = toDoList {
            self.toDoItems = repository.loadToDoItem(toDoList: toDoList)
        } else {
            self.toDoItems = []
        }
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction private func editToDoItems(_ sender: Any) {
        let toDoItem = ToDoItem(toDoText: toDoItemTextField.text!, isCheck: false, createdAt: Date())
        if let toDoList = toDoList {
            repository.appendToDoItem(toDoList: toDoList, toDoItem: toDoItem)
        } else {
            let newToDoList = ToDoList(toDoDate: pushedDate)
            repository.appendToDoList(toDoList: newToDoList)
            repository.appendToDoItem(toDoList: newToDoList, toDoItem: toDoItem)
        }
        performSegue(withIdentifier: "backToToDoCalendarViewControllerWithSegue", sender: nil)
    }
}
