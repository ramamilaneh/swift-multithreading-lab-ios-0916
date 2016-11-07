//
//  ImageViewController.swift
//  swift-multithreading-lab
//
//  Created by Ian Rahman on 7/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit
import CoreImage


//MARK: Image View Controller

class ImageViewController : UIViewController {
    
    var scrollView: UIScrollView!
    var imageView = UIImageView()
    let picker = UIImagePickerController()
    var activityIndicator = UIActivityIndicatorView()
    let filtersToApply = ["CIBloom",
                          "CIPhotoEffectProcess",
                          "CIExposureAdjust"]
    
    var flatigram = Flatigram()
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var chooseImageButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        setUpViews()
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        selectImage()
    }
    
    @IBAction func filterButtonTapped(_ sender: AnyObject) {
        if self.flatigram.state == .unfiltered {
            self.startProcess()
        }else{
            self.presentFilteredAlert()
        }
    }
    
}

extension ImageViewController {
    func filterImage(with completion:@escaping((Bool) -> Void)) {
        let queue = OperationQueue()
        queue.name = "Image Filtration Queue"
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        for filter in filtersToApply {
            let filterer = FilterOperation(flatigram: self.flatigram, filter: filter)
            filterer.completionBlock = {
                if queue.operationCount == 0 {
                    DispatchQueue.main.async {
                        self.flatigram.state = .filtered
                        completion(true)
                    }
                    
                }
                if filterer.isCancelled {
                    completion(false)
                    return
                }
            }
            queue.addOperation(filterer)
            print("Added FilterOperation with \(filter) to \(queue.name!)")
        }
    }
}

extension ImageViewController {
    
    func startProcess() {
        self.filterButton.isEnabled = false
        self.chooseImageButton.isEnabled = false
        self.activityIndicator.startAnimating()
        self.filterImage { (success) in
            if success {
                print("Image successfully filtered")
            }else{
                print("Image filtering did not complete")
            }
        self.imageView.image = self.flatigram.image
            self.filterButton.isEnabled = true
            self.chooseImageButton.isEnabled = true
            self.activityIndicator.stopAnimating()

            
            
            
        }
    }
}
