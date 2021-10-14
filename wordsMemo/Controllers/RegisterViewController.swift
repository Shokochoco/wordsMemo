import UIKit
import CoreData

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var enText: UITextField!
    @IBOutlet weak var frText: UITextField!
    @IBOutlet weak var genderSwitch: UISegmentedControl!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var registerButton: UIButton!
    var words: Words? 
    var genderCategory = "Homme"
    var checkedCheck = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Textfield枠のカラー
        enText.layer.borderColor = UIColor.lightGray.cgColor
        frText.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠の幅
        enText.layer.borderWidth = 1.0
        frText.layer.borderWidth = 1.0
        textView.layer.borderWidth = 1.0
        // 枠を角丸にする
        enText.layer.cornerRadius = 10.0
        frText.layer.cornerRadius = 10.0
        textView.layer.cornerRadius = 10.0
        
        enText.layer.masksToBounds = true
        frText.layer.masksToBounds = true
        textView.layer.masksToBounds = true
        //RegisterBtnデザイン
        registerButton.frame = CGRect(x: 0, y: 625, width: 287, height: 46)
        registerButton.backgroundColor = UIColor(named: "BaseColor")
        registerButton.setTitleColor(.white, for: UIControl.State.normal)
        registerButton.layer.cornerRadius = 10
        // wordsに値が代入されてる状態（既存のものをクリックした時）、textFieldとsegmentedControlなどに元々入ってる値を代入
        if let words = words {
            
            enText.text = words.nameEn!
            frText.text = words.nameFr!
            
            if let wordMemo = words.memo {
                textView.text = wordMemo
            } else {
                textView.text = ""
            }
            
            genderCategory = words.gender!
            checkedCheck = words.checked ? words.checked : words.checked
        }
        //他のところタッチしてキーボード閉じる
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "arrow.backward")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "arrow.backward")
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    // MARK: - Gender Switch
    
    @IBAction func genderChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            genderCategory = "Homme"
        case 1:
            genderCategory = "Femme"
        case 2:
            genderCategory = "Non"
        default:
            print("反応しない")
        }
    }    
    // MARK: - Register Button　新規登録時・編集時
    
    @IBAction func registerButton(_ sender: UIButton) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let wordEnName = enText.text
        let wordFrName = frText.text
        let memoText = textView.text
        
        if wordEnName == "" || wordFrName == "" {
            
            let alert = UIAlertController(title: "Entrez les mots 🇬🇧&🇫🇷", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: .none)
            
        } else {
            // 渡ってきたwordsが空なら（つまり ＋ボタンを押した時）、新しいWords型オブジェクトを作成する
            if words == nil {
                words = Words(context: context) //contextの中に新規wordsを作る
            }
            // 受け取ったオブジェクト（編集時）、または、先ほど新しく作成したオブジェクト（新規時）どちらもwordsにしてあるので、CoreDataに代入する
            if let words = words {
                words.nameEn = wordEnName
                words.nameFr = wordFrName
                words.gender = genderCategory
                words.memo = memoText
                words.checked = checkedCheck
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            navigationController!.popViewController(animated: true)
        }
    }   
}

extension RegisterViewController: UITextViewDelegate {
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //textView以外はview動かないようにする
        if !textView.isFirstResponder {
            return
        }
        
        if self.view.frame.origin.y == 0 {
            if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardRect.height // 始点y座標からキーボードのy座標を引いた地点を新しく始まるviewのy座標始点として代入
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
