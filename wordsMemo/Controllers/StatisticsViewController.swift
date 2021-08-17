
import Foundation
import UIKit
import MBCircularProgressBar
import Charts



class StatisticsViewController: UIViewController {

    @IBOutlet weak var progressCircle: MBCircularProgressBarView!
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var chart: BarChartView!
    
    var dayCount:[Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
}

    override func viewWillAppear(_ animated: Bool) {
        // ナビゲーションを透明にする処理
            self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController!.navigationBar.shadowImage = UIImage()
        
        circle()
        
        let newController = self.tabBarController?.viewControllers?[0] as! UINavigationController
        //Navigation Controllerのトップ画面をView Controllerに指定する
        let newvc = newController.topViewController as! NewViewController
        
        let favController = self.tabBarController?.viewControllers?[1] as! UINavigationController
        let favvc = favController.topViewController as! FavViewController

        titleLabel1.text = "Fini \(String(favvc.favorites.count)) mots🔥"
        titleLabel2.text = "Total \(String(newvc.words.count))mots🇫🇷"
    }

    func circle() {
        
        //Tab Bar ControllerでviewControllerの0番（NewViewController)をNavigation Controllerに指定して取り出す
        let newController = self.tabBarController?.viewControllers?[0] as! UINavigationController
        //Navigation Controllerのトップ画面をView Controllerに指定する
        let newvc = newController.topViewController as! NewViewController
        
        //fav
        let favController = self.tabBarController?.viewControllers?[1] as! UINavigationController
        let favvc = favController.topViewController as! FavViewController

        progressCircle.value = (CGFloat(favvc.favorites.count) / CGFloat(newvc.words.count)) * 100

       }
    

}
