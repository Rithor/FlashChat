//
//  ChatVC.swift
//  FlashChat
//
//  Created by Vitalii on 22.11.2019.
//  Copyright © 2019 Vitalii Andrianov. All rights reserved.
//

import UIKit
import Firebase

class ChatVC: UIViewController {
    
    //MARK: - Properties
    let db = Firestore.firestore()
    var messagesArray = [Message]()
    var dbListener: ListenerRegistration?
    var keyboardHeight: CGFloat = 0.0

    @IBOutlet weak var bottomInputMessageViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messagesTableView.addGestureRecognizer(tapGesture)
        
        messagesTableView.separatorStyle = .none
        messagesTableView.register(UINib(nibName: "MessageCell", bundle: nil),
                                   forCellReuseIdentifier: Constant.messageCellIdentifire)
        
        loadMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillDisappear),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        dbListener?.remove()
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - IBActions
    @IBAction func actionLogOutBButton(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func actionSendButton(_ sender: UIButton) {
        sendMessage()
    }
    
    //MARK: - Auxiliary methods
    private func loadMessages() {
        //TODO: implement offline access
        dbListener = db.collection(Constant.FBase.collectionName)
            .order(by: Constant.FBase.dateFeild)
            .addSnapshotListener { (querySnapshot, error) in
            if let getDocError = error {
                print("Error: Get Data from Firestore. \(getDocError.localizedDescription). \(getDocError)")
            } else {
                guard let snapshotDocs = querySnapshot?.documentChanges else { return }
                for doc in snapshotDocs {
                    let message = doc.document.data()
                    if let messageSender = message[Constant.FBase.senderField] as? String, let messageBody = message[Constant.FBase.bodyField] as? String {
                        self.messagesArray.append(Message(body: messageBody, sender: messageSender))
                        self.scrollChatToDown()
                    }
                }
            }
        }
    }
    
    fileprivate func sendMessage() {
        if let messageBody = messageTextField.text, let messageSender = Auth.auth().currentUser?.email, Validation.isValidateString(messageBody) {
            db.collection(Constant.FBase.collectionName).addDocument(data: [
                Constant.FBase.senderField: messageSender,
                Constant.FBase.bodyField: messageBody,
                Constant.FBase.dateFeild: Date().timeIntervalSince1970
            ]) { (error) in
                if let addDocError = error {
                    print("Error: Add data to FireBase collection. \(addDocError). \(addDocError.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.messageTextField.text = ""
                    }
                    print("Add data successful")
                }
            }
        }
    }
    
    private func updateInputTextView(isKeybordShow: Bool) {
        let offset = bottomInputMessageViewConstraint.constant > 0 ? 0.0 : keyboardHeight
        if isKeybordShow {
            bottomInputMessageViewConstraint.constant += offset
            view.layoutIfNeeded()
            if offset != 0 {
                scrollChatToDown()
            }
        } else {
            bottomInputMessageViewConstraint.constant -= keyboardHeight
            view.layoutIfNeeded()
        }
    }
    
    private func scrollChatToDown() {
        guard messagesArray.count > 1 else { return }
        DispatchQueue.main.async {
            self.messagesTableView.reloadData()
            self.messagesTableView.scrollToRow(at: IndexPath(row: self.messagesArray.count - 1, section: 0),
                                              at: .top,
                                              animated: true)
        }
    }
    
    //MARK: - NotificationCenter func
    @objc private func keyboardWillAppear(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
            if #available(iOS 11.0, *) {
                let bottomInset = view.safeAreaInsets.bottom
                keyboardHeight -= bottomInset
            }
            updateInputTextView(isKeybordShow: true)
        }
    }
    
    @objc private func keyboardWillDisappear(_ notification: Notification) {
        updateInputTextView(isKeybordShow: false)
    }
    
    //MARK: - GestureRecognizer func
    @objc private func tableViewTapped() {
        messageTextField.resignFirstResponder()
    }
    
}

//MARK: - UITableViewDataSource
extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.messageCellIdentifire, for: indexPath) as? MessageCell
        guard let safeCell = cell else { return UITableViewCell() }
        let message = messagesArray[indexPath.row]
        //appearance for current user
        if message.sender == Auth.auth().currentUser?.email {
            safeCell.leftAvatarView.isHidden = true
            safeCell.rightAvaterView.isHidden = false
            safeCell.messageLabel.textColor = #colorLiteral(red: 0.2389388382, green: 0.5892125368, blue: 0.8818323016, alpha: 1)
            safeCell.messageView.backgroundColor = #colorLiteral(red: 0.2389388382, green: 0.5892125368, blue: 0.8818323016, alpha: 1).withAlphaComponent(0.1)
        } else {
            //appearance for another users
            safeCell.leftAvatarView.isHidden = false
            safeCell.rightAvaterView.isHidden = true
            safeCell.messageView.backgroundColor = #colorLiteral(red: 0.2389388382, green: 0.5892125368, blue: 0.8818323016, alpha: 1)
            safeCell.messageLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            let userName = message.sender
            let endIndex = userName.index(userName.startIndex, offsetBy: 2)
            let avatarString = userName[userName.startIndex...endIndex]
            safeCell.leftAvatarLabel.text = avatarString.capitalized
        }
        safeCell.messageLabel.text = messagesArray[indexPath.row].body
        return safeCell
    }
    
}

//MARK: - UITextFieldDelegate
extension ChatVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
    
}
