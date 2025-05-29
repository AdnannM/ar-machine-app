//
//  PdfView.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 16.04.25.
//

import UIKit

protocol PdfViewDelegate: AnyObject {
    func searchDidBeginEditing()
    func searchDidEndEditing()
    func documentSelected(_ document: DocumentItem)
    func dismissView()
}

class PdfView: UIView {
    
    // MARK: - Properties
    private var pdfViewModel: PdfViewModel!
    weak var delegate: PdfViewDelegate? {
        didSet {
            pdfViewModel.delegate = delegate
        }
    }
    
    // MARK: - UI Components
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchBarContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var searchIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var searchClearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.isHidden = true
        button.addTarget(self, action: #selector(clearSearch), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [
                .foregroundColor: UIColor.gray,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
        textField.textColor = .black
        textField.borderStyle = .none
        textField.delegate = self
        textField.returnKeyType = .search
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var machinesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Machines"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var machineDropdownContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleMachineDropdown))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var selectedMachineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select Machine"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var dropdownArrow: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var documentsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var machineDropdownTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.register(MachineDropdownCell.self, forCellReuseIdentifier: "MachineCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(white: 0.8, alpha: 1.0)
        tableView.layer.cornerRadius = 12
        tableView.isHidden = true
        tableView.rowHeight = 55
        return tableView
    }()
    
    private lazy var dropdownCancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 12
        button.isHidden = true
        button.addTarget(self, action: #selector(hideDropdown), for: .touchUpInside)
        return button
    }()
    
    private lazy var documentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Available documents"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var documentsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.register(DocumentCell.self, forCellReuseIdentifier: "DocumentCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = true
        tableView.rowHeight = 80
        return tableView
    }()
    
    // MARK: - Initialization
    
    init(with add3DModelViewModel: Add3DModelViewModel) {
        super.init(frame: .zero)
        setupViewModel(with: add3DModelViewModel)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Default initialization for Interface Builder
        let add3DModelViewModel = Add3DModelViewModel(type: .machine)
        setupViewModel(with: add3DModelViewModel)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // Default initialization for Interface Builder
        let add3DModelViewModel = Add3DModelViewModel(type: .machine)
        setupViewModel(with: add3DModelViewModel)
        setupUI()
    }
    
    private func setupViewModel(with add3DModelViewModel: Add3DModelViewModel) {
        self.pdfViewModel = PdfViewModel(add3DModelViewModel: add3DModelViewModel)
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
        layer.cornerRadius = 20
        updateUI()
    }
    
    override var intrinsicContentSize: CGSize {
        let width = max(400, bounds.width)
        let height = max(500, bounds.height)
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        // Add UI components
        addSubview(closeButton)
        addSubview(searchBarContainer)
        searchBarContainer.addSubview(searchIcon)
        searchBarContainer.addSubview(searchTextField)
        searchBarContainer.addSubview(searchClearButton)
        addSubview(machinesLabel)
        addSubview(machineDropdownContainer)
        machineDropdownContainer.addSubview(selectedMachineLabel)
        machineDropdownContainer.addSubview(dropdownArrow)
        addSubview(documentsContainerView)
        documentsContainerView.addSubview(documentsLabel)
        documentsContainerView.addSubview(documentsTableView)
        
        // Add dropdown and cancel button (hidden by default)
        addSubview(machineDropdownTableView)
        addSubview(dropdownCancelButton)
        
        layout()
        updateUI()
    }
    
