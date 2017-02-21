import UIKit
import AVFoundation
import Foundation

class CameraViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    // AVキャプチャセッション
    var avSession: AVCaptureSession!
    
    // AVキャプチャデバイス
    var avDevice: AVCaptureDevice!
    
    // AVキャプチャデバイスインプット
    var avInput: AVCaptureInput!
    
    // AVキャプチャアウトプット
    var photoAvOutput: AVCaptureStillImageOutput!
    
    // AVキャプチャアウトプット（音声）
    // var audioAvOutoput: AVCaptureAudioFileOutput!
    
    //録音用
    let fileManager = NSFileManager()
    var audioRecorder: AVAudioRecorder?
    
    //timer使って一定の間隔で撮影し続けるようにする
    var timer:NSTimer!
    //データを保存するためのdocumentフォルダのパス取得
    let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
    var madePath:String!
    
    //撮影された画像のインデックス用
    var photoCount:Int=0
    
    private var myTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //document以下に日時をタイトルとしたディレクトリ作成
        let now = NSDate() // 現在日時の取得
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
        dateFormatter.dateFormat = "yyyyMMddHHmmss" // 日付フォーマットの設定
        self.madePath = self.path + "/" + dateFormatter.stringFromDate(now)
        try! self.fileManager.createDirectoryAtPath(madePath ,withIntermediateDirectories: true, attributes: nil)
        let photoPath:String! = self.madePath + "/photo"
        try! self.fileManager.createDirectoryAtPath(photoPath ,withIntermediateDirectories: true, attributes: nil)
        
        // 画面タップで撮影
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.tapPhoto(_:)))
        tapGesture.delegate = self;
        self.view.addGestureRecognizer(tapGesture)
        
        self.setupAudioRecorder()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.initCamera()
        audioRecorder?.record()
        //これで一定間隔でメソッドを実行
        self.timer = NSTimer.scheduledTimerWithTimeInterval(5.0,target: self,selector:#selector(self.loopPhoto),userInfo: nil,repeats:true)//とりあえず5秒間隔でリピート
        
        // UITextFieldを作成する.
        myTextField = UITextField(frame: CGRectMake(0,0,200,30))
        
        // 表示する文字を代入する.
        myTextField.text = "Hello Swift!!"
        
        // Delegateを設定する.
        myTextField.delegate = self
        
        // 枠を表示する.
        myTextField.borderStyle = UITextBorderStyle.RoundedRect
        
        // UITextFieldの表示する位置を設定する.
        myTextField.layer.position = CGPoint(x:self.view.bounds.width/2,y:100);
        
        // Viewに追加する.
        self.view.addSubview(myTextField)
    }
    
    func initCamera() {
        
        // AVキャプチャセッション
        // (AVFoundationにおけるキャプチャ入出力を管理するクラス)
        avSession = AVCaptureSession()
        
        if (avSession.canSetSessionPreset(AVCaptureSessionPresetPhoto)) {
            avSession.beginConfiguration()
            
            // キャプチャクオリティ設定
            // AVCaptureSessionPresetPhoto    写真専用、デバイスの最大解像度
            // AVCaptureSessionPresetHigh     最高録画品質 (静止画でも一番高画質なのはコレ)
            // AVCaptureSessionPresetMedium   WiFi向け
            // AVCaptureSessionPresetLow      3G向け
            // AVCaptureSessionPreset640x480  640x480 VGA固定
            // AVCaptureSessionPreset1280x720 1280x720 HD固定
            avSession.sessionPreset = AVCaptureSessionPresetPhoto
            
            avSession.commitConfiguration()
        }
        
        // AVキャプチャデバイス
        // (前背面カメラやマイク等のデバイス)
        let devices = AVCaptureDevice.devices()
        for capDevice in devices {
            if (capDevice.position == AVCaptureDevicePosition.Back) {
                // 背面カメラを取得
                avDevice = capDevice as? AVCaptureDevice
            }
        }
        
        if (avDevice != nil) {
            
            // AVキャプチャデバイスインプット
            // (AVキャプチャデバイスからの入力)
            do {
                // バックカメラからVideoInputを取得
                avInput = try AVCaptureDeviceInput.init(device: avDevice!)
            } catch let error as NSError {
                print(error)
            }
            
            // AVキャプチャデバイスインプットをセッションに追加
            if (avSession.canAddInput(avInput)) {
                
                avSession.addInput(avInput)
                
                // AVキャプチャアウトプット (出力方法)
                // AVCaptureStillImageOutput: 静止画
                // AVCaptureMovieFileOutput: 動画ファイル
                // AVCaptureAudioFileOutput: 音声ファイル
                // AVCaptureVideoDataOutput: 動画フレームデータ
                // AVCaptureAudioDataOutput: 音声データ
                
                // audioAvOutput = AVCaptureAudioFileOutput()
                
                photoAvOutput = AVCaptureStillImageOutput()
                
                // 出力設定
                photoAvOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                
                // AVキャプチャアウトプットをセッションに追加
                if (avSession.canAddOutput(photoAvOutput)) {
                    avSession.addOutput(photoAvOutput)
                }
                
                // 画像を表示するレイヤーを生成.
                let capVideoLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session:avSession)
                capVideoLayer.frame = self.view.bounds
                capVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                // AVLayerVideoGravityResizeAspectFill
                //      アスペクト比維持 + 必要に応じてトリミング (縦いっぱいに表示し横をトリミング)
                
                // AVLayerVideoGravityResizeAspect
                //      アスペクト比維持 (縦横とも収まる様に表示)
                
                // AVLayerVideoGravityResize
                //      利用可能な画面領域いっぱいにリサイズ
                
                
                // Viewに追加.
                self.view.layer.addSublayer(capVideoLayer)
                
                // セッション開始.
                avSession.startRunning()
                
                renderView()
                
            }
            
        } else {
            
            // UIAlertControllerを作成する.
            let sampleAlert: UIAlertController = UIAlertController(title: "", message: "背面カメラがある実機で動かしてね。", preferredStyle: .Alert)
            
            // アクションを作成、追加
            let yesAction = UIAlertAction(title: "OK", style: .Default) {
                UIAlertAction in
                //                self.close()
            }
            sampleAlert.addAction(yesAction)
            
            // UIAlertを表示する
            self.presentViewController(sampleAlert, animated: true, completion: nil)
        }
    }
    
    // 画面を閉じる
    func close() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // 画面になにか重ねて表示する
    func renderView() {
        
        // 角丸なLabelを作成
        let labelHello: UILabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.size.width - 40, 40))
        labelHello.layer.masksToBounds = true
        labelHello.layer.cornerRadius = 5.0
        
        labelHello.lineBreakMode = NSLineBreakMode.ByCharWrapping
        labelHello.numberOfLines = 1
        
        // 文字と文字色、背景色をセット
        labelHello.text = "5秒loop,tap撮影,10枚で自動終了"
        labelHello.textColor = UIColor.whiteColor()
        labelHello.backgroundColor = UIColor.init(colorLiteralRed: 0.8, green: 0.2, blue: 0.3, alpha: 1.0)
        
        // 文字を中央寄せ、ウィンドウ中央に配置
        labelHello.textAlignment = NSTextAlignment.Center
        labelHello.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height - 80)
        
        // ViewにLabelを追加.
        self.view.addSubview(labelHello)
    }
    
    
    // タップした時撮影をする
    func tapPhoto(sender: UITapGestureRecognizer){
        
        // ビデオ出力に接続する
        let videoConnection = photoAvOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        // 接続から画像を取得する
        self.photoAvOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataBuffer, error) -> Void in
            
            // Jpegに変換する (NSDataにはExifなどのメタデータも含まれている)
            let imageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
            
            var savePath:String!
            savePath = self.madePath + "/photo/" + String(self.photoCount) + ".jpg"
            
            guard imageData.writeToFile(savePath, atomically: true) else{
                print("画像保存失敗？")
                return
            }
            
            //            self.close()
            
            self.photoCount += 1
            print(String(self.photoCount),"<-photoCountです。")
            
        })
    }
    //定期撮影用メソッド
    func loopPhoto(){
        
        // ビデオ出力に接続する
        let videoConnection = photoAvOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        // 接続から画像を取得する
        self.photoAvOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataBuffer, error) -> Void in
            
            // Jpegに変換する (NSDataにはExifなどのメタデータも含まれている)
            let imageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
            
            var savePath:String!
            savePath = self.madePath + "/photo/" + String(self.photoCount) + ".jpg"
            
            guard imageData.writeToFile(savePath, atomically: true) else{
                print("画像保存失敗？")
                return
            }
            
            self.photoCount += 1
            print(String(self.photoCount),"<-photoCountです。")
            
        })
        
        
        //とりあえず10枚以上撮影したら戻る
        if self.photoCount >= 10 {
//            timer.invalidate()
            self.close()
//            
//            //            self.dismissViewControllerAnimated(true, completion: nil)
//            let storyboard: UIStoryboard = self.storyboard!
//            //            let nextView = storyboard.instantiateViewControllerWithIdentifier("itiran") as! ListViewController
//            let nextView = storyboard.instantiateViewControllerWithIdentifier("testdesu")
//            self.presentViewController(nextView, animated: true, completion: nil)
        }
    }
    
    
    //以下音声関係
    
    // 録音するために必要な設定を行う
    // viewDidLoad時に行う
    func setupAudioRecorder() {
        // 再生と録音機能をアクティブにする
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch  {
            // エラー処理
            fatalError("カテゴリ設定失敗")
        }
        //        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        do {
            try session.setActive(true)
        } catch {
            // audio session有効化失敗時の処理
            // (ここではエラーとして停止している）
            fatalError("session有効化失敗")
        }
        //        try! session.setActive(true)
        let recordSetting : [String : AnyObject] = [
            AVEncoderAudioQualityKey : AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey : 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]
        do {
            let a:String = madePath + "/audio.caf"
            print("以下のように音声を保存->",a)
            let b = NSURL(fileURLWithPath: a)
            try audioRecorder = AVAudioRecorder(URL: b, settings: recordSetting)
        } catch {
            print("初期設定でerror出た")
        }
    }
    
    
    
    
    override func viewDidDisappear(animated: Bool) {
        timer.invalidate()
        super.viewDidDisappear(animated)
        
        audioRecorder?.stop()
        
        // カメラの停止とメモリ解放
        self.avSession.stopRunning()
        
        for output in self.avSession.outputs {
            self.avSession.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in self.avSession.inputs {
            self.avSession.removeInput(input as? AVCaptureInput)
        }
        
        self.photoAvOutput = nil
        // self.audioAvOutoput = nil
        self.avInput = nil
        self.avDevice = nil
        self.avSession = nil
    }
    
    
    /*
     UITextFieldが編集された直後に呼ばれるデリゲートメソッド.
     */
    func textFieldDidBeginEditing(textField: UITextField){
        print("textFieldDidBeginEditing:" + textField.text!)
    }
    
    /*
     UITextFieldが編集終了する直前に呼ばれるデリゲートメソッド.
     */
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing:" + textField.text!)
        
        return true
    }
    
    /*
     改行ボタンが押された際に呼ばれるデリゲートメソッド.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let memo = textField.text!.dataUsingEncoding(NSUTF8StringEncoding)
        let memoPath:String! = self.madePath + "/memo" + String(self.photoCount)
        
        memo?.writeToFile(memoPath, atomically: true)
        
        textField.resignFirstResponder()
        
        textField.text = ""
        
        return true
    }
    
    
}


