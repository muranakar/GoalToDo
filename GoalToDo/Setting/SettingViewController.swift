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
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func notifySpecifiedTime(_ sender: Any) {
        dictionaryToDoListAndToDoItems.forEach { (key: ToDoList, value: [ToDoItem]) in
            notificationToDoListDate(toDoList: key, toDoItems: value, specifiedDate: datePicker.date)
        }
        UNUserNotificationCenter.current().getPendingNotificationRequests { notification in
            print(notification)
        }
    }

    func notificationToDoListDate(
            toDoList: ToDoList,
            toDoItems: [ToDoItem],
            specifiedDate: Date
        ) {
            let format = DateFormatter()
            format.dateFormat = "yyyy/MM/dd/HH/mm/ss"
            format.locale = Locale(identifier: "ja_JP")
            // TODO:: ２つのDateをDateフォーマットして、分ける。
            let formatToDoListDate = format.string(from: toDoList.toDoDate)
            print("todolist", formatToDoListDate)
            let separatedFormatToDoListDate: [String] = formatToDoListDate.components(separatedBy: "/")
            let formatSpecifiedDate = format.string(from: specifiedDate)
            print("specified", formatSpecifiedDate)
            let separatedFormatSpecifiedDate: [String] = formatSpecifiedDate.components(separatedBy: "/")

            // TODO:: TODOLISTのDateを月・日を指定する。
            let month = Int(separatedFormatToDoListDate[1])!
            let day = Int(separatedFormatToDoListDate[2])!

            //  TODO:: 指定されたのDateを時間・分を指定する。
            let hour = Int(separatedFormatSpecifiedDate[3])!
            let minute = Int(separatedFormatSpecifiedDate[4])!
            let second = Int(separatedFormatSpecifiedDate[5])!
            print("month", month)
            print("day", day)
            print("hour", hour)
            print("minute", minute)
            print("second", second)
            // 直接日時を設定
            let triggerDate = DateComponents(month: month, day: day, hour: hour, minute:minute, second: second)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            // 通知コンテンツの作成
            let content = UNMutableNotificationContent()
            content.title = "GoalTODO"
            content.body = "\(toDoItems.count)個　やることリストがあります。"
            content.sound = UNNotificationSound.default
            // 通知リクエストの作成
            // identifierをtoDoListのDate型の文字列型に変更。
            let request = UNNotificationRequest.init(
                identifier: format.string(from: toDoList.toDoDate),
                content: content,
                trigger: trigger)
            // 通知リクエストの登録
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }
}
