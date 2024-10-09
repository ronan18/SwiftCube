//
//  SwiftUIView.swift
//  SwiftCube
//
//  Created by Ronan Furuta on 10/8/24.
//

import SwiftUI
import Foundation
import UIKit
import CoreImage

@available(iOS 17.0, *)
struct SwiftUIView: View {
    @State var resultImage: UIImage? = nil
    @State var startImage: UIImage? = nil
    @State var error: String = ""
    var body: some View {
        VStack {
            if let startImage {
                Image(uiImage: startImage)
                    .resizable().aspectRatio(contentMode: .fit)
            }
            if let resultImage {
                Image(uiImage: resultImage)
                    .resizable().aspectRatio(contentMode: .fit)
            } else {
                Text("No image yet")
            }
            Text(error)
        }.onAppear {
            do {
               try self.proccess()
            } catch {
                print(error)
            }
        }
    }
    func proccess() throws {
        let url = Bundle.module.url(forResource: "SampleImage", withExtension: "jpeg")!
        let lutURL = Bundle.module.url(forResource: "SampleLUT", withExtension: "cube")!
        self.startImage = UIImage(contentsOfFile: url.path())
        let lutData = try Data(contentsOf: lutURL)
        let lut =  try SC3DLut.init(rawData: lutData)
        print(lut.debugDescription)
        let filter = try lut.ciFilter()
        filter.setValue(CIImage(image: startImage!), forKey: kCIInputImageKey)
        
        guard  let result = filter.outputImage else {
            self.error = "no result image"
            return
        }
        let context = CIContext(options: nil)
        if let cgimg = context.createCGImage(result, from: result.extent) {
                    let processedImage = UIImage(cgImage: cgimg)
                    // do something interesting with the processed image
            self.resultImage = processedImage
                }
        
    }
}

@available(iOS 17.0, *)
#Preview {
    SwiftUIView()
}
