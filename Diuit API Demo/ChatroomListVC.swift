//
//  ChatroomListVC.swift
//  Diuit API Demo
//
//  Created by David Lin on 11/30/15.
//  Copyright © 2015 Diuit. All rights reserved.
//

import UIKit
import DUMessaging

class ChatroomListVC: UIViewController {
    
    private var chats: [DUChat] = []

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func doShowSettings(sender: AnyObject) {
    }
    
    func registerMessageObserver() {
        NSNotificationCenter.defaultCenter().addObserverForName("messageReceived", object: nil, queue: NSOperationQueue.mainQueue()) { notif in
            let message = notif.userInfo!["message"] as! DUMessage
            NSLog("Got new message #\(message.id):\n\(message.data)")
            DUMessaging.listChatrooms() { error, chats in
                if error != nil {
                    NSLog("list chat room errored:\(error!.localizedDescription)")
                    return
                }
                NSLog("There are \(chats?.count) chatrooms")
                self.chats = (chats as! [DUChat]?)!
                self.tableView.reloadData();
            }
        }
    }
    func loginWithAuthToken(token: String) {
        
        DUMessaging.loginWithAuthToken(token) { error, result in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "Failed to login:\(error!.localizedDescription)", preferredStyle: .Alert);
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil);
                return
            }
            self.registerMessageObserver()

            DUMessaging.listChatrooms() { error, chats in
                if error != nil {
                    NSLog("list chat room errored:\(error!.localizedDescription)")
                    return
                }
                self.chats = (chats as! [DUChat]?)!
                self.tableView.reloadData();
            }
        }
    }
    
    // MARK: Life Cycle
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChatroomSegue" {
            let vc = segue.destinationViewController as! ChatroomVC
            vc.chat = chats[(self.tableView?.indexPathForSelectedRow?.row)!]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let alert = UIAlertController(title: "Login", message: "Which user do you wish to login as?", preferredStyle: .ActionSheet);
        alert.addAction(UIAlertAction(title: "demouser1", style: .Default) { action in
            self.loginWithAuthToken("YOUR_SESSION_TOKEN_1")
            })
        alert.addAction(UIAlertAction(title: "demouser2", style: .Default) { action in
            self.loginWithAuthToken("YOUR_SESSION_TOKEN_2")
            })
        alert.addAction(UIAlertAction(title: "demouser3", style: .Default) { action in
            self.loginWithAuthToken("YOUR_SESSION_TOKEN_3")
            })

        presentViewController(alert, animated: true, completion: nil);
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if DUMessaging.currentUser != nil {
            self.registerMessageObserver()
            DUMessaging.listChatrooms() { error, chats in
                if error != nil {
                    NSLog("list chat room errored:\(error!.localizedDescription)")
                    return
                }
                self.chats = (chats as! [DUChat]?)!
                self.tableView.reloadData();
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension ChatroomListVC: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("cell")!
        let chat = self.chats[indexPath.row] as DUChat
        if let chatName = chat.meta!["name"] as? String {
            c.textLabel?.text = chatName
        } else {
            c.textLabel?.text = "Room \(chat.id)"
        }

        if chat.lastMessage?.mime == "text/plain" {
            c.detailTextLabel?.text = chat.lastMessage?.data
        } else if chat.lastMessage != nil {
            c.detailTextLabel?.text = ""
        } else {
            c.detailTextLabel?.text = ""
        }
        return c
    }
}

extension ChatroomListVC: UITableViewDelegate {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let currentUsr = DUMessaging.currentUser {
            return "Chatrooms of \(currentUsr.serial)"
        } else {
            return "Chatrooms"
        }
    }
}
