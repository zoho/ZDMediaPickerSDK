//
//  GalleryVCExtension.swift
//  CustomMediaPicker
//
//  Created by lakshmi-12493 on 12/04/22.
//

import Foundation
import PhotosUI
import MobileCoreServices

//For Photo Access in Image Picker
extension ZDMPPhotosViewController  {
    
    func accessCheckForPhotoLibrary(){
        if #available(iOS 14, *){
            accessCheckAfteriOS14()
        }
        else{
            accessCheckBeforeiOS14()
        }
    }
    
    @available(iOS 14, *)
    fileprivate func accessCheckAfteriOS14(){
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if(status == PHAuthorizationStatus.authorized || status == PHAuthorizationStatus.limited){
            self.populateData()
        }
        else{
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: ({ [weak self] newStatus in
                guard let self = self else {return}
                (newStatus == PHAuthorizationStatus.authorized || newStatus == PHAuthorizationStatus.limited) ? self.populateData() : self.accessDenied()
            }))
        }
    }
    
    fileprivate func accessCheckBeforeiOS14(){
        let status = PHPhotoLibrary.authorizationStatus()
        if(status == PHAuthorizationStatus.authorized){
            self.populateData()
        }
        else{
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                guard let self = self else { return }
                newStatus == PHAuthorizationStatus.authorized ? self.populateData() : self.accessDenied()
            }
        }
    }
    
    
    
    fileprivate func populateData(){
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            self.fetchAssets()
            self.collectionView.reloadData()
        }
    }
    fileprivate func accessDenied(){
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
        self.localDelegate?.mediaPicker(didFail: .photosAccessDenied)
    }
    
    fileprivate func fetchAssets() {
        if self.album ==  nil {
            self.imageAssets = self.scannerDelegate == nil ? ZDAssets.getAsset() : ZDAssets.getAsset(with: .image)
        }
        else {
            self.imageAssets = self.scannerDelegate == nil ? ZDAssets.getAsset(from: self.album) : ZDAssets.getAsset(from: self.album, with: .image)
        }
    }
    
}


