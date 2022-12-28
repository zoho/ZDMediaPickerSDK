//
//  ZPMediaPicker.swift
//  LImitedPhotosGallery
//
//  Created by lakshmi-12493 on 07/04/22.
//

import UIKit
import PhotosUI
import MobileCoreServices

public enum ZDMediaSource {
    case camera, photoLibrary, scanner
}

public class ZDMediaPicker : NSObject {
    
    private var assets : [PHAsset]? = nil
    private(set) var mediaPickerDelegate : ZDMediaPickerProtocol? = nil
    private(set) var sourceType : ZDMediaSource = .photoLibrary
    
    lazy var cameraPicker: ZDCameraPickerController = {
        return ZDCameraPicker.getCameraPicker(delegate: self, mediaTypes: mediaPickerDelegate?.mediaTypes, requireStrongReference: true) as! ZDCameraPickerController
    }()
    
    lazy var scanner : ZDScannerViewController = {
        return getScanner(with: self)
    }()
    
    public convenience init(mediaPickerDelegate : ZDMediaPickerProtocol? , sourceType : ZDMediaSource = .photoLibrary, shouldForceRTL : Bool = false) {
        self.init()
        self.mediaPickerDelegate = mediaPickerDelegate
        self.sourceType = sourceType
        self.assets = mediaPickerDelegate?.preSelectedAssets
        UIView.shouldForceRTL = shouldForceRTL
    }
    
    public func presentPicker(){
        switch sourceType{
        case .camera , .scanner :
            checkAccessForCamera()
        case .photoLibrary :
            openPhotos(with: self , nil)
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
    func openPhotoLibrary(with delegate : ZDMediaPickerInternalProtocol?, _ scannerDelegate: ZDScanFromPhotosProtocol?) {
        openPhotos(with: delegate , scannerDelegate)
    }
    func mediaPicker(didFinishScanning info: [AVMetadataObject]) {
        mediaPickerDelegate?.mediaPicker(didFinishScanning: info)
    }
    
}


// External Delegate Functions

public protocol ZDMediaPickerProtocol : (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
    var selectionLimit: Int { get }
    var mediaTypes : [String] { get }
    var preSelectedAssets : [PHAsset]? { get }
    func mediaPicker(didFinishPicking media : [PHAsset]?)
    func mediaPicker(didFinishCapturing info: [UIImagePickerController.InfoKey : Any])
    func mediaPicker(didFailWith error : ZDMediaPickerError)
    func mediaPicker(didFinishScanning info: [AVMetadataObject])
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
    func mediaPicker(didFinishScanning info: [AVMetadataObject]){
        
    }
    
}

public enum ZDMediaPickerError : Error {
    case selectionLimitExceeded
    case cameraAccessDenied
    case photosAccessDenied
    case cameraSourceUnavailable
    case unableToSaveMedia(Error)
    case unableToScan
    case unableToFlash
}
