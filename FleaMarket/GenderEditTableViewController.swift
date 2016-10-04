//
//  GenderEditTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 05/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MBProgressHUD

class GenderEditTableViewController: UITableViewController {
    var callback:String->Void = {_ in}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.title = "性别"
        self.tableView.alwaysBounceVertical = false
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel!.text = indexPath.row == 0 ? "男" : "女"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        if indexPath.row == 0{
            UserLoginHandler.instance.editDetailOfCurrentUser(gender: 1){
                success in
                hud.hideAnimated(true)
                if success{
                    self.callback("男")
                    self.navigationController?.popViewControllerAnimated(true)
                }else{
                    OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                }
            }
        }else{
            UserLoginHandler.instance.editDetailOfCurrentUser(gender: 0){
                success in
                hud.hideAnimated(true)
                if success{
                    self.callback("女")
                    self.navigationController?.popViewControllerAnimated(true)
                }else{
                    OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                }
            }
        }
    }
    


}
