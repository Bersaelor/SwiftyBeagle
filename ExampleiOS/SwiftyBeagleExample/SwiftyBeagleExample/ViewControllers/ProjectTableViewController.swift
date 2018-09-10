//
//  ProjectTableViewController.swift
//  SwiftyBeagleExample
//
//  Created by Konrad Feiler on 10.09.18.
//  Copyright © 2018 Konrad Feiler. All rights reserved.
//

import UIKit

@IBDesignable class ProjectTableViewController: UITableViewController {
    
    @IBInspectable var type: String = "" {
        didSet {
            print("type: \(oldValue) -> \(type)")
        }
    }

    private var projects = [KSProject]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ControllerType(rawValue: type)?.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let urlString = ControllerType(rawValue: type)?.feed,
            let url = URL(string: urlString) else { return }
        Resource(url: url).load { [weak self] (response: KSSearchResponse?) in
            self?.projects = response?.projects ?? []
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath)

        let project = projects[indexPath.row]
        cell.textLabel?.text = project.name
        cell.imageView?.load(urlString: project.photo.little)
        cell.detailTextLabel?.text = project.creator.name
        return cell
    }

}

enum ControllerType: String {
    case newest
    case boardgames
}

extension ControllerType {
    var feed: String {
        switch self {
        case .newest:
            return Feed.newest
        case .boardgames:
            return Feed.boardgames
        }
    }
    
    var title: String {
        switch self {
        case .newest:
            return "Newest Projects"
        case .boardgames:
            return "Boardgames"
        }
    }
}
