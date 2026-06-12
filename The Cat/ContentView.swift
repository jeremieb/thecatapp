//
//  ContentView.swift
//  The Cat
//
//  Created by Jeremie Berduck on 11/6/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = BreedListViewModel(apiClient: CatAPIClient())

    var body: some View {
        BreedListView(viewModel: viewModel)
    }
}
