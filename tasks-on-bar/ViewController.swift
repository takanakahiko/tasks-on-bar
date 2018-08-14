//
//  ViewController.swift
//  tasks-on-bar
//
//  Created by Takayuki Nakayama on 2018/08/14.
//  Copyright © 2018年 Takayuki Nakayama. All rights reserved.
//

import Cocoa

class ViewController: NSViewController{
    
    var tableViewData: [String] = [
        "Item 1", "Item 2", "Item 3", "Item 4", "Item 5",
        "Item 1", "Item 2", "Item 3", "Item 4", "Item 5",
        "Item 1", "Item 2", "Item 3", "Item 4", "Item 5",
        "Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        
        let tableView = NSTableView()
        tableView.delegate = self as? NSTableViewDelegate
        tableView.dataSource = self
        
        let tableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("column"))
        tableColumn.width = displayWidth
        tableView.addTableColumn(tableColumn)
        
        let scrollContentView = NSClipView()
        scrollContentView.documentView = tableView
        
        let scrollView = NSScrollView(frame: NSRect(x: 50, y: 50, width: displayWidth - 100, height: displayHeight - 100))
        scrollView.contentView = scrollContentView
        
        self.view.addSubview(scrollView)
    }
}

extension ViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return NSCell(textCell: tableViewData[row])
    }
}
