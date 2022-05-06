//
//  ToDo.swift
//  GoalToDo
//
//  Created by 村中令 on 2022/04/16.
//

import Foundation

struct ToDoList :Hashable {
    var uuidString = UUID().uuidString
    var toDoDate: Date
}

struct ToDoItem {
    var uuidString = UUID().uuidString
    var toDoText: String
    var isCheck: Bool
    var createdAt: Date
}
