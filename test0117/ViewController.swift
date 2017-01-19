//
//  ViewController.swift
//  test0117
//
//  Created by maruyamamotoki on 2017/01/19.
//  Copyright © 2017年 山下亮. All rights reserved.
//
import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func reccoding(sender: AnyObject) {
        
        
        var actionSheet = UIAlertController(title: "選択してください", message: nil, preferredStyle: .ActionSheet)
        
        func handler(act:UIAlertAction!) {
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.allowsEditing = true
            picker.delegate = self
            
            picker.cameraDevice = UIImagePickerControllerCameraDevice.Rear
            
            if(act.title == "写真撮影"){
                picker.mediaTypes = [kUTTypeImage as String]
                picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
                
            }
            else{
                picker.mediaTypes = [kUTTypeMovie as String]
                picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Video
                
                picker.videoQuality = UIImagePickerControllerQualityType.TypeHigh
                
                picker.videoMaximumDuration = 300
            }
            
            
            
            
            
            
            
            
            
            picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
            
        }
        actionSheet.addAction(UIAlertAction(title: "写真撮影", style: .Default, handler: handler))
        actionSheet.addAction(UIAlertAction(title: "動画撮影", style: .Default, handler: handler))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
