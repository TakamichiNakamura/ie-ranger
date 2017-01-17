//
//  TableViewController.swift
//  test0117
//
//  Created by 山下亮 on 2017/01/17.
//  Copyright © 2017年 山下亮. All rights reserved.
//

import UIKit



class Item{
    var title=""
    var link=""
}



class ListViewController:UITableViewController{
    
    var items=[Item]()
    var item:Item?
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text="@@月@@日@@:@@の記録"
        return cell
    }
    
    @IBAction func botan(sender: UIButton) {
        print("UIボタンのテスト")
    }
    
}