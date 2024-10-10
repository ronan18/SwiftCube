# SwiftCube
SwiftCube is a lightweight swift package to turn .cube LUTs into Core Image Filters.

[SwiftCube powers FrameUP, the essential director's viewfinder](https://frameup.ronanfuruta.com/?r=scgh).

## Supports
SwiftCube supports 3D luts in the .cube format with maximum and minimum dimensions of 1 and 0, respectively.

Requires macOS 10.15 and iOS 13 or greater.



## Usage

**Intalize a LUT**
```swift
let lutFromURL = try SC3DLUT(contentsOf: URL)
let lutFromFileData = try SC3DLUT(fileData: Data)
let lutFromDataRepresentation = try SC3DLUT(dataRepresentation: Data)
```

**Create a CIFilter**
```swift
let lut: SC3DLUT = try SC3DLUT(contentsOf: URL)
let filter = try lut.ciFilter()
```

**Turn LUT into data for saving**
```swift
let lut: SC3DLUT = try SC3DLUT(contentsOf: URL)
let filter = try lut.rawDataRepresentation()
```
