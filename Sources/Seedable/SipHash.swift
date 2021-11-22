public struct SipHash24 {
    var state: State = .init()
    private var absorbedBytesCount = 0
    
    private var buffer: UInt64 = 0
    private var bufferByteCount = 0
    
    init(keys: (k0: UInt64, k1: UInt64)) {
        state.v02 ^= .init(repeating: keys.k0)
        state.v13 ^= .init(repeating: keys.k1)
    }
    
    public mutating func update<Bytes>(with bytes: Bytes)
    where Bytes: Sequence, Bytes.Element == UInt8 {
        precondition((0...7).contains(bufferByteCount))
        
        for byte in bytes {
            absorbedBytesCount += 1
            
            buffer |= UInt64(truncatingIfNeeded: byte) &<< (8 * bufferByteCount)
            bufferByteCount += 1
            
            if bufferByteCount == 8 {
                self.absorbBuffer()
                buffer = 0
                bufferByteCount = 0
            }
        }
    }
    
    mutating /*__consuming*/ func finalize() -> UInt64 {
        self.absorbTail()
        
        state.v02.y ^= 0xff
        state.round()
        state.round()
        state.round()
        state.round()
            
        return state.xorSum
    }
    
    mutating func absorbTail() {
        precondition((0...7).contains(bufferByteCount))
        bufferByteCount = -1
        
        buffer |= UInt64(absorbedBytesCount) << 56
        self.absorbBuffer()
    }
    
    private mutating func absorbBuffer() {
        state.v13.y ^= buffer
        state.round()
        state.round()
        state.v02.x ^= buffer
    }
}

public extension SipHash24 {
    static func hash<Bytes>(data bytes: Bytes, withKeys keys: (UInt64, UInt64)) -> UInt64
    where Bytes: Sequence, Bytes.Element == UInt8 {
        var hasher: Self = .init(keys: keys)
        hasher.update(with: bytes)
        return hasher.finalize()
    }
}
