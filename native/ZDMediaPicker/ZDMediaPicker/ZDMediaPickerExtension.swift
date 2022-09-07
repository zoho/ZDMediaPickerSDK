//
//  ZDCameraPicker.swift
//  CustomMediaPicker
//
//  Created by lakshmi-12493 on 12/04/22.
//

import Foundation
import Photos

extension ZDMediaPicker : UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    func checkAccessForCamera(){
        guard let mediaPickerDelegate = mediaPickerDelegate,  let topController = ZDMPUtility.topViewController() else {return}
        ZDCameraPicker.checkAccess { result in
            switch result {
            case .granted:
                DispatchQueue.main.async {
                    topController.present(self.cameraPicker, animated: true)
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
    
    func getZDMediaPickerVCs() -> (UIViewController, UIViewController) {
        let albums = ZDMPUtility.instantiateViewController(withIdentifier: ZDMPViewControllerId.albums) as! ZDMPAlbumsViewController
        albums.title = ZDMPVCTitles.albums
        albums.mediaPickerLocalDelegate = self
        let photos = ZDMPUtility.instantiateViewController(withIdentifier: ZDMPViewControllerId.gallery) as! ZDMPPhotosViewController
        photos.title = ZDMPVCTitles.gallery
        photos.mediaPickerLocalDelegate = self
        return (albums,photos)
    }
    
    func openPhotos(){
        if let topController = ZDMPUtility.topViewController(){
            let vcs  = getZDMediaPickerVCs()
            let nav = UINavigationController(rootViewController: vcs.0)
            nav.pushViewController(vcs.1, animated: false)
            topController.present(nav, animated: true)
        }
    }
}

