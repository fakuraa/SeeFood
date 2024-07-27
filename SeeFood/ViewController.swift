//
//  ViewController.swift
//  SeeFood
//
//  Created by Fadil Kurniawan on 27/07/24.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imgView: UIImageView!
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }


    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imgView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert into CIImage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true)
    }
    
    func detect(image:CIImage){
            guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
                fatalError("Loading CoreML Model Failed.")
            }
        
        let request = VNCoreMLRequest(model: model){(request,error) in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Model Failed to process image")
            }
//            print(results)
            if let firstResult = results.first{
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                }else{
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        }catch{
            print(error)
        }
    }
}

