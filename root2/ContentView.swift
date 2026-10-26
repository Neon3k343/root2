//
//  ContentView.swift
//  root2
//
//  Created by Hubert  Greszta on 15/08/2026.
//

import SwiftUI



struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Cloudspeed", systemImage: "list.bullet"){
                ListView()
            }
            Tab("Cloudspeed", systemImage: "cloud"){
                CloudspeedView()
            }
            Tab("Settings", systemImage: "gear"){
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
}
