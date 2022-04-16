//
//  ToDoListViewController.swift
//  WillDiary
//
//  Created by 澤田世那 on 2022/03/31.
//

import UIKit
import RealmSwift

class ToDoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let results = try! Realm().objects(ToDoListModel.self).sorted(byKeyPath: "createdAt", ascending: true)

    var items: [ToDoListModel] = []
    var editIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ToDoListXibTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell1")
        tableView.backgroundColor = UIColor.clear

    }
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension // 自動設定
     }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! ToDoListXibTableViewCell
        let item = self.results[indexPath.row]
        
        cell.checkImageView.image = item.check ? UIImage(named: "check") : UIImage(named: "uncheck")
        cell.detailedItemLabel.text = item.detailedItem

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        editIndexPath = indexPath
        let item = self.results[indexPath.row]
        try! Realm().write {
            item.check = !item.check
        }
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        performSegue(withIdentifier: "editSegue", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            try! Realm().write {
                try! Realm().delete(self.results[indexPath.row])
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let add = (segue.destination as? UINavigationController)?.topViewController as? AddListViewController {
            
            switch segue.identifier ?? "" {
            case "addSegue":
            add.mode = AddListViewController.Mode.add
                break
            case "editSegue":
            add.mode = AddListViewController.Mode.edit
                if let indexPath = sender {
                    let item = self.results[(indexPath as AnyObject).row]
                    add.detailedItem = item.detailedItem
                }
                break
                
            default:
                break;
            }
        }
    }
    
    @IBAction func exitFromAddByCancelSegue(segue: UIStoryboardSegue) {
    }
    
    @IBAction func exitFromAddBySaveSegue(segue: UIStoryboardSegue) {
        
        if let add = segue.source as? AddListViewController {
            let newItem = ToDoListModel()
            
            newItem.detailedItem = add.detailedItemTextField.text ?? ""
            newItem.check = false
            
            try! Realm().write {
                try! Realm().add(newItem)
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func exitFromEditByCancelSegue(segue: UIStoryboardSegue) {
    }
    
    @IBAction func exitFromEditBySaveSegue(segue: UIStoryboardSegue) {
        
        if let add = segue.source as? AddListViewController {
            if let indexPath = editIndexPath {
                try! Realm().write {
                    self.results[indexPath.row].detailedItem = add.detailedItemTextField.text ?? ""
                }
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
