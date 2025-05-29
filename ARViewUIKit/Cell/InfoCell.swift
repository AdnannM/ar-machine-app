//
//  InfoCell.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 15.04.25.
//

import UIKit

// MARK: - Views
class InfoCell: UITableViewCell {
    
    // UI Components
    
    private let iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = .white
        return iconImageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white
        return titleLabel
    }()
    
    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .lightGray
        subtitleLabel.numberOfLines = 0
        return subtitleLabel
    }()
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(white: 1, alpha: 0.1)
        containerView.layer.cornerRadius = 12
        return containerView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI

extension InfoCell {
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    /// Configure Cell
    func configure(with item: InfoItem) {
        iconImageView.image = UIImage(named: item.iconName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
    }
}
