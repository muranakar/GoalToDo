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
            // すでに保存しているToDoListの中に、ToDoItemを追加する。
            repository.appendToDoItem(toDoList: toDoList, toDoItem: toDoItem)
            //　すでにToDoListが作成されている場合の通知処理
            addNofitycationToDoListIfConditionsAreMet(
                toDoList: toDoList,
                toDoItems: repository.loadToDoItem(toDoList: toDoList)
            )
        } else {
            // 新規で作成したToDoListの中に、ToDoItemを追加する
            let newToDoList = ToDoList(toDoDate: pushedDate)
            repository.appendToDoList(toDoList: newToDoList)
            repository.appendToDoItem(toDoList: newToDoList, toDoItem: toDoItem)
            // 新規でToDoListが作成された場合の、通知処理
            addNofitycationToDoListIfConditionsAreMet(
                toDoList: newToDoList,
                toDoItems: repository.loadToDoItem(toDoList: newToDoList)
            )
        }
        // 通知設定されているかの確認
        UNUserNotificationCenter.current().getPendingNotificationRequests { notification in
            print("登録通知確認", notification)
        }
        performSegue(withIdentifier: "backToToDoCalendarViewControllerWithSegue", sender: nil)
    }
}

func addNofitycationToDoListIfConditionsAreMet(
    toDoList: ToDoList,
    toDoItems: [ToDoItem]
) {
    if ToDoListNotificationRepository().loadNotificationDate() != nil
        && ToDoListNotificationRepository().loadIsNotification() == true {
        ToDoListNotification.addNotificationToDoListDate(
            toDoList: toDoList,
            toDoItems: toDoItems,
            specifiedDate: ToDoListNotificationRepository().loadNotificationDate()!
        )
    }
}
