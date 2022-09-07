**What is ZDMediaPicker ?**

A customised media picker, which acts exactly the same as native picker,  and is supported from iOS 11.0

**Key Features :**

- Handles access permissions internally
- Supports both landscape and portrait orientations
- Categorises images based on User Albums
- Pan gesture for multi Selection to get the experience of native Photos [iOS 13.0, *]
- Long Press Gesture for contextual menu support [iOS 13.0, *]

**How to install it?**

**Using cocoapods :**

> pod 'ZDMediaPickerSDK'



**How to use it?**

**For PhotoLibrary :** 
  ```
let picker = ZDMediaPicker(mediaPickerDelegate: self)
picker.presentPicker()
```


[Note : self should conform to ZDMediaPickerProtocol]

Get the selected media / handle the errors using the following methods:


    func mediaPicker(didFinishPicking media: [PHAsset]?) {
        print(media?.count as Any) // Get media selected from photoLibrary
    }
    
    func mediaPicker(didFailWith error: ZDMediaPickerError) {
        switch error {
        case .photosAccessDenied:
            self.showAlert(title: "Alert!", message: "Kindly allow access to photos and try again", actions: [.init(title: "OK", style: .cancel)], style: .alert)
        case .unableToSaveMedia(_):
            self.showAlert(title: "Alert!", message: "Error in saving media...", actions: [.init(title: "OK", style: .cancel)], style: .alert)
        default :
            break
        }
    }




**For Camera :** 

  ```
let picker = ZDMediaPicker(mediaPickerDelegate: self, sourceType: .camera)
 picker.presentPicker()
```


[Note : self should conform to ZDMediaPickerProtocol]

Get the captured info / handle the errors using the following methods:

    func mediaPicker(didFinishCapturing info: [UIImagePickerController.InfoKey : Any]) {
        print(info) // Get the camera captured info here
    }
    
    func mediaPicker(didFailWith error: ZDMediaPickerError) {
        switch error {
        case .cameraAccessDenied:
            self.showAlert(title: "Alert!", message: "Kindly allow access to camera and try again", actions: [.init(title: "OK", style: .cancel)], style: .alert)
        case .cameraSourceUnavailable:
            self.showAlert(title: "Alert!", message: "Seems like there is no device to capture", actions: [.init(title: "OK", style: .cancel)], style: .alert)
        default :
            break
        }
    }


**To use selection Limit :**

> var selectionLimit: Int = 5

Limit User's selection using the above variable and handle the error when selection limit exceeded as follows :

```
func mediaPicker(didFailWith error: ZDMediaPickerError) {
        switch error {
        case .selectionLimitExceeded:
            self.showAlert(title: "Alert!", message: "Maximum \(selectionLimit) photos please!", actions: [.init(title: "OK", style: .cancel)], style: .alert)
        default :
            break
        }
    }
```


**To use media types :**

> var mediaTypes: [String] = []
```
func setMediaTypes() {
        
        if #available(iOS 14.0, *) {
            mediaTypes = [UTType.image.identifier , UTType.movie.identifier]
        }
        else {
            mediaTypes = [kUTTypeMovie as String , kUTTypeImage as String]
        }
    }
```


To capture images and videos respectively

**To use preSelectedAssets :**

> var preSelectedAssets: [PHAsset]?

Declare the variable as above and use it as follows, to retain User's selection even after dismissing the picker

```
func mediaPicker(didFinishPicking media: [PHAsset]?) {
        // Get the media picked from the photo library here
        preSelectedAssets = media //To return the selected Assets back to ZDMediaPicker
        
    }
```

