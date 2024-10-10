// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import BinaryCodable

public struct SC3DLut: CustomDebugStringConvertible, Codable {
   public var title: String? = nil
    public var type: LUTType! = nil
    public var domain:LUTDomain = .init(min: [0,0,0], max: [1,1,1])
    public  var size: Int! = nil
    public var data: [[Float]] = []
    
    public init(contentsOf url: URL) throws {
        try self.init(fileData: try Data(contentsOf: url))
    }
    public init( dataRepresentation: Data) throws {
        let decoder = BinaryDecoder()
        let data = try decoder.decode(SC3DLut.self, from: dataRepresentation)
        self = data
    }
    public init( fileData: Data) throws {
         
         let stringData =  String(decoding: fileData, as: UTF8.self)
          guard !stringData.isEmpty else {
              throw SwiftCubeError.couldNotDecodeData
          }
         let lines = stringData.components(separatedBy: "\n")
         //print("parsing", fileData.description, lines.count)
        
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
       //  print("title: \(title)")
         
         
    }
    public var debugDescription: String {
        return "LUT \(title ?? "") \(type) \(size) \(data.count)"
       }
    
    public func ciFilter() throws -> CIFilter  {
        let dimension:Float = Float(self.size)
        let colorCubeEffect = CIFilter.colorCubeWithColorSpace()
          colorCubeEffect.cubeDimension = dimension
        colorCubeEffect.colorSpace =  CGColorSpaceCreateDeviceRGB()
        var colorCubeData: [Float32] = []
        self.data.forEach({line in
            guard line.count == 3 else {
                return
            }
            colorCubeData.append(contentsOf: [line[0], line[1], line[2], 1.0])
        })
        let cubeData = Data(bytes: colorCubeData, count: colorCubeData.count * 4)
        colorCubeEffect.cubeData = cubeData
        print(cubeData.debugDescription, "cube data")
        
        return colorCubeEffect
    }
    public func rawDataRepresentation() throws -> Data {
        let encoder = BinaryEncoder()
        let data = try encoder.encode(self)
        return data
    }
}
public struct LUTDomain: Codable {
    let min: [Double]
    let max: [Double]
}
public enum LUTType: Codable{
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
