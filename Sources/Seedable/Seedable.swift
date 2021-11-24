public protocol FillingRandomNumberGenerator: RandomNumberGenerator {
    mutating func fill(_ buffer: UnsafeMutableRawBufferPointer)
}

extension SipRNG: FillingRandomNumberGenerator {}

extension SystemRandomNumberGenerator: FillingRandomNumberGenerator {
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

public protocol Seedable {
    static var seedByteCount: Int { get }
    
    init<Seed>(seededWith seed: Seed) where Seed: Collection, Seed.Element == UInt8
    
    init(seededWith seed: UInt64)
    
    init()
    
    init<RNG>(seededUsing rng: __owned RNG) where RNG: FillingRandomNumberGenerator
}

public extension Seedable {
    init(seededWith seed: UInt64) {
        self.init(seededUsing: SipRNG(hashing: seed))
    }
    
    init() {
        self.init(seededUsing: SystemRandomNumberGenerator())
    }
    
    init<RNG>(seededUsing rng: __owned RNG) where RNG: FillingRandomNumberGenerator {
        var rng = rng
        // TODO: withUnsafeTemporaryAllocation (Swift 5.6)
        var seed: [UInt8] = .init(repeating: 0, count: Self.seedByteCount)
        seed.withUnsafeMutableBytes { rng.fill($0) }
        self.init(seededWith: seed)
    }
}
