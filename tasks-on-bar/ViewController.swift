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
    
    var taskLists:[TaskList] = []
    var tasks:[Task] = []
    var tasksLoader : TasksApi = TasksApi()
    
    @IBAction func plusTaskList(_ sender: NSButton) {
        addTasklist(title:"test")
    }
    
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
        tasksLoader.getTaskLists() { result in
            switch(result){
            case .success(let taskListGroups):
                self.taskLists = taskListGroups.items ?? []
                self.tableView.reloadData()
            case .failure(let error):
                self.handleRequestError(error: error)
            }
        }
    }
    
    func reloadTasks(){
        guard (tableView.selectedRow >= 0) else {
            self.tasks = []
            return
        }
        let tasklistId : String = self.taskLists[tableView.selectedRow].id
        tasksLoader.getTasks(tasklistId: tasklistId) { result in
            switch(result){
            case .success(let taskGroups):
                self.tasks = taskGroups.items ?? []
                self.tableView2.reloadData()
            case .failure(let error):
                self.handleRequestError(error: error)
            }
        }
    }
    
    func addTasklist(title: String){
        tasksLoader.addTaskList(title: title) { result in
            switch(result){
            case .success(_):
                self.reloadTaskLists()
            case .failure(let error):
                self.handleRequestError(error: error)
            }
        }
    }
    
    func handleRequestError(error: Error){
        switch error {
            case OAuth2Error.requestCancelled: NSLog("Cancelled. Try Again.")
            default: NSLog("Failed. Try Again.")
        }
        print(error)
    }
    
    func getArrayByTag(_ tag: Int) -> [ Any ] {
        if(tag == 1) { return taskLists }
        return tasks
    }
}

extension ViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return getArrayByTag(tableView.tag).count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if(tableView.tag == 1) { return taskLists[row].title }
        return tasks[row].title
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


