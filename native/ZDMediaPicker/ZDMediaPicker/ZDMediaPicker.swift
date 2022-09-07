//
//  ZPMediaPicker.swift
//  LImitedPhotosGallery
//
//  Created by lakshmi-12493 on 07/04/22.
//

import UIKit
import PhotosUI
import MobileCoreServices

public class ZDMediaPicker : NSObject {
    
    private var assets : [PHAsset]? = nil
    private(set) var mediaPickerDelegate : ZDMediaPickerProtocol? = nil
    private(set) var sourceType : UIImagePickerController.SourceType = .photoLibrary
    
    lazy var cameraPicker: ZDImagePickerController = {
        return ZDCameraPicker.getCameraPicker(delegate: self, mediaTypes: mediaPickerDelegate?.mediaTypes, requireStrongReference: true) as! ZDImagePickerController
    }()
    
    public convenience init(mediaPickerDelegate : ZDMediaPickerProtocol? , sourceType : UIImagePickerController.SourceType = .photoLibrary) {
        self.init()
        self.mediaPickerDelegate = mediaPickerDelegate
        self.sourceType = sourceType
        self.assets = mediaPickerDelegate?.preSelectedAssets
    }
    
    public func presentPicker(){
        switch sourceType{
        case .camera :
            checkAccessForCamera()
        case .photoLibrary, .savedPhotosAlbum :
            openPhotos()
        @unknown default:
            break
        }
    }
   
}

// Internal Delegate Functions
extension ZDMediaPicker : ZDMediaPickerInternalProtocol{
    
    func mediaPicker(didFail error: ZDMediaPickerError) {
        self.mediaPickerDelegate?.mediaPicker(didFailWith: error)
    }
    func getSelectionLimit() -> Int? {
        self.mediaPickerDelegate?.selectionLimit
    }
    
    func getLocallySelectedMedia() -> [PHAsset]? {
        return self.assets
    }
    func mediaPicker(didFinishPickingMedia media: [PHAsset]?, selectionComplete: Bool) {
        if selectionComplete{
            mediaPickerDelegate?.mediaPicker(didFinishPicking: media)
            return
        }
        if let media = media {
            self.assets = media
        }
    }
//    func shouldDisablePanGestureForMultiSelection() -> Bool {
//        self.mediaPickerDelegate?.shouldDisablePanForMultiSelection ?? false
//    }
    
}


// External Delegate Functions

public protocol ZDMediaPickerProtocol : (UIImagePickerControllerDelegate & UINavigationControllerDelegate){
    var selectionLimit: Int { get }
    var mediaTypes : [String] { get }
    var preSelectedAssets : [PHAsset]? { get }
//    var shouldDisablePanForMultiSelection : Bool {get}
    func mediaPicker(didFinishPicking media : [PHAsset]?)
    func mediaPicker(didFinishCapturing info: [UIImagePickerController.InfoKey : Any])
    func mediaPicker(didFailWith error : ZDMediaPickerError)
}
public extension ZDMediaPickerProtocol{

    var selectionLimit: Int {
        Int.max
    }
    var mediaTypes : [String] {
        [kUTTypeMovie as String , kUTTypeImage as String]
    }
    var preSelectedAssets : [PHAsset]? {
        nil
    }
    func mediaPicker(didFinishPicking media : [PHAsset]?){
        
    }
    func mediaPicker(didFinishCapturing info: [UIImagePickerController.InfoKey : Any]){
       
    }
    func mediaPicker(didFailWith error : ZDMediaPickerError){
        
    }
    
}

public enum ZDMediaPickerError : Error {
    case selectionLimitExceeded
    case cameraAccessDenied
    case photosAccessDenied
    case cameraSourceUnavailable
    case unableToSaveMedia(Error)
}
extension ZDMediaPickerError : LocalizedError {
    
    public var errorDescription: String? {
        switch self {
            
        case .selectionLimitExceeded:
            return "Exceeded the given selection limit "
        case .cameraAccessDenied:
            return "Unable to access the Camera. To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app. "
        case .photosAccessDenied:
            return "Unable to access Photos. To enable access, go to Settings > Privacy > Photos and turn on Photos access for this app. "
        case .cameraSourceUnavailable:
            return "Unable to access the Camera. Seems like the device is not supported to access camera."
        default :
            return self.localizedDescription
        
        }
    }
}
