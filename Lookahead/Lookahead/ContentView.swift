//
//  ContentView.swift
//  Lookahead
//
//  Created by Vedant Mistry on 04/01/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
