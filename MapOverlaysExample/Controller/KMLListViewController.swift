//
//  KMLListViewController.swift
//  MapOverlaysExample
//
//  Created by Oleg B. on 03/01/2018.
//  Copyright © 2018 Oleg B. All rights reserved.
//

import UIKit

class KMLListViewController: UIViewController {
    
    let tableView: UITableView = UITableView()
    let cellId = "CellId"
    weak var delegate: MapViewController?
    
    var filesTitles = [String]()
    var filesNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        filesTitles = ["Allowed Area", "Bad example", "Multiple"]
        filesNames = ["Allowed_area", "Bad_example", "Multiple_areas"]
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
}

extension KMLListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as UITableViewCell
        cell.textLabel?.text = filesTitles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileName = filesNames[indexPath.row]
        self.delegate?.didSelectKMLFile(name: fileName)
        self.navigationController?.popViewController(animated: true)
    }
}

extension KMLListViewController {
    fileprivate func configureView() {
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        // Constrains. TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
