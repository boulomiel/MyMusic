//
//  SearchStoreModifier.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 11/08/2024.
//

import SwiftUI
import SwiftData
import MusicKit
import Combine

struct SearchStoreModifier<Item:SearchStoreItem>: ViewModifier {
    
    @Environment(\.modelContext) var moc
    
    @State var store: SearchStore<Item>
    @Query var data: [SDData]
    private let title: String
    private let imageName: String
    @State private var offsetTextY: CGFloat
    private let obs: Obs = .init()
    
    init(store: SearchStore<Item>,
         descriptor: FetchDescriptor<SDData>,
         title: String,
         imageName: String) {
        self.store = store
        self._data = .init(descriptor)
        self.title = title
        self.imageName = imageName
        self.offsetTextY = 40
    }
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            let size = geo.size
            
            Header(size)
            
            ReadScrollView { reader  in
                content
                    .onReceive(obs.event) { event in
                        switch event {
                        case .headerTap:
                            var cells: [Page.Cell] = .init()
                            if Item.self is Album.Type  {
                                cells = store.displayedPage.albumCell
                            } else if Item.self is Artist.Type {
                                cells = store.displayedPage.artistsCell
                            } else {
                                cells = store.displayedPage.songCells
                            }
                            withAnimation {
                                reader.scrollTo(cells.first?.id, anchor: .top)
                            }
                        }
                    }
            }
            .padding(.top, 50)
            .onScrollTargetVisibilityChange(idType: MusicItemID.self) { ids in
                if let lastId = ids.last,
                   Item.self is Song.Type,
                   let index = store.displayedPage.songCells.firstIndex(where: { $0.id == lastId }),
                   Double(index) > Double(store.displayedPage.count) * 0.75 {
                    onRefreshFromBottom(with: moc.container)
                }
            }
            .onScrollTargetVisibilityChange(idType: Int.self) { ids in
                let count = ids.count - 1
                let threshold = Int(count * 3/4)
                let lastIndex = store.displayedPage.albumCell.chunked(of: 4).count - 1
                let indexThreshold = Int(lastIndex * 3/4)

                if threshold >= indexThreshold,
                   Item.self is Album.Type {
                    onRefreshFromBottom(with: moc.container)
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.y
            } action: { oldValue, newValue in
                offsetTextY = newValue
            }
            .onScrollGeometryChange(for: Bool.self) { geo in
                geo.contentOffset.y >=  geo.contentSize.height * 0.4
            } action: { oldValue, newValue in
                if newValue {
                    onRefreshFromBottom(with: moc.container)
                }
            }
        }
        .onChange(of: store.searchInput, { oldValue, newValue in
            store.inputPublisher.send(newValue)
        })
        .task { await store.loadRecentlyViewed(with: data, in: moc.container) }
        .onAppear(perform: {
            store.observeInput(in: moc.container)
        })
        .onDisappear(perform: {
            print(Self.self, "disappeared")
            store.clean()
        })
        .confirmationDialog("Remove recents items permanently ?",
                            isPresented: $store.showRemoveRecentDialog,
                            titleVisibility: .visible,
                            actions: {
            
            Button("Remove", role: .destructive) {
                let type = SDDataType.song.rawValue
                try? moc.container.mainContext.delete(model: SDData.self, where: #Predicate {
                    return $0.type == type
                })
                store.cleanPage()
            }
            
        })
        .navigationTitle(title)
    }
    
    
    @ViewBuilder
    func Header(_ size: CGSize) -> some View {
        let width = size.width
        let offset = offsetTextY > 0 ? -offsetTextY : 0
        
        let text = Text(title)
            .font(.largeTitle.bold())
            .scaleEffect(offsetTextY > 0 ? max(0, 1 - abs(offsetTextY/60)) : 1)
            .opacity(offsetTextY > 0 ?  abs(60/offsetTextY) : 1)
            .offset(x: offset, y: offset)
            .frame(width: width, height: 60)
        
        let image = Image(systemName: imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(offsetTextY > 0 ? min(1, offsetTextY/50) : 0)
            .opacity(offsetTextY > 0 ? 1.0 - min(1, 60/offsetTextY) : min(offsetTextY > 0 ? 1 : 0, 60/offsetTextY))
            .offset(x: -100, y: -100)
            .offset(x: min(-offset, width / 4), y: min(offsetTextY, 100))
            .frame(width: 50, height: 50)

        
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            if let t = context.resolveSymbol(id: 1) {
                context.draw(t, at: center)
            }
            if let i = context.resolveSymbol(id: 2) {
                context.draw(i, at: center)
            }
            
        } symbols: {
            text
                .tag(1)
            image
                .tag(2)
        }
        .frame(width: width, height: 60)
        .position(x: width / 4 , y: 25)
        .onTapGesture {
            obs.event.send(.headerTap)
        }
    }
    
    private func onRefreshFromBottom(with container: ModelContainer) {
        Task {
            await store.onRefreshFromBottom(with: container)
        }
    }
    
    fileprivate class Obs {
        enum Event {
            case headerTap
        }
        
        var event: PassthroughSubject<Event, Never> = .init()
    }
}

extension View {
    
    func wrappedInStoredScroll<Item:SearchStoreItem>(store: SearchStore<Item>,
                               descriptor: FetchDescriptor<SDData>,
                                                     title: String, imageName: String) -> some View {
        modifier(SearchStoreModifier(store: store, descriptor: descriptor, title: title, imageName: imageName))
    }
}
