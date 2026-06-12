//
//  BreedDetailView.swift
//  The Cat
//
//  Created by Jeremie Berduck on 11/6/26.
//

import SwiftUI
import Charts

struct BreedDetailView: View {
    let breed: Breed

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImage
                VStack(alignment: .leading, spacing: 20) {
                    header
                    if let description = breed.description {
                        Text(description)
                            .font(.body)
                    }
                    temperamentSection
                    lifeSpanSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .navigationTitle(breed.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private var heroImage: some View {
        if let url = breed.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    Color.clear
                        .overlay(
                            image
                                .resizable()
                                .scaledToFill()
                        )
                case .failure:
                    heroPlaceholder
                default:
                    Color.secondary.opacity(0.15).overlay(ProgressView())
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .clipped()
        } else {
            heroPlaceholder
                .frame(maxWidth: .infinity)
                .frame(height: 300)
        }
    }

    private var heroPlaceholder: some View {
        Color.secondary.opacity(0.15)
            .overlay(
                Image(systemName: "pawprint")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
            )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(breed.name)
                .font(.largeTitle.bold())
            Label(breed.origin, systemImage: "mappin.circle")
                .foregroundStyle(.secondary)
        }
    }

    private var traits: [String] {
        breed.temperament
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }

    private var temperamentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Temperament")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(traits, id: \.self) { trait in
                        Text(trait)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.accentColor.opacity(0.12), in: Capsule())
                    }
                }
            }
        }
    }

    private var lifeSpanSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Life Span")
                .font(.headline)
            if let span = parseLifeSpan(breed.lifeSpan) {
                Chart {
                    BarMark(
                        x: .value("Range", "Min"),
                        y: .value("Years", span.min)
                    )
                    .annotation(position: .top, alignment: .center) {
                        Text("\(span.min) yrs").font(.caption.bold())
                    }
                    BarMark(
                        x: .value("Range", "Max"),
                        y: .value("Years", span.max)
                    )
                    .annotation(position: .top, alignment: .center) {
                        Text("\(span.max) yrs").font(.caption.bold())
                    }
                }
                .chartYScale(domain: 0...25)
                .chartYAxisLabel("Years")
                .frame(height: 160)
            } else {
                Text(breed.lifeSpan + " years")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func parseLifeSpan(_ lifeSpan: String) -> (min: Int, max: Int)? {
        let parts = lifeSpan
            .split(separator: "-")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 2,
              let min = Int(parts[0]),
              let max = Int(parts[1]) else { return nil }
        return (min, max)
    }
}

#Preview {
    NavigationStack {
        BreedDetailView(breed: .preview)
    }
}
