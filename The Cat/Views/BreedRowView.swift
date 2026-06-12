//
//  BreedRowView.swift
//  The Cat
//
//  Created by Jeremie Berduck on 11/6/26.
//

import SwiftUI

struct BreedRowView: View {
    let breed: Breed

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
            VStack(alignment: .leading, spacing: 2) {
                Text(breed.name)
                    .font(.headline)
                Text("\(breed.origin) · \(breed.lifeSpan) yrs")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder private var thumbnail: some View {
        if let url = breed.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    thumbnailPlaceholder
                default:
                    Color.secondary.opacity(0.15)
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            thumbnailPlaceholder
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var thumbnailPlaceholder: some View {
        Image(systemName: "pawprint")
            .font(.title2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.secondary.opacity(0.1))
    }
}

#Preview {
    BreedRowView(breed: .preview)
        .padding()
}
