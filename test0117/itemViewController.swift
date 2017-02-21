import UIKit

class itemViewController:UIViewController,UITableViewDelegate, UITableViewDataSource{
    
    var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
    
    @IBOutlet weak var itemList: UITableView!
    
    var selectedDir:String!="20170220204117"
    var madePath:String!// = path + "/" + selectedDir
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         tableView.delegate = self
         tableView.dataSource = self
         */
        
        madePath = path + "/" + selectedDir
        
        //ファイル一覧を確認
        let manager = NSFileManager.defaultManager()
        
        var itemList:[String]=[]
        do {
            itemList = try manager.contentsOfDirectoryAtPath(madePath)
            print ("success!")
            for path in itemList {
                print( path )
            }
        } catch let error as NSError {
            print ("fail!")
        }
    }
    
    
    //次の画面にテーブルのindexの値を渡す
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let a = self.itemList.indexPathForSelectedRow{
            let b = segue.destinationViewController as! detailViewController
            
            b.imageIndex = a.row
            b.dir = selectedDir
            
        }
    }
    
    // セクション数
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // セクションの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    //tableview。カスタムセルに画像を表示
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        let cell: CustomCell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath) as! CustomCell
        //        print("indexPathは",indexPath.row,"です")
        cell.setCell(indexPath.row,dir:selectedDir)
        
        return cell
    }
}
