//
//  ZDMPPhotosViewController.swift
//  LImitedPhotosGallery
//
//  Created by lakshmi-12493 on 06/03/22.
//

import UIKit
import PhotosUI
import MobileCoreServices

class ZDMPPhotosViewController: UIViewController {
    
	var mediaPickerLocalDelegate : ZDMediaPickerInternalProtocol? = nil
    
    var album : PHAssetCollection? = nil
    var imageAssets = PHFetchResult<PHAsset>()
    var selectedAssets = [PHAsset]()
    var selectionLimit : Int = Int.max
    
    
    //To Track Pan Gestures
    var prevIndex : IndexPath? = nil
	var prevDirection : UIPanGestureRecognizer.Direction = .none
    var selectionMode : Bool = false
    var trackGesture : Bool = true
    
    
	lazy var pangesture: UIPanGestureRecognizer = {
		let gesture = UIPanGestureRecognizer(target: self, action: #selector(trackPanGesture(_:)))
		gesture.delegate = self
		return gesture
	}()
    
    lazy var cameraPicker: UIImagePickerController = {
        return ZDCameraPicker.getCameraPicker(delegate: self)
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = ZDMPFlowLayout()
        self.selectedAssets = mediaPickerLocalDelegate?.getLocallySelectedMedia() ?? []
        self.selectionLimit = mediaPickerLocalDelegate?.getSelectionLimit() ?? Int.max
        accessCheckForPhotoLibrary()
        settingBarButtonItems() //Setting items(camera,done button) on navigation bar
//        if !(mediaPickerLocalDelegate?.shouldDisablePanGestureForMultiSelection() ?? false) {
            collectionView.addGestureRecognizer(pangesture)
//        }
    }
    
    func settingBarButtonItems(){
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(selectionDone))
        let camera =  UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(openCamera))
        self.navigationItem.rightBarButtonItems = [done , camera]
    }
	
    @objc func selectionDone(){
		self.mediaPickerLocalDelegate?.mediaPicker(didFinishPickingMedia: selectedAssets, selectionComplete: true)
        self.dismiss(animated: true)
    }
	
    @objc func openCamera(){
        self.didExceedSelectionLimit() ? selectionLimitExceeded() : checkAccessForCamera()
    }
    func didExceedSelectionLimit() -> Bool {
        selectedAssets.count < selectionLimit ? false : true
    }
    deinit{
		self.mediaPickerLocalDelegate?.mediaPicker(didFinishPickingMedia: selectedAssets, selectionComplete: false)
    }

}

extension ZDMPPhotosViewController : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZDMPCellId.gallery, for: indexPath) as? ZDPhotoCell else {return UICollectionViewCell()}
        cell.configure(with: imageAssets[indexPath.row] , hideCheckMark: !assetIsSelected(at: indexPath))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       didTapItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfPhotosPerRow = self.view.getNumberofPhotosPerRow()
        let size = (collectionView.frame.size.width - numberOfPhotosPerRow - 1) / numberOfPhotosPerRow
        return CGSize(width: size , height: size)
    }
	
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        configureMenu(with: indexPath)
    }
    
	
}


