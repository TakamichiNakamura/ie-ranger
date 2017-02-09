//
//  ViewController.swift
//  test0117
//
//  Created by maruyamamotoki on 2017/01/19.
//  Copyright © 2017年 山下亮. All rights reserved.
//
import UIKit
import AVFoundation

class CameraViewController: UIViewController, UIGestureRecognizerDelegate {
    
  // AVキャプチャセッション
  var avSession: AVCaptureSession!
  // AVキャプチャデバイス
  var avDevice: AVCaptureDevice!
  // AVキャプチャデバイスインプット
  var avInput: AVCaptureInput!
  // AVキャプチャアウトプット
  var photoAvOutput: AVCaptureStillImageOutput!

  // 録音機能
  let fileManager = NSFileManager()
  var audioRecorder: AVAudioRecorder?
  let fileName = "sample.caf"
  
  //ボタンを押した時
  func onClickMyButton(sender: UIButton) {
    
    // 録音開始
    audioRecorder?.record()

    // ビデオ出力に接続する
    let videoConnection = photoAvOutput.connectionWithMediaType(AVMediaTypeVideo)
    
    // 接続から画像を取得する
    self.photoAvOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataBuffer, error) -> Void in
      
      // Jpegに変換する (NSDataにはExifなどのメタデータも含まれている)
      let imageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
      
      // UIIMageを作成する
      let image: UIImage = UIImage(data: imageData)!
      
      // アルバムに追加する
      UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
      
      // 録音終了
      self.audioRecorder?.stop()
      
      self.close()
  })
}
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
    // 画面遷移した時呼ばれる
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.initCamera()
        self.setupAudioRecorder()
    }
  
  //録音の初期化
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
  
  //カメラの初期化
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
            
            // UIボタンを作成
            let myButton = UIButton(frame: CGRectMake(0,0,120,50))
            myButton.backgroundColor = UIColor.redColor();
            myButton.layer.masksToBounds = true
            myButton.setTitle("撮影", forState: .Normal)
            myButton.layer.cornerRadius = 20.0
            myButton.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height-50)
            myButton.addTarget(self, action: #selector(CameraViewController.onClickMyButton(_:)), forControlEvents: .TouchUpInside)
            
            // UIボタンをViewに追加.
            self.view.addSubview(myButton);
            
            
            
          }
            
      } else {
            
          // UIAlertControllerを作成する.
          let sampleAlert: UIAlertController = UIAlertController(title: "", message: "背面カメラがある実機で動かしてね。", preferredStyle: .Alert)
            
          // アクションを作成、追加
          let yesAction = UIAlertAction(title: "OK", style: .Default) {
              UIAlertAction in
              self.close()
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
  
  // 録音するファイルのパスを取得(録音時、再生時に参照)
  func documentFilePath()-> NSURL {
    let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL]
    let dirURL = urls[0]
    return dirURL.URLByAppendingPathComponent(fileName)!
  }
  
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // カメラの停止とメモリ解放
        self.avSession.stopRunning()
        
        for output in self.avSession.outputs {
            self.avSession.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in self.avSession.inputs {
            self.avSession.removeInput(input as? AVCaptureInput)
        }
        
        self.photoAvOutput = nil
        self.avInput = nil
        self.avDevice = nil
        self.avSession = nil
    }
    
}
