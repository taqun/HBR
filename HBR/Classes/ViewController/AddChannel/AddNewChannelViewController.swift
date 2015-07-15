//
//  AddNewChannelViewController.swift
//  HBR
//
//  Created by taqun on 2014/10/09.
//  Copyright (c) 2014年 envoixapp. All rights reserved.
//

import UIKit

class AddNewChannelViewController: UITableViewController, UITextFieldDelegate{
    
    @IBOutlet var btnDone: UIBarButtonItem!
    
    @IBOutlet var keywordTf: UITextField!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var bookmarkNumLabel: UILabel!
    
    var onComplete: (() -> (Void))!
    
    private var channelKeyword: String!
    private var channelType: ChannelType = ChannelType.Tag
    var bookmarkNum: Int = 3
    
    
    /*
     * Initialize
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigationbar
        btnDone.target = self
        btnDone.action = Selector("didDone")
        
        // tableview
        tableView.delegate = self
        tableView.dataSource = self
        
        keywordTf.delegate = self
        keywordTf.addTarget(self, action: Selector("textFieldEditingChanged"), forControlEvents: UIControlEvents.EditingChanged)
        
        segmentedControl.addTarget(self, action: Selector("segmentedControlValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    /*
     * Private Method
     */
    @objc private func didDone() {
        self.textFieldShouldReturn(self.keywordTf)
        
        if channelKeyword == nil || channelKeyword == "" {
            //self.onCancel()
        } else {
            var channel = ModelManager.sharedInstance.createChannel(ChannelType.Tag)
            channel.keyword = channelKeyword
            channel.type = channelType
            channel.bookmarkNum = bookmarkNum
            
            var context = channel.managedObjectContext
            context?.MR_saveOnlySelfWithCompletion(nil)
            
            self.onComplete()
        }
    }
    
    @objc private func segmentedControlValueChanged(control: UISegmentedControl) {
        switch control.selectedSegmentIndex {
            case 0:
                channelType = ChannelType.Tag
                break
            case 1:
                channelType = ChannelType.Title
                break
            case 2:
                channelType = ChannelType.Text
                break
            default:
                break
        }
    }
    
    @objc private func textFieldEditingChanged() {
        self.updateBtnDone()
    }
    
    private func updateBtnDone() {
        if count(self.keywordTf.text) == 0 {
            btnDone.enabled = false
        } else {
            btnDone.enabled = true
        }
    }
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "フィードを追加"
        
        if bookmarkNum == 1 {
            bookmarkNumLabel.text = String(bookmarkNum) + " user"
        } else {
            bookmarkNumLabel.text = String(bookmarkNum) + " users"
        }
        
        self.navigationItem.rightBarButtonItem = btnDone
        
        self.updateBtnDone()
        
        Logger.sharedInstance.track("AddNewChannelView")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    /*
    * UITableViewDataSource Protocol
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.indexAtPosition(0)
        let index = indexPath.indexAtPosition(1)
        
        if section == 1 && index == 1 {
            let storyBoard = UIStoryboard(name: "SelectBookmarkNumController", bundle: nil)
            let viewController = storyBoard.instantiateInitialViewController() as! SelectBookmarkNumController
            viewController.addNewChannelViewController = self
            viewController.selectBookmarkNum(self.bookmarkNum)
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    /*
     * UITableViewDelegate Protocol
     */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44;
    }
    
    
    /*
     * UITextFieldDelegate
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        keywordTf.resignFirstResponder()
        
        channelKeyword = keywordTf.text
        
        return true
    }
    
}
