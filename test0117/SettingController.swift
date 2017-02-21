import Foundation
import UIKit

class SettingController:UITableViewController{
    
    var koumoku:[String] = ["自動記録終了する？するなら何分？","どれくらいの感覚で記録する？(単位:秒)","カメラの画質は？","動画も撮るのか","講演者の喋りを自動書き起こしをするか","録音もするか","撮影をするか","カメラを無音で撮るか","アルバムappにも保存するか","などなど"]
    
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
