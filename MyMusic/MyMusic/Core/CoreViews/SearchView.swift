//
//  SearchView.swift
//  MyMusic
//
//  Created by Ruben Mimoun on 09/08/2024.
//

import SwiftUI

struct SearchFieldView: View {
    
    @Binding var input: String
    
    var body: some View {
        TextField("Search", text: $input)
            .frame(height: 35)
            .padding(EdgeInsets(top: 0, leading: 36, bottom: 0, trailing: 12))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .padding(.horizontal, 20)
            .autocorrectionDisabled()
            .font(.system(size: 18).weight(.regular))
            .overlay(alignment: .leading) {
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 30)
            }
            .foregroundStyle(
                .gray
            )
    }
    
}

#Preview {
    @Previewable @State var search: String = ""
    ReadScrollView { reader in
        SearchFieldView(input: $search)
            .preferredColorScheme(.dark)
    }
}
