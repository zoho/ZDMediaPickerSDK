//
//  ZDCameraPicker.swift
//  CustomMediaPicker
//
//  Created by lakshmi-12493 on 12/04/22.
//

import UIKit
import Photos

extension ZDMediaPicker : UIImagePickerControllerDelegate & UINavigationControllerDelegate , AVCaptureMetadataOutputObjectsDelegate {
    func checkAccessForCamera(){
        guard let mediaPickerDelegate = mediaPickerDelegate,  let topController = ZDMPUtility.topViewController() else {return}
        ZDCameraPicker.checkAccess { result in
            switch result {
            case .granted:
                DispatchQueue.main.async {
                    switch self.sourceType {
                    case .camera :
                        topController.present(self.cameraPicker, animated: true)
                    case .scanner :
                        topController.present(self.scanner, animated: true)
                    default:
                        break
                    }
                }
            case .denied:
                mediaPickerDelegate.mediaPicker(didFailWith: .cameraAccessDenied)
                
            case .sourceUnavailable:
                mediaPickerDelegate.mediaPicker(didFailWith: .cameraSourceUnavailable)
            }
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            self?.mediaPickerDelegate?.mediaPicker(didFinishCapturing: info)
            self?.cameraPicker.strongDelegate = nil
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        self.cameraPicker.strongDelegate = nil
    }
 
    
}

//For PhotoLibrary
extension ZDMediaPicker {
    
    func getZDMediaPickerVCs(with delegate : ZDMediaPickerInternalProtocol?, _ scannerDelegate : ZDScanFromPhotosProtocol?) -> (UIViewController, UIViewController) {
        let albums = ZDMPUtility.instantiateViewController(withIdentifier: ZDMPViewControllerId.albums) as! ZDMPAlbumsViewController
        albums.title = ZDMPVCTitles.albums
        albums.localDelegate = delegate
        albums.scannerDelegate = scannerDelegate
        let photos = ZDMPUtility.instantiateViewController(withIdentifier: ZDMPViewControllerId.gallery) as! ZDMPPhotosViewController
        photos.title = ZDMPVCTitles.gallery
        photos.localDelegate = delegate
        photos.scannerDelegate = scannerDelegate
        return (albums,photos)
    }
    
    func openPhotos(with delegate : ZDMediaPickerInternalProtocol? , _ scannerDelegate : ZDScanFromPhotosProtocol?){
        if let topController = ZDMPUtility.topViewController(){
            let vcs  = getZDMediaPickerVCs(with: delegate, scannerDelegate)
            let nav = UINavigationController(rootViewController: vcs.0)
            nav.pushViewController(vcs.1, animated: false)
            topController.present(nav, animated: true)
        }
    }
}

//For Scanner
extension ZDMediaPicker {
    func getScanner(with delegate : ZDMediaPickerInternalProtocol) -> ZDScannerViewController {
        let scanner = ZDMPUtility.instantiateViewController(withIdentifier: ZDMPViewControllerId.scanner) as! ZDScannerViewController
        scanner.localDelegate = delegate
        scanner.modalPresentationStyle = .overFullScreen
        return scanner
    }
}
