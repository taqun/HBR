//
//  SelectChannelTypeViewController.swift
//  HBR
//
//  Created by taqun on 2015/06/14.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit

class SelectChannelTypeViewController: UITableViewController {
    
    @IBOutlet var btnCancel: UIBarButtonItem!
    
    var onCancel: (() -> (Void))!
    var onComplete: (() -> (Void))!
    
    
    /*
     * Initialize
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnCancel.target = self
        btnCancel.action = Selector("didCancel")
        
        let backBtn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBtn
    }
    
    
    /*
     * Private Method
     */
    @objc private func didCancel() {
        self.onCancel()
    }
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "フィードタイプ選択"
        
        self.navigationItem.leftBarButtonItem = btnCancel
    }
    
    
    /*
     * UITableViewDataSource Protocol
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var index = indexPath.row
        
        switch index {
            case 0:
                let storyBoard = UIStoryboard(name: "SelectCategoryViewController", bundle: nil)
                let selectCategoryViewController = storyBoard.instantiateInitialViewController() as! SelectCategoryViewController
                selectCategoryViewController.channelType = ChannelType.Hot
                selectCategoryViewController.onComplete = onComplete
                self.navigationController?.pushViewController(selectCategoryViewController, animated: true)
                
                break
            case 1:
                let storyBoard = UIStoryboard(name: "SelectCategoryViewController", bundle: nil)
                let selectCategoryViewController = storyBoard.instantiateInitialViewController() as! SelectCategoryViewController
                selectCategoryViewController.channelType = ChannelType.New
                selectCategoryViewController.onComplete = onComplete
                self.navigationController?.pushViewController(selectCategoryViewController, animated: true)
                
                break
            case 2:
                let storyBoard = UIStoryboard(name: "AddNewChannelViewController", bundle: nil)
                let addNewChannelViewController = storyBoard.instantiateInitialViewController() as! AddNewChannelViewController
                addNewChannelViewController.onComplete = onComplete
                self.navigationController?.pushViewController(addNewChannelViewController, animated: true)
                
                break
            default:
                break
        }
    }

}
