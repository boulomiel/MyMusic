//
//  SearchAlbumView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 09/08/2024.
//

import SwiftUI
import SwiftData
import MusicKit

struct SearchAlbumView: View {
    
    @Environment(\.modelContext) var moc
    @Query var data: [SDData]
    @State var store: SearchStore<Album>
    @State var provider: Provider = .init()
    @State var searchInput: String = ""
    var fetchDescriptor: FetchDescriptor<SDData>
    
    init(store: SearchStore<Album>) {
        let type = SDDataType.album.rawValue
        self.fetchDescriptor = FetchDescriptor<SDData>(
            predicate: #Predicate { $0.type == type },
            sortBy: [SortDescriptor(\.creationDate)]
        )
        fetchDescriptor.fetchLimit = 20
        self._store = .init(initialValue: store)
    }
    
    var body: some View {
        LazyVStack {
            SearchFieldView(input: $store.searchInput)
                .padding(.bottom)
            ForEach(Array(store.displayedPage.albumCell.chunked(of: 4).enumerated()), id: \.offset) { offset, chunk in
                ScrollAlbumCellView(store: store, chunk: chunk)
                    .frame(height: 200)
                    .id(offset)
                    .scrollTransition { content, phase in
                        content
                            .scaleEffect(y: min(1 - abs(phase.value) / 3, 1))
                    }
                    .hide(if: chunk.isEmpty)
                
            }
            .id(store.currentPage.id)
        }
        .onChange(of: store.searchInput, { oldValue, newValue in
            store.inputPublisher.send(newValue)
        })
        .scrollTargetLayout()
        .wrappedInStoredScroll(store: store, descriptor: fetchDescriptor, title: "Albums", imageName: "opticaldisc")
    }
    
    @Observable
    class Provider {
        @ObservationIgnored var startY: CGFloat = 0
    }
    
    struct ScrollAlbumCellView: View {
        
        @Environment(Router.self) var router
        @State var provider: Provider = .init()
        @Bindable var store: SearchStore<Album>
        let chunk: [Page.Cell]
        
        var displayable: [Page.Cell] {
            if case .hud = chunk.first {
                return Array(chunk.dropFirst())
            } else {
                return chunk
            }
        }
        
        var body: some View {
            ScrollViewReader { reader in
                if case .hud = chunk.first {
                    ListCell(cell: chunk.first!, store: store)
                }
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(displayable, id: \.id) { cell in
                            ListCell(cell: cell, store: store) { album in
                                AlbumCellView(obs: .init(artist: nil, album: album, song: nil, artwortSize: 200))
                                    .id(cell.id)
                            }
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
                .overlay(alignment: .trailing, content: {
                    if chunk.count > 2 {
                        RoundedRectangle(cornerRadius: 4)
                            .background(.ultraThinMaterial)
                            .opacity(0.3)
                            .overlay(alignment: .center) {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.white)
                            }
                            .offset(x: provider.startX > 45 ? provider.startX - 45 : 0)
                            .frame(width: 30)
                            .onTapGesture {
                                withAnimation {
                                    reader.scrollTo(chunk.last?.id, anchor: .center)
                                }
                            }
                    }
                })
            }
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.x
            } action: { oldValue, newValue in
                provider.startX = newValue
            }
            
        }
        
        @Observable
        class Provider {
            var startX: CGFloat
            init() {
                self.startX = .zero
            }
        }
    }
    
    struct AlbumCellView: View {
        
        @State var obs: CellObservable
        @State var image: Image?
        
        var body: some View {
            VStack(spacing: 0, content: ImageContent)
            .frame(width: 200)
            .overlay(alignment: .bottomLeading, content: AlbumDetails)
            .task {
                let image: Image = await .init(uiImage: obs.image)
                withAnimation(.smooth) {
                    self.image = image
                }
            }
            .clipped()
            .onDisappear {
                withAnimation {
                    self.image = nil
                }
            }
        }
        
        @ViewBuilder
        func ImageContent() -> some View {
            if let image = image {
                image
                    .resizable()
                    .background(obs.bg.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(obs.bg)
            }
        }
        
        func AlbumDetails() -> some View {
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
        }
    }
}
