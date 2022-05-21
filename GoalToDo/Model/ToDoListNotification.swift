//
//  ToDoListNotification.swift
//  GoalToDo
//
//  Created by 村中令 on 2022/05/18.
//

import Foundation
import UIKit

struct ToDoListNotification {
    static func addNotificationToDoListDate(
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
//        print("month", month)
//        print("day", day)
//        print("hour", hour)
//        print("minute", minute)
//        print("second", second)
        // 直接日時を設定
        let triggerDate = DateComponents(month: month, day: day, hour: hour, minute: minute, second: second)
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
