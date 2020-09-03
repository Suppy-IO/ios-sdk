//
//  Created by Suppy.io
//

import UIKit

private let cellIdentifier = "cell"

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    private var data = [(key: String, value: String?)]()

    func refreshData() {
        DispatchQueue.main.async { [self] in
            loadFromUserDefaults()
            tableView.reloadData()
        }
    }

    func loadFromUserDefaults() {
        let defaults = UserDefaults.standard

        data.removeAll()

        ConfigKey.allCases.forEach { (key) in
            switch key {
            case .privacyPolicy:
                let url = defaults.url(forKey: key.rawValue)
                data.append((key: key.rawValue, value: url?.absoluteString))
            case .productList:
                let array = defaults.array(forKey: key.rawValue) as? [String]
                data.append((key: key.rawValue, value: array?.joined(separator: ", ")))
            default:
                data.append((key: key.rawValue, value: defaults.string(forKey: key.rawValue)))
            }
        }

        data.sort { $0.key < $1.key }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let row = data[indexPath.row]
        let key = row.key
        let value = row.value

        cell.textLabel?.text = value
        cell.detailTextLabel?.text = key

        if key == ConfigKey.backgroundColor.rawValue,
           let value = value
        {
            switch value {
            case "white": cell.backgroundColor = UIColor.white
            case "red": cell.backgroundColor = UIColor.red
            case "blue": cell.backgroundColor = UIColor.blue
            case "green": cell.backgroundColor = UIColor.green
            case "yellow": cell.backgroundColor = UIColor.yellow
            default:
                cell.backgroundColor = UIColor.white
            }
        }
        return cell
    }
}

