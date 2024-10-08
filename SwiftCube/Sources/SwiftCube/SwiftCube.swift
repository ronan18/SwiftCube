// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins

public struct SC3DLut: CustomDebugStringConvertible {
   public var title: String? = nil
    public var type: LUTType! = nil
    public var domain:LUTDomain = .init(min: [0,0,0], max: [1,1,1])
    public  var size: Int! = nil
    public var data: [[Float]] = []
     init(from rawData: Data) throws {
         
         let stringData =  String(decoding: rawData, as: UTF8.self)
          guard !stringData.isEmpty else {
              throw SwiftCubeError.couldNotDecodeData
          }
         let lines = stringData.components(separatedBy: "\n")
         print("parsing", rawData.description, lines.count)
        
         try lines.forEach {line in
             guard !line.isEmpty && line.first != "#" else {return}
             let parts = line.split(separator: " ")
             switch parts.first {
             case "TITLE":
                 title = String(String(parts.dropFirst().joined(separator: " ")).dropFirst().dropLast())
                 
             case "LUT_3D_SIZE":
                 type = .ThreeDimensional
                 guard let dSize = Int(parts[1]) else {
                     throw SwiftCubeError.invalidSize
                 }
                 print("size: \(dSize)")
                 size = dSize
            case "LUT_1D_SIZE":
                 type = .OneDimensional
                 print("size: ONE D")
                 throw SwiftCubeError.oneDimensionalLutNotSupported
                 
             case "DOMAIN_MIN":
                 
                 throw SwiftCubeError.unsupportedKey
            case "DOMAIN_MAX":
                     throw SwiftCubeError.unsupportedKey
             default:
                 
                 data.append(try parts.map {
                     guard let double = Float($0) else {
                         throw SwiftCubeError.invalidDataPoint
                     }
                     return double
                 })
             
             }
             
         }
         guard size != nil else {
             throw SwiftCubeError.invalidSize
         }
         guard type != nil else {
             throw SwiftCubeError.invalidType
         }
         print("title: \(title)")
         
         
    }
    public var debugDescription: String {
        return "LUT \(title ?? "") \(type) \(size) \(data.count)"
       }
    
    public func ciFilter() throws -> CIColorCube  {
        let dimension:Float = Float(self.size)
        let colorCubeEffect = CIFilter.colorCube()
          colorCubeEffect.cubeDimension = dimension
        
        var colorCubeData: [Float32] = []
        self.data.forEach({line in
            colorCubeData.append(contentsOf: [line[0], line[1], line[2], 1.0])
        })
        let cubeData = Data(bytes: colorCubeData, count: colorCubeData.count * 4)
        
        
        /*
        var colorCubeData: [Float32] = []
        let size = 8
        let step = 1.0 / Float(size - 1)
        for b in 0..<size {
            for g in 0..<size {
                for r in 0..<size {
                    // Calculate the normalized color component values.
                    let red = Float32(r) * step
                    let green = Float32(g) * step
                    // Shift the blue component to add a blue tint.
                    let blue = min(1.0, Float32(b) * step + 0.5)
                    let alpha: Float = 1.0
                    colorCubeData.append(contentsOf: [red, green, blue, alpha])
                }
            }
        }
        print(colorCubeData)
        let cubeData = Data(bytes: colorCubeData, count: colorCubeData.count * 4)*/
        colorCubeEffect.cubeData = cubeData
        print(cubeData.debugDescription, "cube data")
        
        return colorCubeEffect
    }
}
public struct LUTDomain {
    let min: [Double]
    let max: [Double]
}
public enum LUTType{
    case OneDimensional
    case ThreeDimensional
}

public enum SwiftCubeError: Error {
    case couldNotDecodeData
    case invalidSize
    case oneDimensionalLutNotSupported
    case unsupportedKey
    case invalidType
    case invalidDataPoint
}
