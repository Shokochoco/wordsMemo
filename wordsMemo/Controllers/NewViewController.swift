

import UIKit
import CoreData


class NewViewController: UIViewController {
    
    var searchController: UISearchController!
    @IBOutlet weak var tableView: UITableView!
    

    
    var done = UIImage(systemName: "checkmark.circle")!.withRenderingMode(.alwaysTemplate)
    var donefill = UIImage(systemName: "checkmark.circle.fill")!.withRenderingMode(.alwaysTemplate)
    
    @IBAction func backView(segue: UIStoryboardSegue) {
    }
    
    
    var words:[Words] = []
    var searchResults: [Words] = []
    var filterWords:[Words] = []
    
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
  
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let segueEditTaskViewController = "SegueEditTaskViewController" //編集用segueのidentifir
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
    }
    
    private func setup() {
        
        
        searchController = UISearchController(searchResultsController: nil)
        //結果表示用のビューコントローラーに自分を設定する。
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        //searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Ecrivez Français"
        
        
        navigationItem.title = "Français"
        navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 25)!]
        

        
        if #available(iOS 11.0, *) {
            // UISearchControllerをUINavigationItemのsearchControllerプロパティにセットする。
            navigationItem.searchController = searchController
            //Largeタイトル
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 45)!]
            // trueだとスクロールした時にSearchBarを隠す（デフォルトはtrue）
            // falseだとスクロール位置に関係なく常にSearchBarが表示される
            navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        
    }
    
    //フィルターかける、それをsearchResultsに詰める
    func filterContentForSearchText(_ searchText: String) {
        searchResults = words.filter { (word: Words) -> Bool in
            return (word.nameFr?.lowercased().contains(searchText.lowercased()))!
        }
        
        tableView.reloadData()
    }
    
// wondering whether put on this toggle...
    
//    func audioSwitch(){
//        let switchControl = UISwitch(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 50, height: 30)))
//        switchControl.isOn = true
//        switchControl.onTintColor = UIColor.white
//        switchControl.setOn(true, animated: false)
//        switchControl.addTarget(self, action: #selector(self.switchValueDidChange(sender:)), for: .valueChanged)
//        let toggleButton = UIBarButtonItem.init(customView: switchControl)
//    }
//
//    @objc func switchValueDidChange(sender: UISwitch!)
//    {
//        if sender.isOn {
//            print("on")
//        } else{
//            print("off")
//        }
//    }
   
    
    // MARK: - Segue Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination as? RegisterViewController else { return }
        
        
        // contextをAddTaskViewController.swiftのcontextへ渡す
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        destinationViewController.context = context
        //セルをタップした時（searchBarを入れたver)
        if let indexPath = tableView.indexPathForSelectedRow, segue.identifier == segueEditTaskViewController {
            // 編集したいデータを取得
            let word: Words
            if isFiltering {
                word = searchResults[indexPath.row]
            } else {
                word = words[indexPath.row]
            }
            
            
            
            let editedWordJp = word.nameJp!
            let editedWordFr = word.nameFr!
            let editedGender = word.gender!
            
            // 先ほど取得したnameとgenderに合致するデータのみをfetchするようにfetchRequestを作成
            let fetchRequest: NSFetchRequest<Words> = Words.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "nameJp = %@ and nameFr = %@ and gender = %@", editedWordJp, editedWordFr, editedGender)
            // そのfetchRequestを満たすデータをfetchしてtask(配列だが要素を1種類しか持たないはず）に代入し、それを渡す
            do {
                let words = try context.fetch(fetchRequest)
                destinationViewController.words = words[0]
            } catch {
                print("Fetching Failed.")
            }
        }
    }
    
    
    
}

// MARK: - TableView Datasorse Methods

extension NewViewController: UITableViewDataSource, UITableViewDelegate {
    
    //    サーチバー入れた後
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return searchResults.count
        }
        
        return words.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordTableViewCell", for: indexPath)as! WordTableViewCell
        
        //checkボタンタップ用デリゲート
        cell.indexPath = indexPath
        cell.delegate = self
        //検索した時
        var word: Words
        if isFiltering {
            word = searchResults[indexPath.row]
        } else {
            word = words[indexPath.row]
        }

     
//           if  sender.isOn {
//            word = words[indexPath.row]
//           } else {
//            filterWords = words.filter{$0.checked == false}
//            word = filterWords[indexPath.row]
//           }
        
        
        
        cell.wordJp.text = word.nameJp!
        cell.wordFr.text = word.nameFr!
        cell.genderText.text = word.gender
        
        switch cell.genderText.text {
        case "Homme":
            cell.genderText.backgroundColor = #colorLiteral(red: 0.7490203977, green: 0.9648717046, blue: 0.9835821986, alpha: 1)
        case "Femme":
            cell.genderText.backgroundColor = #colorLiteral(red: 1, green: 0.6926959157, blue: 0.7553421855, alpha: 1)
        case "Non" :
            cell.genderText.backgroundColor = #colorLiteral(red: 0.9402483106, green: 1, blue: 0.8370730281, alpha: 1)
        default:
            print("Color error")
        }
        
        let image = word.checked ? donefill : done
        cell.checkButton.setImage(image, for: .normal)
        cell.checkButton.tintColor = word.checked ? #colorLiteral(red: 0.02745098039, green: 0.6, blue: 0.5725490196, alpha: 1) : .lightGray
        
        
        return cell
    }
     
    // MARK: - Save and Get data
    
 func getData() {


        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
        fetchRequest.predicate = NSPredicate(format: "checked == false")

        words.removeAll()

        do {
            let wordData =  try context.fetch(fetchRequest) as! [Words]

            words.append(contentsOf: wordData)

        } catch {
            print("error getData")
        }

        tableView.reloadData()
    }
    
//    func getData(with request: NSFetchRequest<Words> = Words.fetchRequest(), predicate: NSPredicate? = nil) {
//
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//        do {
//            words = try context.fetch(Words.fetchRequest())
//        } catch  {
//            print("load fail")
//        }
//        tableView.reloadData()
//    }
    
    //save
    
    func saveItems() {
        
        do {
            try context.save()
        } catch  {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    
    // MARK: - SwipeAction
    
    
    // Quand je swipe le rang
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 削除処理
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            //削除処理を記述
            self.context.delete(self.words[indexPath.row])
            self.words.remove(at: indexPath.row)
            self.saveItems()
            
            // 実行結果に関わらず記述
            completionHandler(true)
            
            action.image = UIImage(systemName: "trash")
        }
        // 定義したアクションをセット
        return UISwipeActionsConfiguration(actions:[deleteAction])
    }
    
    
}

// MARK: - UISearchResultsUpdating

extension NewViewController: UISearchResultsUpdating {
    //検索した時の画面の動き
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension NewViewController: WordTableViewCellDelegate {
    
    func checkButtonTapped(indexPath: IndexPath) {
        
        //プロパティ自体にcheckedをセットしてセルの繰り返しを防ぐ
        words[indexPath.row].checked = !words[indexPath.row].checked
        
        // pour moi pour etudier
        //            if words[indexPath.row].checked {
        //                vc.favorites.append(words[indexPath.row])
        //            } else {
        //                vc.favorites.removeAll { $0 == words[indexPath.row] } //$0にはvc.favoritesの中身がひとつずつ代入
        //            }
        
        saveItems()
    }
}
