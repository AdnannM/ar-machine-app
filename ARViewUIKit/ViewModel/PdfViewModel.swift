//
//  PdfViewModel.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 17.04.25.
//

import UIKit

final class PdfViewModel {
    // MARK: - Properties
    private var add3DModelViewModel: Add3DModelViewModel
    private(set) var documents: [DocumentItem] = []
    private(set) var filteredDocuments: [DocumentItem] = []
    private(set) var selectedMachineIndex = 0
    private(set) var isDropdownVisible = false
    
    weak var delegate: PdfViewDelegate?
    
    // MARK: - Initialization
    
    init(add3DModelViewModel: Add3DModelViewModel) {
        self.add3DModelViewModel = add3DModelViewModel
        loadDocumentsForCurrentMachine()
    }
    
    // MARK: - Public Methods
    
    func selectMachine(at index: Int) {
        selectedMachineIndex = index
        loadDocumentsForCurrentMachine()
    }
    
    func filterDocuments(with searchText: String) {
        if searchText.isEmpty {
            filteredDocuments = documents
        } else {
            filteredDocuments = documents.filter {
                $0.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func modelCount() -> Int {
        return add3DModelViewModel.modelCount()
    }
    
    func model(at index: Int) -> MachineModel {
        return add3DModelViewModel.model(at: index)
    }
    
    func getCurrentMachineTitle() -> String {
        guard modelCount() > 0 else { return "No Machine" }
        return model(at: selectedMachineIndex).title
    }
    
    func toggleDropdownVisibility() {
        isDropdownVisible.toggle()
    }
    
    func setDropdownVisibility(visible: Bool) {
        isDropdownVisible = visible
    }
    
    func handleDocumentSelection(at index: Int) {
        if index >= 0 && index < filteredDocuments.count {
            let document = filteredDocuments[index]
            let machineName = getCurrentMachineTitle()
            
            // Print selected machine and PDF file
            print("Selected Machine: \(machineName)")
            print("Selected PDF: \(document.title)")
            
            delegate?.documentSelected(document)
        }
    }
    
    // Method to print info about a document by its index
    func printDocumentInfo(at index: Int) {
        if index >= 0 && index < documents.count {
            let document = documents[index]
            let machineName = getCurrentMachineTitle()
            print("Machine: \(machineName) | Document: \(document.title)")
        }
    }
        
    // Method to get document and machine info as a formatted string
    func getDocumentInfoString(at index: Int) -> String {
        if index >= 0 && index < filteredDocuments.count {
            let document = filteredDocuments[index]
            let machineName = getCurrentMachineTitle()
            return "Machine: \(machineName) | PDF: \(document.title)"
        }
        return "Invalid document selection"
    }
    
    func dismissView() {
        delegate?.dismissView()
    }
    
    // MARK: - Search Methods
    
    func searchDidBeginEditing() {
        delegate?.searchDidBeginEditing()
    }
    
    func searchDidEndEditing() {
        delegate?.searchDidEndEditing()
    }
    
    func clearSearch() {
        filterDocuments(with: "")
    }
    
    // MARK: - Private Methods
    
    private func loadDocumentsForCurrentMachine() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let date = dateFormatter.date(from: "20 April 2023") ?? Date()
        
        // Get the selected machine from view model
        let machine = add3DModelViewModel.model(at: selectedMachineIndex)
        
        // Create different documents for each machine
        switch machine.id {
        case "machine1":
            documents = [
                DocumentItem(title: "Machine 1 - Manual", fileType: "PDF file", creationDate: date,  fileURL: URL(string: "https://www.fervi.com/cgi-bin/download/t999_user_manual.pdf")),
                DocumentItem(title: "Machine 1 - Troubleshooting", fileType: "PDF file", creationDate: date,  fileURL: URL(string: "https://www.fervi.com/cgi-bin/download/t999_user_manual.pdf")),
                DocumentItem(title: "Machine 1 - Parts Catalog", fileType: "PDF file", creationDate: date,  fileURL: URL(string: "https://www.fervi.com/cgi-bin/download/t999_user_manual.pdf"))
            ]
        case "machine2":
            documents = [
                DocumentItem(title: "Error 108", fileType: "PDF file", creationDate: date,  fileURL: URL(string: "https://www.fervi.com/cgi-bin/download/t999_user_manual.pdf")),
                DocumentItem(title: "Machine 2 - Guide", fileType: "PDF file", creationDate: date,  fileURL: URL(string: "https://www.fervi.com/cgi-bin/download/t999_user_manual.pdf")),
                DocumentItem(title: "Machine 2 - Parts Catalog", fileType: "PDF file", creationDate: date,  fileURL: URL(string: "https://www.fervi.com/cgi-bin/download/t999_user_manual.pdf"))
            ]
        case "machine3":
            documents = [
                DocumentItem(title: "Machine 3 - Specifications", fileType: "PDF file", creationDate: date,  fileURL: URL(string: "https://www.fervi.com/cgi-bin/download/t999_user_manual.pdf")),
                DocumentItem(title: "Machine 3 - Operation Manual", fileType: "PDF file", creationDate: date,  fileURL: URL(string: "https://www.fervi.com/cgi-bin/download/t999_user_manual.pdf")),
                DocumentItem(title: "Machine 3 - Parts Catalog", fileType: "PDF file", creationDate: date,  fileURL: URL(string: "https://www.fervi.com/cgi-bin/download/t999_user_manual.pdf"))
            ]
        case "machine4":
            documents = [
                DocumentItem(title: "Machine 4 - Manual", fileType: "PDF file", creationDate: date,  fileURL: URL(string: "https://www.fervi.com/cgi-bin/download/t999_user_manual.pdf")),
                DocumentItem(title: "Machine 4 - Parts Catalog", fileType: "PDF file", creationDate: date,  fileURL: URL(string: "https://www.fervi.com/cgi-bin/download/t999_user_manual.pdf")),
                DocumentItem(title: "Machine 1 - Troubleshooting", fileType: "PDF file", creationDate: date,  fileURL: URL(string: "https://www.fervi.com/cgi-bin/download/t999_user_manual.pdf")),
            ]
        default:
            documents = []
        }
        
        filteredDocuments = documents
    }
}
