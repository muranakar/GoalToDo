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
    private var toDoItems: [ToDoList.ToDoItem]
    @IBOutlet weak private var selectDateLabel: UILabel!
    @IBOutlet weak private var toDoItemTextField: UITextField!
    // TODO: TODOリストに変更
    // TODO: 編集データ保存　Repository
    required init?(coder: NSCoder, pushDate: Date) {
        self.pushedDate = pushDate
        self.pushDateString = DateFormatter.calendrDateFormatter().string(from: pushDate)
        self.toDoItems = repository.loadToDoItems(date: pushDateString!)
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
        let toDoItem = ToDoList.ToDoItem(toDoText: toDoItemTextField.text!, isCheck: false, createdAt: pushedDate)
        toDoItems.append(toDoItem)
        let toDoList = ToDoList(toDoItems: toDoItems, toDoDate: Date())
        repository.appendToDoList(toDoList: toDoList)
        performSegue(withIdentifier: "backToToDoCalendarViewControllerWithSegue", sender: nil)
    }
}

private extension DateFormatter {
    static func calendrDateFormatter() -> Self {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "ydMMM",
            options: 0,
            locale: Locale(identifier: "ja_JP")
        )
        return formatter as! Self
    }
}
