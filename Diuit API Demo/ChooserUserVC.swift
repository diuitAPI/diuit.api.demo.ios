//
//  ChooserUserVC.swift
//  Diuit API Demo
//
//  Created by Pofat Diuit on 2015/12/24.
//  Copyright © 2015年 Diuit. All rights reserved.
//

import UIKit
import DUMessaging

class ChooserUserVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var joinButton: UIBarButtonItem!
    
    private var doJoinRoom: Bool = false
    private let userDict: NSDictionary = [
        "demouser1":"demouser1",
        "demouser2":"demouser2",
        "demouser3":"demouser3"]
    private var filteredDict: NSMutableDictionary?
    /* XXX: 10 is a demo chat id, you should replace with your id */
    private let roomDict: [String:Int] = ["join me":10]
    private var selected: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        filteredDict = NSMutableDictionary(dictionary: userDict)
        filteredDict!.removeObjectForKey((DUMessaging.currentUser?.serial)!)

        self.tableView.allowsMultipleSelection = true
        self.tableView.reloadData()
    }
    
    @IBAction func join() {
        if self.doJoinRoom {
            /* XXX: 10 is a demo chat id, you should replace with your id */
            let chatId:Int = 10
            DUMessaging.joinChatroomWithId(chatId) {error, chat in
                if error != nil {
                    NSLog("error joining chat: \(error!.localizedDescription)")
                    return
                }
                self.navigationController?.popViewControllerAnimated(true)
            }
        } else {
            if selected.count != 0 {
                DUMessaging.createChatroomWith(selected) {error, chat in
                    if error != nil {
                        NSLog("error creating chat: \(error!.localizedDescription)")
                        return
                    }
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }
}

extension ChooserUserVC: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (self.filteredDict != nil) ? (self.filteredDict?.count)! : 0
        } else {
            return self.roomDict.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("cell")!
        let keys = self.filteredDict?.allKeys
        if indexPath.section == 0 {
            c.textLabel!.text = self.filteredDict?.valueForKey(keys![indexPath.row] as! String) as? String
            if ((selected.indexOf((c.textLabel!.text)!)) != nil) {
                c.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                c.accessoryType = UITableViewCellAccessoryType.None
            }
        } else {
            c.textLabel!.text = "join me"
            if ((selected.indexOf((c.textLabel!.text)!)) != nil) {
                c.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                c.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        return c
    }
}

extension ChooserUserVC: UITableViewDelegate {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Create chat with friends"
        } else {
            return "Join other room"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            self.joinButton.title = "Create Chat"
            self.doJoinRoom = false
            let roomIndex = selected.indexOf("join me")
            if roomIndex != nil {
                selected.removeAtIndex(roomIndex!)
            }

            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            if let index = selected.indexOf((cell?.textLabel!.text)!) {
                selected.removeAtIndex(index)
            } else {
                selected.append((cell?.textLabel!.text)!)
            }
        } else {
            self.joinButton.title = "Join Chat"
            self.doJoinRoom = true
            selected.removeAll()
            selected.append("join me")
        }
        self.tableView.reloadData()
    }
}

