import UIKit
import AVFoundation

class ViewController: UIViewController {

    // file操作をするNSFileManager
    // 録音したファイルをDocumentsディレクトリに保存
    // 端末のDocumentsディレクトリに保存された情報を再生画面で読み込む.
    let fileManager = NSFileManager()
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    let fileName = "sample.caf"
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAudioRecorder()
    }

    // 録音ボタンを押した時の挙動
    @IBAction func pushRecordButton(sender: AnyObject) {
        audioRecorder?.record()
    }
    
    // 再生ボタンを押した時の挙動
    @IBAction func pushPlayButton(sender: AnyObject) {
        self.play()
    }

    // 録音するために必要な設定を行う
    // viewDidLoad時に行う
    func setupAudioRecorder() {
        // 再生と録音機能をアクティブにする
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! session.setActive(true)
        let recordSetting : [String : AnyObject] = [
            AVEncoderAudioQualityKey : AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey : 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]
        do {
            try audioRecorder = AVAudioRecorder(URL: self.documentFilePath(), settings: recordSetting)
        } catch {
            print("初期設定でerror出たよ(-_-;)")
        }
    }
    // 再生
    func play() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: self.documentFilePath())
        } catch {
            print("再生時にerror出たよ(´・ω・｀)")
        }
        audioPlayer?.play()
        
    }
    // 録音するファイルのパスを取得(録音時、再生時に参照)
    // swift2からstringByAppendingPathComponentが使えなくなったので少し面倒
    func documentFilePath()-> NSURL {
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL]
        let dirURL = urls[0]
        return dirURL.URLByAppendingPathComponent(fileName)
    }
    
    
}

