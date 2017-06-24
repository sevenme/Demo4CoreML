//
//  DetectViewController.swift
//  Demo4CoreML
//
//  Created by Seven on 24/06/2017.
//  Copyright © 2017 Seven. All rights reserved.
//

import UIKit

class DetectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initNavigation()
        self.detectPhoto(image: imageView.image)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */


    func initNavigation() {
        let rightBar = UIBarButtonItem.init(title: "更换图片", style: .done, target: self, action: #selector(changePhoto))
        navigationItem.rightBarButtonItem = rightBar
    }

    /// 点击事件
    @objc
    private func changePhoto() {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func detectPhoto(image: UIImage?){
        if let existImage = image {
            let googLeNetPlaces = GoogLeNetPlaces.init()
            let size = CGSize.init(width: 224, height: 224)
            if let scaledImage = resizeImage(image: existImage, size: size) {
                if let pixelBuffer = convertToBuffer(from: scaledImage) {
                    let input = GoogLeNetPlacesInput.init(sceneImage: pixelBuffer)
                    if let ouput = try? googLeNetPlaces.prediction(input: input) {
                        let sceneLabelProbs = ouput.sceneLabelProbs
                        let name = ouput.sceneLabel
                        if let chance = sceneLabelProbs[name] {
                            descLabel.text = " \(name), 几率\(chance)"
                        }
                        return
                    }
                }
            }
        }
        descLabel.text = "检测失败"
    }

    func resizeImage(image: UIImage, size: CGSize) -> UIImage? {

        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    func convertToBuffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        dismiss(animated:true, completion: nil)
        detectPhoto(image: chosenImage)
    }

}
