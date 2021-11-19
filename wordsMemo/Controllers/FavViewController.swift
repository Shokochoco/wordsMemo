import Foundation
import UIKit
import CoreData

class FavViewController: UIViewController, UISearchResultsUpdating {
    
    private var searchController: UISearchController!
    private var done = UIImage(systemName: "checkmark.circle")!.withRenderingMode(.alwaysTemplate)
    private var donefill = UIImage(systemName: "checkmark.circle.fill")!.withRenderingMode(.alwaysTemplate)
    var favorites: [Words] = []
    var searchResults: [Words] = []
    
    @IBOutlet weak var favTableView: UITableView!
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        setup()
        AppUtility.lockOrientation(.all)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    private func setup() {
        navigationItem.title = "C'est fait!"
        navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 25)!]
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self //結果表示用のビューコントローラーに自分を設定する。
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "écrivez français"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
    }
    
    func filterContentForSearchText(_ searchText: String) {
        searchResults = favorites.filter { (favorite: Words) -> Bool in
            return (favorite.nameFr?.lowercased().contains(searchText.lowercased()))!
        }
        
        favTableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
        
    }
}

extension FavViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return searchResults.count
        }
        
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordTableViewCell", for: indexPath)as! WordTableViewCell
        cell.selectionStyle = .none
        let favorite: Words
        
        if isFiltering {
            favorite = searchResults[indexPath.row]
        } else {
            favorite = favorites[indexPath.row]
        }
        
        cell.wordEn.text = favorite.nameEn
        cell.wordFr.text = favorite.nameFr
        cell.genderText.text = favorite.gender
        
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
        
        let image = favorite.checked ? donefill : done
        cell.checkButton.setImage(image, for: .normal)
        cell.checkButton.tintColor = favorite.checked ? #colorLiteral(red: 0.02745098039, green: 0.6, blue: 0.5725490196, alpha: 1) : .lightGray
        
        return cell
        
    }
    // MARK: - SwipeAction
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            context.delete(self.favorites[indexPath.row])
            self.favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            completionHandler(true)
            
            action.image = UIImage(systemName: "trash")
        }
        
        return UISwipeActionsConfiguration(actions:[deleteAction])
    }
    // MARK: - Save and Get data    
    private func getData() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
        fetchRequest.predicate = NSPredicate(format: "checked == true")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        favorites.removeAll()
        
        do {
            let favData =  try context.fetch(fetchRequest) as! [Words]
            
            favorites.append(contentsOf: favData)
            
        } catch {
            print("error getData")
        }
        
        favTableView.reloadData()
    }    
}


