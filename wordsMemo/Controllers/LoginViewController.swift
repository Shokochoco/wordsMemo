import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet private weak var mailText: UITextField!
    @IBOutlet private weak var passText: UITextField!
    @IBOutlet private weak var loginBtn: UIButton!
    @IBOutlet private weak var signupBtn: UIButton!
    
    private var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginBtn.frame = CGRect(x: 0, y: 625, width: 287, height: 46)
        loginBtn.setTitleColor(.white, for: UIControl.State.normal)
        loginBtn.layer.cornerRadius = 10
        loginBtn.layer.shadowOffset = CGSize(width: 5, height: 5)
        loginBtn.layer.shadowOpacity = 0.7
        loginBtn.layer.shadowColor = UIColor.black.cgColor
        loginBtn.layer.shadowRadius = 5
        loginBtn.backgroundColor = #colorLiteral(red: 0, green: 0.6546586752, blue: 0.6037966609, alpha: 1)

        mailText.placeholder = "✉️ mail"
        passText.placeholder = "🔑 password"
        mailText.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passText.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        
        indicator.center = view.center
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = #colorLiteral(red: 0, green: 0.6113008261, blue: 0.5758315325, alpha: 0.8470000029)
        view.addSubview(indicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AppUtility.lockOrientation(.all)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction private func createAccountTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func loginTapped(_ sender: UIButton) {
        guard let email = mailText.text else { return }
        guard let pass = passText.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
            if let error = error {
                let dialog = UIAlertController(title: "Log In failed", message: error.localizedDescription, preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
                return
            }
            DispatchQueue.main.async {
                self.indicator.startAnimating()
                self.userInfoFromFireStore()
            }
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func userInfoFromFireStore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] (snapshot, error) in
            if let error = error {
                print("FireStoreから取得失敗", error)
                return
            }
            if let data = snapshot?.data() {
                print("FireStoreから取得成功\(data)")
            }
        }
        
    }
    @IBAction private func forgotPassTapped(_ sender: UIButton) {

        var alertTextField: UITextField?
        
        let alert = UIAlertController(title: "Reset Password",message: "We will send you a link to reset your password", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter your email"
                alertTextField = textField
            })
        alert.addAction(UIAlertAction(title: "Cancel",style: UIAlertAction.Style.cancel,handler: nil))
        alert.addAction(UIAlertAction(title: "OK",style: UIAlertAction.Style.default) { _ in
            
                guard let email = alertTextField?.text else { return }
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        let failedlog = UIAlertController(title: "Failed", message: error.localizedDescription, preferredStyle: .alert)
                        failedlog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(failedlog, animated: true, completion: nil)
                    } else {
                        let successlog = UIAlertController(title: "Succeed", message: "Check your email box.", preferredStyle: .alert)
                        successlog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(successlog, animated: true, completion: nil)
                    }
                }                
            })
        self.present(alert, animated: true, completion: nil)
        }
    
}

