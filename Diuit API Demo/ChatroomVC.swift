//
//  ChatroomVC.swift
//  Diuit API Demo
//
//  Created by David Lin on 12/6/15.
//  Copyright © 2015 Diuit. All rights reserved.
//

import UIKit
import SDWebImage
import TTTAttributedLabel
import DUMessaging

class ChatroomVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textfield: UITextField!
    
    private var messages: [DUMessage] = []
    private var refreshCompleteRecord:[String] = [String]()
    
    var chat: DUChat!
    // MARK: private helper
    func JSONParseDictionary(string: String) -> [String: AnyObject]{
        
        
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding){
            
            do{
                if let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject]{
                    
                    return dictionary
                    
                }
            }catch {
                
                print("error")
            }
        }
        return [String: AnyObject]()
    }
    // MARK: UI Events
    @IBAction func doSendTextMessage() {
        if chat == nil || textfield.text?.characters.count == 0 {
            return
        }

        if textfield.text == "send file1" {
            let path = NSBundle.mainBundle().pathForResource("sampleFile1", ofType: "pdf")
            self.chat.sendFileWithPath(path!, meta: ["name":"sampleFile1.pdf"]) { code, message in
                if code != 200 {
                    let alert = UIAlertController(title: "Info", message: message as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    NSLog("file message 1 sent")
                }
            }
            textfield.text? = ""
            return
        }

        if textfield.text == "send file2" {
            let path = NSBundle.mainBundle().pathForResource("sampleFile2", ofType: "pdf")
            self.chat.sendFileWithPath(path!, meta: ["name":"sampleFile2.pdf"]) { code, message in
                if code != 200 {
                    let alert = UIAlertController(title: "Info", message: message as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    NSLog("file message 2 sent")
                }
            }
            textfield.text? = ""
            return
        }
        
        self.chat.sendText(self.textfield.text!) { code, message in
            if code != 200 {
                let alert = UIAlertController(title: "Info", message: message as? String, preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                NSLog("text message sent")
            }
        }
        textfield.text? = ""
    }

    @IBAction func readFromAlbum(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            NSLog("Read album error!")
        }
    }

    // MARK: UIImagePicker Delegate
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            NSLog(String(info))
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            picker.dismissViewControllerAnimated(true, completion: {
                () -> Void in
            })
            self.chat.sendImage(image) { code, message in
                if code != 200 {
                    let alert = UIAlertController(title: "Info", message: message as? String, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    NSLog("image message sent")
                }
            }
            
    }

    // MARK: Life Cycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let chatId = self.chat?.id {
            NSNotificationCenter.defaultCenter().addObserverForName("messageReceived.\(chatId)", object: nil, queue: NSOperationQueue.mainQueue()) { notif in
                let message = notif.userInfo!["message"] as! DUMessage
                NSLog("Got new message: \(message.id)")
                self.messages.insert(message, atIndex: 0)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic);
                if message.mime == "application/diuit-chat-sys-message" {
                    // show alert when kicked
                    let json = self.JSONParseDictionary(message.data!)
                    if let userSerial = json["userId"] as? String {
                        if userSerial == DUMessaging.currentUser?.serial {
                            let alert = UIAlertController(title: "Ohoh!", message: "You are asked to leave here", preferredStyle: .Alert);
                            alert.addAction(UIAlertAction(title: "Got it", style: .Default) { action in
                                self.navigationController?.popViewControllerAnimated(true)
                                })
                            self.presentViewController(alert, animated: true, completion: nil);
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.allowsSelection = false
        NSLog("Chat is \(chat)")
        
        self.chat.listMessagesBefore() { code, messages in
            NSLog("Exited, \(messages)")
            if code != 200 {
                NSLog("Failed to list messages")
                return
            }
            self.messages = messages as! [DUMessage]
            self.tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(ChatroomSettingVC) {
            let vc = segue.destinationViewController as! ChatroomSettingVC
            vc.chat = chat
        }
    }
}

extension ChatroomVC: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let isRightCell:Bool
        let c: UITableViewCell!
        let message = messages[indexPath.row]
        if message.senderUser?.serial == DUMessaging.currentUser!.serial {
            let cellIdentifier: String
            if message.mime == "image/jpeg" {
                cellIdentifier = "rightChatImageCell"
            } else {
                cellIdentifier = "rightChatTextCell"
            }
            c = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
            isRightCell = true
        } else {
            let cellIdentifier: String
            if message.mime == "image/jpeg" {
                cellIdentifier = "leftChatImageCell"
            } else {
                cellIdentifier = "leftChatTextCell"
            }
            c = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
            isRightCell = false
        }
        c.prepareForReuse()
        
        let avatarImageView = c.viewWithTag(1) as! UIImageView
        avatarImageView.backgroundColor = UIColor.grayColor()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width/2
        avatarImageView.clipsToBounds = true;
        if message.senderUser?.serial == "demouser1" {
            avatarImageView.image = UIImage(named: "avatar1")
        } else if message.senderUser?.serial == "demouser2" {
            avatarImageView.image = UIImage(named: "avatar2")
        } else {
            avatarImageView.image = UIImage(named: "avatar3")
        }
        //avatarImageView.image = (isRightCell) ? UIImage(named: "avatar1") : UIImage(named: "avatar2")
        
        let bubbleTextLabel = c.viewWithTag(2) as? TTTAttributedLabel
        
        let timestampLabel = c.viewWithTag(3) as! UILabel
        let whoSaysTextLabel = c.viewWithTag(4) as? UILabel
        let thumbImageView = c.viewWithTag(6) as? UIImageView
        
        if message.mime == "text/plain" {
            bubbleTextLabel!.superview?.layer.cornerRadius = 4
            bubbleTextLabel!.text = message.data
        } else if message.mime == "application/diuit-chat-sys-message" {
            bubbleTextLabel!.superview?.layer.cornerRadius = 4
            whoSaysTextLabel?.text = "System Message:"
            avatarImageView.image = UIImage(named: "system-avatar")
            bubbleTextLabel!.text = message.data!
        } else if message.mime == "image/jpeg" {
            let url = NSURL(string: message.data!)
            thumbImageView!.superview?.layer.cornerRadius = 4
            thumbImageView!.sd_setImageWithURL(url!, placeholderImage: nil, completed: { (image: UIImage?, error: NSError?, cacheType: SDImageCacheType!, imageURL: NSURL?) in
                let newHeight = Float((image?.size.height)! * 193 / (image?.size.width)!)
                let pref: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                pref.setObject(NSNumber(float: newHeight), forKey:String(url!))
                pref.synchronize()

                if self.refreshCompleteRecord.contains(String(message.id)) {
                    NSLog("image in message:\(message.id) has already been refreshed, so pass")
                } else {
                    self.tableView.reloadData()
                    self.refreshCompleteRecord.append(String(message.id))
                }
            })
        } else if message.mime == "application/octet-stream" {
            bubbleTextLabel!.superview?.layer.cornerRadius = 4
            bubbleTextLabel!.delegate = self
            if let fileName = message.meta?["name"] as? NSString {
                bubbleTextLabel!.text = "File:\(fileName)"
                let r = NSMakeRange(5, fileName.length)
                bubbleTextLabel!.addLinkToURL(NSURL(string: message.data!), withRange: r)
            } else {
                bubbleTextLabel!.text = "This is a file"
                let r = NSMakeRange(10, "file".length)
                bubbleTextLabel!.addLinkToURL(NSURL(string: message.data!), withRange: r)
            }
        }
        let sdf = NSDateFormatter()
        sdf.timeStyle = .ShortStyle
        timestampLabel.text = sdf.stringFromDate(message.createdAt!)

        if let name = message.senderUser?.serial! {
            whoSaysTextLabel?.text = "'\(name)' says:"
        }

        return c
    }
}

extension ChatroomVC: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        if message.mime == "image/jpeg" {
            let url = message.data
            let height = NSUserDefaults.standardUserDefaults().objectForKey(url!)?.floatValue
            return (height <= 1) ? CGFloat(44) : CGFloat(height!)
        } else {
            return UITableViewAutomaticDimension
        }
    }
}

extension ChatroomVC: TTTAttributedLabelDelegate {
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        UIApplication.sharedApplication().openURL(url)
    }
}
