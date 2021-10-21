import Foundation
import UIKit
import Firebase

class MypageViewController: UIViewController {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var mailText: UITextField!
    @IBOutlet weak var finishCount: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var logout: UIButton!
    @IBOutlet weak var nameEditBtn: UIButton!
    @IBOutlet weak var mailEdit: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var finishNumber:Int = 0
    var totalNumber:Int = 0
    
    @IBOutlet weak var scoreView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        nameText.isEnabled = false
    }
    
    func setup() {
        scoreView.layer.cornerRadius = 10
        scoreView.layer.masksToBounds = false

        scoreView.layer.shadowColor = UIColor.black.cgColor
        scoreView.layer.shadowOffset = CGSize(width: 5, height: 5)
        scoreView.layer.shadowOpacity = 0.5
        scoreView.layer.shadowRadius = 5
        scoreView.backgroundColor = #colorLiteral(red: 0, green: 0.6113008261, blue: 0.5758315325, alpha: 1)
        
        nameText.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        mailText.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        
        logout.frame = CGRect(x: 0, y: 625, width: 287, height: 46)
        logout.layer.shadowColor = UIColor.black.cgColor
        logout.layer.shadowOffset = CGSize(width: 5, height: 5)
        logout.layer.shadowOpacity = 0.5
        logout.layer.shadowRadius = 5
        logout.backgroundColor = #colorLiteral(red: 0, green: 0.6113008261, blue: 0.5758315325, alpha: 1)
        logout.setTitleColor(.white, for: UIControl.State.normal)
        logout.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        finishCount.text = "Fini 🥖：\(finishNumber) mots"
        total.text = "Total 🍷： \(totalNumber) mots"
        userInfoFromFireStore()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func nameEditTapped(_ sender: UIButton) {
    
        if nameEditBtn.isEnabled {
            nameText.isEnabled = true

            let edit = UIImage(systemName: "pencil.circle")
            nameEditBtn.setImage(edit, for: .normal)
            print("true")
            func changeInformation() {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = nameText.text
                changeRequest?.commitChanges { error in
            print(error)
                }
             }
            nameEditBtn.isEnabled = false
        }
        
        if nameEditBtn.isEnabled == false {
            let done = UIImage(systemName: "pencil.circle.fill")
            nameEditBtn.setImage(done, for: .normal)
            print("false")

            nameEditBtn.isEnabled = true
            nameEditBtn.isEnabled = !nameEditBtn.isEnabled
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
                nameText.text = "\(data["name"]!)"
                mailText.text = "\(data["email"]!)"
                
            }
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Signup", bundle: nil)
            let signupViewController = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
            signupViewController.modalPresentationStyle = .fullScreen
            self.present(signupViewController, animated: true, completion: nil)
        } catch {
            let failedlog = UIAlertController(title: "Log Out Failed", message: " ", preferredStyle: .alert)
            failedlog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Are you sure ?", message: "You can not cancel if you tap OK.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel",style: UIAlertAction.Style.cancel,handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            
            let user = Auth.auth().currentUser

            user?.delete { error in
              if let error = error {
                print("アカウント削除できませんでした\(error)")
                let failedAccount = UIAlertController(title: "Delete your account Failed", message: " ", preferredStyle: .alert)
                failedAccount.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
              } else {
                let storyboard = UIStoryboard(name: "Signup", bundle: nil)
                let signupViewController = storyboard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
                signupViewController.modalPresentationStyle = .fullScreen
                self.present(signupViewController, animated: true, completion: nil)
              }
            }
        })
        self.present(alert, animated: true, completion: nil)
    }
    
}

