// Playground Support will allow us to use Live View to display our UI directly in Xcode Playgrounds
import PlaygroundSupport
import UIKit

public protocol Listable {
    var text: String { get }
    var imageURL: String { get }
}

public class ListViewController: UITableViewController {
    // MARK: - Public variables

    public var list = [Listable]() {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - Lifecycle

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Default")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    public override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return list.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Default", for: indexPath)

        let element = list[indexPath.row]
        cell.textLabel?.text = element.text
        // We'll manage the image later

        return cell
    }
}

// Structure to test our viewController
public struct TestApp: Listable {
    public let text: String
    public let imageURL: String
}

// Array of applications
let testApplications = [
    TestApp(text: "First App", imageURL: ""),
    TestApp(text: "Second App", imageURL: ""),
    TestApp(text: "Third App", imageURL: ""),
]

let listViewController = ListViewController()

listViewController.list = testApplications

// Here we assign the View controller to the Playground's live View
PlaygroundPage.current.liveView = listViewController
