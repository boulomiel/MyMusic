# MyMusic - IOS

Template integration of MusicKit in different scrolling layout IOS 18

## About the Project

The project integrates the usage of the MusicKit api. In order to research by song, albums and artist the project
uses a tabview and displays 3 differents scrolling layout.

The project shows how to play a song, only from the search song tab.

- Each last search is saved in the model container of SwiftData.
- Cahing images through NSCache and AsyncChannel in order to save and fetch images sequentially, per cell.
- SearchStoreModifier<Item:SearchStoreItem> is a wrapper per scroll, each scroll and pagination depend on the same @Observable.

### Built With
- SwiftUI - IOS 18
- MusicKit
- swift-async-algorithms package
- SwiftData

