//
//  ViewController.swift
//  tasks-on-bar
//
//  Created by Takayuki Nakayama on 2018/08/14.
//  Copyright © 2018年 Takayuki Nakayama. All rights reserved.
//

import Cocoa
import OAuth2

class ViewController: NSViewController{
    
    @IBOutlet weak var tableView: NSTableView!
    
    var tableViewData: [String] = [
        "Item 1", "Item 2", "Item 3", "Item 4", "Item 5",
        "Item 1", "Item 2", "Item 3", "Item 4", "Item 5",
        "Item 1", "Item 2", "Item 3", "Item 4", "Item 5",
        "Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self as? NSTableViewDelegate
        tableView.dataSource = self
        
        let loader = Tasks()
        loader.requestUserdata() { dict, error in
            if let error = error {
                switch error {
                    case OAuth2Error.requestCancelled: NSLog("Cancelled. Try Again.")
                    default: NSLog("Failed. Try Again.")
                }
            } else {
                self.tableViewData.removeAll();
                for item in (dict?["items"] as! NSArray) {
                    self.tableViewData.append((item as! Dictionary)["title"]!)
                }
                print(self.tableViewData,self.tableViewData.count)
                self.tableView?.reloadData()
            }
        }
    }
}

extension ViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return tableViewData[row]
    }
}
