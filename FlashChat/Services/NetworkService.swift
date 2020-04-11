//
//  NetworkService.swift
//  FlashChat
//
//  Created by Vitalii on 05.12.2019.
//  Copyright © 2019 Vitalii Andrianov. All rights reserved.
//

import Foundation
import Firebase

class NetworkService {
    
    var dbListener: ListenerRegistration?
    let db = Firestore.firestore()
    
    //MARK: - Work with Messages
    func loadMessages(completion: @escaping (Message?, Error?) -> Void) {
        dbListener = db.collection(Constant.FBase.collectionName)
            .order(by: Constant.FBase.dateFeild)
            .addSnapshotListener { (querySnapshot, error) in
                if let getDocError = error {
                    if Auth.auth().currentUser != nil {
                        completion(nil, getDocError)
                    }
                } else {
                    guard let snapshotDocs = querySnapshot?.documentChanges else { return }
                    for doc in snapshotDocs {
                        let message = doc.document.data()
                        if let messageSender = message[Constant.FBase.senderField] as? String, let messageBody = message[Constant.FBase.bodyField] as? String {
                            completion(Message(body: messageBody, sender: messageSender), nil)
                        }
                    }
                }
        }
    }
    
    func sendMessage(string: String, completion: @escaping (Bool, Error?) -> Void) {
        if let messageSender = Auth.auth().currentUser?.email,
            CommonFunc.isValidateString(string) {
            
            db.collection(Constant.FBase.collectionName).addDocument(data: [
                Constant.FBase.senderField: messageSender,
                Constant.FBase.bodyField: string,
                Constant.FBase.dateFeild: Date().timeIntervalSince1970
            ]) { (error) in
                if let addDocError = error {
                    completion(false, addDocError)
                } else {
                    completion(true, nil)
                }
            }
        }
    }
    
    //MARK: - Work with Users
    func logOut(completion: @escaping (Bool, Error?) -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            completion(true, nil)
        } catch let signOutError as NSError {
            completion(false, signOutError)
        }
    }
    
    func isCurrentUser(email: String) -> Bool {
        return email == Auth.auth().currentUser?.email ? true : false
    }
    
    func createNewUser(with userEmail: String, _ userPassword: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (user, error) in
            if let regError = error {
                completion(nil, regError)
            } else {
                guard let newUser = user else { return }
                completion(newUser, nil)
            }
        }
    }
    
    func signInUser(with userEmail: String, _ userPassword: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { authResult, error in
            if let signInError = error {
                completion(nil, signInError)
            } else {
                completion(authResult, nil)
            }
        }
    }
    
}
