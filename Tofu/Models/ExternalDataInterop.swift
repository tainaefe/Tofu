import Foundation
import CryptoKit

class ExternalDataInterop {

    enum ExternalDataInteropError: Error {
        case invalidPasscode
        case invalidData
    }
    
    /// Generate an encryption/decryption key for the given passcode.
    private func encryptionKey(from passcode: String) throws -> SymmetricKey {
        guard !passcode.isEmpty else { throw ExternalDataInteropError.invalidPasscode }
        return SymmetricKey(data: SHA256.hash(data: Data(passcode.utf8)))
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
