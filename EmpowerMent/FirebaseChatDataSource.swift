//
//  FirebaseChatDataSource.swift
//  EmpowerMent
//
//  Created by Espey, Benjamin G on 9/9/17.
//  Copyright © 2017 bennyty. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import Chatto
import ChattoAdditions

typealias ConversationIDKey = String

func firebaseDataToMessage(message: [String: AnyObject]) -> ChatItemProtocol! {
    if message["message"] != nil {
        let messageText = message["message"] as! String
        let uid = message["uid"] as! String
        let messageUsername = message["user"] as! String
        let username = UserDefaults.standard.string(forKey: "username")!
        let isIncoming = messageUsername != username
        let chatItem = createTextMessageModel(uid, text: messageText, isIncoming: isIncoming)
        return chatItem
    } else if message["photo"] != nil {
        let photo = message["photo"] as! UIImage
        let uid = message["uid"] as! String
        let messageUsername = message["user"] as! String
        let username = UserDefaults.standard.string(forKey: "username")!
        let isIncoming = messageUsername != username
        let chatItem = createPhotoMessageModel(uid, image: photo, size: photo.size, isIncoming: isIncoming)
        return chatItem
    } else {
        return nil
    }
}

class FirebaseChatDataSource: ChatDataSourceProtocol {

    private var conversationRef: DatabaseReference
    var hasMoreNext: Bool {
        return false
    }

    var hasMorePrevious: Bool {
        return false
    }

    var chatItems: [ChatItemProtocol]

    var delegate: ChatDataSourceDelegateProtocol?

    lazy var messageSender: FakeMessageSender = {
        let sender = FakeMessageSender()
        sender.onMessageChanged = { [weak self] (message) in
            guard let sSelf = self else { return }
            sSelf.delegate?.chatDataSourceDidUpdate(sSelf)
        }
        return sender
    }()

    init(conversationID: ConversationIDKey) {
        // Load from database on statup
        let ref = Database.database().reference()
        chatItems = []

        conversationRef = ref.child("conversations/\(conversationID)")

        conversationRef.queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value, with: {
            [weak self] (data) in
            // Difference in children
            if data.exists() {
                let messages = data.value as! [String : AnyObject]
                var newChatItems = [ChatItemProtocol]()
                for message in messages {
                    let message = message.value as! [String : AnyObject]
                    if let chatItem = EmpowerMent.firebaseDataToMessage(message: message) {
                        newChatItems.append(chatItem)
                    } else {
                        print("Failed to make message for data: \(message)")
                    }
                }
                self?.chatItems = newChatItems
                if self != nil {
                    self?.delegate?.chatDataSourceDidUpdate(self!, updateType: .firstLoad)
                }
            }
        })

        conversationRef.queryLimited(toLast: 1).observe(.childAdded, with: {
//        conversationRef.observe(.childAdded, with: {
            [weak self] (data) in
            // Difference in children
            let message = data.value as! [String : AnyObject]
            if let chatItem = EmpowerMent.firebaseDataToMessage(message: message) {
                self?.chatItems.append(chatItem)
            } else {
                print("Failed to make message for data: \(message)")
            }

            if self != nil {
                self?.delegate?.chatDataSourceDidUpdate(self!, updateType: .firstLoad)
            }
            
        })
    }

    

    deinit {
        conversationRef.removeAllObservers()
    }

    func loadNext() {
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }

    func loadPrevious() {
        delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }

    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {

        // If you want, implement message count contention for performance, otherwise just call completion(false)
        completion(false) // Being lazy
    }
    
    func addPhotoMessage(_ photo: UIImage) {
        let newChild = conversationRef.childByAutoId()
        let username = UserDefaults.standard.string(forKey: "username")!
        newChild.updateChildValues([
            newChild.child("uid").key : newChild.key,
            newChild.child("photo").key : photo,
            newChild.child("user").key : username,
            newChild.child("timestamp").key : ServerValue.timestamp()
            ])
    }

    func addTextMessage(_ text: String) {
        let newChild = conversationRef.childByAutoId()
        let username = UserDefaults.standard.string(forKey: "username")
        newChild.updateChildValues([
            newChild.child("uid").key : newChild.key,
            newChild.child("message").key : text,
            newChild.child("user").key : username ?? "",
            newChild.child("timestamp").key : ServerValue.timestamp()
            ])
    }
}
