
import UIKit
import CoreData

class RegisterViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var jpText: UITextField!
    @IBOutlet weak var frText: UITextField!
    @IBOutlet weak var genderSwitch: UISegmentedControl!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var registerButton: UIButton!
    
    var words: Words? //セルをタップした時の編集情報の受け皿、最初はオプショナル
    var genderCategory = "Homme"
    var checkedCheck = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Textfield枠のカラー
        textView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠の幅
        textView.layer.borderWidth = 1.0
        // 枠を角丸にする
        textView.layer.cornerRadius = 10.0
        textView.layer.masksToBounds = true
        
        //RegisterBtnデザイン
        registerButton.frame = CGRect(x: 0, y: 625, width: 287, height: 46)
        registerButton.backgroundColor = UIColor(named: "BaseColor")
        registerButton.setTitleColor(.white, for: UIControl.State.normal)
        registerButton.layer.cornerRadius = 10
        
        // wordsに値が代入されていたら(編集されていたら)、textFieldとsegmentedControlなどにそれを表示
        if let words = words {
            
            jpText.text = words.nameJp!
            frText.text = words.nameFr!
            
            if let wordMemo = words.memo {
                textView.text = wordMemo
            } else {
                textView.text = ""
            }
            
            
            switch genderSwitch.selectedSegmentIndex {
            case 0:
                genderCategory = "Homme"
            case 1:
                genderCategory = "Femme"
            case 2:
                genderCategory = "Non"
            default:
                print("反応しない")
            }
            
            
            checkedCheck = words.checked ? words.checked : words.checked
            
            
        }
        
        //他のところタッチしてキーボード閉じる
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
    }
    
    //他のところタッチしてキーボード閉じる
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //textView以外はview動かないようにする
        if !textView.isFirstResponder {
            return
        }
        
        if self.view.frame.origin.y == 0 { //y座標が0の時
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
    
    // MARK: - Register Button
    
    
    
    @IBAction func registerButton(_ sender: UIButton) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let wordJpName = jpText.text
        let wordFrName = frText.text
        let memoText = textView.text
        
        
        if wordJpName == ""  { //|| wordFrName == ""
            dismiss(animated: true, completion: nil)
            return
        }
        
        // 受け取った値が空であれば、新しいWords型オブジェクトを作成する
        if words == nil {
            //contextの中にnewItemを作って用意
            words = Words(context: context)
        }
        
        // 受け取ったオブジェクト、または、先ほど新しく作成したオブジェクトそのタスクのnameとcategoryに入力データを代入する
        if let words = words {
            words.nameJp = wordJpName
            words.nameFr = wordFrName
            words.gender = genderCategory
            words.memo = memoText
            words.checked = checkedCheck
        }
        
        //保存
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */

