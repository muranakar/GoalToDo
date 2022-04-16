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
    private var pushDateToDoItem: [ToDoList.ToDoItem] {
        repository.loadToDoItems(date: pushDate)
    }

    var pushDate = Date()
    var pushDateString: String { DateFormatter.calendrDateFormatter().string(from: pushDate) }
    private let gregorian = Calendar(identifier: .gregorian)

    @IBOutlet private weak var calendarView: FSCalendar!
    @IBAction private func editButtonPushed(_ sender: Any) {
        self.performSegue(withIdentifier: "ToDiary", sender: nil)
    }
    @IBOutlet private weak var toDoItemsTableView: UITableView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // 以降 https://qiita.com/shxun6934/items/e4e6e81cecf68b22bdc3 の記事を参考

    // MARK: - 画面遷移
    // TODO: セグエを変更
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDiary" {
            if let editingDiaryView = (segue.destination) as? EditToDoCalendarViewController {
                editingDiaryView.pushDate = self.pushDateString  // ここでEditingDiaryViewのpushDateに渡してる
            }
        }
    }
}

extension ToDoCalendarViewController: FSCalendarDelegate,
                                   FSCalendarDataSource {
    func calendar(
        _ calendar: FSCalendar,
        didSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {
        pushDate = date
        print(pushDate)
        print(pushDateString)
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

extension ToDoCalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let pushDateCell = tableView.dequeueReusableCell(
                withIdentifier: "pushDateCell",
                for: indexPath
            ) as! PushDateTableViewCell
            pushDateCell.configure(labelText: pushDateString)
            return pushDateCell
        default:
            let toDOItemCell = tableView.dequeueReusableCell(
                withIdentifier: "toDoItemCell",
                for: indexPath
            ) as! ToDoItemTableViewCell
            // TODO: ToDoItemのisCheckがfalseのときに、Labelを非表示にする設定をする必要がある。
            toDOItemCell.configure(labelText: pushDateToDoItem[indexPath.row - 1].toDoText)
            return toDOItemCell
        }
    }
}

extension ToDoCalendarViewController: UITableViewDelegate {
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
