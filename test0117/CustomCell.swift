import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var memoText: UILabel!
    
    var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //cellにデータを格納させるメソッド
    func setCell(index :Int,dir:String) {
        self.path = self.path + "/" + dir
        let imagePath:String = path + "/photo" + String(index) + ".jpg"
        let imageTest:UIImage = UIImage(contentsOfFile: imagePath)!
        let memoPath:String = path + "/memo" + String(index)
        var memoTest:String = ""
        let manager = NSFileManager()
        if manager.fileExistsAtPath(memoPath){
            try! memoTest = NSString(contentsOfFile: memoPath, encoding: NSUTF8StringEncoding) as String
        }
        self.photoImage.image = imageTest
        self.memoText.text = memoTest
    }
}
