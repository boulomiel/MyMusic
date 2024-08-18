//
//  SearchArtistView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 11/08/2024.
//

import SwiftUI
import SwiftData
import MusicKit

struct SearchArtistView: View {
    
    @Environment(\.modelContext) private var moc
    @Query private var data: [SDData]
    @State private var store: SearchStore<Artist>
    @State private var searchInput: String = ""
    private var fetchDescriptor: FetchDescriptor<SDData>
    private let layoutId: MusicItemID = .init(UUID().uuidString)
    
    init(store: SearchStore<Artist>) {
        let type = SDDataType.artist.rawValue
        self.fetchDescriptor = FetchDescriptor<SDData>(
            predicate: #Predicate { $0.type == type },
            sortBy: [SortDescriptor(\.creationDate)]
        )
        fetchDescriptor.fetchLimit = 20
        self._store = .init(initialValue: store)
    }
    
    var body: some View {
        GeometryReader { geo in
            LazyVStack {
                let size = geo.size
                SearchFieldView(input: $store.searchInput)
                    .padding(.bottom)
                if case .hud = store.displayedPage.artistsCell.first {
                    ListCell(cell: store.displayedPage.artistsCell.first!, store: store)
                        .frame(width: size.width)
                        .id(store.displayedPage.artistsCell.first!.id)
                }
                CompositionnalLayout(geo: geo) {
                    ForEach(Array(store.displayedPage.artistsCell.dropFirst()), id: \.id) { cell in
                        ListCell(cell: cell, store: store) { artists in
                            ArtistCellView(obs: .init(artist: artists, album: nil, song: nil, artwortSize: 120))
                        }
                    }
                }
            }
            .scrollTargetLayout()
            .wrappedInStoredScroll(store: store, descriptor: fetchDescriptor, title: "Artists", imageName: "guitars")
        }
    }
    
    struct ArtistCellView: View {
        
        @State var obs: CellObservable
        @State var image: Image?
        
        var body: some View {
            GeometryReader { geo in
                VStack {
                    if let image = image {
                        image
                            .resizable()
                            .background(obs.bg.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(obs.mesh)
                    }
                }
                .frame(width: geo.size.width ,height: geo.size.height)
            }
            .overlay(alignment: .bottomLeading, content: {
                VStack(alignment: .leading) {
                    Text(obs.title)
                        .lineLimit(1)
                        .font(.system(size: 12).bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(obs.artistName)
                        .lineLimit(1)
                        .font(.system(size: 10))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .background(obs.bg.opacity(0.4))
            })
            .task {
                let image: Image = await .init(uiImage: obs.image)
                self.image = image
            }
            .clipped()
            .onDisappear {
                self.image = nil
            }
        }
    }
}
