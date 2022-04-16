//
//  CountDownTimerViewController.swift
//  WillDiary
//
//  Created by 澤田世那 on 2022/03/31.
//

import UIKit

class CountDownTimerViewController: UIViewController {
    
    var dyingDate: Date?
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(self.viewDidLoadTimerCounter),
                                     userInfo: nil,
                                     repeats: true)
    }

    @IBOutlet weak var countDownLabel: UILabel!
    
    @objc func viewDidLoadTimerCounter() {
        
// UserDefaultsで保存したDatePickerの設定時刻を、このメソッドが実行されるときに呼び出して、新たな定数に代入し、その値をアンラップしてから使用する。
        if let value = UserDefaults.standard.object(forKey: "setPicker") as? Date {
            countDownLabel.text = timerFunction(setDate: value)
        }
    }
    
    @IBAction func exitFromEditByBackSegue(segue: UIStoryboardSegue) {
        
        if let add = segue.source as? EditingTimerViewController {
            dyingDate = add.dyingDatePicker.date

            if let setDate = dyingDate {
                UserDefaults.standard.set(setDate, forKey: "setPicker")
                // settings.synchronize()
                
                // タイマーをスタート
                Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(timerCounter),
                                     userInfo: nil,
                                     repeats: true)
            }
        }
    }
        
    @objc func timerCounter() {
        if let setDate = dyingDate {
            countDownLabel.text = timerFunction(setDate: setDate)
        }
    }
        
    func timerFunction(setDate: Date) -> String {
        
        // https://qiita.com/isom0242/items/e83ab77a3f56f66edd2f の記事を参考
        let nowDate = Date() // 現在時刻
        let calendar = Calendar(identifier: .japanese) // 日本設定のカレンダーを指定
        // 現在時刻と設定時刻の差を算出
        let timerValue = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nowDate, to: setDate)
        return String(format: "残り"+"%2d年 %2dヶ月 %2d日 %2d時間 %2d分 %2d秒",
                        timerValue.year!,
                        timerValue.month!,
                        timerValue.day!,
                        timerValue.hour!,
                        timerValue.minute!,
                        timerValue.second!)
    }
}
