import Foundation
import UIKit
import AVFoundation

class detailViewController:UIViewController{
    @IBOutlet weak var previewImage: UIImageView!
    
    //前の画面から渡されたindexの値を用いて画像を表示する
    var imageIndex:Int!
    var dir:String!
    
    var path:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
    
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.path = path + "/" + dir
        let a:String = self.path + "/photo/" + String(imageIndex) + ".jpg"
        let b:UIImage = UIImage(contentsOfFile: a)!
        
        self.previewImage.image = b
        let soundIndex:Double = Double(imageIndex)
        self.play(soundIndex)
        

        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.audioPlayer?.stop()
    }
    
    func setupAudioRecorder() {
        // 再生と録音機能をアクティブにする
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)
        //        let recordSetting : [String : AnyObject] = [
        //            AVEncoderAudioQualityKey : AVAudioQuality.Min.rawValue,
        //            AVEncoderBitRateKey : 16,
        //            AVNumberOfChannelsKey: 2,
        //            AVSampleRateKey: 44100.0
        //        ]
        //        do {
        //            try audioRecorder = AVAudioRecorder(URL: self.documentFilePath(), settings: recordSetting)
        //        } catch {
        //            print("初期設定でerror出た")
        //        }
    }
    // 再生
    func play(soundDelay:Double) {
        do {
            let a = self.path + "/audio.caf"
            let b = NSURL(fileURLWithPath: a)
            try self.audioPlayer = AVAudioPlayer(contentsOfURL:b)
        } catch {
            print("再生時にerror出た")
        }
        let a = (audioPlayer?.deviceCurrentTime)! - soundDelay * 5
        audioPlayer?.playAtTime(a)
    }
}
