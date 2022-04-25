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

    private var toDoItems: [[ToDoItem]] { // [[uuid: a, isCheck: true],[uuid: b, isCheck: false]]
        var items: [[ToDoItem]] = []
        toDoLists.forEach { toDoList in
            let singleToDoItems = repository.loadToDoItem(toDoList: toDoList)
            let sortedToDoItems = singleToDoItems.sorted { $0.createdAt < $1.createdAt } // TODO: コード理解必要
            items.append(sortedToDoItems)
        }
        return items
    }
    
    var toDoDate: Date = Date()
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
        toDoLists.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var toDoDateString: String {
            DateFormatter.calendrDateFormatter().string(from: toDoLists[section].toDoDate)
        }
        return toDoDateString
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let singleToDoItems = repository.loadToDoItem(toDoList: toDoLists[section])
        return singleToDoItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! ToDoListXibTableViewCell
//        let item = self.results[indexPath.row]
//        cell.checkImageView.image = item.check ? UIImage(named: "check") : UIImage(named: "uncheck")
//        cell.detailedItemLabel.text = item.detailedItem
// TODO: 以下コード解読必要 (なぜindexPath.rowを2回指定する必要があるか)
        let items = toDoItems[indexPath.row] // Section選んで
        let item = items[indexPath.row]     // Cell選んでるイメージ？
        cell.checkImageView.image = item.isCheck ? UIImage(named: "check") : UIImage(named: "uncheck")
        cell.detailedItemLabel.text = item.toDoText
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let item = self.results[indexPath.row]
        //        try! Realm().write {
        //            item.check = !item.check
        //        }
        editIndexPath = indexPath
        let items = toDoItems[indexPath.row]
        var item = items[indexPath.row]
        item.isCheck = !item.isCheck
        repository.updateToDoItem(toDoItem: item)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "editSegue", sender: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            try! Realm().write {
//                try! Realm().delete(self.results[indexPath.row])
//            }
        if editingStyle == .delete {
            let items = toDoItems[indexPath.row]
            let item = items[indexPath.row]
            repository.removeToDoItem(toDoItem: item)
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let add = (segue.destination as? UINavigationController)?.topViewController as? AddListViewController {
            switch segue.identifier ?? "" {
            case "addSegue":
            add.mode = AddListViewController.Mode.add
            case "editSegue":
            add.mode = AddListViewController.Mode.edit
                if let indexPath = sender {
                    let indexPath = indexPath as AnyObject
                    let items = toDoItems[indexPath.row]
                    let item = items[indexPath.row]
                    add.toDoText = item.toDoText
                }
            default:
                break
            }
        }
    }

    @IBAction private func exitFromAddByCancelSegue(segue: UIStoryboardSegue) {
    }

    @IBAction private func exitFromAddBySaveSegue(segue: UIStoryboardSegue) {
        if let add = segue.source as? AddListViewController {
//            let newItem = ToDoListModel()
//            newItem.detailedItem = add.detailedItemTextField.text ?? ""
//            newItem.check = false
//
//            try! Realm().write {
//                try! Realm().add(newItem)
//            }
            // TODO: どの日付にItemを追加するのかで処理が変わってくる。
            // TODO: SectionTittleをタップさせて、その日付のCellに追加させるのか、新たに日付を追加して、その日付にCellを追加させるのか
//            let newToDoItem = ToDoItem(
//        toDoText: add.detailedItemTextField.text ?? "", isCheck: false, createdAt: Date())
//            repository.appendToDoItem(toDoList: <#T##ToDoList#>, toDoItem: <#T##ToDoItem#>)
            self.tableView.reloadData()
        }
    }

    @IBAction private func exitFromEditByCancelSegue(segue: UIStoryboardSegue) {
    }

    @IBAction private func exitFromEditBySaveSegue(segue: UIStoryboardSegue) {
        if let add = segue.source as? AddListViewController {
            if let indexPath = editIndexPath {
//                try! Realm().write {
//                    self.results[indexPath.row].detailedItem = add.detailedItemTextField.text ?? ""
//                }
                let items = toDoItems[indexPath.row]
                var item = items[indexPath.row]
                item.toDoText = add.detailedItemTextField.text ?? ""
                repository.updateToDoItem(toDoItem: item)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
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
