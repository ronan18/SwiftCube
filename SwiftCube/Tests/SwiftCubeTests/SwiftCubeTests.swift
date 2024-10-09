import Testing
import Foundation
import CoreImage
import UIKit
@testable import SwiftCube

@available(iOS 16.0, *)
@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
 
    let lutURL = Bundle.module.url(forResource: "SampleLUT", withExtension: "cube")!
    let lutData = try Data(contentsOf: lutURL)
    let lut =  try SC3DLut.init(rawData: lutData)
    print(lut.debugDescription)
    let filter = try lut.ciFilter()
    
    let inputImageURL = Bundle.module.url(forResource: "SampleImage", withExtension: "jpeg")!
    let startImage = UIImage(contentsOfFile: inputImageURL.path())
    filter.setValue(CIImage(image: startImage!), forKey: kCIInputImageKey)
    let result = filter.outputImage
    #expect(result != nil)
    
    return
}

@Test func dataInOut() async throws {
    let lutURL = Bundle.module.url(forResource: "SampleLUT", withExtension: "cube")!
    let lutData = try Data(contentsOf: lutURL)
    let lut =  try SC3DLut.init(rawData: lutData)
    print(lut.debugDescription)
    let filter = try lut.ciFilter()
    
    let data = try lut.rawDataRepresentation()
    
    let lut2 = try SC3DLut.init(dataRepresentation: data)
    
    #expect(lut.title == lut2.title)
    #expect(lut.data == lut2.data)
    #expect(lut.size == lut2.size)
    #expect(lut.type == lut2.type)
    
}
