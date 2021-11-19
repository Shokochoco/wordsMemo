import Foundation
import UIKit
import Firebase

class MypageViewController: UIViewController {
    
    @IBOutlet private weak var nameText: UITextField!
    @IBOutlet private weak var mailText: UITextField!
    @IBOutlet private weak var finishCount: UILabel!
    @IBOutlet private weak var total: UILabel!
    @IBOutlet private weak var logout: UIButton!
    @IBOutlet private weak var deleteBtn: UIButton!
    
    var finishNumber:Int = 0
    var totalNumber:Int = 0
    
    @IBOutlet private weak var scoreView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        nameText.delegate = self
        mailText.isEnabled = false
    }
    
    private func setup() {
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
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
        finishCount.text = "Fini 🥖：\(finishNumber) mots"
        total.text = "Total 🍷： \(totalNumber) mots"
        userInfoFromFireStore()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func userInfoFromFireStore() {
        guard let uid = Auth.auth().currentUser?.uid else { fatalError() }
        let userInfo = Firestore.firestore().collection("users").document(uid)
        userInfo.getDocument { [self] (snapshot, error) in
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
 // MARK: - Button Tapped
    @IBAction private func updateEmailTapped(_ sender: Any) {
        var alertTextField: UITextField?
        
        let alert = UIAlertController(title: "Change Email",message: "We will send you a link to confirm your new email", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter your new email"
            alertTextField = textField
        })
        
        alert.addAction(UIAlertAction(title: "Cancel",style: UIAlertAction.Style.cancel,handler: nil))
        alert.addAction( UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in
            guard let email = alertTextField?.text else { return }
            let user = Auth.auth().currentUser
            user?.updateEmail(to: email) { error in
                if let error = error {
                    let failedlog = UIAlertController(title: "Failed", message: error.localizedDescription, preferredStyle: .alert)
                    failedlog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(failedlog, animated: true, completion: nil)
                } else {
                    user?.sendEmailVerification { error in
                        if let error = error {
                            print("sendメッセージ失敗")
                        } else {
                            guard let uid = Auth.auth().currentUser?.uid else { fatalError() }
                            let userInfo = Firestore.firestore().collection("users").document(uid)
                            userInfo.updateData([ "email": email ]) { err in
                                if let error = error {
                                    print("Error updating document: \(error)")
                                } else {
                                    print("Document successfully updated")
                                }
                            }
                            let successlog = UIAlertController(title: "Succeed", message: "Check your email box. Please Log out and Sign up again", preferredStyle: .alert)
                            //closureでOK押したら最初の画面に戻った方がいい？
                            successlog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(successlog, animated: true, completion: nil)
                       }
                    }
                }
            }
            
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func logoutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch {
            let failedlog = UIAlertController(title: "Log Out Failed", message: " ", preferredStyle: .alert)
            failedlog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
    }
    
    @IBAction private func deleteBtnTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Are you sure ?", message: "You can not cancel if you tap OK.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel",style: UIAlertAction.Style.cancel,handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            
            let user = Auth.auth().currentUser
            user?.delete { error in
                if let error = error {
                    let failedAccount = UIAlertController(title: "Delete your account Failed", message: " ", preferredStyle: .alert)
                    failedAccount.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension MypageViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        guard let uid = Auth.auth().currentUser?.uid else { fatalError() }
        let userInfo = Firestore.firestore().collection("users").document(uid)
        userInfo.updateData([
            "name": nameText.text ?? ""
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
}
