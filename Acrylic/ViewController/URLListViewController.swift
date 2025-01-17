import Cocoa

class URLListViewController: NSViewController {
    static let archivedURLListKey = "archivedURLList"

    @IBOutlet weak var urlListView: NSTableView!

    weak var addButton: NSButton!

    var keyValueStore: NSUbiquitousKeyValueStore {
        return .default
    }

    private var items: [URLItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyValueStoreDidChange(notification:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: NSUbiquitousKeyValueStore.default)

        loadItems()

        urlListView.doubleAction = #selector(openURLItem(_:))

        let menu = NSMenu()
        menu.addItem(withTitle: "Open", action: #selector(openURLItem(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Edit", action: #selector(editURLItem(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Delete", action: #selector(deleteURLItem(_:)), keyEquivalent: "")
        urlListView.menu = menu
    }

    func setUp() {
        addButton.action = #selector(addURLItem(_:))
    }

    @objc func addURLItem(_ sender: Any?) {
        guard let viewController: URLItemInputViewController = storyboard?.instantiateController(identifier: NSStoryboard.SceneIdentifier("URLItemInputView")) else {
            fatalError("Could not instantiate URLItemInputViewController")
        }
        viewController.delegate = self
        presentAsSheet(viewController)
    }

    @objc func openURLItem(_ sender: Any?) {
        if urlListView.clickedRow == -1 {
            return
        }

        let item = items[urlListView.clickedRow]

        guard let viewController: AcrylicWebViewController = storyboard?.instantiateController(identifier: NSStoryboard.SceneIdentifier("AcrylicWebView")) else {
            fatalError("Could not instantiate AcrylicWebViewController")
        }

        let window = NSWindow(contentViewController: viewController)
        window.makeKeyAndOrderFront(self)
        let windowController = NSWindowController(window: window)
        windowController.showWindow(self)

        viewController.openURL(item.url)
    }

    @objc func editURLItem(_ sender: Any?) {
        if urlListView.clickedRow == -1 {
            return
        }

        let item = items[urlListView.clickedRow]
        guard let viewController: URLItemInputViewController = storyboard?.instantiateController(identifier: NSStoryboard.SceneIdentifier("URLItemInputView")) else {
            fatalError("Could not instantiate URLItemInputViewController")
        }
        viewController.item = item
        viewController.delegate = self
        presentAsSheet(viewController)
    }

    @objc func deleteURLItem(_ sender: Any?) {
        if urlListView.clickedRow == -1 {
            return
        }

        items.remove(at: urlListView.clickedRow)
        synchronizeItems()
        urlListView.reloadData()
    }

    @objc func keyValueStoreDidChange(notification: Notification) {
        loadItems()
    }

    private func loadItems() {
        if let dataList = keyValueStore.array(forKey: Self.archivedURLListKey) as? [Data] {
            let urlList: [URLItem]
            do {
                urlList = try dataList.compactMap {
                    try NSKeyedUnarchiver.unarchivedObject(ofClass: URLItem.self, from: $0)
                }
            } catch {
                assertionFailure("Could not unarchive url list")
                urlList = []
            }

            items = urlList
            urlListView.reloadData()
        }
    }

    private func synchronizeItems() {
        let dataList: [Data]
        do {
            dataList = try items.map {
                try NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: true)
            }
        } catch {
            assertionFailure("Could not archive url list")
            dataList = []
        }

        keyValueStore.set(dataList, forKey: Self.archivedURLListKey)
        keyValueStore.synchronize()
    }
}

extension URLListViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        items.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            fatalError("column not found")
        }
        guard let view = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? NSTableCellView else {
            fatalError("Could not make table view cell")
        }

        let item = items[row]

        switch column.identifier.rawValue {
        case "Title":
            view.textField?.stringValue = item.title
        case "URL":
            view.textField?.stringValue = item.url.absoluteString
        default:
            fatalError("Unknown column: \(column.identifier)")
        }

        return view
    }
}

extension URLListViewController: URLItemInputViewControllerDelegate {
    func urlItemInputViewController(viewController: URLItemInputViewController, didRequestAddURLItem item: URLItem) {
        if let editItemIndex = items.firstIndex(where: { $0.id == item.id }) {
            items[editItemIndex] = item
        } else {
            items.append(item)
        }
        synchronizeItems()
        urlListView.reloadData()
    }
}
