import UIKit
import CoreData

class NewViewController: UIViewController {
    
    var searchController: UISearchController!
    @IBOutlet weak var tableView: UITableView!
    
    var done = UIImage(systemName: "checkmark.circle")!.withRenderingMode(.alwaysTemplate)
    var donefill = UIImage(systemName: "checkmark.circle.fill")!.withRenderingMode(.alwaysTemplate)
    var words:[Words] = []
    var searchResults: [Words] = []
    var filteredNotCheked = [Words?]()
    var filteredChecked = [Words?]()
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    //編集用segueのidentifir
    private let segueEditTaskViewController = "SegueEditTaskViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        audioSwitch()
        setup()
//        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    private func setup() {
        
        searchController = UISearchController(searchResultsController: nil)
        //結果表示用のビューコントローラーに自分を設定する。
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "écrivez français"
        navigationItem.title = "Français"
        navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 25)!]
        
        navigationItem.searchController = searchController
        //Largeタイトル
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 45)!]
        navigationItem.hidesSearchBarWhenScrolling = true
        
    }
    
    func filterContentForSearchText(_ searchText: String) {
        searchResults = words.filter { (word: Words) -> Bool in
            return (word.nameFr?.lowercased().contains(searchText.lowercased()))!
        }
        
        tableView.reloadData()
    }
    
    func audioSwitch(){
        
        let switchControl = UISwitch(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 50, height: 30)))
        switchControl.isOn = true
        switchControl.onTintColor = #colorLiteral(red: 0, green: 0.6117647059, blue: 0.5764705882, alpha: 0.8470000029)
        switchControl.setOn(true, animated: false)
        switchControl.addTarget(self, action: #selector(self.switchValueDidChange(sender:)), for: .valueChanged)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: switchControl)
    }
    
    @objc func switchValueDidChange(sender: UISwitch!) {
        
        if sender.isOn {
            getData()
        } else{
            getDataNotyet()
        }
    }
    
    // MARK:  - Segue Navigation　RegisterViewにセルの情報を渡す
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination as? RegisterViewController else { return }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //セルをタップした時
        if let indexPath = tableView.indexPathForSelectedRow, segue.identifier == segueEditTaskViewController {
            //検索してる時
            let word: Words
            if isFiltering {
                word = searchResults[indexPath.row]
            } else {
                word = words[indexPath.row]
            }
            // 編集したいデータを取得
            let editedWordEn = word.nameEn!
            let editedWordFr = word.nameFr!
            let editedGender = word.gender!
            
            // 先ほど取得したnameとgenderに合致するデータのみをfetchするようにfetchRequestを作成
            let fetchRequest: NSFetchRequest<Words> = Words.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "nameEn = %@ and nameFr = %@ and gender = %@ ", editedWordEn, editedWordFr, editedGender)
            // そのfetchRequestを満たすデータをfetchしてwords(配列だが要素を1種類しか持たないはず）に代入し、それを渡す
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
        
        //統計計算用
        filteredNotCheked = words.filter { $0.checked == false }
        filteredChecked = words.filter { $0.checked == true }
        
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
        
        cell.wordEn.text = word.nameEn!
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
    
    func getDataNotyet() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
        fetchRequest.predicate = NSPredicate(format: "checked == false")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        words.removeAll()
        
        do {
            let wordData =  try context.fetch(fetchRequest) as! [Words]
            
            words.append(contentsOf: wordData)
            
        } catch {
            print("error getData")
        }
        
        tableView.reloadData()
    }
    
    func getData(with request: NSFetchRequest<Words> = Words.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            words = try context.fetch(Words.fetchRequest())
        } catch  {
            print("load fail")
        }
        tableView.reloadData()
    }
    
    func saveItems() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            try context.save()
        } catch  {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
    }
    
    // MARK: - SwipeAction(delete)
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            context.delete(self.words[indexPath.row])
            self.words.remove(at: indexPath.row)
            self.saveItems()
            
            completionHandler(true)
            action.image = UIImage(systemName: "trash")
        }
        return UISwipeActionsConfiguration(actions:[deleteAction])
    }
}

// MARK: - UISearchResultsUpdating 検索した時の画面の動き

extension NewViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension NewViewController: WordTableViewCellDelegate {
    
    func checkButtonTapped(indexPath: IndexPath) {
        
        let date = Date()
        //プロパティ自体にcheckedをセットしてセルの繰り返しを防ぐ
        if isFiltering {
            searchResults[indexPath.row].checked = !searchResults[indexPath.row].checked
            searchResults[indexPath.row].checkedDate = searchResults[indexPath.row].checked ? date: nil
        } else {
            words[indexPath.row].checked = !words[indexPath.row].checked
            words[indexPath.row].checkedDate = words[indexPath.row].checked ? date: nil
        }        
        saveItems()
    }
}

