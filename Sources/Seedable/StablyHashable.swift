public typealias StableHasher = SipHash24

public protocol StablyHashable {
    func hash(into hasher: inout StableHasher)
}

extension FixedWidthInteger {
    public func hash(into hasher: inout StableHasher) {
        precondition(Self.bitWidth.isMultiple(of: 8))
        withUnsafeBytes(of: littleEndian) {
            hasher.update(with: $0)
        }
    }
}

extension Int8:   StablyHashable {}
extension Int16:  StablyHashable {}
extension Int32:  StablyHashable {}
extension Int64:  StablyHashable {}

extension UInt8:  StablyHashable {}
extension UInt16: StablyHashable {}
extension UInt32: StablyHashable {}
extension UInt64: StablyHashable {}

extension Int: StablyHashable {
    public func hash(into hasher: inout StableHasher) {
        precondition(Self.bitWidth.isMultiple(of: 8))
        precondition(Self.bitWidth <= 128)
        withUnsafeBytes(of: littleEndian) {
            hasher.update(with: $0)
        }
        hasher.update(with: repeatElement(0, count: (128 - Self.bitWidth) / 8))
    }
}

extension UInt: StablyHashable {
    public func hash(into hasher: inout StableHasher) {
        precondition(Self.bitWidth.isMultiple(of: 8))
        precondition(Self.bitWidth <= 128)
        withUnsafeBytes(of: littleEndian) {
            hasher.update(with: $0)
        }
        hasher.update(with: repeatElement(0, count: (128 - Self.bitWidth) / 8))
    }
}

extension Collection where Element: StablyHashable {
    public func hash(into hasher: inout StableHasher) {
        count.hash(into: &hasher) // Compability with core::Hash.
        for element in self {
            element.hash(into: &hasher)
        }
    }
}

extension Array:              StablyHashable where Element: StablyHashable {}
extension CollectionOfOne:    StablyHashable where Element: StablyHashable {}
extension EmptyCollection:    StablyHashable where Element: StablyHashable {}
extension Range:              StablyHashable where Element: StablyHashable {}
extension Repeated:           StablyHashable where Element: StablyHashable {}
extension ReversedCollection: StablyHashable where Element: StablyHashable {}
extension Slice:              StablyHashable where Element: StablyHashable {}
// TODO: More?

extension StringProtocol {
    public func hash(into hasher: inout StableHasher) {
        hasher.update(with: utf8)
        hasher.update(with: CollectionOfOne(0xff)) // Compability with core::Hash.
    }
}

extension String:    StablyHashable {}
extension Substring: StablyHashable {}
