import Cocoa

protocol URLItemInputViewControllerDelegate: AnyObject {
    func urlItemInputViewController(viewController: URLItemInputViewController, didRequestAddURLItem item: URLItem)
}

class URLItemInputViewController: NSViewController {
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var urlTextField: NSTextField!

    var item: URLItem?
    weak var delegate: URLItemInputViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let item = item {
            titleTextField.stringValue = item.title
            urlTextField.stringValue = item.url.absoluteString
        }
    }

    @IBAction func addURL(_ sender: Any) {
        let title = titleTextField.stringValue
        if title.isEmpty {
            return
        }

        guard let url = URL(string: urlTextField.stringValue), let scheme = url.scheme, ["http", "https"].contains(scheme) else {
            return
        }

        let urlItem: URLItem
        if let editURLItem = item {
            urlItem = URLItem(id: editURLItem.id, title: title, url: url)
        } else {
            urlItem = URLItem(title: title, url: url)
        }
        delegate?.urlItemInputViewController(viewController: self, didRequestAddURLItem: urlItem)

        self.presentingViewController?.dismiss(self)
    }

    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(self)
    }
}
