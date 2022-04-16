//
//  Goal.swift
//  GoalToDo
//
//  Created by 村中令 on 2022/04/16.
//

import Foundation

struct Goal {
    var uuidString = UUID().uuidString
    var goalText: String
    var goalDate = Date()
}
