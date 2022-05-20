//
//  IsNotificationRepository.swift
//  GoalToDo
//
//  Created by 村中令 on 2022/05/18.
//

import Foundation

struct ToDoListNotificationRepository {
    let keyIsNotification = "isNotification"
    let keyNotificationDate = "notificationDate"
    func loadIsNotification() -> Bool {
        let loadedIsNotification = UserDefaults.standard.bool(forKey: keyIsNotification)
        return loadedIsNotification
    }
    func saveIsNotification(isNotification: Bool) {
        UserDefaults.standard.set(isNotification, forKey: keyIsNotification)
    }

    func loadNotificationDate() -> Date? {
        let loadedNotificationDate = UserDefaults.standard.object(forKey: keyNotificationDate) as? Date
        return loadedNotificationDate
    }
    func saveNotificationDate(notificationDate: Date) {
        UserDefaults.standard.set(notificationDate, forKey: keyNotificationDate)
    }

    // 削除はなくてもよいか。
//    func remove() {
//       UserDefaults.standard.removeObject(forKey: key)
//    }
}
