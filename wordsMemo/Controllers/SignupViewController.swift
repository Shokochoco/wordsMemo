import Foundation
import UIKit
import Firebase
import FirebaseStorage

class SigninViewController:UIViewController {
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var mailText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    
    
    override func viewDidLoad() {
        
        view.backgroundColor = #colorLiteral(red: 0, green: 0.6112995148, blue: 0.5753389001, alpha: 1)
        nameText.delegate = self
        mailText.delegate = self
        passText.delegate = self
        
        loginBtn.isEnabled = false
        
        signupBtn.frame = CGRect(x: 0, y: 625, width: 287, height: 46)
        signupBtn.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        signupBtn.setTitleColor(.white, for: UIControl.State.normal)
        signupBtn.layer.cornerRadius = 10
        signupBtn.layer.shadowOpacity = 0.7
        signupBtn.layer.shadowColor = UIColor.gray.cgColor
        signupBtn.layer.shadowRadius = 3
        
        nameText.placeholder = "👤 name"
        mailText.placeholder = "✉️ mail"
        passText.placeholder = "🔑 password"
        nameText.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        mailText.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passText.addBorderBottom(height: 1.0, color: UIColor.lightGray)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func newRegisterBtn(_ sender: Any) {
        guard let  email = mailText.text else { return }
        guard let password = passText.text else { return }
        guard let name = nameText.text else { return }
               
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
            print("FirebaseAuthへの保存に失敗しました。\(error)")
                let dialog = UIAlertController(title: "新規登録失敗", message: error.localizedDescription, preferredStyle: .alert)
                        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(dialog, animated: true, completion: nil)
            } else {
              //FirebaseStoreへ保存処理
                guard let uid = Auth.auth().currentUser?.uid else {return}
                let docData = ["email": email,"password": password, "name": name, "createdAt":Timestamp()] as [String : Any]
                
                Firestore.firestore().collection("users").document(uid).setData(docData){ (error) in
                    if let error = error {
                        print("Firestore情報保存に失敗しました\(error)")
                    } else {
                        print("Firestore情報保存に成功しました")
                        // navigate to next screen
                        self.dismiss(animated: true, completion: nil)
                    }

            }
        }
       }
        
        
        
    }
    
}

extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
       let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}

extension SigninViewController: UITextFieldDelegate {
    
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//        let emailIsEmpty = nameText.text?.isEmpty ?? true
//        let passIsEmpty = passText.text?.isEmpty ?? true
//        let nameIsEmpty = nameText.text?.isEmpty ?? true
//
//        if emailIsEmpty || passIsEmpty || nameIsEmpty {
//            signupBtn.isEnabled = false
//        } else {
//            signupBtn.isEnabled = true
//        }
//    }
}
