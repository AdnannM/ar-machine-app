//
//  DocumentCell.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 17.04.25.
//

import UIKit

// MARK: - Document Cell
class DocumentCell: UITableViewCell {
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let fileTypeLabel = UILabel()
    private let dateLabel = UILabel()
    
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
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        contentView.addSubview(containerView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
        containerView.addSubview(titleLabel)
        
        fileTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        fileTypeLabel.font = .systemFont(ofSize: 14)
        fileTypeLabel.textColor = .darkGray
        containerView.addSubview(fileTypeLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        containerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            fileTypeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            fileTypeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            fileTypeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: fileTypeLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with document: DocumentItem) {
        titleLabel.text = document.title
        fileTypeLabel.text = document.fileType
        dateLabel.text = document.dateString
    }
}

