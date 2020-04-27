//
//  ChatVC.swift
//  FlashChat
//
//  Created by Vitalii on 22.11.2019.
//  Copyright © 2019 Vitalii Andrianov. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {
    
    //MARK: - Properties
    private let networkServise = NetworkService()
    
    private var messagesArray = [Message]()
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
        setupUI()
        loadMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        networkServise.dbListener?.remove()
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - IBActions
    @IBAction private func actionLogOutBButton(_ sender: UIBarButtonItem) {
        networkServise.logOut { (isSuccessful, error) in
            if isSuccessful {
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                CommonFunc.showAlertWith(message: error!.localizedDescription, sender: self)
            }
        }
    }
    
    @IBAction private func actionSendButton(_ sender: UIButton) {
        sendMessage()
    }
    
    //MARK: - Work with messages
    private func loadMessages() {
        networkServise.loadMessages { (message, error) in
            if let loadError = error {
                CommonFunc.showAlertWith(
                    message: "Check your internet connection.\n\(loadError.localizedDescription)",
                    sender: self)
            } else if let message = message {
                self.messagesArray.append(message)
                self.scrollChatToDown()
            }
        }
    }
    
    private func sendMessage() {
        guard let newMessage = messageTextView.text else { return }
        networkServise.sendMessage(string: newMessage) { (isSuccessful, error) in
            if isSuccessful {
                DispatchQueue.main.async {
                    self.messageTextView.text = ""
                    UIView.animate(withDuration: 0.2) {
                        self.bottomViewHeightConstraint.constant = Constant.Constraint.defaultBottomViewHeight
                        self.messageTextViewHeightConstraint.constant = Constant.Constraint.defaultTextViewHeight
                        self.view.setNeedsLayout()
                    }
                }
            } else {
                CommonFunc.showAlertWith(
                    message: "Message wasn't send.\n\(error!.localizedDescription)",
                    sender: self)
            }
        }
    }
    
    //MARK: - Auxiliary methods
    fileprivate func setupUI() {
        navigationItem.hidesBackButton = true
        
        messageTextView.layer.cornerRadius = 5
        messageTextView.isScrollEnabled = false
        
        messagesTableView.separatorStyle = .none
        messagesTableView.register(UINib(nibName: "MessageCell", bundle: nil),
                                   forCellReuseIdentifier: Constant.messageCellIdentifire)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messagesTableView.addGestureRecognizer(tapGesture)
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
        view.setNeedsLayout()
    }
    
    private func scrollChatToDown() {
        guard messagesArray.count > 1 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
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
        scrollChatToDown()
    }
    
    //MARK: - GestureRecognizer func
    @objc private func tableViewTapped() {
        scrollChatToDown()
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
        safeCell.messageLabel.text = messagesArray[indexPath.row].body
        if networkServise.isCurrentUser(email: message.sender) {
            safeCell.configureForCurrentUser()
        } else {
            safeCell.configureForAnotherUser(name: message.sender)
        }
        return safeCell
    }
}

//MARK: - UITextViewDelegate
extension ChatVC: UITextViewDelegate {
    
    //changing messageTextView height
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimateSize = textView.sizeThatFits(size)
        let oldState = bottomViewHeightConstraint.constant - messageTextViewHeightConstraint.constant
        messageTextViewHeightConstraint.constant = estimateSize.height
        let newState = bottomViewHeightConstraint.constant - messageTextViewHeightConstraint.constant
        if oldState > newState {
            bottomViewHeightConstraint.constant += oldState
            scrollChatToDown()
        } else if oldState < newState {
            bottomViewHeightConstraint.constant -= oldState
        }
    }
    
    //send message by pressed "Return" key
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendMessage()
            return false
        }
        return true
    }
    
}
