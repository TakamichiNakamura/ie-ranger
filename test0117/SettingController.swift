import Foundation
import UIKit

class SettingController:UITableViewController{
    
    var koumoku:[String] = ["[未実装]自動記録終了する？するなら何分？","[未実装]どれくらいの感覚で記録する？(単位:秒)","[未実装]カメラの画質は？","などなど"]
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return koumoku.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = koumoku[indexPath.row]
        return cell
    }
    var refControl:UIRefreshControl!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.refControl = UIRefreshControl()
        self.refControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        self.refControl.addTarget(self, action: #selector(SettingController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refControl)
    }
    
    func refresh()
    {
        self.koumoku = ["更新完了"]
        self.tableView.reloadData()
        self.refControl?.endRefreshing()
    }
}
