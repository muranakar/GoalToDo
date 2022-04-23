//
//  ToDoListViewController.swift
//  WillDiary
//
//  Created by 澤田世那 on 2022/03/31.
//

import UIKit
// import RealmSwift

class ToDoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let repository = RealmRepository()
    private var toDoLists: [ToDoList] {
        let singleToDoLists = repository.loadToDoList()
        let sortedToDoLists = singleToDoLists.sorted { $0.toDoDate < $1.toDoDate } // TODO: コード理解必要
           return sortedToDoLists
       }

    private var toDoItems: [[ToDoItem]] {
        var items: [[ToDoItem]] = []
        toDoLists.forEach { toDoList in
            let singleToDoItems = repository.loadToDoItem(toDoList: toDoList)
            let sortedToDoItems = singleToDoItems.sorted { $0.createdAt < $1.createdAt } // TODO: コード理解必要
            items.append(sortedToDoItems)
        }
        return items
    }
    
    private var toDoList: ToDoList? {
        repository.loadToDoList(date: toDoDate)
    }
    var toDoDate: Date = Date()
    var toDoDateString: String {
        DateFormatter.calendrDateFormatter().string(from: toDoList?.toDoDate ?? Date())
    }
    private var sectionTittle: [String]?  // TODO: toDoListsの要素であるtoDoListのtoDoDateを取り出して、それをStringに変換したものを配列にする。
    var isSortedeAscending = true
    var editIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ToDoListXibTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell1")
        tableView.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBOutlet private weak var tableView: UITableView!

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension // 自動設定
     }

    // https://i-app-tec.com/ios/tableview-section.html を参考
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sectionTittle = sectionTittle {
            return sectionTittle.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionTittle?[section] // // TODO: toDoListの各日付の表示
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.results.count
//        guard let toDoItems = toDoItems else { return 0 }
//        return toDoItems.count
        toDoItems.count // TODO: それぞれのtoDoListによって異なってくる
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! ToDoListXibTableViewCell
////        let item = self.results[indexPath.row]
//        guard let toDoItems = toDoItems else { return cell }
//
//        let item = toDoItems[indexPath.row]
////        cell.checkImageView.image = item.check ? UIImage(named: "check") : UIImage(named: "uncheck")
////        cell.detailedItemLabel.text = item.detailedItem
//        // itemを書き込んだ日付を現在時刻(Date())から日本時間の現在時刻に変換しなければならない
//        cell.checkImageView.image = item.isCheck ? UIImage(named: "check") : UIImage(named: "uncheck")
//        cell.detailedItemLabel.text = item.toDoText
        

        return cell
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        editIndexPath = indexPath
////        let item = self.results[indexPath.row]
////        try! Realm().write {
////            item.check = !item.check
////        }
//        guard let toDoItems = toDoItems else { return }
//        var item = toDoItems[indexPath.row]
//        item.isCheck = !item.isCheck
//
//        toDoList = ToDoList(toDoItems: [item], toDoDate: toDoDate)
//        guard let toDoList = toDoList else { return }
//        realmRepository.updateToDoList(toDoList: toDoList)
//
//        self.tableView.reloadRows(at: [indexPath], with: .automatic)
//    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "editSegue", sender: indexPath)
    }

//    func tableView(_ tableView: UITableView,
//                   commit editingStyle: UITableViewCell.EditingStyle,
//                   forRowAt indexPath: IndexPath) {
////        if editingStyle == .delete {
////            try! Realm().write {
////                try! Realm().delete(self.results[indexPath.row])
////            }
////            tableView.deleteRows(at: [indexPath], with: .automatic)
////        }
//        if editingStyle == .delete {
//            guard let toDoItems = toDoItems else { return }
//            let item = toDoItems[indexPath.row]
//            toDoList = ToDoList(toDoItems: [item], toDoDate: toDoDate)
//            guard let toDoList = toDoList else { return }
//            realmRepository.removeToDoList(toDoList: toDoList)
//        }
//        tableView.deleteRows(at: [indexPath], with: .automatic)
//    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let add = (segue.destination as? UINavigationController)?.topViewController as? AddListViewController {
//            switch segue.identifier ?? "" {
//            case "addSegue":
//            add.mode = AddListViewController.Mode.add
//            case "editSegue":
//            add.mode = AddListViewController.Mode.edit
//                if let indexPath = sender {
//                    guard let toDoItems = toDoItems else { return }
//                    let item = toDoItems[(indexPath as AnyObject).row]
//                    add.toDoText = item.toDoText
//                }
//            default:
//                break
//            }
//        }
//    }

    @IBAction private func exitFromAddByCancelSegue(segue: UIStoryboardSegue) {
    }

    @IBAction private func exitFromAddBySaveSegue(segue: UIStoryboardSegue) {
//        if let add = segue.source as? AddListViewController {
////            let newItem = ToDoListModel()
////            newItem.detailedItem = add.detailedItemTextField.text ?? ""
////            newItem.check = false
////
////            try! Realm().write {
////                try! Realm().add(newItem)
////            }
//            toDoItems = [ToDoList.ToDoItem(
//                toDoText: add.detailedItemTextField.text ?? "",
//                isCheck: false, createdAt: Date())]
//            guard let toDoItems = toDoItems else { return }
//            toDoList = ToDoList(toDoItems: toDoItems, toDoDate: toDoDate)
//            guard let toDoList = toDoList else { return }
//            realmRepository.appendToDoList(toDoList: toDoList)
//            self.tableView.reloadData()
//        }
    }

    @IBAction private func exitFromEditByCancelSegue(segue: UIStoryboardSegue) {
    }

    @IBAction private func exitFromEditBySaveSegue(segue: UIStoryboardSegue) {
//        if let add = segue.source as? AddListViewController {
//            if let indexPath = editIndexPath {
////                try! Realm().write {
////                    self.results[indexPath.row].detailedItem = add.detailedItemTextField.text ?? ""
////                }
//                guard let toDoItems = toDoItems else { return }
//                var item = toDoItems[indexPath.row]
//                item.toDoText = add.detailedItemTextField.text ?? ""
//                toDoList = ToDoList(toDoItems: [item], toDoDate: toDoDate)
//                guard let toDoList = toDoList else { return }
//                realmRepository.updateToDoList(toDoList: toDoList)
//
//                self.tableView.reloadRows(at: [indexPath], with: .automatic)
//            }
//        }
//    }
    }
}

private extension DateFormatter {
    static func calendrDateFormatter() -> Self {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "ydMMM",
            options: 0,
            locale: Locale(identifier: "ja_JP")
        )
        return formatter as! Self
    }
}
