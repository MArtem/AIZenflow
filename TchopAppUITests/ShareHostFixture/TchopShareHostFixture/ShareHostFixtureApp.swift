import UIKit

@main
final class ShareHostFixtureAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ShareHostFixtureViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

final class ShareHostFixtureViewController: UIViewController {
    private let presentShareButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "Tchop Share host fixture"
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.textAlignment = .center

        let descriptionLabel = UILabel()
        descriptionLabel.text = "Presents deterministic text through the system share sheet."
        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center

        presentShareButton.setTitle("Present share sheet", for: .normal)
        presentShareButton.accessibilityIdentifier = "shareHost.presentShare"
        presentShareButton.accessibilityHint = "Opens the system share sheet with fixture text."
        presentShareButton.addTarget(self, action: #selector(presentShareSheet), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, presentShareButton])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func presentShareSheet() {
        let shareSheet = UIActivityViewController(
            activityItems: ["Tchop bounded share-host fixture text"],
            applicationActivities: nil
        )

        if let popover = shareSheet.popoverPresentationController {
            popover.sourceView = presentShareButton
            popover.sourceRect = presentShareButton.bounds
        }

        present(shareSheet, animated: true)
    }
}
