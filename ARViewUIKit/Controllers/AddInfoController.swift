//
//  AddInfoController.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 14.04.25.
//

import UIKit

// MARK: - Protocols
protocol InfoCellDelegate: AnyObject {
    func didSelectInfoItem(_ item: InfoItem)
}

class AddInfoController: UIViewController {
    // UI Components
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Information"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .white
        return titleLabel
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(InfoCell.self, forCellReuseIdentifier: "InfoCell")
        return tableView
    }()
    
    // View Model
    private let viewModel = InfoListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        setupUI()
        layotu()
        setupBindings()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
}


// MARK: - SetupUI

extension AddInfoController {
    private func setupUI() {
        // Title setup
        view.addSubview(titleLabel)
        
        // TableView setup
        view.addSubview(tableView)
    }
    
    private func layotu() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Helpers

extension AddInfoController {
    private func setupBindings() {
        // Handle item selection
        viewModel.onItemSelected = { [weak self] item in
            self?.handleItemSelected(item)
        }
    }
    
    private func handleItemSelected(_ item: InfoItem) {
        // Handle the selected item
        print("Selected: \(item.title)")
        // Add your navigation or presentation logic here
    }
}

// MARK: - TableView Extensions

extension AddInfoController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoCell
        cell.configure(with: viewModel.item(at: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
