//
//  DemoPhotoViewController.swift
//  YangMingShanDemo
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

class DemoPhotoViewController: UIViewController, YMSPhotoPickerViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    let cellIdentifier = "imageCellIdentifier"
    var images: NSArray! = []
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var numberOfPhotoSelectionTextField: UITextField!

    @IBAction func presentPhotoPicker(sender: AnyObject) {
        if self.numberOfPhotoSelectionTextField.text!.characters.count > 0
        && UInt(self.numberOfPhotoSelectionTextField.text!) != 1 {
            let pickerViewController = YMSPhotoPickerViewController.init()

            pickerViewController.numberOfPhotoToSelect = UInt(self.numberOfPhotoSelectionTextField.text!)!

            let customColor = UIColor.init(red: 64.0/255.0, green: 0.0, blue: 144.0/255.0, alpha: 1.0)
            let customCameraColor = UIColor.init(red: 86.0/255.0, green: 1.0/255.0, blue: 236.0/255.0, alpha: 1.0)

            pickerViewController.theme.titleLabelTextColor = UIColor.whiteColor()
            pickerViewController.theme.navigationBarBackgroundColor = customColor
            pickerViewController.theme.tintColor = UIColor.whiteColor()
            pickerViewController.theme.orderTintColor = customCameraColor
            pickerViewController.theme.orderLabelTextColor = UIColor.whiteColor()
            pickerViewController.theme.cameraVeilColor = customCameraColor
            pickerViewController.theme.cameraIconColor = UIColor.whiteColor()
            pickerViewController.theme.statusBarStyle = .LightContent

            self.yms_presentCustomAlbumPhotoView(pickerViewController, delegate: self)
        }
        else {
            self.yms_presentAlbumPhotoViewWithDelegate(self)
        }
    }
    
    func deletePhotoImage(sender: UIButton!) {
        let mutableImages: NSMutableArray! = NSMutableArray.init(array: images)
        mutableImages.removeObjectAtIndex(sender.tag)

        self.images = NSArray.init(array: mutableImages)
        self.collectionView.performBatchUpdates({ 
            self.collectionView.deleteItemsAtIndexPaths([NSIndexPath.init(forItem: sender.tag, inSection: 0)])
            }, completion: nil)
    }

    override func viewDidLoad() {
        let barButtonItem: UIBarButtonItem! = UIBarButtonItem.init(barButtonSystemItem: .Organize, target: self, action:#selector(presentPhotoPicker(_:)))
        self.navigationItem.rightBarButtonItem = barButtonItem

        self.collectionView.registerNib(UINib.init(nibName: "DemoImageViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
    }

    // MARK: - YMSPhotoPickerViewControllerDelegate

    func photoPickerViewControllerDidReceivePhotoAlbumAccessDenied(picker: YMSPhotoPickerViewController!) {
        let alertController = UIAlertController.init(title: "Allow photo album access?", message: "Need your permission to access photo albumbs", preferredStyle: .Alert)
        let dismissAction = UIAlertAction.init(title: "Cancel", style: .Cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: "Settings", style: .Default) { (action) in
            UIApplication.sharedApplication().openURL(NSURL.init(string: UIApplicationOpenSettingsURLString)!)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(settingsAction)

        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func photoPickerViewControllerDidReceiveCameraAccessDenied(picker: YMSPhotoPickerViewController!) {
        let alertController = UIAlertController.init(title: "Allow camera album access?", message: "Need your permission to take a photo", preferredStyle: .Alert)
        let dismissAction = UIAlertAction.init(title: "Cancel", style: .Cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: "Settings", style: .Default) { (action) in
            UIApplication.sharedApplication().openURL(NSURL.init(string: UIApplicationOpenSettingsURLString)!)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(settingsAction)

        // The access denied of camera is always happened on picker, present alert on it to follow the view hierarchy
        picker.presentViewController(alertController, animated: true, completion: nil)
    }

    func photoPickerViewController(picker: YMSPhotoPickerViewController!, didFinishPickingImage image: UIImage!) {
        picker.dismissViewControllerAnimated(true) {
            self.images = [image]
            self.collectionView.reloadData()
        }
    }

    func photoPickerViewController(picker: YMSPhotoPickerViewController!, didFinishPickingImages photoAssets: [PHAsset]!) {

        picker.dismissViewControllerAnimated(true) {
            let imageManager = PHImageManager.init()
            let options = PHImageRequestOptions.init()
            options.deliveryMode = .HighQualityFormat
            options.resizeMode = .Exact
            options.synchronous = true

            let mutableImages: NSMutableArray! = []

            for asset: PHAsset in photoAssets
            {
                let scale = UIScreen.mainScreen().scale
                let targetSize = CGSizeMake((CGRectGetWidth(self.collectionView.bounds) - 20*2) * scale, (CGRectGetHeight(self.collectionView.bounds) - 20*2) * scale)
                imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: options, resultHandler: { (image, info) in
                    mutableImages.addObject(image!)
                })
            }

            self.images = mutableImages.copy() as? NSArray
            self.collectionView.reloadData()
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: DemoImageViewCell! = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! DemoImageViewCell
        cell.photoImageView.image =  self.images.objectAtIndex(indexPath.item) as? UIImage
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(DemoPhotoViewController.deletePhotoImage(_:)), forControlEvents: .TouchUpInside)

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), CGRectGetHeight(collectionView.bounds))
    }

}

