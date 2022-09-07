//
//  CameraAccessCheck.swift
//  CustomMediaPicker
//
//  Created by lakshmi-12493 on 13/04/22.
//

import Foundation
import PhotosUI
import MobileCoreServices

class ZDImagePickerController: UIImagePickerController {
    var strongDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? {
        didSet {
            self.delegate = strongDelegate
        }
    }
}
struct ZDCameraPicker{
    enum ZDMediaAccessCheck {
        case granted
        case denied
        case sourceUnavailable
    }
    static func checkAccess(_ handler : @escaping ((ZDMediaAccessCheck)->())){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if (authStatus == .authorized){
                handler(.granted)
            }
            else{
                AVCaptureDevice.requestAccess(for: .video) { permission in
                    permission ? handler(.granted) : handler(.denied)
                }
            }
        }
        else {
            handler(.sourceUnavailable)
        }
    }
    static func getCameraPicker(delegate : (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? , mediaTypes : [String]? = [kUTTypeMovie as String , kUTTypeImage as String], requireStrongReference : Bool = false) -> UIImagePickerController{
        let picker = ZDImagePickerController()
        requireStrongReference ? (picker.strongDelegate = delegate): (picker.delegate = delegate)
        picker.sourceType = .camera
        if var mediaTypes = mediaTypes, let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .camera){
            mediaTypes.removeAll { mediaType in
                !availableMediaTypes.contains(mediaType)
            }
            if !mediaTypes.isEmpty{
                picker.mediaTypes = mediaTypes
            }
        }
        return picker
    }
    
}
