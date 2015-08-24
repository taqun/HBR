//
//  SelectCategoryViewController.swift
//  HBR
//
//  Created by taqun on 2015/06/14.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit
import CoreData

class SelectCategoryViewController: UITableViewController {
    
    @IBOutlet var btnDone: UIBarButtonItem!
    
    var channelType: ChannelType!
    var category: HatenaCategory!
    
    var onComplete: (() -> (Void))!
    
    
    /*
     * Initialize
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnDone.target = self
        btnDone.action = Selector("didDone")
    }
    
    
    /*
     * Private Method
     */
    @objc private func didDone() {
        var channel = ModelManager.sharedInstance.createChannel()
        channel.type = self.channelType
        channel.category = self.category
        
        let context = channel.managedObjectContext
        CoreDataManager.sharedInstance.saveContext()
        
        self.onComplete()
    }
    
    
    /*
     * UIViewController Method
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "カテゴリー選択"
        
        self.category = HatenaCategory.All
        
        self.navigationItem.rightBarButtonItem = btnDone
    }
    
    
    /*
     * UITableView Delegate
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let visibleCells = tableView.visibleCells() as? [UITableViewCell] {
            for cell in visibleCells {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        self.category = HBRHatena.Categories[indexPath.row]
    }

}
