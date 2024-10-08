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
  let lut =  try SC3DLut.init(from: lutData)
    print(lut.debugDescription)
    let filter = try lut.ciFilter()
    
    let inputImageURL = Bundle.module.url(forResource: "SampleImage", withExtension: "jpeg")!
    let startImage = UIImage(contentsOfFile: inputImageURL.path())
    filter.inputImage = CIImage(image: startImage!)
    let result = filter.outputImage
    #expect(result != nil)
    
    return
}
