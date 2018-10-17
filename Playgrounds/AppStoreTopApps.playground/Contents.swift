import UIKit
import PlaygroundSupport



public protocol DataFetching {
    func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void)
}

extension DataFetching {
    public func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void) {

        let session = URLSession.shared

        session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }.resume()
        
    }
}

public struct App {
    let name: String
    let summary: String
    let thumbImageUrl: String
}

extension App: Decodable {
    private enum CodingKeys: String, CodingKey {
        case name = "im:name"
        case summary
        case image = "im:image"
    }

    private enum LabelKeys: String, CodingKey {
        case label
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nameContainer = try container.nestedContainer(keyedBy: LabelKeys.self, forKey: .name)
        name = try nameContainer.decode(String.self, forKey: .label)

        let summaryContainer = try container.nestedContainer(keyedBy: LabelKeys.self, forKey: .summary)
        summary = try summaryContainer.decode(String.self, forKey: .label)

        var imagesContainer = try container.nestedUnkeyedContainer(forKey: .image)

        var tempImageThumb = ""

        while !imagesContainer.isAtEnd {
            let imageContainer = try imagesContainer.nestedContainer(keyedBy: LabelKeys.self)

            tempImageThumb = try imageContainer.decode(String.self, forKey: LabelKeys.label)
            break
        }

        thumbImageUrl = tempImageThumb
    }
}

public class AppStoreRessource: DataFetching {

    private struct ServerResponse: Decodable {
        let feed: Feed
    }

    private struct Feed: Decodable {
        let entry: [App]
    }

    public func getTopApps(top: Int, completion: @escaping ([App], Error?) -> Void) {

        let urlString = "https://itunes.apple.com/fr/rss/toppaidapplications/limit=\(top)/json"

        let url = URL(string: urlString)

        fetchData(url: url!) { (data, dataError) in

            var apps = [App]()
            var parseError = dataError

            defer {
                completion(apps, parseError)
            }

            guard let data = data else {
                return
            }

            do {
                let jsonDecoder = JSONDecoder()
                let serverResponse = try jsonDecoder.decode(ServerResponse.self, from: data)
                apps = serverResponse.feed.entry
            }
            catch {
                parseError = error
            }
        }
    }
}

public protocol Listable {
    var text: String { get }
    var longText: String { get }
}

class AppsViewController: UITableViewController {

    public var list = [Listable]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Default")

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Default", for: indexPath)

        let element = list[indexPath.row]

        cell.textLabel?.text = element.text

        return cell
    }
}

extension App: Listable {
    public var text: String {
        return name
    }

    public var longText: String {
        return summary
    }
}

let appsViewController = AppsViewController()

let ressource = AppStoreRessource()

ressource.getTopApps(top: 10) { (apps, error) in
    //
    print(apps)
    appsViewController.list = apps
}

PlaygroundPage.current.liveView = appsViewController


