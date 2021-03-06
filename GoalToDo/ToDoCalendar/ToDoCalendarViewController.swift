//
//  WillDiaryViewController.swift
//  WillDiary
//
//  Created by 澤田世那 on 2022/03/31.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic

final class ToDoCalendarViewController: UIViewController {
    private let repository = RealmRepository()
    private var pushDateToDoList: ToDoList? {
        guard let pushDate = pushDate else { return nil }
        return repository.loadToDoList(date: pushDate)
    }
    private var pushDateToDoItems: [ToDoItem] {
        guard let pushDateToDoList = pushDateToDoList else {
            return []
        }
        return repository.loadToDoItem(toDoList: pushDateToDoList)
    }

    private var pushDate: Date?
    var pushDateString: String? {
        guard let pushDate = pushDate else { return nil }
        return DateFormatter.calendrDateFormatter().string(from: pushDate) }
    private let gregorian = Calendar(identifier: .gregorian)

    @IBOutlet private weak var calendarView: FSCalendar!
    @IBAction private func editButtonPushed(_ sender: Any) {
        guard pushDate != nil else {
            return presentAlert(title: "エラー", message: "日付を選択してください")
        }
        self.performSegue(withIdentifier: "ToDiary", sender: nil)
    }
    @IBOutlet private weak var toDoItemsTableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.toDoItemsTableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - 画面遷移
    @IBSegueAction
    func makeEditToDoCalender(
        coder: NSCoder,
        sender: Any?,
        segueIdentifier: String?
    ) -> EditToDoCalendarViewController? {
        guard let pushDate = pushDate else { return nil }
        return .init(coder: coder, pushDate: pushDate)
    }
    @IBAction private func backToToDoCalendarViewController(segue: UIStoryboardSegue) {
    }
}

extension ToDoCalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pushDateToDoItems.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let pushDateCell = tableView.dequeueReusableCell(
                withIdentifier: "pushDateCell",
                for: indexPath
            ) as! PushDateTableViewCell
            if let pushDateString = pushDateString {
            pushDateCell.configure(labelText: pushDateString)
            return pushDateCell
            }
            return pushDateCell
        default:
            let toDOItemCell = tableView.dequeueReusableCell(
                withIdentifier: "toDoItemCell",
                for: indexPath
            ) as! ToDoItemTableViewCell
            // TODO: ToDoItemのisCheckがfalseのときに、Labelを非表示にする設定をする必要がある。
            toDOItemCell.configure(labelText: pushDateToDoItems[indexPath.row - 1].toDoText)
            return toDOItemCell
        }
    }
}

extension ToDoCalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let newToDoItem = pushDateToDoItems[indexPath.row - 1]
        repository.removeToDoItem(toDoItem: newToDoItem)
        tableView.reloadData()
    }
}

// 以降 https://qiita.com/shxun6934/items/e4e6e81cecf68b22bdc3 の記事を参考
extension ToDoCalendarViewController: FSCalendarDelegate,
                                      FSCalendarDataSource {
    func calendar(
        _ calendar: FSCalendar,
        didSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {
        pushDate = date
        toDoItemsTableView.reloadData()
    }
}

extension ToDoCalendarViewController: FSCalendarDelegateAppearance {
    // https://qiita.com/Koutya/items/f5c7c12ab1458b6addcd の記事を参考
    func calendar(
        _ calendar: FSCalendar,
        appearance: FSCalendarAppearance,
        titleDefaultColorFor date: Date
    ) -> UIColor? {
        // 曜日タイトルの色変更（土曜は青、日曜は赤）
        calendarView.calendarWeekdayView.weekdayLabels[0].textColor = UIColor.red
        calendarView.calendarWeekdayView.weekdayLabels[6].textColor = UIColor.blue
        // 祝日判定をする（祝日は赤色で表示する）
        if AssistCalendar().judgeHoliday(date) {
            return UIColor.red
        }
        // 土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = AssistCalendar().getWeekIdx(date)
        if weekday == 1 { // 日曜日
            return UIColor.red
        } else if weekday == 7 { // 土曜日
            return UIColor.blue
        }
        return nil
    }
}

// https://qiita.com/Koutya/items/f5c7c12ab1458b6addcd の記事を参考
private  struct AssistCalendar {
    // 祝日判定を行い結果を返すメソッド（True：祝日）
    func judgeHoliday(_ date: Date) -> Bool {
        // 祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        // CalculateCalendarLogic(): 祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()

        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    // date型 -> 年月日をIntで取得
    // swiftlint:disable:next large_tuple
    func getDay(_ date: Date) -> (Int, Int, Int) {
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year, month, day)
    }
    // 曜日判定（日曜日:1 〜 土曜日:7）
    func getWeekIdx(_ date: Date) -> Int {
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
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
