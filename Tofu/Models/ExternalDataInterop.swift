import Foundation
import CryptoKit
import CommonCrypto

class ExternalDataInterop {

    enum ExternalDataInteropError: Error {
        case invalidPasscode
        case invalidData
        case encryptionFailed
    }
    
    /// Generate a PBKDF2 derived key from the given password.
    private func derivedPBKDF2Key(from password: String, keySize: SymmetricKeySize, rounds: Int) throws -> Data {

        // To perform PBKDF2 key derivation, we need to use CommonCrypto, which isn't very Swift-y.
        let passwordData = Data(password.utf8)
        let saltData = Data("twofusalt".utf8)
        let saltLength = saltData.count

        let derivedKeyByteLength = keySize.bitCount / 8
        var derivedKeyData = Data(repeating: 0, count: derivedKeyByteLength)

        let derivationStatus: Int32 = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
            saltData.withUnsafeBytes { saltBytes in
                let keyBuffer: UnsafeMutablePointer<UInt8> = derivedKeyBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
                let saltBuffer: UnsafePointer<UInt8> = saltBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
                return CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), password, passwordData.count, saltBuffer, saltLength,
                                            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256), UInt32(rounds),
                                            keyBuffer, derivedKeyByteLength)
            }
        }

        guard derivationStatus == kCCSuccess else { throw ExternalDataInteropError.encryptionFailed }
        return derivedKeyData
    }

    /// Generate an encryption/decryption key for the given passcode.
    private func encryptionKey(from passcode: String) throws -> SymmetricKey {
        guard !passcode.isEmpty else { throw ExternalDataInteropError.invalidPasscode }
        // 600k figure from https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html#pbkdf2
        return SymmetricKey(data: try derivedPBKDF2Key(from: passcode, keySize: .bits256, rounds: 600_000))
    }

    /// Encrypt the given data with the given passcode.
    func encrypt(_ sourceData: Data, with passcode: String) throws -> Data {
        return try AES.GCM.seal(sourceData, using: try encryptionKey(from: passcode)).combined!
    }
    
    /// Attempt to decrypt the given data using the given passcode.
    func decrypt(_ encryptedData: Data, with passcode: String) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: try encryptionKey(from: passcode))
    }
    
    /// Encrypt the given accounts with the given passcode.
    func encryptedData(for accounts: [Account], with passcode: String) throws -> Data {
        let encodedAccounts = try NSKeyedArchiver.archivedData(withRootObject: accounts, requiringSecureCoding: true)
        return try encrypt(encodedAccounts, with: passcode)
    }

    /// Attempt to decrypt the given accounts with using the given passcode.
    func decryptAccounts(from encryptedAccountData: Data, with passcode: String) throws -> [Account] {
        let decryptedData = try decrypt(encryptedAccountData, with: passcode)
        guard let accounts: [Account] = try {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: decryptedData)
            unarchiver.requiresSecureCoding = true
            return unarchiver.decodeObject(of: [NSArray.self, Account.self], forKey: NSKeyedArchiveRootObjectKey) as? [Account]
        }() else {
            throw ExternalDataInteropError.invalidData
        }
        return accounts
    }

}
