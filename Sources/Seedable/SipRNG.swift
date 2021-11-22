public struct SipRNG: RandomNumberGenerator, Seedable {
    var state: State
    var adjustor: UInt64 = 0x13
    
    public init(withInitialState state: (v0: UInt64, v1: UInt64, v2: UInt64, v3: UInt64)) {
        self.state = .init(v02: .init(state.v0, state.v2), v13: .init(state.v1, state.v3))
    }
    
    public init<Bytes>(withInitialState bytes: Bytes)
    where Bytes: Collection, Bytes.Element == UInt8 {
        var bytes = bytes[...]
        
        let v0 = UInt64(littleEndianBytes: bytes.prefix(8))
        bytes = bytes.dropFirst(8)
        let v1 = UInt64(littleEndianBytes: bytes.prefix(8))
        bytes = bytes.dropFirst(8)
        let v2 = UInt64(littleEndianBytes: bytes.prefix(8))
        bytes = bytes.dropFirst(8)
        let v3 = UInt64(littleEndianBytes: bytes.prefix(8))
        bytes = bytes.dropFirst(8)
        
        precondition(bytes.isEmpty)
        
        self.init(withInitialState: (v0, v1, v2, v3))
    }
    
    public init<S>(seededWith seed: S) where S: Seed {
        var hasher: SipHash24 = .init(keys: (0, 0))
        
        seed.hash(into: &hasher)
        
        hasher.absorbTail()
        
        hasher.state.round()
        hasher.state.round()
        
        state = hasher.state
    }
    
    public mutating func next() -> UInt64 {
        state.v02.y ^= adjustor
        adjustor &-= 0x11
        assert(adjustor != 0x13)
        
        state.round()
        state.round()
        
        return state.xorSum.littleEndian
    }
    
    public mutating func next<T>() -> T where T: FixedWidthInteger & UnsignedInteger {
        var result: T = .zero
        withUnsafeMutableBytes(of: &result) {
            self.fill($0)
        }
        return result
    }
    
    public mutating func fill(_ buffer: UnsafeMutableRawBufferPointer) {
        var word: UInt64 = 0
        for index in buffer.indices {
            if index.isMultiple(of: 8) {
                word = self.next()
            }
            withUnsafeBytes(of: &word) {
                buffer[index] = $0[index % 8]
            }
        }
    }
}

fileprivate extension UInt64 {
    init<Bytes>(littleEndianBytes bytes: Bytes) where Bytes: Collection, Bytes.Element == UInt8 {
        precondition(bytes.count == 8)
        self = bytes.enumerated().reduce(0) {
            $0 | (Self($1.element) &<< ($1.offset &* 8))
        }
    }
}
