//
//  ModelTableViewCell.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 16.04.25.
//

import UIKit

// Custom UITableViewCell for displaying a model
class ModelTableViewCell: UITableViewCell {
    static let identifier = "ModelTableViewCell"

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    let machineImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(machineImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            machineImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            machineImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            machineImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 70),
            machineImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 50),
            
            machineImageView.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 10)
        ])
    }

    func configure(with title: String, image: UIImage?) {
        titleLabel.text = title
        machineImageView.image = image ?? UIImage(systemName: "questionmark.circle") // Default image
    }
}

