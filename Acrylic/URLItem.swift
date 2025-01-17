import Foundation

final class URLItem: NSObject, NSSecureCoding {
    static var supportsSecureCoding = true

    let id: UUID
    let title: String
    let url: URL

    init(id: UUID = UUID(), title: String, url: URL) {
        self.id = id
        self.title = title
        self.url = url
    }

    init?(coder: NSCoder) {
        let rawTitle = coder.decodeObject(of: NSString.self, forKey: "title")
        let rawURL = coder.decodeObject(of: NSURL.self, forKey: "url")

        guard let title = rawTitle, let url = rawURL else {
            return nil
        }

        self.id = UUID()
        self.title = title as String
        self.url = url as URL
    }

    func encode(with coder: NSCoder) {
        coder.encode(title as NSString, forKey: "title")
        coder.encode(url as NSURL, forKey: "url")
    }
}
