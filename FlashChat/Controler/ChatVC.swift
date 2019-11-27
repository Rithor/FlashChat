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
    private var messagesArray = [Message]()
    private var dbListener: ListenerRegistration?
    private var keyboardHeight: CGFloat = 0.0
    private var isFirstLoad = true
    
    @IBOutlet private weak var bottomInputMessageViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var messagesTableView: UITableView!
    @IBOutlet private weak var messageTextView: UITextView!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        messageTextView.layer.cornerRadius = 5
        messageTextView.isScrollEnabled = false
        
        messagesTableView.separatorStyle = .none
        messagesTableView.register(UINib(nibName: "MessageCell", bundle: nil),
                                   forCellReuseIdentifier: Constant.messageCellIdentifire)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messagesTableView.addGestureRecognizer(tapGesture)
        
        loadMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(keyboardWillAppear),
                       name: UIResponder.keyboardWillShowNotification,
                       object: nil)
        nc.addObserver(self,
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
    @IBAction private func actionLogOutBButton(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            CommonFunc.showAlertWith(message: signOutError.localizedDescription, sender: self)
        }
    }
    
    @IBAction private func actionSendButton(_ sender: UIButton) {
        sendMessage()
    }
    
    //MARK: - Auxiliary methods
    private func loadMessages() {
        //TODO: implement offline access
        dbListener = db.collection(Constant.FBase.collectionName)
            .order(by: Constant.FBase.dateFeild)
            .addSnapshotListener { (querySnapshot, error) in
                if let getDocError = error {
                    //TODO: load offline data
                    if Auth.auth().currentUser != nil {
                        CommonFunc.showAlertWith(
                            message: "Check your internet connection.\n\(getDocError.localizedDescription)",
                            sender: self)
                    }
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
    
    private func sendMessage() {
        if let messageBody = messageTextView.text,
            let messageSender = Auth.auth().currentUser?.email,
            CommonFunc.isValidateString(messageBody) {
            
            db.collection(Constant.FBase.collectionName).addDocument(data: [
                Constant.FBase.senderField: messageSender,
                Constant.FBase.bodyField: messageBody,
                Constant.FBase.dateFeild: Date().timeIntervalSince1970
            ]) { (error) in
                if let addDocError = error {
                    CommonFunc.showAlertWith(
                        message: "Message wasn't send.\n\(addDocError.localizedDescription)",
                        sender: self)
                } else {
                    DispatchQueue.main.async {
                        self.messageTextView.text = ""
                        UIView.animate(withDuration: 0.2) {
                            self.bottomViewHeightConstraint.constant = Constant.Constraint.defaultBottomViewHeight
                            self.messageTextViewHeightConstraint.constant = Constant.Constraint.defaultTextViewHeight
                            self.view.layoutIfNeeded()
                        }
                    }
                }
            }
        }
    }
    
    private func updateInputTextView(isKeybordShow: Bool) {
        let offset = bottomInputMessageViewConstraint.constant > 0 ? 0.0 : keyboardHeight
        if isKeybordShow {
            bottomInputMessageViewConstraint.constant += offset
            if offset != 0 {
                scrollChatToDown()
            }
        } else {
            bottomInputMessageViewConstraint.constant -= keyboardHeight
        }
        view.layoutIfNeeded()
    }
    
    private func scrollChatToDown() {
        guard messagesArray.count > 1 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.messagesTableView.reloadData()
            let lastIndex = IndexPath(row: self.messagesArray.count - 1, section: 0)
            self.messagesTableView.scrollToRow(at: lastIndex,
                                               at: .top,
                                               animated: !self.isFirstLoad)
            self.isFirstLoad = false
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
        messagesTableView.reloadData()
    }
    
    //MARK: - GestureRecognizer func
    @objc private func tableViewTapped() {
        messageTextView.resignFirstResponder()
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
            safeCell.messageLabel.textColor = Constant.Color.brandMintDarkColor
            safeCell.messageView.backgroundColor = Constant.Color.brandMintDarkColor?.withAlphaComponent(0.1)
        } else {
            //appearance for another users
            safeCell.leftAvatarView.isHidden = false
            safeCell.rightAvaterView.isHidden = true
            safeCell.messageView.backgroundColor = Constant.Color.brandMintDarkColor
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

//MARK: - UITextViewDelegate
extension ChatVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimateSize = textView.sizeThatFits(size)
        let oldState = bottomViewHeightConstraint.constant - messageTextViewHeightConstraint.constant
        messageTextViewHeightConstraint.constant = estimateSize.height
        let newState = bottomViewHeightConstraint.constant - messageTextViewHeightConstraint.constant
        if oldState != newState {
            bottomViewHeightConstraint.constant += oldState
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendMessage()
            return false
        }
        return true
    }
    
}
