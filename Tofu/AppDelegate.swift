import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        return true
    }

    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        let rootViewController = window!.rootViewController!

        guard let account = Account(url: url) else {
            let alert = UIAlertController(
                title: "Could Not Import Account",
                message: "The account information was not of the expected format.",
                preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Close", style: .default))

            rootViewController.present(alert, animated: true)

            return false
        }

        let accountsViewController = rootViewController.children.first as! AccountsViewController

        accountsViewController.createAccount(account)

        let alert = UIAlertController(
            title: "Account Imported",
            message: "Successfully imported \(account.description)",
            preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        rootViewController.present(alert, animated: true)

        return true
    }
}
