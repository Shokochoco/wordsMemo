import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var mailText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        indicatorSetup()
//        mailText.delegate = self
//        passText.delegate = self
    }
    
    func setup() {
                
        loginBtn.frame = CGRect(x: 0, y: 625, width: 287, height: 46)
        loginBtn.setTitleColor(.white, for: UIControl.State.normal)
        loginBtn.layer.cornerRadius = 10
        loginBtn.layer.shadowOffset = CGSize(width: 5, height: 5)
        loginBtn.layer.shadowOpacity = 0.7
        loginBtn.layer.shadowColor = UIColor.black.cgColor
        loginBtn.layer.shadowRadius = 5
        loginBtn.backgroundColor = #colorLiteral(red: 0, green: 0.6546586752, blue: 0.6037966609, alpha: 1)
        
        mailText.text = "1@gmail.com"
        passText.text = "123456"
        mailText.placeholder = "✉️ mail"
        passText.placeholder = "🔑 password"
        mailText.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passText.addBorderBottom(height: 1.0, color: UIColor.lightGray)
    }
    
    func indicatorSetup() {
        indicator.center = view.center
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = .gray
        view.addSubview(indicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signinTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = mailText.text else { return }
        guard let pass = passText.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
            if let error = error {
                let dialog = UIAlertController(title: "ログイン失敗", message: error.localizedDescription, preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
                return
            }
            print("ログイン成功")
            DispatchQueue.main.async {
                self.indicator.startAnimating()
                //FireStoreからuid情報を取る
                self.userInfoFromFireStore()
            }
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func userInfoFromFireStore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { [self] (snapshot, error) in
            if let error = error {
              print("FireStoreから取得失敗", error)
              return
            }
            if let data = snapshot?.data() {
                print("FireStoreから取得成功\(data)")
            }
        }

    }
    
    func gotoNewViewController () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "newView") as! NewViewController
        //ナビゲーションで遷移
        navigationController?.pushViewController(newViewController, animated: true)
    }

}

extension LoginViewController: UITextFieldDelegate {
    
}
