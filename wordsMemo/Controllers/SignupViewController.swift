import Foundation
import UIKit
import Firebase

class SignupViewController: UIViewController {
    
    @IBOutlet private weak var mailText: UITextField!
    @IBOutlet private weak var passText: UITextField!
    @IBOutlet private weak var nameText: UITextField!
    @IBOutlet private weak var loginBtn: UIButton!
    @IBOutlet private weak var signupBtn: UIButton!

    private let indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        AppUtility.lockOrientation(.portrait)
        view.backgroundColor = #colorLiteral(red: 0, green: 0.6112995148, blue: 0.5753389001, alpha: 1)
        signupBtn.frame = CGRect(x: 0, y: 625, width: 287, height: 46)
        signupBtn.setTitleColor(.white, for: UIControl.State.normal)
        signupBtn.layer.cornerRadius = 10
        signupBtn.layer.shadowOffset = CGSize(width: 5, height: 5)
        signupBtn.layer.shadowOpacity = 0.7
        signupBtn.layer.shadowColor = UIColor.black.cgColor
        signupBtn.layer.shadowRadius = 5
        signupBtn.backgroundColor = #colorLiteral(red: 0.02722084895, green: 0.5078135729, blue: 0.4728758931, alpha: 1)
          
        nameText.placeholder = "👤 name"
        mailText.placeholder = "✉️ mail"
        passText.placeholder = "🔑 password"
        nameText.addBorderBottom(height: 1.0, color: UIColor.white)
        mailText.addBorderBottom(height: 1.0, color: UIColor.white)
        passText.addBorderBottom(height: 1.0, color: UIColor.white)
        
        indicator.center = view.center
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = .white
        view.addSubview(indicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction private func newRegisterBtn(_ sender: Any) {
        guard let email = mailText.text,
              let password = passText.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let dialog = UIAlertController(title: "Sign Up Failed", message: error.localizedDescription, preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
            } else {
                DispatchQueue.main.async {
                    self.indicator.startAnimating()
                }//FirebaseStoreへ保存と情報取得
                self.userInfoToFirestore(email: email)
            }
        }
    }
    
    private func userInfoToFirestore(email: String) {
        guard let uid = Auth.auth().currentUser?.uid,
              let name = nameText.text else { return }
        
        let docData = ["email": email, "name": name, "createdAt":Timestamp()] as [String : Any]
        let userInfo = Firestore.firestore().collection("users").document(uid)
        
        userInfo.setData(docData){ (error) in
            if let error = error {
                print("Firestore情報保存に失敗しました\(error)")
                return
            } else {
                print("Firestore情報保存に成功")
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
}
    
    @IBAction private func alreadyHaveTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        navigationController?.pushViewController(loginViewController, animated: true)
    }

    @IBAction func RegisterLaterTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


