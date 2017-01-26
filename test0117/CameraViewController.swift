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
    
    // AVキャプチャアウトプット（音声）
    // var audioAvOutoput: AVCaptureAudioFileOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 画面タップで撮影
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.takePhoto(_:)))
        tapGesture.delegate = self;
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.initCamera()
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
    
    // 画面になにか重ねて表示する
    func renderView() {
        
        // 角丸なLabelを作成
        let labelHello: UILabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.size.width - 40, 40))
        labelHello.layer.masksToBounds = true
        labelHello.layer.cornerRadius = 5.0
        
        labelHello.lineBreakMode = NSLineBreakMode.ByCharWrapping
        labelHello.numberOfLines = 1
        
        // 文字と文字色、背景色をセット
        labelHello.text = "画面タップで撮影&アルバム保存"
        labelHello.textColor = UIColor.whiteColor()
        labelHello.backgroundColor = UIColor.init(colorLiteralRed: 0.8, green: 0.2, blue: 0.3, alpha: 1.0)
        
        // 文字を中央寄せ、ウィンドウ中央に配置
        labelHello.textAlignment = NSTextAlignment.Center
        labelHello.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height - 80)
        
        // ViewにLabelを追加.
        self.view.addSubview(labelHello)
    }
    
    
    // 撮影をする
    func takePhoto(sender: UITapGestureRecognizer){
        
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
            
            self.close()
        })
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
        // self.audioAvOutoput = nil
        self.avInput = nil
        self.avDevice = nil
        self.avSession = nil
    }
    
}