    private func layout() {
        // Set constraints for UI components
        NSLayoutConstraint.activate([
            // Close button
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Search container
            searchBarContainer.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            searchBarContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchBarContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            searchBarContainer.heightAnchor.constraint(equalToConstant: 44),
            
            // Search icon
            searchIcon.leadingAnchor.constraint(equalTo: searchBarContainer.leadingAnchor, constant: 12),
            searchIcon.centerYAnchor.constraint(equalTo: searchBarContainer.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),
            
            // Search text field
            searchTextField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: searchClearButton.leadingAnchor, constant: -8),
            searchTextField.topAnchor.constraint(equalTo: searchBarContainer.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchBarContainer.bottomAnchor),
            
            // Search clear button
            searchClearButton.trailingAnchor.constraint(equalTo: searchBarContainer.trailingAnchor, constant: -12),
            searchClearButton.centerYAnchor.constraint(equalTo: searchBarContainer.centerYAnchor),
            searchClearButton.widthAnchor.constraint(equalToConstant: 20),
            searchClearButton.heightAnchor.constraint(equalToConstant: 20),
            
            // Machines label
            machinesLabel.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor, constant: 24),
            machinesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            // Machine dropdown container
            machineDropdownContainer.topAnchor.constraint(equalTo: machinesLabel.bottomAnchor, constant: 8),
            machineDropdownContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            machineDropdownContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            machineDropdownContainer.heightAnchor.constraint(equalToConstant: 44),
            
            // Selected machine label
            selectedMachineLabel.leadingAnchor.constraint(equalTo: machineDropdownContainer.leadingAnchor, constant: 16),
            selectedMachineLabel.centerYAnchor.constraint(equalTo: machineDropdownContainer.centerYAnchor),
            selectedMachineLabel.trailingAnchor.constraint(equalTo: dropdownArrow.leadingAnchor, constant: -8),
            
            // Dropdown arrow
            dropdownArrow.trailingAnchor.constraint(equalTo: machineDropdownContainer.trailingAnchor, constant: -16),
            dropdownArrow.centerYAnchor.constraint(equalTo: machineDropdownContainer.centerYAnchor),
            dropdownArrow.widthAnchor.constraint(equalToConstant: 16),
            dropdownArrow.heightAnchor.constraint(equalToConstant: 16),
            
            // Documents container
            documentsContainerView.topAnchor.constraint(equalTo: machineDropdownContainer.bottomAnchor, constant: 24),
            documentsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            documentsContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            documentsContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Documents label
            documentsLabel.topAnchor.constraint(equalTo: documentsContainerView.topAnchor),
            documentsLabel.leadingAnchor.constraint(equalTo: documentsContainerView.leadingAnchor, constant: 16),
            
            // Documents table view
            documentsTableView.topAnchor.constraint(equalTo: documentsLabel.bottomAnchor, constant: 8),
            documentsTableView.leadingAnchor.constraint(equalTo: documentsContainerView.leadingAnchor, constant: 16),
            documentsTableView.trailingAnchor.constraint(equalTo: documentsContainerView.trailingAnchor, constant: -16),
            documentsTableView.bottomAnchor.constraint(equalTo: documentsContainerView.bottomAnchor, constant: -16),
            
            // Machine dropdown table view
            machineDropdownTableView.topAnchor.constraint(equalTo: machineDropdownContainer.bottomAnchor, constant: 4),
            machineDropdownTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            machineDropdownTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            machineDropdownTableView.heightAnchor.constraint(lessThanOrEqualToConstant: 220),
            
            // Dropdown cancel button
            dropdownCancelButton.topAnchor.constraint(equalTo: machineDropdownTableView.bottomAnchor, constant: 8),
            dropdownCancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dropdownCancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dropdownCancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        pdfViewModel.dismissView()
    }
    
    @objc private func clearSearch() {
        searchTextField.text = ""
        searchClearButton.isHidden = true
        pdfViewModel.clearSearch()
        documentsTableView.reloadData()
        searchTextField.resignFirstResponder()
    }
    
    @objc private func textFieldDidChange() {
        let text = searchTextField.text ?? ""
        searchClearButton.isHidden = text.isEmpty
        pdfViewModel.filterDocuments(with: text)
        documentsTableView.reloadData()
    }
    
    @objc private func toggleMachineDropdown() {
        pdfViewModel.toggleDropdownVisibility()
        updateDropdownVisibility()
    }
    
    @objc private func hideDropdown() {
        pdfViewModel.setDropdownVisibility(visible: false)
        updateDropdownVisibility()
    }
    
    private func updateDropdownVisibility() {
        if pdfViewModel.isDropdownVisible {
            showDropdown()
        } else {
            hideDropdownUI()
        }
    }
    
    private func showDropdown() {
        machineDropdownTableView.isHidden = false
        dropdownCancelButton.isHidden = false
        
        // Hide documents section
        documentsContainerView.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.dropdownArrow.transform = CGAffineTransform(rotationAngle: .pi)
        }
        
        // Make sure dropdown is at the front
        bringSubviewToFront(machineDropdownTableView)
        bringSubviewToFront(dropdownCancelButton)
    }
    
    private func hideDropdownUI() {
        UIView.animate(withDuration: 0.3, animations: {
            self.dropdownArrow.transform = .identity
        }) { _ in
            self.machineDropdownTableView.isHidden = true
            self.dropdownCancelButton.isHidden = true
            self.documentsContainerView.isHidden = false
        }
    }
    
    private func selectMachine(_ index: Int) {
        pdfViewModel.selectMachine(at: index)
        updateUI()
        hideDropdown()
        documentsTableView.reloadData()
    }
    
    private func updateUI() {
        // Set machine title
        selectedMachineLabel.text = pdfViewModel.getCurrentMachineTitle()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension PdfView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == machineDropdownTableView {
            return pdfViewModel.modelCount()
        } else {
            return pdfViewModel.filteredDocuments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == machineDropdownTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MachineCell", for: indexPath) as! MachineDropdownCell
            let machine = pdfViewModel.model(at: indexPath.row)
            cell.configure(with: machine.title)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath) as! DocumentCell
            let document = pdfViewModel.filteredDocuments[indexPath.row]
            cell.configure(with: document)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == machineDropdownTableView {
            selectMachine(indexPath.row)
        } else {
            pdfViewModel.handleDocumentSelection(at: indexPath.row)
        }
    }
}

// MARK: - UITextFieldDelegate

extension PdfView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pdfViewModel.searchDidBeginEditing()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        pdfViewModel.searchDidEndEditing()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