//For Camera Access and using captured Image
extension ZDMPPhotosViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func checkAccessForCamera(){
        ZDCameraPicker.checkAccess { result in
            switch result {
            case .granted:
                DispatchQueue.main.async {[weak self] in
                    guard let self = self else {return}
                    self.present(self.cameraPicker, animated: true)
                }
                
            case .denied:
                self.localDelegate?.mediaPicker(didFail: .cameraAccessDenied)

            case .sourceUnavailable:
                self.localDelegate?.mediaPicker(didFail: .cameraSourceUnavailable)

            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage{
            self.collectionView.setContentOffset(.zero, animated: true)
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        else if (info[.mediaType] as? String) == kUTTypeMovie as String {
            self.collectionView.setContentOffset(.zero, animated: true)
            if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
               UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path){
                UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    // Saving captured Image
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        saveMedia(with: error)
    }
    
    // Saving captured video
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        saveMedia(with: error)
    }
    
    fileprivate func saveMedia(with error : Error?){
        if let error = error {
            self.localDelegate?.mediaPicker(didFail: .unableToSaveMedia(error))
        } else {
            fetchAssets()
            if let capturedMedia = imageAssets.firstObject {
                selectedAssets.insert(capturedMedia, at: 0)
            }
            DispatchQueue.main.async {
                self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            }
        }
    }
    
}


//Track Pan Gesture
extension ZDMPPhotosViewController : UIGestureRecognizerDelegate{

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {return false}
        let velocity = panGesture.velocity(in: collectionView)
        //To Begin with horizontal selection
        return abs(velocity.x) > abs(velocity.y)
    }



    @objc func trackPanGesture(_ gesture : UIPanGestureRecognizer){

        switch(gesture.state){
            
        
        case .began:
            let location = gesture.location(in: collectionView)
            if let startIndex = collectionView.indexPathForItem(at: location ){
                trackGesture = true
                selectionMode = !assetIsSelected(at: startIndex)
                if selectionMode  &&  didExceedSelectionLimit(){
                    selectionLimitExceeded()
                    trackGesture = false
                }
                else {
                    didTapItem(at: startIndex)
                }
                prevIndex = startIndex
                prevDirection = gesture.directionCurrent
            }
        case .changed:
            let location = gesture.location(in: collectionView)
            let windowLocation = gesture.location(in: view)
            
            // Select items on gesture change
            if let currentIndex = collectionView.indexPathForItem(at: location) , let startIndex = prevIndex{
                if prevIndex != currentIndex{
                    makeSelection(upto: currentIndex.item - startIndex.item)
                    prevIndex = currentIndex
                }
            }
            
            // Scroll Down on reaching bottom of the screen
            if (windowLocation.y > (0.75 * view.frame.height)){
                if (gesture.directionCurrent == .left || gesture.directionCurrent == .right) {
                    if prevDirection != .down{
                        return
                    }
                }
                prevDirection = gesture.directionCurrent
                if !didExceedSelectionLimit(){
                    collectionView.scrollView(with: .down)
                }
            }
            
            // Scroll up on reaching top of the screen
            if (windowLocation.y < (0.25 * view.frame.height)){
                if (gesture.directionCurrent == .left || gesture.directionCurrent == .right) {
                    if prevDirection != .up{
                        return
                    }
                }
                prevDirection = gesture.directionCurrent
                if !didExceedSelectionLimit() {
                    collectionView.scrollView(with: .up)
                }
            }
            
        case .ended:
            prevIndex = nil
            prevDirection = .none
        
        case .possible, .cancelled, .failed :
            break
        
        @unknown default:
            break
        }
        
    }
    
    func makeSelection(upto count : Int){
        guard let start = prevIndex else {return}
        let itemCount = (count > 0) ? count : abs(count)
        for item in 0 ..< itemCount {
            let indexPath = (count > 0) ? IndexPath(item: start.item + item + 1, section: start.section) : IndexPath(item: start.item - item - 1, section: start.section)
            if selectionMode {
                if (!assetIsSelected(at: indexPath) && !didExceedSelectionLimit()){
                    didTapItem(at: indexPath)
                }
                else if trackGesture && didExceedSelectionLimit() && !assetIsSelected(at: indexPath){
                    selectionLimitExceeded()
                    trackGesture = false
                }
            }
            else {
                assetIsSelected(at: indexPath) ? didTapItem(at: indexPath) : nil
            }
        }
    }
    
    func didTapItem(at indexPath : IndexPath){
        guard let cell = collectionView.cellForItem(at: indexPath) as? ZDPhotoCell else {return}
        if assetIsSelected(at: indexPath){
            if let index = selectedAssets.firstIndex(of: imageAssets[indexPath.row]){
                selectedAssets.remove(at: index)
                DispatchQueue.main.async {
                    cell.ImageView.alpha = (cell.ImageView.alpha == 1) ? 0.9 : 1
                    cell.checkMark.isHidden = !cell.checkMark.isHidden
                    cell.durationLabel?.isHidden = !cell.checkMark.isHidden
                }
            }
        }
        else {
            if didExceedSelectionLimit() {
                selectionLimitExceeded()
            }
            else {
                selectedAssets.append(imageAssets[indexPath.row])
                DispatchQueue.main.async {
                    cell.ImageView.alpha = (cell.ImageView.alpha == 1) ? 0.9 : 1
                    cell.checkMark.isHidden = !cell.checkMark.isHidden
                    cell.durationLabel?.isHidden = !cell.checkMark.isHidden
                }
            }
        }
    }
    
    func didSelectQR(at indexpath : IndexPath) {
        self.dismiss(animated: true) {
            self.localDelegate?.mediaPicker(didFinishPickingMedia: [self.imageAssets[indexpath.row]], selectionComplete: true)
        }
    }
    
    func selectionLimitExceeded(){
        self.localDelegate?.mediaPicker(didFail: .selectionLimitExceeded)
    }
    
    func assetIsSelected(at indexPath : IndexPath) -> Bool{
        selectedAssets.contains(imageAssets[indexPath.row])
    }
}

//For Image Preview
extension ZDMPPhotosViewController {
    
    @available(iOS 13.0, *)
    func configureMenu(with indexPath : IndexPath) -> UIContextMenuConfiguration? {
        let asset = imageAssets[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil) {
            self.makePreview(with: asset)
        } actionProvider: { [weak self] actions in
            guard let self = self else {return nil}
            let selectAction = UIAction(title: ZDMPPreviewMenuActions.select) { action in
                self.didTapItem(at: indexPath)
            }
            let unselectAction = UIAction(title: ZDMPPreviewMenuActions.deselect) { action in
                self.didTapItem(at: indexPath)
            }
            let cancelAction = UIAction(title: ZDMPPreviewMenuActions.cancel,
                     attributes: .destructive) { action in
            }
            
            return self.assetIsSelected(at: indexPath) ? UIMenu(children: [unselectAction, cancelAction]) : UIMenu(children: [selectAction, cancelAction])
        }
    }

    func makePreview(with asset : PHAsset) -> UIViewController {
        let previewController = UIViewController()
        if asset.mediaType == .video{
            previewController.videoPreview(with: asset)
        }
        else if asset.mediaSubtypes.contains(.photoLive){
            previewController.livePhotoPreview(with: asset)
        }
        else {
            previewController.imagePreview(with: asset)
        }
        return previewController
    }
    
}
