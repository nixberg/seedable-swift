struct State {
    var v02: SIMD2<UInt64> = .init(0x736f6d6570736575, 0x6c7967656e657261)
    var v13: SIMD2<UInt64> = .init(0x646f72616e646f6d, 0x7465646279746573)
    
    mutating func round() {
        v02 &+= v13
        v13.rotate(left: .init(13, 16))
        v13 ^= v02
        
        var v20 = v02.rotatedAndSwapped()
        
        v20 &+= v13
        v13.rotate(left: .init(17, 21))
        v13 ^= v20
        
        v02 = v20.rotatedAndSwapped()
    }
    
    var xorSum: UInt64 {
        (v02 ^ v13).xorSum()
    }
}

fileprivate extension SIMD where Scalar: FixedWidthInteger {
    @inline(__always)
    mutating func rotate(left counts: Self) {
        let countsComplement = Scalar(Scalar.bitWidth) &- counts
        self = (self &<< counts) | (self &>> countsComplement)
    }
}

fileprivate extension SIMD2 where Scalar == UInt64 {
    @inline(__always)
    func rotatedAndSwapped() -> Self {
        var result = self
        withUnsafeMutablePointer(to: &result) {
            $0.withMemoryRebound(to: SIMD4<UInt32>.self, capacity: 1) {
                $0.pointee = $0.pointee[.init(2, 3, 1, 0)]
            }
        }
        return result
    }
}

fileprivate extension SIMD where Scalar: BinaryInteger {
    @inline(__always)
    func xorSum() -> Scalar {
        indices.reduce(0, { $0 ^ self[$1] })
    }
}
