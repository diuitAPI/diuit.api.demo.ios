//
//  ChatroomSettingVC.swift
//  Diuit API Demo
//
//  Created by Pofat Diuit on 2015/12/24.
//  Copyright © 2015年 Diuit. All rights reserved.
//

import UIKit
import DUMessaging

class ChatroomSettingVC: UIViewController {

    @IBOutlet var idLabel: UILabel!
    @IBOutlet var roomNameText: UITextField!
    @IBOutlet var tableView: UITableView!

    var chat:DUChat!
    var serials:[String]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.serials = self.chat.members!
        let index = self.serials.indexOf((DUMessaging.currentUser?.serial)!)
        self.serials.removeAtIndex(index!)
        
        self.idLabel.text = "Chat ID: \(self.chat.id)"
        self.roomNameText.text = (self.chat.meta!["name"] != nil) ? self.chat.meta!["name"] as! String : "room \(chat.id)"
        // Do any additional setup after loading the view.
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .None
        self.tableView.reloadData()
    }

    @IBAction func save() {
        if self.roomNameText.text != "" {
            self.chat.updateMeta(["name": self.roomNameText.text!]) { code, chat in
                if code == 200 {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        } else {
            let alert = UIAlertController(title: "Info", message: "Room name can not be empty", preferredStyle: .Alert);
            presentViewController(alert, animated: true, completion: nil);
        }
    }

    @IBAction func leaveRoom() {
        self.chat.leaveOnCompletion() { code, message in
            if code == 200 {
                let vcs = self.navigationController?.viewControllers
                for vc in vcs! {
                    if vc.isKindOfClass(ChatroomListVC) {
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}

extension ChatroomSettingVC: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.serials.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("cell")!
        let serialLabel = c.viewWithTag(1) as! UILabel
        let kickBtn = c.viewWithTag(2) as! UIButton
        serialLabel.text = self.serials[indexPath.row]
        kickBtn.addTarget(self, action: "kick:", forControlEvents: .TouchUpInside)
        return c
    }
    
    func kick(sender: UIButton!) {
        if (((sender.superview?.superview?.isKindOfClass(UITableViewCell))) != nil) {
            let indexPath = self.tableView.indexPathForCell(sender.superview?.superview as! UITableViewCell)
            NSLog("kick \(self.serials[indexPath!.row])")
            self.chat.kickUser(self.serials[indexPath!.row]) {code, message in
                if code != 200 {
                    NSLog("error kicking due to : \(message)")
                } else {
                    self.serials.removeAtIndex(indexPath!.row)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
}

extension ChatroomSettingVC: UITableViewDelegate {
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("select \(indexPath.row) row")
    }
}
