//
//  BreedListView.swift
//  The Cat
//
//  Created by Jeremie Berduck on 11/6/26.
//

import SwiftUI

struct BreedListView: View {
    var viewModel: BreedListViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.breeds.isEmpty && !viewModel.isRefreshing {
                    emptyState
                } else {
                    breedList
                }
            }
            .navigationTitle("Cat Breeds")
        }
        .task { await viewModel.loadBreeds() }
    }

    @ViewBuilder private var emptyState: some View {
        if viewModel.isLoading {
            ProgressView("Loading breeds…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            ContentUnavailableView(error, systemImage: "pawprint")
        }
    }

    private var breedList: some View {
        List(viewModel.breeds) { breed in
            NavigationLink {
                BreedDetailView(breed: breed)
            } label: {
                BreedRowView(breed: breed)
            }
            .onAppear {
                if breed.id == viewModel.breeds.last?.id {
                    Task { await viewModel.loadBreeds() }
                }
            }
        }
        .listStyle(.plain)
        .refreshable { await viewModel.refresh() }
        .safeAreaInset(edge: .bottom) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
        .overlay(alignment: .bottom) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.85), in: Capsule())
                    .padding(.bottom, 16)
            }
        }
    }
}
