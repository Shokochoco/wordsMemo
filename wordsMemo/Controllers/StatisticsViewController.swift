
import Foundation
import UIKit
import MBCircularProgressBar
import Charts
import CoreData


class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var progressCircle: MBCircularProgressBarView!
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var chart: BarChartView!
    
    var dayChecekdMarkCounts = [Double]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChart()
        setData()
        //回転を検知する
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // ナビゲーションを透明にする処理
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
        circle()
        setupChart()
        setData()
        
        let newController = self.tabBarController?.viewControllers?[0] as! UINavigationController
        //Navigation Controllerのトップ画面をView Controllerに指定する
        let newvc = newController.topViewController as! NewViewController
        
        let checkedCount = newvc.filteredChecked.count
        let totalCount = Int(checkedCount)+Int(newvc.filteredNotCheked.count)
        
        titleLabel1.text = "Les mots finis ✅： \(String(checkedCount))"
        titleLabel2.text = "Les mots totalaux： \(String(totalCount))"
        
    }
    
    //回転をするたびにcircleグラフを再度表示
    @objc func orientationChange() {
        circle()
    }
    
    func circle() {
        
        //Tab Bar ControllerでviewControllerの0番（NewViewController)をNavigation Controllerに指定して取り出す
        let newController = self.tabBarController?.viewControllers?[0] as! UINavigationController
        //Navigation Controllerのトップ画面をView Controllerに指定する
        let newvc = newController.topViewController as! NewViewController
        
        let checkedCount = newvc.filteredChecked.count
        let totalCount = Int(checkedCount)+Int(newvc.filteredNotCheked.count)
        
        progressCircle.value = (CGFloat(checkedCount) / CGFloat(totalCount)) * 100
        
    }
    
    
    func getDataPoints(accuracy: [BarChartDataEntry]) -> [BarChartDataEntry] {
        var dataPoints: [BarChartDataEntry] = []
        
        for count in (0..<accuracy.count) {
            dataPoints.append(BarChartDataEntry(x: Double(count), y: accuracy[count].y))
        }
        return dataPoints
    }
    
    func setData() {
        
        chart.noDataText = "No Data available for Chart"
        
        //yAxisのデータ
        func readData(date:Date){
            
            let cal = Calendar.current
            var fourDaysAgo = cal.date(byAdding: .day, value: -4, to: date)!
            dayChecekdMarkCounts.removeAll()
            
            for _ in 1...5 {
                // XX月XX日0時0分0秒に設定したものをstartにいれる
                var component = NSCalendar.current.dateComponents([.year, .month, .day], from: fourDaysAgo)
                component.hour = 0
                component.minute = 0
                component.second = 0
                let start:NSDate = NSCalendar.current.date(from:component)! as NSDate
                
                //XX月XX日23時59分59秒に設定したものをendにいれる
                component.hour = 23
                component.minute = 59
                component.second = 59
                let end:NSDate = NSCalendar.current.date(from:component)! as NSDate
                
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let fetchRequest:NSFetchRequest<Words> = Words.fetchRequest()
                // XX月XX日0時0分0秒からXX月XX日23時59分59秒までのデータを探す
                let predicate = NSPredicate(format:"(checkedDate >= %@) AND (checkedDate <= %@)",start,end)
                fetchRequest.predicate = predicate
                
                
                //一致した日付をfetchDataに代入
                let fetchData = try! context.fetch(fetchRequest)
                
                if !fetchData.isEmpty {
                    dayChecekdMarkCounts.append(Double(fetchData.count))
                } else {
                    dayChecekdMarkCounts.append(Double(0))
                }
                fourDaysAgo = cal.date(byAdding: .day, value: 1, to: fourDaysAgo)!
            }
            
        }
        
        readData(date: Date())
        
        let entries:[BarChartDataEntry] = [
            BarChartDataEntry(x: 1, y: dayChecekdMarkCounts[0]),
            BarChartDataEntry(x: 2, y: dayChecekdMarkCounts[1]),
            BarChartDataEntry(x: 3, y: dayChecekdMarkCounts[2]),
            BarChartDataEntry(x: 4, y: dayChecekdMarkCounts[3]),
            BarChartDataEntry(x: 5, y: dayChecekdMarkCounts[4])]
        
        let dataPoint = getDataPoints(accuracy: entries)
        
        let dataSet = BarChartDataSet(entries: dataPoint, label: "")
        dataSet.colors = [#colorLiteral(red: 0.02745098039, green: 0.6, blue: 0.5725490196, alpha: 1)] //グラフの色
        dataSet.valueFormatter = BarChartValueFormatter() //小数点消す
        
        let data = BarChartData(dataSet: dataSet)
        chart.data = data
    }
    
    
    func setupChart() {
        
        //X軸設定
        let dateFormatter = DateFormatter() //DateFormatterクラスをインスタンス化
        dateFormatter.dateFormat = "M/d" //日付のフォーマット指定
        let cal = Calendar.current
        let date = Date() //これはforの外側に書く
        var fourDaysAgo = cal.date(byAdding: .day, value: -4, to: date)! //これはforの外側に書く
        var days = [String]()  //これはforの外側に書く
        
        for _ in 1 ... 5 {
            let dataString = dateFormatter.string(from: fourDaysAgo) //dataをStringにする
            days.append(dataString) //days配列に追加
            fourDaysAgo = cal.date(byAdding: .day, value: 1, to: fourDaysAgo)!//dateを1日後の日付に変更
        }
        
        
        let formatter = DateValueFormatter(days: days) //DateValueFormatterを呼び出す
        
        chart.xAxis.valueFormatter = formatter
        
        //labelCountはChartDataEntryと同じ数
        chart.xAxis.labelCount = 5
        //granularityは1.0で固定
        chart.xAxis.granularity = 1.0
        chart.xAxis.labelPosition = .bottom //x軸ラベル下側に表示
        chart.xAxis.labelFont = UIFont.systemFont(ofSize: 15) //x軸のフォントの大きさ
        chart.xAxis.drawGridLinesEnabled = false
        
        //y軸設定
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = true
        
        chart.leftAxis.axisMinimum = 0.0 // Y座標の値が0始まりになるように設定
        chart.leftAxis.axisMaximum = 15.0
        chart.leftAxis.drawZeroLineEnabled = true
        chart.leftAxis.zeroLineColor = .systemGray
        // ラベルの数を設定
        chart.leftAxis.labelCount = 5
        // ラベルの色を設定
        chart.leftAxis.labelTextColor = .systemGray
        // グリッドの色を設定
        chart.leftAxis.gridColor = .systemGray
        // y左軸線の表示
        chart.leftAxis.drawAxisLineEnabled = false
        
        //その他
        chart.legend.enabled = false //"■ months"のlegendの表示
        chart.animate(yAxisDuration: 1.5)
        chart.gridBackgroundColor = .systemBackground
        
        chart.pinchZoomEnabled = false
        chart.drawBarShadowEnabled = false
        chart.drawBordersEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.drawGridBackgroundEnabled = true
        //タップ時のハイライトを消す処理
        chart.highlightPerTapEnabled = false
        chart.highlightPerDragEnabled = false
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

//x軸のラベル設定
class DateValueFormatter: NSObject, IAxisValueFormatter {
    
    let dateFormatter = DateFormatter() //DateFormatterクラスをインスタンス化
    var days:[String]              //変数daysをString型
    
    init(days: [String]) {        //変数daysの初期化
        self.days = days
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {  //IAxisValueFormatterとセット
        return days[Int(value)]
    }
    
    
}

//小数点表示を整数表示にする処理。バーの上部に表示される数字。
class BarChartValueFormatter: NSObject, IValueFormatter{
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String{
        return String(Int(entry.y))
    }
}
