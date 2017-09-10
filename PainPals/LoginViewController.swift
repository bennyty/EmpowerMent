//
//  ViewController.swift
//  PainPals
//
//  Created by Espey, Benjamin G on 9/9/17.
//  Copyright © 2017 bennyty. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var code: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func LoginTapped(_ sender: UITapGestureRecognizer) {
        guard let username = self.username.text, username != "" else {
            self.username.shake()
            return
        }
        guard let password = self.password.text, password != "" else {
            self.password.shake()
            return
        }
        guard let code = self.code.text, code != "" else {
            self.code.shake()
            return
        }
        Auth.auth().signIn(withEmail: username, password: password) { (user, error) in
            UserDefaults.standard.set(username, forKey: "username")
            UserDefaults.standard.set(password, forKey: "password")
            self.performSegue(withIdentifier: "LoginSuccess", sender: code)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        var dataSource: FirebaseChatDataSource!

        let chatController = { () -> DemoChatViewController? in
            if let controller = segue.destination as? DemoChatViewController {
                return controller
            }
            if let tabController = segue.destination as? UITabBarController,
                let controller = tabController.viewControllers?.first as? DemoChatViewController {
                return controller
            }
            return nil
            }()!

        if dataSource == nil {
            dataSource = FirebaseChatDataSource(conversationID: sender as! ConversationIDKey)
        }
        chatController.dataSource = dataSource
        chatController.messageSender = dataSource.messageSender
    }

}

