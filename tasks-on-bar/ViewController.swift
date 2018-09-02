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
    @IBOutlet weak var tableView2: NSTableView!
    
    var taskLists: NSArray = []
    var tasks: NSArray = []
    var tasksLoader : Tasks = Tasks()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tag = 1
        tableView2.tag = 2
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView2.delegate = self
        tableView2.dataSource = self
        
        reloadTaskLists();
        
    }
    
    
    func reloadTaskLists(){
        tasksLoader.requestTaskLists() { dict, error in
            if let error = error {
                self.handleRequestError(error: error)
                return
            }
            self.taskLists = (dict?["items"] as! NSArray)
            self.tableView?.reloadData()
        }
    }
    
    func reloadTasks(){
        guard (tableView.selectedRow >= 0) else {
            self.tasks = []
            return
        }
        let tasklistId : String = (self.taskLists[tableView.selectedRow] as! Dictionary)["id"]!
        tasksLoader.requestTasks(tasklistId: tasklistId) { dict, error in
            if let error = error {
                self.handleRequestError(error: error)
                return
            }
            if let tasks = dict?["items"] as? NSArray {
                self.tasks = tasks
            }else{
                self.tasks = []
            }
            self.tableView2.reloadData()
        }
    }
    
    func handleRequestError(error: Error){
        switch error {
            case OAuth2Error.requestCancelled: NSLog("Cancelled. Try Again.")
            default: NSLog("Failed. Try Again.")
        }
        print(error)
    }
    
    func getArrayByTag(_ tag: Int) -> NSArray{
        if(tag == 1) { return taskLists }
        return tasks
    }
}

extension ViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return getArrayByTag(tableView.tag).count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return (getArrayByTag(tableView.tag)[row] as! Dictionary)["title"]
    }
}

extension ViewController: NSTableViewDelegate{
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if let myTable = notification.object as? NSTableView {
            if(myTable.tag != 1){ return; }
            reloadTasks();
        }
        
    }
}


