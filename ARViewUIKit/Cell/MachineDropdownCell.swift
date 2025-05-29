//
//  MachineDropdownCell.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 17.04.25.
//

import UIKit

// MARK: - Machine Dropdown Cell
class MachineDropdownCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .white
        selectionStyle = .default
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with machine: String) {
        titleLabel.text = machine
    }
}
