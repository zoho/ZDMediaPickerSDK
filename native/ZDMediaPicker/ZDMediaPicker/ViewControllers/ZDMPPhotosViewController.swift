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
    
	var localDelegate : ZDMediaPickerInternalProtocol? = nil
    var scannerDelegate : ZDScanFromPhotosProtocol? = nil
    
    var album : PHAssetCollection? = nil
    var imageAssets = PHFetchResult<PHAsset>()
    var selectedAssets = [PHAsset](){
        didSet {
            oldValue.isEmpty || selectedAssets.isEmpty ? settingBarButtonItems() : nil
        }
    }
    var selectionLimit : Int = Int.max
    
    
    //To Track Pan Gestures
    var prevIndex : IndexPath? = nil
	var prevDirection : UIPanGestureRecognizer.Direction = .none
    var selectionMode : Bool = false
    var trackGesture : Bool = true // To avoid unlimited callbacks to selectionLimitExceeded error
    
    
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
        self.view.accessibilityIdentifier = ZDMPViewControllerId.gallery
        self.selectedAssets = localDelegate?.getLocallySelectedMedia() ?? []
        self.selectionLimit = localDelegate?.getSelectionLimit() ?? Int.max
        accessCheckForPhotoLibrary()
        settingBarButtonItems() //Setting items(camera,done button) on navigation bar
        !isFromScanner ? collectionView.addGestureRecognizer(pangesture) : nil
    }
    override func viewDidLayoutSubviews() {
        if #available(iOS 16.0, *){ //iOS 16 view frame width issue fix
            self.view.observeIfOrientationChanged {
                self.collectionView.reloadData()
            }
        }
    }
    
    func settingBarButtonItems(){
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(selectionDone))
        let camera =  UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(openCamera))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(selectionDone))
        let barButtonItems = selectedAssets.isEmpty ? [cancel , camera] : [done , camera]
        self.navigationItem.rightBarButtonItems = !isFromScanner ? barButtonItems : []
    }
	
    @objc func selectionDone(){
        self.dismiss(animated: true) {
            self.localDelegate?.mediaPicker(didFinishPickingMedia: self.selectedAssets, selectionComplete: true)
        }
    }
	
    @objc func openCamera(){
        self.didExceedSelectionLimit() ? selectionLimitExceeded() : checkAccessForCamera()
    }
    func didExceedSelectionLimit() -> Bool {
        selectedAssets.count < selectionLimit ? false : true
    }
    deinit{
		self.localDelegate?.mediaPicker(didFinishPickingMedia: selectedAssets, selectionComplete: false)
        self.scannerDelegate?.didPopFromPhotos()
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
        !isFromScanner ? didTapItem(at: indexPath) : didSelectQR(at: indexPath)
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
