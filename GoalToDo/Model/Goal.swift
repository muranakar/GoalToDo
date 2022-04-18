//
//  Goal.swift
//  GoalToDo
//
//  Created by 村中令 on 2022/04/16.
//

import Foundation

struct Goal {
    // uuidString自体がRealmに依存している。structでID:RawRepresentableで、UUIDとUUIDStringを管理しても良いかも。
    var uuidString = UUID().uuidString
    var goalText: String
    var goalDate = Date()
}
