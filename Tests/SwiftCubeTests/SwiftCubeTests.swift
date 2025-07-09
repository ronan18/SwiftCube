import Testing
import Foundation
import CoreImage
import UIKit
@testable import SwiftCube

let testingLUT = Bundle.module.url(forResource: "SampleLUT", withExtension: "cube")!

@available(iOS 16.0, *)
@Test func importAndCreateLUT() async throws {
 
    let lutURL = testingLUT
    let lutData = try Data(contentsOf: lutURL)
    let lut =  try SC3DLut.init(fileData: lutData)
    print(lut.debugDescription)
    let filter = try lut.ciFilter()
    
    let inputImageURL = Bundle.module.url(forResource: "SampleImage", withExtension: "jpg")!
    let startImage = UIImage(contentsOfFile: inputImageURL.path())
    filter.setValue(CIImage(image: startImage!), forKey: kCIInputImageKey)
    let result = filter.outputImage
    #expect(result != nil)
    
    return
}
@available(iOS 16.0, *)
@Test func importAndCreateLUTFromURL() async throws {
 
    let lutURL = testingLUT
   
    let lut =  try SC3DLut.init(contentsOf: lutURL)
    print(lut.debugDescription)
    let filter = try lut.ciFilter()
    
    let inputImageURL = Bundle.module.url(forResource: "SampleImage", withExtension: "jpg")!
    let startImage = UIImage(contentsOfFile: inputImageURL.path())
    filter.setValue(CIImage(image: startImage!), forKey: kCIInputImageKey)
    let result = filter.outputImage
    #expect(result != nil)
    
    return
}

@Test func dataInOut() async throws {
    let lutURL = testingLUT
    let lutData = try Data(contentsOf: lutURL)
    let lut =  try SC3DLut.init(fileData: lutData)
    print(lut.debugDescription)
    let filter = try lut.ciFilter()
    
    let data = try lut.rawDataRepresentation()
    
    let lut2 = try SC3DLut.init(dataRepresentation: data)
    
    #expect(lut.title == lut2.title)
    #expect(lut.data == lut2.data)
    #expect(lut.size == lut2.size)
    #expect(lut.type == lut2.type)
    
}
