import UIKit
import AVFoundation

class ViewController: UIViewController {

    // file操作をするNSFileManager
    // 録音したファイルをDocumentsディレクトリに保存
    // 端末のDocumentsディレクトリに保存された情報を再生画面で読み込む.
    // 機能的に独立しているため,一つの案として，カメラと録音のアプリを独立させ，機能を起動させるボタンを押すと他のアプリケーションが起動する，というのはどうだろうか．
    // あるいは，実機のアプリケーション"写真"の中に入っている場合，そこから時間軸からノートの中に埋め込む
    let fileManager = FileManager()
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
    @IBAction func pushRecordButton(_ sender: AnyObject) {
        audioRecorder?.record()
    }
    
    // 再生ボタンを押した時の挙動
    @IBAction func pushPlayButton(_ sender: AnyObject) {
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
            AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue as AnyObject,
            AVEncoderBitRateKey : 16 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey: 44100.0 as AnyObject
        ]
        do {
            try audioRecorder = AVAudioRecorder(url: self.documentFilePath(), settings: recordSetting)
        } catch {
            print("初期設定でerror出たよ(-_-;)")
        }
    }
    // 再生
    func play() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: self.documentFilePath())
        } catch {
            print("再生時にerror出たよ(´・ω・｀)")
        }
        audioPlayer?.play()
        
    }
    // 録音するファイルのパスを取得(録音時、再生時に参照)
    // swift2からstringByAppendingPathComponentが使えなくなったので少し面倒
    func documentFilePath()-> URL {
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask) as [URL]
        let dirURL = urls[0]
        return dirURL.appendingPathComponent(fileName)
    }
    
    
}

