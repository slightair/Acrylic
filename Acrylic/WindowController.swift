import Cocoa

class WindowController: NSWindowController {
    @IBOutlet weak var addButton: NSButton!

    var urlListViewController: URLListViewController {
        guard let viewController = window?.contentViewController as? URLListViewController else {
            fatalError("Could not retrieve URLListViewController")
        }
        return viewController
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        urlListViewController.addButton = addButton
        urlListViewController.setUp()
    }
}
