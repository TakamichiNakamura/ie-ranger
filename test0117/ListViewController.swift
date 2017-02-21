import UIKit
import Foundation

class Item{
    var title=""
    var link=""
}

class ListViewController:UITableViewController{
    
    var items=[Item]()
    var item:Item?
    
    //documentディレクトリのパス
    let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
    
    //ディレクトリ一覧
    var pathList:[String]=[]
    
    var refControl:UIRefreshControl!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //docment以下のディレクトリ一覧確認
        
        let manager = NSFileManager.defaultManager()
        //var itemList:[String]=[]
        do {
            print("pathは",path)
            self.pathList = try
                manager.contentsOfDirectoryAtPath(path)
            print ("success!")
            print("itemList->",self.pathList)
        } catch let error as NSError {
            print ("fail!")
        }
//        do {
//            let a = path + "/20170220204117"
//            print("aは",a)
//            self.pathList = try manager.contentsOfDirectoryAtPath(a)
//            print ("success!")
//            print("path/20170220204117は？ー＞",self.pathList)
//        } catch let error as NSError {
//            print ("fail!")
//        }
        self.refControl = UIRefreshControl()
        self.refControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        self.refControl.addTarget(self, action: #selector(ListViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func refresh()
    {
//        self.pathList = ["更新完了"]
        let manager = NSFileManager.defaultManager()
        do {
            print("pathは",path)
            self.pathList = try
                manager.contentsOfDirectoryAtPath(path)
            print ("success!")
            print("itemList->",self.pathList)
        } catch let error as NSError {
            print ("fail!")
        }
        self.tableView.reloadData()
        self.refControl?.endRefreshing()
    }
    
//    //itemViewControllerにタップされたセルの番号を渡す
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let a = self.tableView.indexPathForSelectedRow{
//            print("aは",a)
//            let b = segue.destinationViewController as! itemViewController
//            print("選ばれたセルは",self.pathList[a.row])
//            b.selectedDir = self.pathList[a.row]
//        }
//    }
    
    /*
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        /*
        let manager = NSFileManager.defaultManager()
        var itemList:[String]=[]
        do {
            itemList = try manager.contentsOfDirectoryAtPath(path)
            print ("success!")
            self.pathList = itemList
            /*
            print("itemList->",itemList)
            for path in itemList {
                print( path )
            }*/
        } catch let error as NSError {
            print ("fail!")
        }*/
    }
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pathList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text=pathList[indexPath.row]
        return cell
    }
}

