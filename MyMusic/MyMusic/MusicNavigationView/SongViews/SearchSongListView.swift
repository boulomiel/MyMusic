//
//  ArtistListView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 06/08/2024.
//

import MusicKit
import SwiftUI
import SwiftData
import Combine

struct SearchSongListView: View {
    
    @Environment(\.musicStore) var musicStore
    @Environment(Router.self) var router
    @Environment(\.modelContext) var moc
    @Environment(\.musicPlayer) var musicPlayer
    var matchingNameSpace: Namespace.ID

    @Query var data: [SDData]
    @State var store: SearchStore<Song>
    var fetchDescriptor: FetchDescriptor<SDData>
    
    init(store: SearchStore<Song>, matchingNameSpace: Namespace.ID) {
        self.matchingNameSpace = matchingNameSpace
        let songsValue = SDDataType.song.rawValue
        self.fetchDescriptor = FetchDescriptor<SDData>(
            predicate:  #Predicate { $0.type == songsValue },
            sortBy: [SortDescriptor<SDData>(\.creationDate)]
        )
        fetchDescriptor.fetchLimit = 10
        self._store = .init(initialValue: store)
    }
    
    var body: some View {
        LazyVStack {
            SearchFieldView(input: $store.searchInput)
                .padding(.bottom)
            ForEach(store.displayedPage.songCells, id: \.id) { cell in
                ListCell(cell: cell, store: store, songCell: { song in
                    SearchCellView(obs: .init(artist: nil, album: nil, song: song))
                        .onTapGesture {
                            Task {
                                musicStore.set(song)
                                await musicPlayer.playNew(song: song)
                                await MainActor.run {
                                    router.toPlayerView(song)
                                }
                            }
                        }
                })
                .id(cell.id)
                .matchedTransitionSource(id: cell.id, in: matchingNameSpace)
                .scrollTransition(.animated(.smooth(duration: 0.6))) { effect, phase in
                    effect
                        .opacity(1 - abs(phase.value))
                        .scaleEffect(1 - abs(phase.value)/2)
                        .rotation3DEffect(.degrees(CGFloat(90) * abs(phase.value)), axis: (0, 1, 0))
                }
                Divider()
            }
        }
        .padding(.horizontal)
        .scrollTargetLayout()
        .wrappedInStoredScroll(store: store, descriptor: fetchDescriptor, title: "Songs", imageName: "music.note.list")
    }
}



fileprivate struct SampleData: PreviewModifier {
    
    static func makeSharedContext() async throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SDData.self, configurations: config)
        let ids = ["7003061", "1499111059", "1435333805", "311145", "693583"]
        ids.forEach { id in
            let d = SDData(itemID: id, type: .artist)
            container.mainContext.insert(d)
        }
        try container.mainContext.save()
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
    }
}

#Preview(traits: .modifier(SampleData())) {
    @Previewable @Namespace var namespace
    SearchSongListView(store: .init(), matchingNameSpace: namespace)
}

struct FramePreferences: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
    
    typealias Value = CGRect
    
}
