import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        forward(urlContexts: connectionOptions.urlContexts)
    }

    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        super.scene(scene, openURLContexts: URLContexts)
        forward(urlContexts: URLContexts)
    }

    private func forward(urlContexts: Set<UIOpenURLContext>) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        for context in urlContexts {
            _ = appDelegate.handleIncomingURL(context.url)
        }
    }
}