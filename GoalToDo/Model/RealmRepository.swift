//
//  DataModel.swift
//  WillDiary
//
//  Created by 澤田世那 on 2022/04/01.
//

import Foundation
import RealmSwift

class RealmGoal: Object {
    @objc dynamic var uuidString: String = ""
    @objc dynamic var goalText: String = ""
    @objc dynamic var goalDate: Date = Date()

    convenience init(uuid: UUID, text: String, goalDate: Date) {
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
    convenience init(uuid: UUID, toDoDate: Date) {
        self.init()
        self.uuidString = uuid.uuidString
        self.toDoDate = toDoDate
    }
    override class func primaryKey() -> String? {
        "uuidString"
    }
}

class RealmToDoItem: Object {
    @objc dynamic var uuidString: String = ""
    @objc dynamic var toDoText: String = ""
    @objc dynamic var isCheck: Bool = false
    @objc dynamic var createdAt: Date = Date()
    let toDoItems = LinkingObjects(fromType: RealmToDoList.self, property: "toDoItems")

    convenience init(uuid: UUID, toDoText: String, isCheck: Bool) {
        self.init()
        self.uuidString = uuid.uuidString
        self.toDoText = toDoText
        self.isCheck = isCheck
    }
    override class func primaryKey() -> String? {
        "uuidString"
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
    }

    func managedObject() -> RealmToDoList {
        let realmToDoList = RealmToDoList()
        realmToDoList.uuidString = self.uuidString
        realmToDoList.toDoDate = self.toDoDate
        return realmToDoList
    }
}
private extension ToDoItem {
    init(managedObject: RealmToDoItem) {
        self.uuidString = managedObject.uuidString
        self.isCheck = managedObject.isCheck
        self.toDoText = managedObject.toDoText
        self.createdAt = managedObject.createdAt
    }

    func managedObject() -> RealmToDoItem {
        let realmToDoItem = RealmToDoItem()
        realmToDoItem.uuidString = self.uuidString
        realmToDoItem.isCheck = self.isCheck
        realmToDoItem.toDoText = self.toDoText
        realmToDoItem.createdAt = self.createdAt
        return realmToDoItem
    }
}

struct RealmRepository {
    private let realm = try! Realm()
    // MARK: - Goal共通型に関するRepository
    func loadGoal() -> Goal? {
        let realmGoal = realm.objects(RealmGoal.self)
        let realmGoalArray = Array(realmGoal)
        let goalArray = realmGoalArray.map { Goal(managedObject: $0) }
        guard let goal = goalArray.first else { return nil }
        return goal
    }
    func appendGoal(goal: Goal) {
        try! realm.write {
            let realmGoal = goal.managedObject()
            realm.add(realmGoal)
        }
    }
    func updateGoal(goal: Goal) {
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
    // MARK: - ToDoList共通型に関するRepository
    func loadToDoList(date: Date) -> ToDoList? {
        let realmToDoLists = realm.objects(RealmToDoList.self)
        guard let realmToDoList = realmToDoLists
            .filter("toDoDate == %@", date)
            .first else { return nil }
        let toDoList = ToDoList(managedObject: realmToDoList)
        return toDoList
    }
    func loadToDoList() -> [ToDoList] {
        let realmToDoLists = realm.objects(RealmToDoList.self)
        let realmtoDoListsArray = Array(realmToDoLists)
        let toDoLists = realmtoDoListsArray.map { ToDoList(managedObject: $0)}
        return toDoLists
    }

    func appendToDoList(toDoList: ToDoList) {
        try! realm.write {
            let realmToDoList = toDoList.managedObject()
            realm.add(realmToDoList)
        }
    }
    func updateToDoList(toDoList: ToDoList) {
        try! realm.write {
            let realmToDoList = realm.object(ofType: RealmToDoList.self, forPrimaryKey: toDoList.uuidString)
            realmToDoList?.toDoDate = toDoList.toDoDate
        }
    }

    func removeToDoList(toDoList: ToDoList) {
        guard let toDoList = realm.object(
            ofType: RealmToDoList.self,
            forPrimaryKey: toDoList.uuidString
        ) else { return }
        try! realm.write {
            realm.delete(toDoList)
        }
    }

    func loadToDoItem(toDoList: ToDoList) -> [ToDoItem] {
        let realmAssessor = realm.object(ofType: RealmToDoList.self, forPrimaryKey: toDoList.uuidString)
        guard let realmToDoItems = realmAssessor?.toDoItems else { return [] }
        let toDoItemsArray = Array(realmToDoItems)
        let toDoItems = toDoItemsArray.map {ToDoItem(managedObject: $0)}
        return toDoItems
    }

    func loadToDoItem(toDoItem: ToDoItem) -> ToDoItem? {
        guard let realmToDoItem = realm.object(
            ofType: RealmToDoItem.self,
            forPrimaryKey: toDoItem.uuidString
        ) else {
            return nil
        }
        let toDoItem = ToDoItem(managedObject: realmToDoItem)
        return toDoItem
    }

    func appendToDoItem(toDoList: ToDoList, toDoItem: ToDoItem) {
        guard let list = realm.object(
            ofType: RealmToDoList.self,
            forPrimaryKey: toDoList.uuidString
        )?.toDoItems else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            list.append(toDoItem.managedObject())
        }
    }

    func updateToDoItem(toDoItem: ToDoItem) {
        try! realm.write {
            let realmToDoItem = realm.object(ofType: RealmToDoItem.self, forPrimaryKey: toDoItem.uuidString)
            realmToDoItem?.toDoText = toDoItem.toDoText
            realmToDoItem?.isCheck = toDoItem.isCheck
            realmToDoItem?.createdAt = toDoItem.createdAt
        }
    }

    func removeToDoItem(toDoItem: ToDoItem) {
        guard let fetchedRealmtoDoItem = realm.object(
            ofType: RealmToDoItem.self,
            forPrimaryKey: toDoItem.uuidString
        ) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(fetchedRealmtoDoItem)
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
