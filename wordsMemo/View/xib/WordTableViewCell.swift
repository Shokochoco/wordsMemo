import UIKit

protocol WordTableViewCellDelegate: AnyObject {
    func checkButtonTapped(indexPath: IndexPath)
}

class WordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var wordEn: UILabel!
    @IBOutlet weak var wordFr: UILabel!
    @IBOutlet weak var genderText: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    weak var delegate: WordTableViewCellDelegate?
    
    var indexPath: IndexPath!
    
    @IBAction func  checkButton(_ sender:  UIButton) {
        //画像変更・お気に入り更新
        delegate?.checkButtonTapped(indexPath: indexPath)
    }
  
}
