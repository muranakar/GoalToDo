//
//  SettingViewController.swift
//  GoalToDo
//
//  Created by 村中令 on 2022/05/06.
//

import UIKit

class SettingViewController: UIViewController {
    private var request: UNNotificationRequest!
    private let repository = RealmRepository()
    private var toDoLists: [ToDoList] {
        let singleToDoLists = repository.loadToDoList()
        let sortedToDoLists = singleToDoLists.sorted { $0.toDoDate < $1.toDoDate }
        return sortedToDoLists
    }

    private var toDoItems: [[ToDoItem]] {
        var items: [[ToDoItem]] = []
        toDoLists.forEach { toDoList in
            let singleToDoItems = repository.loadToDoItem(toDoList: toDoList)
            let sortedToDoItems = singleToDoItems.sorted { $0.createdAt < $1.createdAt }
            items.append(sortedToDoItems)
        }
        return items
    }
    //
    private var dictionaryToDoListAndToDoItems: [ToDoList: [ToDoItem]] {
        [ToDoList: [ToDoItem]](uniqueKeysWithValues: zip(toDoLists, toDoItems))
    }
    @IBOutlet weak private var datePicker: UIDatePicker!
    @IBOutlet weak private var notificationSwitch: UISwitch!
    // この初期値は設定する必要性はない。
    private var isNotification: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()

        switch LaunchUtil.launchStatus {
        case .firstLaunch:
            print("初回起動")
            // 初回起動時（１回だけ）に行う処理
            // ①isNotificationに、trueを代入
            // ②UserDefaultsのIsNotificationに、trueを保存
            // ③UISwitchのisOnを、trueに変更
            isNotification = true
            ToDoListNotificationRepository().saveIsNotification(isNotification: true)
            notificationSwitch.isOn = isNotification
        case .newVersionLaunch, .launched:
            print("通常起動と、新しいバージョン一緒にした")
            // 2回目以降に行う処理
            // ①isNotificationに、UserDefaultsに保存されているIsNotificationを代入
            // ②UISwitchのisOnを、IsNotificationを設定
            isNotification = ToDoListNotificationRepository().loadIsNotification()
            notificationSwitch.isOn = isNotification
        }
    }

    @IBAction private func switchIsNotification(_ sender: Any) {
        isNotification.toggle()
        ToDoListNotificationRepository().saveIsNotification(isNotification: isNotification)
        notificationSwitch.isOn = isNotification

        if isNotification == true {
            // 通知登録処理
            dictionaryToDoListAndToDoItems.forEach { (key: ToDoList, value: [ToDoItem]) in
                ToDoListNotification.addNotificationToDoListDate(
                    toDoList: key,
                    toDoItems: value,
                    specifiedDate: datePicker.date
                )
            }
        } else {
            //　通知削除処理
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        //　通知削除、登録されているかを確認するため、print()
        UNUserNotificationCenter.current().getPendingNotificationRequests { notification in
            print("通知リスト", notification)
        }
    }
}
