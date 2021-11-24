import Seedable
import XCTest

final class SipTests: XCTestCase {
    func testSipHash24() {
        let keys: (UInt64, UInt64) = (0x0706050403020100, 0x0f0e0d0c0b0a0908)
        
        let vectors: [UInt64] = [
            0x726fdb47dd0e0e31, 0x74f839c593dc67fd, 0x0d6c8009d9a94f5a, 0x85676696d7fb7e2d,
            0xcf2794e0277187b7, 0x18765564cd99a68d, 0xcbc9466e58fee3ce, 0xab0200f58b01d137,
            0x93f5f5799a932462, 0x9e0082df0ba9e4b0, 0x7a5dbbc594ddb9f3, 0xf4b32f46226bada7,
            0x751e8fbc860ee5fb, 0x14ea5627c0843d90, 0xf723ca908e7af2ee, 0xa129ca6149be45e5,
            0x3f2acc7f57c29bdb, 0x699ae9f52cbe4794, 0x4bc1b3f0968dd39c, 0xbb6dc91da77961bd,
            0xbed65cf21aa2ee98, 0xd0f2cbb02e3b67c7, 0x93536795e3a33e88, 0xa80c038ccd5ccec8,
            0xb8ad50c6f649af94, 0xbce192de8a85b8ea, 0x17d835b85bbb15f3, 0x2f2e6163076bcfad,
            0xde4daaaca71dc9a5, 0xa6a2506687956571, 0xad87a3535c49ef28, 0x32d892fad841c342,
            0x7127512f72f27cce, 0xa7f32346f95978e3, 0x12e0b01abb051238, 0x15e034d40fa197ae,
            0x314dffbe0815a3b4, 0x027990f029623981, 0xcadcd4e59ef40c4d, 0x9abfd8766a33735c,
            0x0e3ea96b5304a7d0, 0xad0c42d6fc585992, 0x187306c89bc215a9, 0xd4a60abcf3792b95,
            0xf935451de4f21df2, 0xa9538f0419755787, 0xdb9acddff56ca510, 0xd06c98cd5c0975eb,
            0xe612a3cb9ecba951, 0xc766e62cfcadaf96, 0xee64435a9752fe72, 0xa192d576b245165a,
            0x0a8787bf8ecb74b2, 0x81b3e73d20b49b6f, 0x7fa8220ba3b2ecea, 0x245731c13ca42499,
            0xb78dbfaf3a8d83bd, 0xea1ad565322a1a0b, 0x60e61c23a3795013, 0x6606d7e446282b93,
            0x6ca4ecb15c5f91e1, 0x9f626da15c9625f3, 0xe51b38608ef25f57, 0x958a324ceb064572,
        ]
        
        let input = vectors
            .indices
            .map(UInt8.init)
        
        for (i, vector) in vectors.enumerated() {
            XCTAssertEqual(SipHash24.hash(data: input.prefix(i), withKeys: keys), vector)
        }
    }
    
    func testSipRNGZeroSeed() {
        let vectors: [UInt64] = [
            0x4c022e4ec04e602a, 0xc2c0399c269058d6, 0xf5c7399cde9c362c, 0x37e5b9491363680a,
            0x9582782644903316, 0x02a9d2e160aad88d, 0x983958db9376e6f6, 0xdead8960b8524928,
            0xcfa886c6642c1b2f, 0x8f8f91fcf7045f2a, 0x1bbda585fc387fb3, 0x242485d9cc54c688,
            0x09be110f767d8cee, 0xd61076dfc3569ab3, 0x8f6092dd2692af57, 0xbdf362ab8e29260b,
        ]
        
        var rng = SipRNG(seededWith: repeatElement(0, count: 32))
        
        for vector in vectors {
            XCTAssertEqual(rng.next(), vector)
        }
    }
    
    func testSipRNGNonzeroSeed() {
        let vectors: [UInt64] = [
            0x479bf2823a7a923e, 0x0f04e2cbc75d554d, 0xd589aceb3b65f36b, 0x091f8758ab30951a,
            0x10d2bebadd90c381, 0xb3a6345b6273b101, 0xd05dbd603684e153, 0xabaaa983f818f5db,
            0x2a063ed10d464bf2, 0x1d395c4c511e9073, 0x43011ca87ead4d7c, 0x22acb2bfbca6a069,
            0x0dd6b8dd2abb4d8f, 0xb3bc3889e7142461, 0x062cbac703609d15, 0x74aec28d9fdd44bf,
        ]
        
        var rng = SipRNG(seededWith: (0..<32))
        
        for vector in vectors {
            XCTAssertEqual(rng.next(), vector)
        }
    }
    
    func testMakeRNG() {
        var seeder = SipRNG(hashing: "test string")
        var rng = SipRNG(withInitialState: (
            seeder.next(),
            seeder.next(),
            seeder.next(),
            seeder.next()
        ))
        XCTAssertEqual(rng.next(), 7267854722795183454)
        XCTAssertEqual(rng.next(), 0602994585684902144)
        
        rng = SipRNG(seededUsing: SipRNG(hashing: "test string"))
        XCTAssertEqual(rng.next(), 7267854722795183454)
        XCTAssertEqual(rng.next(), 0602994585684902144)
        
        rng = SipRNG(seededUsing: SipRNG(hashing: -1))
        XCTAssertEqual(rng.next(), 18092017109811415700)
        XCTAssertEqual(rng.next(), 06068271683024885693)
    }
    
    func testSipRNGZero() {
        var rng = SipRNG(withInitialState: (0, 0, 19, 0))
        XCTAssertEqual(rng.next(), 0)
    }
    
    func testSipRNGUIn8() {
        var rng = SipRNG(seededWith: repeatElement(0, count: 32))
        XCTAssertEqual(rng.next() as UInt8, 42)
    }
    
    func testSipRNGUIn16() {
        var rng = SipRNG(seededWith: repeatElement(0, count: 32))
        XCTAssertEqual(rng.next() as UInt16, 24618)
    }
    
    func testSipRNGUIn32() {
        var rng = SipRNG(seededWith: repeatElement(0, count: 32))
        XCTAssertEqual(rng.next() as UInt32, 3226361898)
    }
    
    func testSipRNGUIn64() {
        var rng = SipRNG(seededWith: repeatElement(0, count: 32))
        XCTAssertEqual(rng.next() as UInt64, 5476991012604633130)
    }
}
