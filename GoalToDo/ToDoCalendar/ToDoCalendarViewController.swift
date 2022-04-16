//
//  WillDiaryViewController.swift
//  WillDiary
//
//  Created by 澤田世那 on 2022/03/31.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

class WillDiaryViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    let date = Date()
    let df = DateFormatter()
    lazy var pushDate: String = dateFormatter.string(from: date)
    
    private let gregorian = Calendar(identifier: .gregorian)
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        return formatter
    }()
    
    // https://qiita.com/Koutya/items/f5c7c12ab1458b6addcd の記事を参考
    struct AssistCalendar {
        // 祝日判定を行い結果を返すメソッド（True：祝日）
        func judgeHoliday(_ date : Date) -> Bool {
            
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
        func getDay(_ date:Date) -> (Int,Int,Int) {
            let tmpCalendar = Calendar(identifier: .gregorian)
            let year = tmpCalendar.component(.year, from: date)
            let month = tmpCalendar.component(.month, from: date)
            let day = tmpCalendar.component(.day, from: date)
            return (year,month,day)
        }
        
        // 曜日判定（日曜日:1 〜 土曜日:7）
        func getWeekIdx(_ date: Date) -> Int {
            let tmpCalendar = Calendar(identifier: .gregorian)
            return tmpCalendar.component(.weekday, from: date)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        
        print(date)
        print(pushDate)

        DispatchQueue(label: "background").async {
            DispatchQueue.main.async {
                self.diaryDescriptionTextLabel.text = self.makeDiaryDescription()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) { // TODO: 解読
        super.viewWillAppear(animated)
    }
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var diaryDescriptionTextLabel: UILabel!
    
    @IBAction func editButtonPushed(_ sender: Any) {
        self.performSegue(withIdentifier: "ToDiary", sender: nil)
    }
    
    // https://qiita.com/Koutya/items/f5c7c12ab1458b6addcd の記事を参考
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
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
        }
        
        else if weekday == 7 { // 土曜日
            return UIColor.blue
         }
        return nil
    }
    
    // 以降 https://qiita.com/shxun6934/items/e4e6e81cecf68b22bdc3 の記事を参考
    func makeDiaryDescription () -> String { // TODO: メソッド名の変更
        
        let realm = try! Realm()

        guard let savedDiary = realm.objects(DiaryModel.self).filter("calendarDate == '\(self.pushDate)'").last else {
            return pushDate
        }
        
        let diaryDescription = savedDiary.diaryText
        return diaryDescription
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) { // TODO: 解読
 
        let selectDay = AssistCalendar().getDay(date)
        print(date)
        print(selectDay)
        pushDate = dateFormatter.string(from: date)
        
        DispatchQueue(label: "background").async {
            DispatchQueue.main.async {
                self.diaryDescriptionTextLabel.text = self.makeDiaryDescription()
            }
        }
    }
    
    @IBAction func diaryExitFromEditBySaveSegue(segue: UIStoryboardSegue) { // TODO: 解読
        if let add = segue.source as? EditingDiaryViewController {
            
            let realm = try! Realm() // Realmの初期化
            let diary = DiaryModel() // モデルのインスタンス化

            diary.calendarDate = pushDate
            diary.diaryText = add.diaryDescriptionTextView.text
            self.diaryDescriptionTextLabel.text = diary.diaryText
            
            try! realm.write {
                realm.add(diary)// Realmに追加
            }
        }
    }
    // 画面遷移の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // TODO: 解読
        if (segue.identifier == "ToDiary") {
            if let editingDiaryView = (segue.destination) as? EditingDiaryViewController {
                editingDiaryView.pushDate = self.pushDate  // ここでEditingDiaryViewのpushDateに渡してる
            }
        }
    }
}
