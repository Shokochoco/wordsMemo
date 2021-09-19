

import UIKit
import CoreData

protocol WordTableViewCellDelegate: class {
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

 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
        // Configure the view for the selected state
    }
  
}
