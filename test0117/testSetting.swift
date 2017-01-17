//
//  testSetting.swift
//  test0117
//
//  Created by 山下亮 on 2017/01/17.
//  Copyright © 2017年 山下亮. All rights reserved.
//

import Foundation
import UIKit

class testSetting:UITableViewController{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("testSet", forIndexPath: indexPath)
        cell.textLabel!.text="ここに設定項目が入ります"
        return cell
    }
}