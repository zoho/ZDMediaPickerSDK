//
//  ViewController.swift
//  DemoApp_ZDMediaPicker
//
//  Created by lakshmi-12493 on 15/04/22.
//

import UIKit
import ZDMediaPicker
import PhotosUI

class ViewController: UIViewController, ZDMediaPickerProtocol {
   
    var selectionLimit: Int = 30
    
    
    @IBAction func openCameraPicker(_ sender: UIButton) {
        let picker = ZDMediaPicker(mediaPickerDelegate: self, sourceType: .camera)
        picker.presentPicker()
    }
    
    @IBAction func openMediaPicker(_ sender: UIButton) {
        let picker = ZDMediaPicker(mediaPickerDelegate: self)
        picker.presentPicker()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


}

extension ViewController {
    
    func mediaPicker(didFinishPicking media: [PHAsset]?) {
        if let media = media {
            showActionSheet(message: "\(media.count) media picked from photoLibrary")
        }
    }
    
    func mediaPicker(didFinishCapturing image: UIImage?, _ video: AVAsset?) {
        if let image = image {
            showActionSheet(message: "Image captured with size \(image.size)")
        }
        else if let video = video {
            showActionSheet(message: "Video captured for duration  \(video.duration.timeFormatted())")
        }
    }
    func showActionSheet(message : String ){
        let actionSheet = UIAlertController(title: "Info from Media Picker",
                                      message: message,
                                      preferredStyle: UIAlertController.Style.actionSheet)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        actionSheet.addAction(okAction)
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            self.present(actionSheet, animated: true)
        }
    }
    
}

extension CMTime{

    func timeFormatted() -> String {
        let seconds: Int = lround(CMTimeGetSeconds(self))
        var hour: Int = 0
        var minute: Int = Int(seconds/60)
        let second: Int = seconds % 60
        if minute > 59 {
            hour = minute / 60
            minute = minute % 60
            return String(format: "%d:%d:%02d", hour, minute, second)
        } else {
            return String(format: "%d:%02d", minute, second)
        }
    }
}

