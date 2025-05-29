//
//  ContentView.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 12.04.25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isShowingViewController: Bool = false
    
    var body: some View {
        VStack {
            Button {
                isShowingViewController.toggle()
            } label: {
                Text("ARView")
                    .padding()
                    .foregroundStyle(.white)
                    .background(.red)
                    .cornerRadius(20)
            }
        }
        .padding()
        
        .fullScreenCover(isPresented: $isShowingViewController) {
            ARViewControllerRepresentable()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}

