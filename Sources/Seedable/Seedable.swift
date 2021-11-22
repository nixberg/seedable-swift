public typealias Seeder = SipRNG

public protocol Seedable {
    init<S>(seededWith seed: S) where S: Seed
}

public protocol Seed {
    func hash(into hasher: inout SipHash24)
}

extension FixedWidthInteger {
    public func hash(into hasher: inout SipHash24) {
        precondition(Self.bitWidth.isMultiple(of: 8))
        withUnsafeBytes(of: littleEndian) {
            hasher.update(with: $0)
        }
    }
}

extension Int8:   Seed {}
extension Int16:  Seed {}
extension Int32:  Seed {}
extension Int64:  Seed {}

extension UInt8:  Seed {}
extension UInt16: Seed {}
extension UInt32: Seed {}
extension UInt64: Seed {}

extension Int: Seed {
    public func hash(into hasher: inout SipHash24) {
        precondition(Self.bitWidth.isMultiple(of: 8))
        precondition(Self.bitWidth <= 128)
        withUnsafeBytes(of: littleEndian) {
            hasher.update(with: $0)
        }
        hasher.update(with: repeatElement(0, count: (128 - Self.bitWidth) / 8)) // As Int128.
    }
}

extension UInt: Seed {
    public func hash(into hasher: inout SipHash24) {
        precondition(Self.bitWidth.isMultiple(of: 8))
        precondition(Self.bitWidth <= 128)
        withUnsafeBytes(of: littleEndian) {
            hasher.update(with: $0)
        }
        hasher.update(with: repeatElement(0, count: (128 - Self.bitWidth) / 8)) // As UInt128.
    }
}

extension Collection where Element: Seed {
    public func hash(into hasher: inout SipHash24) {
        count.hash(into: &hasher) // Compability with core::Hash.
        for element in self {
            element.hash(into: &hasher)
        }
    }
}

extension Array:              Seed where Element: Seed {}
extension CollectionOfOne:    Seed where Element: Seed {}
extension Range:              Seed where Element: Seed {}
extension Repeated:           Seed where Element: Seed {}
extension ReversedCollection: Seed where Element: Seed {}
extension Slice:              Seed where Element: Seed {}
// TODO: More?

extension StringProtocol {
    public func hash(into hasher: inout SipHash24) {
        hasher.update(with: utf8)
        hasher.update(with: CollectionOfOne(0xff)) // Compability with core::Hash.
    }
}

extension String:    Seed {}
extension Substring: Seed {}
