//
//  DataModel.swift
//  WillDiary
//
//  Created by 澤田世那 on 2022/04/01.
//

import Foundation
import RealmSwift

struct Goal {
    var uuidString = UUID().uuidString
    var goalText: String
    var goalDate = Date()
}

struct ToDoList {
    var uuidString = UUID().uuidString
    var toDoItems: [ToDoItem]
    var toDoDate: Date

    struct ToDoItem {
        var toDoText: String
        var isCheck: Bool
        var createdAt: Date
    }
}


class RealmGoal: Object {
    @objc dynamic var uuidString: String = ""
    @objc dynamic var goalText: String = ""
    @objc dynamic var goalDate: Date = Date()

    convenience init(uuid:UUID,  text: String,goalDate: Date) {
        self.init()
        self.uuidString = uuid.uuidString
        self.goalText = text
        self.goalDate = goalDate
    }
    override class func primaryKey() -> String? {
        "uuidString"
    }
}

class RealmToDoList: Object {
    @objc dynamic var uuidString: String = ""
    var toDoItems = List<RealmToDoItem>()
    @objc dynamic var toDoDate: Date = Date()
    convenience init(uuid:UUID, toDoDate: Date) {
        self.init()
        self.uuidString = uuid.uuidString
        self.toDoDate = toDoDate
    }
    override class func primaryKey() -> String? {
        "uuidString"
    }
}

class RealmToDoItem: Object {
    @objc dynamic var toDoText: String = ""
    @objc dynamic var isCheck: Bool = false
    @objc dynamic var createdAt: Date = Date()
    let toDoItems = LinkingObjects(fromType: RealmToDoList.self, property: "toDoItems")

    convenience init(toDoText: String,isCheck: Bool) {
        self.init()
        self.toDoText = toDoText
        self.isCheck = isCheck
    }
}


private extension Goal {
    init(managedObject: RealmGoal) {
        self.uuidString = managedObject.uuidString
        self.goalText = managedObject.goalText
        self.goalDate = managedObject.goalDate
    }

    func managedObject() -> RealmGoal {
        let realmGoal = RealmGoal()
        realmGoal.uuidString = self.uuidString
        realmGoal.goalText = self.goalText
        realmGoal.goalDate = self.goalDate
        return realmGoal
    }
}

private extension ToDoList {
    init(managedObject: RealmToDoList) {
        self.uuidString = managedObject.uuidString
        self.toDoDate = managedObject.toDoDate
        let realmToDoItemsArray = Array(managedObject.toDoItems)
        let toDoItemsArray = realmToDoItemsArray.map{ToDoItem(managedObject: $0)}
        self.toDoItems = toDoItemsArray
    }

    func managedObject() -> RealmToDoList {
        let realmToDoList = RealmToDoList()
        realmToDoList.uuidString = self.uuidString
        realmToDoList.toDoDate = self.toDoDate
        let realmToDoItemsArray = self.toDoItems.map{$0.managedObject()}
        realmToDoList.toDoItems.append(objectsIn: realmToDoItemsArray)
        return realmToDoList
    }
}
private extension ToDoList.ToDoItem {
    init(managedObject: RealmToDoItem) {
        self.isCheck = managedObject.isCheck
        self.toDoText = managedObject.toDoText
        self.createdAt = managedObject.createdAt
    }

    func managedObject() -> RealmToDoItem {
        let realmToDoItem = RealmToDoItem()
        realmToDoItem.isCheck = self.isCheck
        realmToDoItem.toDoText = self.toDoText
        realmToDoItem.createdAt = self.createdAt
        return realmToDoItem
    }
}

struct RealmRepository {
    private let realm = try! Realm()

    // MARK: -　Goal共通型に関するRepository
    func loadGoal() -> Goal? {
        let realmGoal = realm.objects(RealmGoal.self)
        let realmGoalArray = Array(realmGoal)
        let goalArray = realmGoalArray.map { Goal(managedObject: $0) }
        guard let goal = goalArray.first else { return nil }
        return goal
    }
    func appendGoal(goal: Goal){
        try! realm.write{
            let realmGoal = goal.managedObject()
            realm.add(realmGoal)
        }
    }
    func updateGoal(goal: Goal){
        try! realm.write {
            let realmGoal = realm.object(ofType: RealmGoal.self, forPrimaryKey: goal.uuidString)
            realmGoal?.goalText = goal.goalText
            realmGoal?.goalDate = goal.goalDate
        }
    }

    func removeGoal(goal: Goal) {
        guard let goal = realm.object(
            ofType: RealmGoal.self,
            forPrimaryKey: goal.uuidString
        ) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(goal)
        }
    }
    // MARK: -　ToDoList共通型に関するRepository
//    func loadToDoList(sortedAscending: Bool) -> [ToDoList] {
//        let realmToDoList = realm.objects(RealmToDoList.self).sorted(byKeyPath: "", ascending: <#T##Bool#>)
//        let realmToDoListArray = Array(realmToDoList)
//        let toDoList = realmToDoListArray.map { ToDoList(managedObject: $0) }
//        return toDoList
//    }
    func loadToDoItems(date: Date) -> [ToDoList.ToDoItem] {
        let realmToDoLists = realm.objects(RealmToDoList.self)
        let realmToDoList = realmToDoLists.filter("toDoDate == '\(date)'").first
        guard let realmToDoList = realmToDoList else { return [] }
        let toDoList = ToDoList(managedObject: realmToDoList)
        let toDoItems = toDoList.toDoItems
        return toDoItems
    }
    
    func loadToDoItems(date: Date, sortedAscending: Bool) -> [ToDoList.ToDoItem] {
        let realmToDoLists = realm.objects(RealmToDoList.self)
        let realmToDoList = realmToDoLists.filter("toDoDate == '\(date)'").first
        guard let realmToDoList = realmToDoList else { return [] }
        let realmToDoItems = realmToDoList.toDoItems
            .sorted(
                byKeyPath: "toDoDate",
                ascending: sortedAscending)
        let realmToDoItemArray = Array(realmToDoItems)
        let toDoItemArray = realmToDoItemArray.map { ToDoList.ToDoItem(managedObject: $0) }
        return toDoItemArray
    }
    
    func appendToDoList(toDoList: ToDoList){
        try! realm.write{
            let realmToDoList = toDoList.managedObject()
            realm.add(realmToDoList)
        }
    }
    func updateToDoList(toDoList: ToDoList){
        try! realm.write {
            let realmToDoList = realm.object(ofType: RealmToDoList.self, forPrimaryKey: toDoList.uuidString)
            realmToDoList?.toDoItems = toDoList.managedObject().toDoItems
            realmToDoList?.toDoDate = toDoList.toDoDate
        }
    }

    func removeToDoList(toDoList: ToDoList) {
        guard let toDoList = realm.object(
            ofType: RealmToDoList.self,
            forPrimaryKey: toDoList.uuidString
        ) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(toDoList)
        }
    }
}

// MARK: - せなさんコード
class ToDoListModel: Object {
    @objc dynamic var detailedItem = ""
    @objc dynamic var check = false
    @objc dynamic var createdAt = Date()
}

class DiaryModel: Object {
    @objc dynamic var calendarDate: String = ""
    @objc dynamic var diaryText: String = ""
    open var primaryKey: String {
        // TODO: 解読
        return "calendarDate"
    }
}
